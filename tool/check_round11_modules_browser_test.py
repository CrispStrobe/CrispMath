"""Independent complete-enumeration controls for the real module UI audit."""
import unittest
from round11_module_reference_checks import validate_enumeration, ENUMERATIONS


class EnumerationControls(unittest.TestCase):
    def test_every_frozen_assignment_is_required(self):
        for name,source,expected in ENUMERATIONS:
            text='\n'.join(f'{index}.  '+', '.join(f'{key}={value}'for key,value in row.items())for index,row in enumerate(reversed(expected),1))
            self.assertEqual(len(validate_enumeration(text,expected)),len(expected))
            for wrong in [text+'\n'+text.splitlines()[0],text.replace('=-3','=3',1),text.replace('1.','2.',1)]:
                if wrong==text:continue
                with self.assertRaises(AssertionError,msg=name):validate_enumeration(wrong,expected)
            with self.assertRaises(AssertionError,msg=name):validate_enumeration('',expected)


if __name__=='__main__':unittest.main()
