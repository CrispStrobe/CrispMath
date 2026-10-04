import unittest
from guided_popup_geometry import stable_popup_window


class PopupGeometryControls(unittest.TestCase):
    def sample(self, time, **changes):
        return dict(count=1, ready=True, x=40., y=100., width=200.,
                    height=48., timeMs=time, **changes)

    def test_complete_quarter_second_is_required(self):
        self.assertFalse(stable_popup_window([self.sample(0), self.sample(249)]))
        self.assertTrue(stable_popup_window([self.sample(0), self.sample(100), self.sample(250)]))

    def test_moving_item_restarts_the_window(self):
        moving = self.sample(200)
        moving['x'] += 10
        self.assertFalse(stable_popup_window([self.sample(0), moving, self.sample(250)]))
        self.assertTrue(stable_popup_window([moving, self.sample(250), self.sample(500)]))

    def test_duplicate_clipped_or_obscured_item_cannot_pass(self):
        for key, value in [('count', 2), ('ready', False), ('x', float('nan'))]:
            invalid = self.sample(250)
            invalid[key] = value
            self.assertFalse(stable_popup_window([self.sample(0), invalid]))
            self.assertFalse(stable_popup_window([invalid, self.sample(500)]))

    def test_small_rounding_does_not_restart_stable_bounds(self):
        rounded = self.sample(250)
        rounded['x'] += .1
        self.assertTrue(stable_popup_window([self.sample(0), rounded]))
