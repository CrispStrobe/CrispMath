"""Build reproducible printed and real-human-handwriting OCR evaluation images.

MathWriting images are generated only in ignored benchmark storage, never app
assets. Preserve the dataset attribution/license beside generated images.
"""
import argparse
import hashlib
import io
import json
import math
from pathlib import Path
import tarfile
import urllib.request
import xml.etree.ElementTree as ET

DATA_URL = 'https://storage.googleapis.com/mathwriting_data/mathwriting-2024-excerpt.tgz?generation=1706701808342822'
DATA_SHA256 = 'cba038def001480a89962b25cb20a60df4c4145e94c86ef9d2af65f192cb82bc'
DATA_SOURCE = 'https://github.com/google-research/google-research/tree/master/mathwriting'
HANDWRITING = [
    {'id': '000a4e8ca49c5a1c', 'label': '(x-y)/sqrt(2)',
     'reference': '(x-y)/sqrt(2)', 'probes': [
         {'scope': {'x': 3, 'y': 1}, 'expected': 1.4142135623730951},
         {'scope': {'x': 5, 'y': 1}, 'expected': 2.8284271247461903}]},
    {'id': '00fcddfee1ebfee6', 'label': '2sin(x/2)',
     'reference': '2*sin(x/2)', 'probes': [
         {'scope': {'x': math.pi}, 'expected': 2},
         {'scope': {'x': 0}, 'expected': 0}]},
    {'id': '0255dc5b14261907', 'label': r'1+x+\frac{x^{2}}{2}',
     'reference': '1+x+x^2/2', 'probes': [
         {'scope': {'x': 2}, 'expected': 5},
         {'scope': {'x': -1}, 'expected': 0.5}]},
]


def parse_ink(data):
    root = ET.fromstring(data)
    annotations = {element.attrib['type']: element.text for element in root
                   if element.tag.endswith('annotation')}
    strokes = []
    for element in root:
        if not element.tag.endswith('trace'):
            continue
        points = []
        for raw in (element.text or '').strip().split(','):
            if not raw.strip():
                continue
            values = raw.split()
            if len(values) < 2:
                raise ValueError('Ink point needs x and y')
            point = tuple(map(float, values[:2]))
            if not all(math.isfinite(value) for value in point):
                raise ValueError('Ink coordinates must be finite')
            points.append(point)
        if points:
            strokes.append(points)
    if not strokes:
        raise ValueError('Ink has no strokes')
    return annotations, strokes


def normalize_strokes(strokes, height=96, padding=12):
    points = [point for stroke in strokes for point in stroke]
    if not points:
        raise ValueError('Ink has no points')
    x_min, y_min = (min(point[axis] for point in points) for axis in (0, 1))
    x_max, y_max = (max(point[axis] for point in points) for axis in (0, 1))
    width_span, height_span = max(1, x_max-x_min), max(1, y_max-y_min)
    scale = min(height/height_span, 1600/width_span)
    normalized = [[((x-x_min)*scale+padding, (y-y_min)*scale+padding)
                   for x, y in stroke] for stroke in strokes]
    size = (math.ceil(width_span*scale+2*padding),
            math.ceil(height_span*scale+2*padding))
    return normalized, size


def verified_archive(archive):
    if archive is None:
        with urllib.request.urlopen(DATA_URL, timeout=60) as response:
            data = response.read()
    else:
        data = Path(archive).read_bytes()
    if hashlib.sha256(data).hexdigest() != DATA_SHA256:
        raise ValueError('MathWriting archive checksum mismatch')
    return data


def provision(output, archive=None):
    from PIL import Image, ImageDraw, ImageEnhance, ImageFilter
    import matplotlib
    from matplotlib.mathtext import math_to_image
    import PIL

    output = Path(output)
    output.mkdir(parents=True, exist_ok=True)
    cases = []
    for font in ['cm', 'dejavusans', 'dejavuserif', 'stix']:
        filename = f'printed-{font}.png'
        with matplotlib.rc_context({'mathtext.fontset': font}):
            math_to_image('$5+7$', output/filename, dpi=180, format='png', color='black')
        cases.append({'id': f'font-{font}', 'kind': 'printed-font',
                      'image': filename, 'reference': '5+7', 'expected': 12})
    for identifier, latex, reference, expected in [
            ('fractions', r'\frac{3}{4}+\frac{1}{4}', '3/4+1/4', 1),
            ('root', r'\sqrt{81}+1', 'sqrt(81)+1', 10)]:
        filename = identifier+'.png'
        with matplotlib.rc_context({'mathtext.fontset': 'cm'}):
            math_to_image('$'+latex+'$', output/filename, dpi=180, format='png', color='black')
        cases.append({'id': identifier, 'kind': 'printed-structure',
                      'image': filename, 'reference': reference, 'expected': expected})
    base = Image.open(output/'printed-cm.png').convert('RGB')
    variants = {'skew': base.rotate(3, expand=True, fillcolor='white'),
                'blur': base.filter(ImageFilter.GaussianBlur(.6)),
                'low-contrast': ImageEnhance.Contrast(base).enhance(.35),
                'low-resolution': base.resize((max(1, base.width//2), max(1, base.height//2)))}
    for identifier, image in variants.items():
        filename = identifier+'.png'
        image.save(output/filename)
        cases.append({'id': identifier, 'kind': 'image-variation',
                      'image': filename, 'reference': '5+7', 'expected': 12})
    data = verified_archive(archive)
    with tarfile.open(fileobj=io.BytesIO(data)) as dataset:
        for sample in HANDWRITING:
            member = f"mathwriting-2024-excerpt/test/{sample['id']}.inkml"
            ink = dataset.extractfile(member).read()
            annotations, strokes = parse_ink(ink)
            if annotations.get('inkCreationMethod') != 'human' or annotations.get('normalizedLabel') != sample['label']:
                raise ValueError('Handwriting sample provenance/label changed')
            points, size = normalize_strokes(strokes)
            image = Image.new('RGB', size, 'white')
            draw = ImageDraw.Draw(image)
            for stroke in points:
                draw.line(stroke, fill='black', width=3, joint='curve')
                for x, y in [stroke[0], stroke[-1]]:
                    draw.ellipse((x-1.5, y-1.5, x+1.5, y+1.5), fill='black')
            filename = 'handwritten-'+sample['id']+'.png'
            image.save(output/filename)
            cases.append({**sample, 'id': 'handwritten-'+sample['id'],
                          'sample_id': sample['id'], 'kind': 'human-handwriting', 'image': filename,
                          'ink_sha256': hashlib.sha256(ink).hexdigest()})
    manifest = {'schema': 1, 'pillow': PIL.__version__, 'matplotlib': matplotlib.__version__,
                'handwriting_source': DATA_SOURCE, 'handwriting_archive': DATA_URL,
                'archive_sha256': DATA_SHA256, 'cases': cases}
    (output/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    (output/'NOTICE.txt').write_text(
        'MathWriting dataset: Google Research, https://github.com/google-research/google-research/tree/master/mathwriting\n'
        'Human handwriting/raster derivatives: CC BY-NC-SA 4.0. Labels may also be CC BY-SA (Wikipedia).\n'
        'This directory is benchmark data, not an application asset.\n')
    return manifest


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', default='.dart_tool/inference/ocr-corpus')
    parser.add_argument('--archive', help='Optional already-downloaded pinned archive')
    arguments = parser.parse_args()
    result = provision(arguments.output, arguments.archive)
    print(json.dumps({'cases': len(result['cases']), 'output': arguments.output}))
