import unittest
from check_macos_package_metadata import validate_metadata


class PackageMetadataControls(unittest.TestCase):
    def test_stale_package_or_checkout_cannot_claim_the_candidate(self):
        source='a'*40;vendor='b'*40
        args=[{'CFBundleShortVersionString':'1.2.0','CFBundleVersion':'23'},
              '1.2.0+23',source,source,'0.17.12','0.17.12',vendor,vendor]
        self.assertEqual(validate_metadata(*args)['actualBundleVersion'],'23')
        stale=dict(args[0],CFBundleVersion='22')
        stale_name=dict(args[0],CFBundleShortVersionString='1.1.0')
        for index,value in [(0,stale),(0,stale_name),(2,'c'*40),(5,'0.17.8'),(6,'c'*40)]:
            wrong=list(args);wrong[index]=value
            with self.assertRaises(AssertionError):validate_metadata(*wrong)


if __name__=='__main__':unittest.main()
