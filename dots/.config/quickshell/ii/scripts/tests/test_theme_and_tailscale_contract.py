#!/usr/bin/env python3
"""Contract tests for Tailscale command resilience and symmetrical light/dark mode color switching."""

import os
import unittest

ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../../../.."))


class ThemeAndTailscaleContractTest(unittest.TestCase):
    def test_tailscale_service_contract(self):
        tailscale_path = os.path.join(ROOT_DIR, "dots/.config/quickshell/ii/services/TailscaleService.qml")
        self.assertTrue(os.path.isfile(tailscale_path), f"File not found: {tailscale_path}")

        with open(tailscale_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Tailscale up command should pass --reset and --timeout so it never fails on non-default flags or hangs
        self.assertIn('args.push("--reset")', content, "Tailscale buildUpCommand must include --reset")
        self.assertIn('args.push("--timeout=', content, "Tailscale buildUpCommand must specify a timeout")

        # Toggles while active must use 'tailscale set'
        self.assertIn('root.enqueue("set", ["tailscale", "set", "--accept-dns="', content)
        self.assertIn('root.enqueue("set", ["tailscale", "set", "--shields-up="', content)
        self.assertIn('root.enqueue("set", ["tailscale", "set", "--ssh="', content)

        # Health warnings such as firewall blocking should be detected
        self.assertIn("healthList.find", content, "Tailscale parseStatus should check healthList for blockers")

    def test_generate_colors_material_no_premature_exit(self):
        gen_path = os.path.join(ROOT_DIR, "dots/.config/quickshell/ii/scripts/colors/generate_colors_material.py")
        self.assertTrue(os.path.isfile(gen_path), f"File not found: {gen_path}")

        with open(gen_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Should never sys.exit(75) which breaks SCSS color generation
        self.assertNotIn("sys.exit(75)", content, "generate_colors_material.py must not abort with sys.exit(75)")

    def test_mode_toggles_symmetrical_light_dark_wallpaper_guard(self):
        files_to_check = [
            "dots/.config/quickshell/ii/modules/settings/configs/colors/ColorsModeToggle.qml",
            "dots/.config/quickshell/ii/modules/common/models/quickToggles/DarkModeToggle.qml",
            "dots/.config/quickshell/ii/services/MaterialThemeLoader.qml",
            "dots/.config/quickshell/ii/modules/common/widgets/ConfigLightDarkToggle.qml",
            "dots/.config/quickshell/ii/services/DarkModeService.qml",
            "dots/.config/quickshell/ii/modules/welcome/WelcomeLightDarkToggle.qml",
        ]

        for rel_path in files_to_check:
            abs_path = os.path.join(ROOT_DIR, rel_path)
            self.assertTrue(os.path.isfile(abs_path), f"File not found: {abs_path}")
            with open(abs_path, "r", encoding="utf-8") as f:
                content = f.read()

            # Must verify that lightModeWallpaperPath is valid before branching into wallpaper swapping
            self.assertIn("hasSeparateLightWall", content, f"{rel_path} must guard on hasSeparateLightWall")


if __name__ == "__main__":
    unittest.main()
