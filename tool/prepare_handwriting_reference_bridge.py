"""Instrument only the pinned native bridge for bounded hosted reference checks."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

from compare_handwriting_encoders import BRIDGE_SOURCE, require


def replace_once(source, before, after):
    require(source.count(before) == 1, 'Native trace anchor changed: ' + before[:90])
    return source.replace(before, after, 1)


def instrument(source):
    helper = r'''
// Hosted diagnostic only: capture actual intermediate values without changing operators.
static void reference_trace(const char * name, const float * values, int a, int b, int c) {
    const char * directory = getenv("POSFORMER_REFERENCE_TRACE");
    if (!directory) return;
    char path[1024];
    snprintf(path, sizeof(path), "%s/%s.f32", directory, name);
    FILE * file = fopen(path, "wb");
    if (!file) abort();
    const size_t count = (size_t)a * b * c;
    if (fwrite(values, sizeof(float), count, file) != count) abort();
    fclose(file);
    snprintf(path, sizeof(path), "%s/%s.shape.json", directory, name);
    file = fopen(path, "wb");
    if (!file) abort();
    fprintf(file, "[%d,%d,%d]\n", a, b, c);
    fclose(file);
}
static void reference_decoder_trace(const char * stage, int layer, int step,
                                    const float * values, int d) {
    char name[128];
    snprintf(name, sizeof(name), "%s_layer%d_step%d", stage, layer, step);
    reference_trace(name, values, 1, 1, d);
}
'''
    source = replace_once(source, '// Tensor mapping', helper + '\n// Tensor mapping')
    source = replace_once(source, '    int cur_ch = init_ch;\n    auto dense_block',
        '    auto trace_graph = [&](const char * name) {\n'
        '        if (getenv("POSFORMER_REFERENCE_TRACE")) {\n'
        '            ggml_set_name(x, name); ggml_set_output(x); ggml_build_forward_expand(gf, x);\n'
        '        }\n    };\n    trace_graph("pool0");\n'
        '    int cur_ch = init_ch;\n    auto dense_block')
    # Add retained graph outputs at the real stage boundaries.
    pool_call = ('pf_pool_ceil(g, x, GGML_OP_POOL_MAX' if
                 'static ggml_tensor * pf_pool_ceil(' in source else
                 'ggml_pool_2d(g, x, GGML_OP_POOL_MAX')
    for before, after in [
        ('    x = ggml_relu(g, x);\n    x = ' + pool_call,
         '    x = ggml_relu(g, x);\n    if (getenv("POSFORMER_REFERENCE_TRACE")) {\n'
         '        ggml_set_name(x, "stem"); ggml_set_output(x); ggml_build_forward_expand(gf, x);\n'
         '    }\n    x = ' + pool_call),
        ('    dense_block(ctx->block1);\n    transition(ctx->trans1);\n'
         '    dense_block(ctx->block2);\n    transition(ctx->trans2);\n    dense_block(ctx->block3);',
         '    dense_block(ctx->block1); trace_graph("block1");\n'
         '    transition(ctx->trans1); trace_graph("pool1");\n'
         '    dense_block(ctx->block2); trace_graph("block2");\n'
         '    transition(ctx->trans2); trace_graph("pool2");\n'
         '    dense_block(ctx->block3); trace_graph("block3");'),
    ]:
        source = replace_once(source, before, after)
    source = replace_once(source, '    ctx->encoder_output.resize(n_pos * D);\n    for (int c = 0; c < D; c++)',
        '    if (getenv("POSFORMER_REFERENCE_TRACE")) {\n'
        '        for (const char * name : {"stem", "pool0", "block1", "pool1", "block2", "pool2", "block3"}) {\n'
        '            ggml_tensor * stage = ggml_graph_get_tensor(gf, name);\n'
        '            if (!stage) abort();\n'
        '            std::vector<float> values(ggml_nelements(stage));\n'
        '            ggml_backend_tensor_get(stage, values.data(), 0, values.size() * sizeof(float));\n'
        '            reference_trace(name, values.data(), stage->ne[2], stage->ne[1], stage->ne[0]);\n'
        '        }\n    }\n'
        '    reference_trace("projection", chw.data(), D, out_h, out_w);\n'
        '    ctx->encoder_output.resize(n_pos * D);\n    for (int c = 0; c < D; c++)')
    source = replace_once(source, '    relu_ip(feat.data(), init_ch * h1 * w1);',
        '    relu_ip(feat.data(), init_ch * h1 * w1);\n'
        '    reference_trace("stem", feat.data(), init_ch, h1, w1);')
    source = replace_once(source, '    int cur_ch = init_ch, cur_h = h2, cur_w = w2;',
        '    reference_trace("pool0", pooled.data(), init_ch, h2, w2);\n'
        '    int cur_ch = init_ch, cur_h = h2, cur_w = w2;')
    source = replace_once(source, '    run_block(ctx->block1);\n    run_trans(ctx->trans1);\n'
        '    run_block(ctx->block2);\n    run_trans(ctx->trans2);\n    run_block(ctx->block3);',
        '    run_block(ctx->block1); reference_trace("block1", features.data(), cur_ch, cur_h, cur_w);\n'
        '    run_trans(ctx->trans1); reference_trace("pool1", features.data(), cur_ch, cur_h, cur_w);\n'
        '    run_block(ctx->block2); reference_trace("block2", features.data(), cur_ch, cur_h, cur_w);\n'
        '    run_trans(ctx->trans2); reference_trace("pool2", features.data(), cur_ch, cur_h, cur_w);\n'
        '    run_block(ctx->block3); reference_trace("block3", features.data(), cur_ch, cur_h, cur_w);')
    source = replace_once(source, '    // No ReLU here — PyTorch\'s feature_proj is a plain Conv2d',
        '    reference_trace("projection", proj.data(), D, cur_h, cur_w);\n'
        '    // No ReLU here — PyTorch\'s feature_proj is a plain Conv2d')
    source = replace_once(source, '    t0 = std::chrono::steady_clock::now();\n'
        '    if (ctx->enc_sched && !std::getenv("POSFORMER_SCALAR_ENCODER"))',
        '    reference_trace("preprocessed", input, 1, h, w);\n'
        '    t0 = std::chrono::steady_clock::now();\n'
        '    if (ctx->enc_sched && !std::getenv("POSFORMER_SCALAR_ENCODER"))')
    source = replace_once(source, '    ctx->result_buf = greedy_decode(ctx);',
        '    reference_trace("encoded", ctx->encoder_output.data(), ctx->enc_h, ctx->enc_w, ctx->hparams.d_model);\n'
        '    ctx->result_buf = greedy_decode(ctx);')
    source = replace_once(source, '    for (int step = 0; step < hp.max_len; step++) {',
        '    const char * bounded = getenv("POSFORMER_REFERENCE_STEPS");\n'
        '    const int steps = bounded ? std::min(hp.max_len, std::max(1, atoi(bounded))) : hp.max_len;\n'
        '    for (int step = 0; step < steps; step++) {')
    source = replace_once(source, '        memset(ds.prev_layer_ca_weights.data(), 0, nhead * n_enc * sizeof(float));',
        '        reference_decoder_trace("token_input", -1, step, ds.x.data(), D);\n'
        '        memset(ds.prev_layer_ca_weights.data(), 0, nhead * n_enc * sizeof(float));')
    for name, norm in [('norm1', 'ln1'), ('norm2', 'ln2'), ('norm3', 'ln3')]:
        line = f'layernorm(ds.x.data(), D, tf32(ctx, l.{norm}_w), tf32(ctx, l.{norm}_b));'
        source = replace_once(source, line, line +
            f'\n                reference_decoder_trace("{name}", li, step, ds.x.data(), D);')
    source = replace_once(source, '        int best = 0;\n        float best_score',
        '        reference_decoder_trace("logits", -1, step, ds.logits.data(), V);\n'
        '        int best = 0;\n        float best_score')
    return source


def prepare(root, normalized, report, forward_repair=False):
    root = Path(root)
    base = subprocess.check_output(['git', '-C', str(root), 'rev-parse', 'HEAD'], text=True).strip()
    require(base == BRIDGE_SOURCE, 'Unpinned bridge source')
    path = root / 'src/posformer_ocr.cpp'
    pristine = subprocess.check_output(['git', '-C', str(root), 'show',
                                       BRIDGE_SOURCE + ':src/posformer_ocr.cpp'])
    require(path.read_bytes() == pristine, 'Native source already modified')
    patch = Path(__file__).parent / 'patches' / ('posformer-forward-repair.patch' if forward_repair
                                               else 'posformer-input-norm.patch')
    if normalized or forward_repair:
        subprocess.run(['git', '-C', str(root), 'apply', '--check', str(patch.resolve())], check=True)
        subprocess.run(['git', '-C', str(root), 'apply', str(patch.resolve())], check=True)
    path.write_text(instrument(path.read_text()))
    result = {'bridge_source': base, 'original_source_sha256': hashlib.sha256(pristine).hexdigest(),
              'instrumented_source_sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
              'instrumentation_tool_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'input_norm_patch_sha256': (hashlib.sha256((Path(__file__).parent / 'patches/posformer-input-norm.patch').read_bytes()).hexdigest()
                                         if normalized or forward_repair else None),
              'forward_repair_patch_sha256': hashlib.sha256(patch.read_bytes()).hexdigest() if forward_repair else None,
              'mathematical_change': ('post-position normalization and ceil pooling' if forward_repair else
                                     'post-position learned normalization' if normalized else 'none'),
              'trace_scope': 'Actual operators, retained encoder outputs, first five decoder steps only.'}
    Path(report).write_text(json.dumps(result, indent=2) + '\n')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', required=True)
    parser.add_argument('--normalized', action='store_true')
    parser.add_argument('--forward-repair', action='store_true')
    parser.add_argument('--report', required=True)
    args = parser.parse_args()
    prepare(args.root, args.normalized, args.report, args.forward_repair)
