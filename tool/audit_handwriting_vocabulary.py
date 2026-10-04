"""Measure frozen-reference lexical coverage of the actual pinned PosFormer GGUF."""
import argparse
import hashlib
import json
import os
import re
from pathlib import Path

from compare_handwriting_encoders import POSFORMER_SHA256, tokens, require

FROZEN_MANIFEST_SHA256 = 'a2edabf8937298a52f072c41917bf4a8022ecaee9a50d00dcc1d52934b711109'
MODELS = {
    'crohme-q8': POSFORMER_SHA256,
    'mathwriting-v2': '12060161fc6dc3c3fde146532ffade00f8f2286dd5a53e1f8777215afa9193c0',
}


def file_hash(path):
    digest = hashlib.sha256()
    with Path(path).open('rb') as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def metadata(reader):
    def field(name):
        require(name in reader.fields, f'Missing actual GGUF field: {name}')
        return reader.fields[name].contents()
    require(field('general.architecture') == 'posformer', 'Wrong GGUF architecture')
    vocabulary = field('tokenizer.tokens')
    count = field('posformer.decoder.vocab_size')
    require(isinstance(vocabulary, list) and all(isinstance(t, str) and t for t in vocabulary),
            'Invalid tokenizer string array')
    require(type(count) is int and 3 < count <= 4096 and len(vocabulary) == count,
            'Tokenizer and decoder vocabulary dimensions differ')
    require(len(set(vocabulary)) == count, 'Duplicate tokenizer tokens')
    specials = {name: field(f'posformer.decoder.{name}_token')
                for name in ('pad', 'sos', 'eos')}
    require(len(set(specials.values())) == 3 and
            all(type(i) is int and 0 <= i < count for i in specials.values()),
            'Invalid special-token IDs')
    require(all(vocabulary[index] == f'<{name}>' for name, index in specials.items()),
            'Special-token names and IDs disagree')
    dimensions = {name: field(f'posformer.decoder.{name}')
                  for name in ('d_model', 'nhead', 'max_len')}
    require(all(type(value) is int and value > 0 for value in dimensions.values()) and
            dimensions['d_model'] <= 1024 and dimensions['nhead'] <= 32 and
            dimensions['d_model'] % dimensions['nhead'] == 0 and
            dimensions['max_len'] <= 512, 'Unsupported decoder dimensions')
    require(field('posformer.encoder.input_channels') == 1, 'Unsupported encoder channels')
    tensors = {tensor.name: tensor for tensor in reader.tensors}
    require('dec.proj.bias' in tensors and 'dec.proj.weight' in tensors,
            'Missing decoder projection tensors')
    bias_shape = [int(i) for i in tensors['dec.proj.bias'].shape]
    weight_shape = [int(i) for i in tensors['dec.proj.weight'].shape]
    require(bias_shape == [count] and weight_shape == [dimensions['d_model'], count],
            'Tokenizer and projection tensor dimensions differ')
    return {'tokens': vocabulary, 'vocab_size': count, 'special_token_ids': specials,
            'decoder_dimensions': dimensions, 'encoder_input_channels': 1,
            'projection_bias_shape': bias_shape, 'projection_weight_shape': weight_shape}


def representable(reference, vocabulary):
    """Exact whitespace-normalized concatenation, allowing multi-token commands.

    A missing command token alone is insufficient to prove unrepresentability:
    a vocabulary containing backslash plus letters could concatenate it.
    """
    target = tokens(reference)
    require(len(target) <= 8192, 'Reference exceeds bounded lexical audit')
    lexical = {tokens(t) for t in vocabulary} - {''}
    by_initial = {}
    for token in lexical:
        by_initial.setdefault(token[0], []).append(token)
    reachable = {0}
    for index in range(len(target)):
        if index not in reachable:
            continue
        for token in by_initial.get(target[index], []):
            if target.startswith(token, index):
                reachable.add(index + len(token))
    return len(target) in reachable


def coverage(manifest, vocabulary):
    cases = manifest.get('cases', [])
    require(manifest.get('split') == 'test' and isinstance(cases, list) and len(cases) == 50,
            'Need all 50 frozen test references')
    require(len({case.get('id') for case in cases}) == 50, 'Duplicate case IDs')
    lexical = set(vocabulary['tokens'])
    rows = []
    for case in cases:
        reference = case.get('reference_latex')
        tokens(reference)  # Reject missing/non-string annotations.
        canonical = re.findall(r'\\[a-zA-Z]+|\\.|[^\s]', reference)
        rows.append({'id': case['id'], 'reference_latex': reference,
                     'missing_canonical_tokens': sorted(set(canonical) - lexical),
                     'exact_string_representable': representable(reference, lexical)})
    unavailable = sum(not row['exact_string_representable'] for row in rows)
    return {'samples': 50, 'cases_with_missing_canonical_tokens':
            sum(bool(row['missing_canonical_tokens']) for row in rows),
            'exact_strings_unrepresentable': unavailable,
            'lexically_representable_reference_count': 50 - unavailable,
            'interpretation': 'Lexical coverage only, not measured recognition accuracy. '
            'Unrepresentability is checked by exact whitespace/BPE-normalized token concatenation; '
            'references, aliases and accuracy scoring remain unchanged.', 'cases': rows}


def audit(model, manifest_path, model_id='crohme-q8'):
    from gguf import GGUFReader
    require(model_id in MODELS, 'Unknown pinned model identity')
    expected_hash = MODELS[model_id]
    require(file_hash(model) == expected_hash, 'Unpinned weights')
    require(file_hash(manifest_path) == FROZEN_MANIFEST_SHA256, 'Frozen manifest changed')
    source = os.environ.get('GITHUB_SHA', '')
    require(re.fullmatch(r'[0-9a-f]{40}', source), 'Missing CI source identity')
    actual = metadata(GGUFReader(model, mode='r'))
    manifest = json.loads(Path(manifest_path).read_text())
    return {'format': 'crispmath.handwriting-vocabulary-audit', 'source': source,
            'model_id': model_id, 'model_sha256': expected_hash,
            'corpus_manifest_sha256': FROZEN_MANIFEST_SHA256,
            'tokenizer_field': 'tokenizer.tokens',
            'tokenizer_sha256': hashlib.sha256(json.dumps(actual['tokens'],
                ensure_ascii=False, separators=(',', ':')).encode()).hexdigest(),
            'actual_gguf_metadata': actual, **coverage(manifest, actual)}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--model', required=True)
    parser.add_argument('--manifest', required=True)
    parser.add_argument('--output', required=True)
    parser.add_argument('--model-id', choices=sorted(MODELS), default='crohme-q8')
    args = parser.parse_args()
    result = audit(args.model, args.manifest, args.model_id)
    Path(args.output).write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: value for key, value in result.items()
                      if key not in ('cases', 'actual_gguf_metadata')}))
