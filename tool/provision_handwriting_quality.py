"""Provision 50 deterministically selected real MathWriting test drawings."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import tarfile
from provision_ocr_quality import DATA_URL, DATA_SHA256, DATA_SOURCE, verified_archive, parse_ink, normalize_strokes


def provision(output, archive=None):
    from PIL import Image, ImageDraw
    output = Path(output)
    output.mkdir(parents=True, exist_ok=True)
    cases = []
    with tarfile.open(fileobj=io.BytesIO(verified_archive(archive)), mode='r:gz') as bundle:
        members = [m for m in bundle.getmembers() if m.isfile() and '/test/' in m.name and m.name.endswith('.inkml')]
        members.sort(key=lambda m: hashlib.sha256(('CrispMath-2026-10-02:' + Path(m.name).stem).encode()).digest())
        if len(members) < 50:
            raise ValueError('Archive has fewer than 50 test drawings')
        for member in members[:50]:
            labels, strokes = parse_ink(bundle.extractfile(member).read())
            reference = labels.get('normalizedLabel') or labels.get('label')
            if not reference:
                raise ValueError('Missing independent dataset annotation: ' + member.name)
            strokes, size = normalize_strokes(strokes)
            image = Image.new('RGB', size, 'white')
            draw = ImageDraw.Draw(image)
            for stroke in strokes:
                if len(stroke) == 1:
                    x, y = stroke[0]
                    draw.ellipse((x-1, y-1, x+1, y+1), fill='black')
                else:
                    draw.line(stroke, fill='black', width=2, joint='curve')
            identifier = Path(member.name).stem
            image.save(output / (identifier + '.png'))
            cases.append({'id': identifier, 'image': identifier + '.png', 'reference_latex': reference})
    manifest = {'format': 'crispmath.handwriting-quality', 'version': 1, 'dataset': DATA_SOURCE,
                'archive_url': DATA_URL, 'archive_sha256': DATA_SHA256, 'split': 'test',
                'selection': 'first 50 SHA-256 ranked IDs with fixed CrispMath-2026-10-02 seed',
                'cases': cases}
    (output / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (output / 'NOTICE.txt').write_text('Real human drawings from MathWriting (Google Research), CC BY-NC-SA 4.0.\n'
        + DATA_SOURCE + '\nImages and reports are benchmark artifacts, not application assets.\n')
    print(json.dumps({'samples': len(cases), 'split': 'test', 'manifest': str(output / 'manifest.json')}), flush=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', default='.dart_tool/inference/handwriting-corpus')
    parser.add_argument('--archive')
    args = parser.parse_args()
    provision(args.output, args.archive)
