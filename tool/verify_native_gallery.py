"""Verify native CI screenshots and calculator evidence without app bundles."""
import json
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
        if profile != 'macos':
            assert evidence['nativeWorkflowUrl'] is True
            assert evidence['nativeWorkflowUrlSupported'] is True
        else:
            assert evidence['nativeWorkflowUrlSupported'] is False
            assert evidence['captureKind'] == 'native-macos-render-tree'
        engineering = evidence['engineeringWorksheet']['l']
        assert engineering[2]['r'] == '5'
        assert engineering[4].get('r') and not engineering[4].get('e')
        evidence_by_profile[profile] = evidence
        for file in files:
            data = file.read_bytes()
            assert data[:8] == b'\x89PNG\r\n\x1a\n'
            assert data[25] == 2, 'Screenshot must be RGB without alpha'
            width, height = struct.unpack('>II', data[16:24])
            if profile == 'macos':
                assert width > height and width >= 2200 and height >= 1200
            else:
                assert height > width and width >= 1200
            images.append({'file': str(file.relative_to(root)),
                           'width': width, 'height': height,
                           'captureKind': evidence['captureKind']})
    manifest.update(screenshots=images, evidence=evidence_by_profile, passed=True)
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'Verified {len(images)} populated native screenshots at {manifest["source"]}')


if __name__ == '__main__':
    main()
