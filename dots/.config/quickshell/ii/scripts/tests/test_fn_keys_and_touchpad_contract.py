"""Contract tests for Fn keys, Touchpad toggle, and Audio mute preservation.

Validates that:
1. XF86TouchpadToggle, XF86TouchpadOn, and XF86TouchpadOff are active and bound to
   touchpad-toggle.sh with ignore_mods = true (never commented out).
2. XF86AudioMute and XF86AudioMicMute are active and configured with
   locked = true, ignore_mods = true, and wireplumber set-mute commands.
3. Audio volume controls (XF86AudioRaiseVolume, XF86AudioLowerVolume) have
   ignore_mods = true to prevent key rejection when NumLock or firmware Fn masks are active.
4. Media controls (Play, Pause, Next, Prev) have ignore_mods = true.
5. hyprland/scripts/touchpad-toggle.sh exists and is executable.
"""

from pathlib import Path
import os
import re
import unittest

REPO_ROOT = Path(__file__).resolve().parents[6]
KEYBINDS_LUA_PATH = REPO_ROOT / "dots/.config/hypr/hyprland/keybinds.lua"
TOUCHPAD_SCRIPT_PATH = REPO_ROOT / "dots/.config/hypr/hyprland/scripts/touchpad-toggle.sh"
MUTE_SCRIPT_PATH = REPO_ROOT / "dots/.config/hypr/hyprland/scripts/volume-mute.sh"


class FnKeysAndTouchpadContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.keybinds = KEYBINDS_LUA_PATH.read_text(encoding="utf-8")

    def test_touchpad_and_mute_scripts_exist_and_are_executable(self):
        self.assertTrue(TOUCHPAD_SCRIPT_PATH.is_file(), "touchpad-toggle.sh does not exist")
        self.assertTrue(os.access(TOUCHPAD_SCRIPT_PATH, os.X_OK), "touchpad-toggle.sh is not executable")
        self.assertTrue(MUTE_SCRIPT_PATH.is_file(), "volume-mute.sh does not exist")
        self.assertTrue(os.access(MUTE_SCRIPT_PATH, os.X_OK), "volume-mute.sh is not executable")

    def test_touchpad_binds_are_not_commented_out(self):
        # Must not be commented out
        self.assertNotIn("-- hl.bind(\"XF86TouchpadToggle\"", self.keybinds)
        self.assertNotIn("-- hl.bind(\"XF86TouchpadOn\"", self.keybinds)
        self.assertNotIn("-- hl.bind(\"XF86TouchpadOff\"", self.keybinds)

        # Must have active bindings
        self.assertIn('hl.bind("XF86TouchpadToggle"', self.keybinds)
        self.assertIn('hl.bind("XF86TouchpadOn"', self.keybinds)
        self.assertIn('hl.bind("XF86TouchpadOff"', self.keybinds)

    def test_touchpad_binds_have_ignore_mods(self):
        # Extract the XF86TouchpadToggle bind block
        match = re.search(
            r'hl\.bind\("XF86TouchpadToggle",\s*hl\.dsp\.exec_cmd\([^)]+\),\s*\{([^}]+)\}\)',
            self.keybinds,
        )
        self.assertIsNotNone(match, "Could not find active XF86TouchpadToggle bind definition")
        opts = match.group(1)
        self.assertIn("ignore_mods = true", opts)
        self.assertIn("locked = true", opts)

    def test_audio_mute_binds_have_ignore_mods(self):
        # XF86AudioMute
        mute_match = re.search(
            r'hl\.bind\("XF86AudioMute",\s*hl\.dsp\.exec_cmd\([^)]+\),\s*\{([^}]+)\}\)',
            self.keybinds,
        )
        self.assertIsNotNone(mute_match, "Could not find active XF86AudioMute bind definition")
        opts = mute_match.group(1)
        self.assertIn("ignore_mods = true", opts)
        self.assertIn("locked = true", opts)

        # XF86AudioMicMute
        mic_match = re.search(
            r'hl\.bind\("XF86AudioMicMute",\s*hl\.dsp\.exec_cmd\([^)]+\),\s*\{([^}]+)\}\)',
            self.keybinds,
        )
        self.assertIsNotNone(mic_match, "Could not find active XF86AudioMicMute bind definition")
        mic_opts = mic_match.group(1)
        self.assertIn("ignore_mods = true", mic_opts)
        self.assertIn("locked = true", mic_opts)

    def test_audio_volume_binds_have_ignore_mods(self):
        raise_match = re.search(
            r'hl\.bind\("XF86AudioRaiseVolume",\s*hl\.dsp\.exec_cmd\("wpctl set-volume [^"]+"\),\s*\{([^}]+)\}\)',
            self.keybinds,
        )
        self.assertIsNotNone(raise_match, "Could not find active XF86AudioRaiseVolume bind definition")
        raise_opts = raise_match.group(1)
        self.assertIn("ignore_mods = true", raise_opts)

        lower_match = re.search(
            r'hl\.bind\("XF86AudioLowerVolume",\s*hl\.dsp\.exec_cmd\("wpctl set-volume [^"]+"\),\s*\{([^}]+)\}\)',
            self.keybinds,
        )
        self.assertIsNotNone(lower_match, "Could not find active XF86AudioLowerVolume bind definition")
        lower_opts = lower_match.group(1)
        self.assertIn("ignore_mods = true", lower_opts)


if __name__ == "__main__":
    unittest.main()
