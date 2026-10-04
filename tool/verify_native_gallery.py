"""Verify native CI screenshots and calculator evidence without app bundles."""
import json
import math
import os
from pathlib import Path
import struct
import sys


SCENES = {
    'calculator-exact-integral', 'connected-worksheet',
    'linked-function-graph', 'multiple-function-graph', 'graph-curve-trace',
    'generated-graph-value-table', 'shortcuts-created-worksheet',
    'evaluated-engineering-worksheet', 'worksheet-graph-export-preview',
    'worksheet-checkpoint-history', 'handwriting-editable-input',
}


def verify_dimensions(profile, width, height):
    if profile == 'macos':
        # Apple's Mac upload sizes all have a 16:10 aspect ratio. Reject the
        # old 2560x1800 internal gallery instead of calling it upload-ready.
        assert (width, height) in {
            (1280, 800), (1440, 900), (2560, 1600), (2880, 1800),
        }, f'Unsupported Mac screenshot size: {width}x{height}'
    else:
        assert height > width and width >= 1200


def verify_connected_worksheet(document):
    """Validate the guide actually created through the native document menu."""
    lines = document['l']
    assert [line['s'] for line in lines] == ['a=3', 'f(x)=x^2+a', 'f(4)']
    assert all(not line.get('e') for line in lines), 'Guide must evaluate without errors'
    assert lines[0]['r'] == '3'
    assert lines[1]['r'] == 'x^2+(3)', 'Function must preserve its independent variable'
    assert lines[2]['r'] == '19', 'Function application must use the linked parameter'
    assert lines[2]['evidence']['accuracy'] == 'exact'


def main():
    root = Path(sys.argv[1])
    profiles = sys.argv[2:]
    manifest_path = root / 'manifest.json'
    manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else {}
    manifest.update(source=os.environ['GITHUB_SHA'], physicalDeviceTest=False)
    images = []
    evidence_by_profile = {}
    for profile in profiles:
        files = sorted((root / profile).glob('*.png'))
        assert {file.stem for file in files} == SCENES, (profile, files)
        evidence = json.loads((root / profile / 'native-evidence.json').read_text())
        for key in ['exportPreview', 'historyCheckpoint', 'handwritingInput',
                    'nativeBridge', 'populatedGraph', 'graphTrace', 'generatedValueTable']:
            assert evidence[key] is True, (profile, key)
        assert evidence['nativeDerivative'] == 'cos(x)'
        assert evidence['integral']['value'] == '1/3'
        assert evidence['integral']['evidence']['accuracy'] == 'exact'
        verify_connected_worksheet(evidence['document'])
        if profile != 'macos':
            assert evidence['nativeWorkflowUrl'] is True
            assert evidence['nativeWorkflowUrlSupported'] is True
        else:
            assert evidence['nativeWorkflowUrlSupported'] is False
            assert evidence['captureKind'] == 'native-macos-render-tree'
        engineering = evidence['engineeringWorksheet']['l']
        assert engineering[2]['r'] == '5'
        assert engineering[4].get('r') and not engineering[4].get('e')
        assert '/' not in engineering[4]['r']
        assert abs(float(engineering[4]['r']) - 45 * math.pi) < 1e-7
        assert abs(float(engineering[5]['r']) - 45 * math.pi / 1000) < 1e-9
        assert all(line['evidence']['accuracy'] in {'unknown', 'approximate'}
                   for line in engineering[3:])
        assert all(line['evidence']['accuracy'] == 'exact'
                   for line in engineering[1:3])
        evidence_by_profile[profile] = evidence
        for file in files:
            data = file.read_bytes()
            assert data[:8] == b'\x89PNG\r\n\x1a\n'
            assert data[25] == 2, 'Screenshot must be RGB without alpha'
            width, height = struct.unpack('>II', data[16:24])
            verify_dimensions(profile, width, height)
            images.append({'file': str(file.relative_to(root)),
                           'width': width, 'height': height,
                           'captureKind': evidence['captureKind']})
    manifest.update(screenshots=images, evidence=evidence_by_profile, passed=True)
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'Verified {len(images)} populated native screenshots at {manifest["source"]}')


if __name__ == '__main__':
    main()
