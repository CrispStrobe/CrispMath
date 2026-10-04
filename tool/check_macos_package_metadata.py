"""Verify actual packaged macOS version and checked-out app/plugin provenance."""
import argparse
import json
from pathlib import Path
import plistlib
import re
import subprocess


def validate_metadata(info, app_version, source, expected_source,
                      plugin_version, locked_version, plugin_source, pinned_source):
    match=re.fullmatch(r'([^+\s]+)\+(\d+)',app_version)
    assert match,app_version
    assert info.get('CFBundleShortVersionString')==match[1],info
    assert str(info.get('CFBundleVersion'))==match[2],info
    assert re.fullmatch(r'[0-9a-f]{40}',source) and source==expected_source,(source,expected_source)
    assert re.fullmatch(r'[0-9a-f]{40}',plugin_source) and plugin_source==pinned_source,(plugin_source,pinned_source)
    assert plugin_version==locked_version,(plugin_version,locked_version)
    return {'passed':True,'appSource':source,'appVersion':match[1],
            'actualBundleVersion':str(info['CFBundleVersion']),
            'actualBundleShortVersion':info['CFBundleShortVersionString'],
            'pluginVersion':plugin_version,'pluginSource':plugin_source,
            'evidence':'built Contents/Info.plist and actual checkout/lock metadata'}


def version(path):
    match=re.search(r'^version:\s*([^\s]+)',path.read_text(),re.M)
    assert match,path
    return match[1]


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--app',type=Path,required=True)
    parser.add_argument('--expected-source',required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    with (args.app/'Contents'/'Info.plist').open('rb') as source:
        info=plistlib.load(source)
    checkout=Path('.ci/CrispEmbed')
    revision=lambda path:subprocess.check_output(['git','-C',str(path),'rev-parse','HEAD'],text=True).strip()
    pinned=re.search(r'repository:\s*CrispStrobe/CrispEmbed\s+ref:\s*([0-9a-f]{40})',Path('.github/workflows/build-macos.yml').read_text())
    assert pinned,'Mac workflow must pin the vendor checkout'
    locked=re.search(r'^  crispembed:\n(?:(?:    .*|)\n)*?    version:\s*"([^"]+)"',Path('pubspec.lock').read_text(),re.M)
    assert locked,'Resolved vendor version must be recorded'
    report=validate_metadata(info,version(Path('pubspec.yaml')),revision(Path('.')),
                             args.expected_source,version(checkout/'flutter/crispembed/pubspec.yaml'),
                             locked[1],revision(checkout),pinned[1])
    args.output.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report))


if __name__=='__main__':main()
