import io
from pathlib import Path
import tarfile
import tempfile
import unittest
import zipfile

from stage_ocr_runtime import stage


class StageOcrRuntimeTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.plugin = self.root / 'plugin'
        self.plugin.mkdir()
        (self.plugin / 'pubspec.yaml').write_text('version: 0.17.11\n')

    def test_linux_stages_primary_and_dependency_aliases(self):
        archive = self.root / 'runtime.tar.gz'
        with tarfile.open(archive, 'w:gz') as bundle:
            for name, contents in [('libcrispembed.so', b'ocr'),
                                   ('libggml.so.0.17.0', b'cpu')]:
                member = tarfile.TarInfo(name)
                member.size = len(contents)
                bundle.addfile(member, io.BytesIO(contents))
            alias = tarfile.TarInfo('libggml.so.0')
            alias.type = tarfile.SYMTYPE
            alias.linkname = 'libggml.so.0.17.0'
            bundle.addfile(alias)
        stage(self.plugin, 'linux', archive)
        libraries = self.plugin / 'linux/lib'
        self.assertEqual((libraries / 'libcrispembed.so').read_bytes(), b'ocr')
        self.assertEqual((libraries / 'libggml.so.0').read_bytes(), b'cpu')
        self.assertFalse((libraries / 'libggml.so.0').is_symlink())

    def test_windows_stages_all_dll_dependencies_only(self):
        archive = self.root / 'runtime.zip'
        with zipfile.ZipFile(archive, 'w') as bundle:
            bundle.writestr('release/crispembed.dll', b'ocr')
            bundle.writestr('release/ggml-cpu.dll', b'cpu')
            bundle.writestr('release/server.exe', b'not bundled')
        stage(self.plugin, 'windows', archive)
        libraries = self.plugin / 'windows/lib'
        self.assertEqual(sorted(p.name for p in libraries.iterdir()),
                         ['crispembed.dll', 'ggml-cpu.dll'])

    def test_missing_primary_library_fails_before_staging(self):
        archive = self.root / 'runtime.zip'
        with zipfile.ZipFile(archive, 'w') as bundle:
            bundle.writestr('ggml.dll', b'cpu')
        with self.assertRaisesRegex(ValueError, 'does not contain crispembed.dll'):
            stage(self.plugin, 'windows', archive)
        self.assertFalse((self.plugin / 'windows/lib').exists())


if __name__ == '__main__':
    unittest.main()
