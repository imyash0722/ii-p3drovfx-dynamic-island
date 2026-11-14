import QtQuick
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: Translation.tr("Dark Mode")
    statusText: Appearance.m3colors.darkmode ? Translation.tr("Dark") : Translation.tr("Light")

    toggled: Appearance.m3colors.darkmode
    icon: "contrast"
    hasMenu: true
    
    mainAction: () => {
        const background = Config.options?.background;
        const hasSeparateLightWall = background?.useSeparateLightModeWallpaper
            && background.lightModeWallpaperPath
            && background.lightModeWallpaperPath !== "";
        if (hasSeparateLightWall) {
            if (Appearance.m3colors.darkmode) {
                // Switching to light mode
                Wallpapers.applyLightModeWallpaper(background.lightModeWallpaperPath);
                return;
            } else {
                // Switching to dark mode
                const darkPath = background.wallpaperPath;
                if (darkPath && darkPath !== "") {
                    Wallpapers.apply(darkPath, true);
                    return;
                }
            }
        }
        if (Appearance.m3colors.darkmode) {
            Quickshell.execDetached([Directories.wallpaperSwitchScriptPath, "--mode", "light", "--noswitch"]);
        } else {
            Quickshell.execDetached([Directories.wallpaperSwitchScriptPath, "--mode", "dark", "--noswitch"]);
        }
    }

    tooltipText: Translation.tr("Dark Mode")
}
