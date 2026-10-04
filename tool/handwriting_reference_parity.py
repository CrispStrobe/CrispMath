"""Hosted-only exported-FP32-weight comparison with pinned official PosFormer.

This is inference parity, not original-checkpoint/training parity or an accuracy test.
"""
import argparse
import ctypes
import hashlib
import importlib
import json
import os
from pathlib import Path
import subprocess
import sys
import types

from audit_handwriting_vocabulary import FROZEN_MANIFEST_SHA256, MODELS, file_hash, metadata
from compare_handwriting_encoders import BRIDGE_SOURCE, require

REFERENCE_SOURCE = '802019a0533639f3b0bf18d44e93be073945cac5'
CASES = ['01752f0f5fba0225', '00fee560e6c9af79', '02b1dc6d4efd493a',
         '00915f0ffe17930e', '022b4cfb5a5a3856']
ENCODER_STAGES = ['stem', 'pool0', 'block1', 'pool1', 'block2', 'pool2', 'block3',
                  'projection', 'encoded']
# Fixed before measurements. FP32 reduction-order differences; GGML convolutions
# explicitly round weights/patches to FP16. Failures remain in the report.
TOLERANCES = {'scalar': (0.0005, 0.0002), 'default': (0.005, 0.002),
              'decoder': (0.0005, 0.0002), 'preprocessed': (0.000001, 0)}


def check_shape(actual, expected, name):
    require(tuple(actual) == tuple(expected), f'{name}: shape {actual} != {expected}')


def validate_manifest(manifest_path):
    require(file_hash(manifest_path) == FROZEN_MANIFEST_SHA256, 'Changed frozen manifest')
    manifest = json.loads(Path(manifest_path).read_text())
    require(manifest.get('split') == 'test' and len(manifest['cases']) == 50,
            'Incomplete frozen corpus')
    require([case['id'] for case in manifest['cases'][:5]] == CASES,
            'Changed deterministic first five')
    return manifest['cases'][:5]


class TensorStore:
    """No ignored tensors, random placeholders or unconstrained reshape."""
    def __init__(self, reader, np):
        self.np = np
        self.tensors = {t.name: t for t in reader.tensors}
        require(len(self.tensors) == len(reader.tensors), 'Duplicate tensors')
        self.used = set()

    def get(self, name, shape, *, flattened_conv=False):
        require(name in self.tensors and name not in self.used, 'Missing/duplicate tensor: ' + name)
        tensor = self.tensors[name]
        require(int(tensor.tensor_type) == 0, 'Reference phase requires actual F32: ' + name)
        actual = tuple(int(v) for v in reversed(tensor.shape))
        expected = (shape[0], self.np.prod(shape[1:])) if flattened_conv else tuple(shape)
        check_shape(actual, expected, name)
        data = self.np.array(tensor.data, dtype=self.np.float32, copy=True).reshape(shape)
        require(self.np.isfinite(data).all(), 'Nonfinite tensor: ' + name)
        self.used.add(name)
        return data

    def complete(self):
        require(self.used == set(self.tensors), 'Unconsumed exported tensors: ' +
                str(sorted(set(self.tensors) - self.used)))
        return {'count': len(self.used), 'names': sorted(self.used),
                'type': 'F32', 'all_exported_tensors_consumed': True}


def load_reference(source, reader, np, torch):
    actual_source = subprocess.check_output(['git', '-C', str(source), 'rev-parse', 'HEAD'],
                                            text=True).strip()
    require(actual_source == REFERENCE_SOURCE, 'Unpinned independent architecture')
    actual = metadata(reader)
    def field(name):
        require(name in reader.fields, 'Missing architecture metadata: ' + name)
        return reader.fields[name].contents()
    # Inference-only Lightning base: the pinned forward methods use only Module
    # and .device. No training engine, checkpoint loader or reference math is replaced.
    class InferenceModule(torch.nn.Module):
        @property
        def device(self):
            return next(self.parameters(), torch.empty(0)).device
    lightning = types.ModuleType('pytorch_lightning')
    lightning.LightningModule = InferenceModule
    sys.modules['pytorch_lightning'] = lightning
    # Metric recorder is imported by an unused beam/training utility. Its methods
    # must never execute during this forward-only diagnostic.
    class UnusedMetric(torch.nn.Module):
        def __init__(self, *args, **kwargs):
            raise RuntimeError('Training metric entered inference diagnostic')
    metrics = types.ModuleType('torchmetrics')
    metrics.Metric = UnusedMetric
    sys.modules['torchmetrics'] = metrics
    for package in ('Pos_Former', 'Pos_Former.model', 'Pos_Former.utils'):
        module = types.ModuleType(package)
        module.__path__ = [str(Path(source).joinpath(*package.split('.')))]
        sys.modules[package] = module
    data = types.ModuleType('Pos_Former.datamodule')
    ids = actual['special_token_ids']
    data.vocab = types.SimpleNamespace(PAD_IDX=ids['pad'], SOS_IDX=ids['sos'], EOS_IDX=ids['eos'])
    data.vocab_size = actual['vocab_size']
    sys.modules['Pos_Former.datamodule'] = data
    Encoder = importlib.import_module('Pos_Former.model.encoder').Encoder
    Decoder = importlib.import_module('Pos_Former.model.decoder').Decoder
    d = actual['decoder_dimensions']['d_model']
    enc = Encoder(d, field('posformer.encoder.growth_rate'), field('posformer.encoder.num_layers'))
    dec = Decoder(d, actual['decoder_dimensions']['nhead'], field('posformer.decoder.num_layers'),
                  field('posformer.decoder.dim_feedforward'), 0.0,
                  field('posformer.arm.dc'), field('posformer.arm.cross_coverage'),
                  field('posformer.arm.self_coverage'))
    original_parameter_objects = [parameter for model in (enc, dec) for parameter in model.parameters()]
    original_parameters = {id(parameter) for parameter in original_parameter_objects}
    store = TensorStore(reader, np)
    def param(module, attr, name, shape=None, conv=False):
        shape = tuple(getattr(module, attr).shape) if shape is None else tuple(shape)
        setattr(module, attr, torch.nn.Parameter(torch.from_numpy(store.get(name, shape,
                                                            flattened_conv=conv)), requires_grad=False))
    def affine(module, prefix):
        param(module, 'weight', prefix + '.weight')
        param(module, 'bias', prefix + '.bias')
    def conv(module, prefix):
        param(module, 'weight', prefix + '.weight', conv=True)
        param(module, 'bias', prefix + '.bias', (module.out_channels,))
    conv(enc.model.conv1, 'enc.stem.conv')
    enc.model.norm1 = torch.nn.Identity()
    for block in range(1, 4):
        for index, layer in enumerate(getattr(enc.model, 'dense' + str(block))):
            for index_conv in (1, 2):
                conv(getattr(layer, 'conv' + str(index_conv)),
                     f'enc.block{block}.layer{index}.conv{index_conv}')
                setattr(layer, 'bn' + str(index_conv), torch.nn.Identity())
        if block < 3:
            transition = getattr(enc.model, 'trans' + str(block))
            conv(transition.conv1, f'enc.trans{block}.conv')
            transition.bn1 = torch.nn.Identity()
    class ChannelAffine(torch.nn.Module):
        def __init__(self):
            super().__init__()
            count = enc.model.out_channels
            self.register_buffer('scale', torch.from_numpy(store.get('enc.post_norm.scale', (count,))))
            self.register_buffer('offset', torch.from_numpy(store.get('enc.post_norm.offset', (count,))))
        def forward(self, x):
            return x * self.scale[None, :, None, None] + self.offset[None, :, None, None]
    enc.model.post_norm = ChannelAffine()
    conv(enc.feature_proj, 'enc.feature_proj')
    affine(enc.norm, 'enc.norm')
    param(dec.word_embed[0], 'weight', 'dec.word_embed.weight')
    affine(dec.word_embed[1], 'dec.word_embed_ln')
    affine(dec.norm, 'dec.input_norm')
    dec.pos_enc.pe = torch.from_numpy(store.get('dec.pos_enc', tuple(dec.pos_enc.pe.shape)))
    for index, layer in enumerate(dec.model.layers):
        prefix = f'dec.layers.{index}.'
        for module_name, tensor_name in [('self_attn', 'self_attn'), ('multihead_attn', 'cross_attn')]:
            attention = getattr(layer, module_name)
            param(attention, 'in_proj_weight', prefix + tensor_name + '.in_proj_weight')
            param(attention, 'in_proj_bias', prefix + tensor_name + '.in_proj_bias')
            affine(attention.out_proj, prefix + tensor_name + '.out_proj')
        affine(layer.linear1, prefix + 'ffn.up')
        affine(layer.linear2, prefix + 'ffn.down')
        for norm in ('norm1', 'norm2', 'norm3'):
            affine(getattr(layer, norm), prefix + norm)
    affine(dec.proj, 'dec.proj')
    conv(dec.model.arm.conv, 'arm.conv')
    conv(dec.model.arm.proj, 'arm.proj')
    dec.model.arm.post_norm.bn = torch.nn.Identity()
    require(not any(id(parameter) in original_parameters for model in (enc, dec)
                    for parameter in model.parameters()), 'Random/unmapped reference parameter remains')
    accounting = store.complete()
    accounting['all_reference_parameters_replaced'] = True
    return enc.eval(), dec.eval(), actual, accounting


def compare(native, reference, tolerance, np):
    require(np.isfinite(native).all() and np.isfinite(reference).all(), 'Nonfinite trace')
    result = {'native_shape': list(native.shape), 'reference_shape': list(reference.shape),
              'atol': tolerance[0], 'rtol': tolerance[1]}
    if native.shape != reference.shape:
        return {**result, 'matches': False, 'reason': 'shape', 'max_abs': None}
    delta = np.abs(native.astype(np.float64) - reference.astype(np.float64))
    return {**result, 'matches': bool(np.allclose(native, reference, atol=tolerance[0], rtol=tolerance[1])),
            'reason': 'values', 'max_abs': float(delta.max()),
            'mean_abs': float(delta.mean())}


def validate_provenance(provenance, library_hash, instrumentation_hash, patch_hash, forward_hash=None):
    require(provenance.get('bridge_source') == BRIDGE_SOURCE, 'Wrong native base source')
    require(provenance.get('library_sha256') == library_hash, 'Trace library provenance mismatch')
    require(provenance.get('instrumentation_tool_sha256') == instrumentation_hash,
            'Trace instrumentation provenance mismatch')
    change = provenance.get('mathematical_change')
    require(change in ('none', 'post-position learned normalization',
                       'post-position normalization and ceil pooling'), 'Unknown mathematical change')
    expected = None if change == 'none' else patch_hash
    require(provenance.get('input_norm_patch_sha256') == expected, 'Wrong normalization patch')
    require(provenance.get('forward_repair_patch_sha256') ==
            (forward_hash if change == 'post-position normalization and ceil pooling' else None),
            'Wrong forward repair patch')
    if change == 'post-position normalization and ceil pooling':
        require(forward_hash is not None, 'Missing forward patch identity')
    require(provenance.get('instrumented_source_sha256') != provenance.get('original_source_sha256'),
            'Uninstrumented source reported')


def read_trace(directory, name, np):
    path = Path(directory) / name
    shape = json.loads(path.with_suffix('.shape.json').read_text())
    require(len(shape) == 3 and all(type(v) is int and 0 < v < 100000 for v in shape), 'Invalid trace shape')
    data = np.fromfile(path.with_suffix('.f32'), dtype='<f4')
    require(data.size == int(np.prod(shape)), 'Truncated native trace: ' + name)
    require(np.isfinite(data).all(), 'Nonfinite native trace: ' + name)
    return data.reshape(shape)


def independent_preprocess(image, np):
    # The frozen drawings are binary RGB. Independently use Pillow grayscale;
    # native receives RGB bytes and computes its own channel conversion/inversion.
    rgb = np.asarray(image.convert('RGB'))
    require(np.isin(rgb, [0, 255]).all() and (rgb[:, :, 0] == rgb[:, :, 1]).all()
            and (rgb[:, :, 0] == rgb[:, :, 2]).all(), 'Nonbinary frozen input')
    require(image.width * image.height <= 100000, 'Resize stage outside bounded comparison')
    gray = np.asarray(image.convert('L'), dtype=np.float32) / np.float32(255)
    return (1 - gray if gray.mean() > 0.5 else gray)[None]


def encoder_reference(enc, pixels, torch):
    captures, handles = {}, []
    def save(name, module):
        handles.append(module.register_forward_hook(lambda _m, _i, out:
                       captures.__setitem__(name, out.detach().clone()[0])))
    for name, module in [('block1', enc.model.dense1), ('pool1', enc.model.trans1),
                         ('block2', enc.model.dense2), ('pool2', enc.model.trans2),
                         ('block3', enc.model.dense3), ('projection', enc.feature_proj)]:
        save(name, module)
    mask = torch.zeros((1, pixels.shape[1], pixels.shape[2]), dtype=torch.bool)
    tensor = torch.from_numpy(pixels)[None]
    with torch.inference_mode():
        captures['stem'] = torch.relu(enc.model.norm1(enc.model.conv1(tensor)))[0]
        captures['pool0'] = torch.nn.functional.max_pool2d(captures['stem'][None], 2, ceil_mode=True)[0]
        encoded, _ = enc(tensor, mask)
        captures['encoded'] = encoded[0]
    for handle in handles:
        handle.remove()
    return {name: value.numpy().copy() for name, value in captures.items()}


def decoder_reference(dec, encoded, prefix, torch):
    captures, handles = {}, []
    handles.append(dec.norm.register_forward_hook(lambda _m, _i, out:
                   captures.__setitem__('token_input_layer-1', out[0, -1].detach().clone())))
    for index, layer in enumerate(dec.model.layers):
        for norm in ('norm1', 'norm2', 'norm3'):
            key = f'{norm}_layer{index}'
            handles.append(getattr(layer, norm).register_forward_hook(
                lambda _m, _i, out, name=key: captures.__setitem__(name, out[-1, 0].detach().clone())))
    with torch.inference_mode():
        logits, _ = dec(torch.from_numpy(encoded)[None],
                        torch.zeros((1, encoded.shape[0], encoded.shape[1]), dtype=torch.bool),
                        torch.tensor([prefix], dtype=torch.long))
        captures['logits_layer-1'] = logits[0, -1]
    for handle in handles:
        handle.remove()
    return {name: value.numpy().copy()[None, None] for name, value in captures.items()}


def negative_controls(np, torch):
    a = np.arange(48, dtype=np.float32).reshape(2, 3, 8) / 13
    tolerance = TOLERANCES['decoder']
    require(compare(a, a.copy(), tolerance, np)['matches'], 'Identity comparison failed')
    require(not compare(a, a + 0.02, tolerance, np)['matches'], 'Comparator missed changed values')
    require(not compare(a, a[:, :, :-1], tolerance, np)['matches'], 'Comparator missed shape mismatch')
    try:
        compare(a * np.nan, a, tolerance, np)
    except ValueError:
        pass
    else:
        raise ValueError('Comparator accepted NaN')
    odd = torch.arange(15, dtype=torch.float32).reshape(1, 1, 3, 5)
    ceil = torch.nn.functional.avg_pool2d(odd, 2, ceil_mode=True)
    floor = torch.nn.functional.avg_pool2d(odd, 2)
    require(not compare(ceil.numpy(), floor.numpy(), tolerance, np)['matches'], 'Pool negative control failed')
    x = torch.tensor([[2., -1., 0., 4.]])
    pos = torch.tensor([[1., 3., -2., 1.]])
    scale = torch.tensor([2., 0.5, 1.2, -0.7])
    bias = torch.tensor([1., -1., 0.3, 0.4])
    norm = lambda v: torch.nn.functional.layer_norm(v, (4,), scale, bias, 1e-5)
    require(not compare(norm(x + pos).numpy(), (norm(x) + pos).numpy(), tolerance, np)['matches'],
            'Wrong normalization ordering not detected')
    return {'changed_values_rejected': True, 'wrong_shape_rejected': True, 'nonfinite_rejected': True,
            'ceil_vs_floor_rejected': True, 'wrong_normalization_order_rejected': True}


def run(args):
    import numpy as np
    import torch
    from gguf import GGUFReader
    from PIL import Image
    require(os.environ.get('GITHUB_ACTIONS') == 'true', 'Model comparisons require hosted CI')
    require(file_hash(args.model) == MODELS['mathwriting-v2'], 'Unpinned FP32 candidate')
    torch.set_num_threads(2)
    torch.set_num_interop_threads(1)
    torch.manual_seed(0)
    torch.use_deterministic_algorithms(True)
    enc, dec, actual, tensors = load_reference(args.reference, GGUFReader(args.model, mode='r'), np, torch)
    controls = negative_controls(np, torch)
    cases = validate_manifest(args.manifest)
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    library = ctypes.CDLL(str(Path(args.library).resolve()))
    library.posformer_ocr_init.argtypes = [ctypes.c_char_p, ctypes.c_int]
    library.posformer_ocr_init.restype = ctypes.c_void_p
    library.posformer_ocr_recognize_raw.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_uint8),
                                                   ctypes.c_int, ctypes.c_int, ctypes.c_int,
                                                   ctypes.POINTER(ctypes.c_int)]
    library.posformer_ocr_recognize_raw.restype = ctypes.c_void_p
    library.posformer_ocr_free.argtypes = [ctypes.c_void_p]
    library.posformer_ocr_free.restype = None
    provenance = json.loads(Path(args.provenance).read_text())
    validate_provenance(provenance, file_hash(args.library),
        file_hash(Path(__file__).parent / 'prepare_handwriting_reference_bridge.py'),
        file_hash(Path(__file__).parent / 'patches/posformer-input-norm.patch'),
        file_hash(Path(__file__).parent / 'patches/posformer-forward-repair.patch'))
    if args.encoder == 'scalar':
        os.environ['POSFORMER_SCALAR_ENCODER'] = '1'
    else:
        os.environ.pop('POSFORMER_SCALAR_ENCODER', None)
    os.environ['POSFORMER_REFERENCE_STEPS'] = '5'
    rows = []
    for case in cases:
        directory = output.parent / (output.stem + '-traces') / case['id']
        directory.mkdir(parents=True, exist_ok=True)
        os.environ['POSFORMER_REFERENCE_TRACE'] = str(directory.resolve())
        image_path = Path(args.manifest).parent / case['image']
        image = Image.open(image_path).convert('RGB')
        pixels = independent_preprocess(image, np)
        reference_encoder = encoder_reference(enc, pixels, torch)
        rgb = np.ascontiguousarray(np.asarray(image), dtype=np.uint8)
        context = library.posformer_ocr_init(str(Path(args.model).resolve()).encode(), 2)
        require(context, 'Native model failed to load')
        length = ctypes.c_int()
        try:
            result = library.posformer_ocr_recognize_raw(context,
                rgb.ctypes.data_as(ctypes.POINTER(ctypes.c_uint8)), image.width, image.height, 3,
                ctypes.byref(length))
            require(result, 'Native recognition runtime failure')
            native_text = ctypes.string_at(result, length.value).decode()
        finally:
            library.posformer_ocr_free(context)
        preprocess = compare(read_trace(directory, 'preprocessed', np), pixels,
                             TOLERANCES['preprocessed'], np)
        stages = {name: compare(read_trace(directory, name, np), reference_encoder[name],
                               TOLERANCES[args.encoder], np) for name in ENCODER_STAGES}
        native_encoded = read_trace(directory, 'encoded', np)
        prefix = [actual['special_token_ids']['sos']]
        decoder_steps = []
        for step in range(5):
            if not (directory / f'logits_layer-1_step{step}.f32').exists():
                require(prefix[-1] in (actual['special_token_ids']['eos'], actual['special_token_ids']['pad']),
                        'Missing nonterminal decoder trace')
                break
            reference_decoder = decoder_reference(dec, native_encoded, prefix, torch)
            comparisons = {name: compare(read_trace(directory, f'{name}_step{step}', np), value,
                                         TOLERANCES['decoder'], np)
                           for name, value in reference_decoder.items()}
            logits = read_trace(directory, f'logits_layer-1_step{step}', np).reshape(-1)
            next_token = int(np.argmax(logits))
            decoder_steps.append({'step': step, 'input_prefix_ids': prefix.copy(),
                                  'native_argmax': next_token,
                                  'reference_argmax': int(np.argmax(reference_decoder['logits_layer-1'])),
                                  'stages': comparisons})
            prefix.append(next_token)
        rows.append({'id': case['id'], 'image_sha256': file_hash(image_path),
                     'reference_latex': case['reference_latex'], 'image_size': [image.width, image.height],
                     'native_bounded_text': native_text, 'preprocessing': preprocess,
                     'encoder': stages, 'first_encoder_divergence': next((name for name in ENCODER_STAGES
                         if not stages[name]['matches']), None), 'decoder': decoder_steps})
        print(json.dumps({'case': case['id'], 'first_encoder_divergence': rows[-1]['first_encoder_divergence'],
                          'decoder_steps': len(decoder_steps)}), flush=True)
    report = {'format': 'crispmath.handwriting-exported-reference-parity',
              'source': os.environ['GITHUB_SHA'], 'reference_source': REFERENCE_SOURCE,
              'model_sha256': file_hash(args.model), 'library_sha256': file_hash(args.library),
              'corpus_manifest_sha256': FROZEN_MANIFEST_SHA256, 'native_provenance': provenance,
              'encoder': args.encoder, 'actual_gguf_metadata': actual, 'tensor_accounting': tensors,
              'negative_controls': controls, 'samples': len(rows), 'cases': rows,
              'torch_version': torch.__version__, 'tolerances': TOLERANCES,
              'limits': ['Exported FP32 weights only: original training checkpoint/BN statistics unavailable.',
                         'Official inference uses folded-convolution bias and stored affine post-normalization.',
                         'Lightning training base replaced only with torch Module/device for inference imports.',
                         'Unused training metric import is guarded to reject execution.',
                         'ARM retains pinned official structural IDs, not inferred new-vocabulary semantics.',
                         'Decoder comparison isolates decoder using actual native encoded features and native prefixes.',
                         'Preprocessing compares binary frozen RGB drawings, polarity and no-resize path only.',
                         'Default GGML convolutions use FP16; scalar/independent reference use FP32.',
                         'Five cases and at most five decoder steps: this is not an accuracy or promotion gate.']}
    output.write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('model', 'manifest', 'library', 'reference', 'provenance', 'output'):
        parser.add_argument('--' + name, required=True)
    parser.add_argument('--encoder', choices=['default', 'scalar'], required=True)
    run(parser.parse_args())
