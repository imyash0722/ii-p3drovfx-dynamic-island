"""Contract test for Copilot key binding to Dynamic Island widgets dashboard.

Validates that:
1. dots/.config/hypr/hyprland/keybinds.lua binds Copilot key hardware combinations:
   - SUPER + SHIFT + F23 (standard Microsoft/OEM hardware keycode)
   - XF86CoPilot (Linux/udev keysym)
   - F23 (firmware/BIOS keysym)
   all triggering quickshell:dynamicIslandDashboardToggle with description
   "Dynamic Island: Toggle widgets dashboard".
2. dots/.config/quickshell/ii/GlobalStates.qml defines:
   - signal toggleIslandDashboardRequested()
   - function toggleDynamicIslandDashboard()
   - GlobalShortcut with name "dynamicIslandDashboardToggle"
3. dots/.config/quickshell/ii/modules/ii/dynamicIsland/styles/notch/NotchIsland.qml:
   - connects to GlobalStates.onToggleIslandDashboardRequested
   - toggles root.dashboardActive via openDashboard() and dismissDashboard()
   - openDashboard() clears preferClockFace and expandSuppressed
"""

from pathlib import Path
import unittest

REPO_ROOT = Path(__file__).resolve().parents[6]
KEYBINDS_LUA = REPO_ROOT / "dots/.config/hypr/hyprland/keybinds.lua"
GLOBAL_STATES_QML = REPO_ROOT / "dots/.config/quickshell/ii/GlobalStates.qml"
NOTCH_ISLAND_QML = REPO_ROOT / "dots/.config/quickshell/ii/modules/ii/dynamicIsland/styles/notch/NotchIsland.qml"


class CopilotKeyContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.keybinds = KEYBINDS_LUA.read_text(encoding="utf-8")
        cls.global_states = GLOBAL_STATES_QML.read_text(encoding="utf-8")
        cls.notch_island = NOTCH_ISLAND_QML.read_text(encoding="utf-8")

    def test_keybinds_registers_copilot_combinations(self):
        self.assertIn(
            'hl.bind("SUPER + SHIFT + F23", hl.dsp.global("quickshell:dynamicIslandDashboardToggle")',
            self.keybinds,
        )
        self.assertIn(
            'hl.bind("XF86CoPilot", hl.dsp.global("quickshell:dynamicIslandDashboardToggle")',
            self.keybinds,
        )
        self.assertIn(
            'hl.bind("F23", hl.dsp.global("quickshell:dynamicIslandDashboardToggle")',
            self.keybinds,
        )
        self.assertIn(
            'description = "Dynamic Island: Toggle widgets dashboard"',
            self.keybinds,
        )

    def test_global_states_declares_shortcut_and_signal(self):
        self.assertIn("signal toggleIslandDashboardRequested()", self.global_states)
        self.assertIn("function toggleDynamicIslandDashboard()", self.global_states)
        self.assertIn('name: "dynamicIslandDashboardToggle"', self.global_states)
        self.assertIn("root.toggleDynamicIslandDashboard()", self.global_states)

    def test_notch_island_handles_toggle_signal(self):
        self.assertIn("function onToggleIslandDashboardRequested()", self.notch_island)
        self.assertIn("if (root.dashboardActive)", self.notch_island)
        self.assertIn("root.dismissDashboard()", self.notch_island)
        self.assertIn("root.openDashboard()", self.notch_island)

    def test_open_dashboard_clears_clock_face_suppression(self):
        # When opening dashboard, it must unsuppress and preferClockFace = false
        open_db_slice = self.notch_island.split("function openDashboard()")[1].split("}")[0]
        self.assertIn("root.preferClockFace = false;", open_db_slice)
        self.assertIn("root.expandSuppressed = false;", open_db_slice)
        self.assertIn("root.dashboardRequested = true;", open_db_slice)


if __name__ == "__main__":
    unittest.main()
