pragma ComponentBehavior: Bound
import QtQml
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import "../"

NestableObject {
    id: root
    property var monitors: []
    property var profiles: []
    readonly property int activeMonitorCount: monitors ? monitors.filter(m => m && !m.disabled).length : 0

    Component.onCompleted: {
        Qt.callLater(() => {
            fetchProc.running = true;
            reloadProfiles();
        });
    }

    function reloadProfiles() {
        profilesProc.running = true;
    }

    function updateMonitor(index, changes) {
        if (changes && changes.disabled === true) {
            const activeCount = root.monitors.filter(m => m && !m.disabled).length;
            if (root.monitors[index] && !root.monitors[index].disabled && activeCount <= 1) {
                console.warn("[MonitorConfigOption] Blocked attempt to disable the only active monitor");
                return;
            }
        }
        let m = root.monitors.slice();
        m[index] = Object.assign({}, m[index], changes);
        root.monitors = m;
    }

    function setPrimaryMonitor(index) {
        if (!root.monitors || index < 0 || index >= root.monitors.length)
            return;
        let m = root.monitors.slice().map((mon, i) => {
            let copy = Object.assign({}, mon);
            copy.isPrimary = (i === index);
            return copy;
        });
        root.monitors = m;
        root.save();
    }

    Timer {
        id: debounceSaveTimer
        interval: 150
        repeat: false
        onTriggered: {
            root.doSave();
        }
    }

    function save() {
        debounceSaveTimer.restart();
    }

    function doSave() {
        if (saveProc.running) {
            // If the process is still running, try again shortly
            debounceSaveTimer.start();
            return;
        }

        if (root.monitors.length === 0)
            return;
        if (root.monitors.some(m => !m.name))
            return;

        const activeCount = root.monitors.filter(m => m && !m.disabled).length;
        if (activeCount === 0) {
            console.warn("[MonitorConfigOption] Blocked saving profile with no active monitors");
            return;
        }

        // The phone as a monitor is not hyprmon's: its output lives only while the phone
        // streams. Changes to it go to PhoneScreenService, which applies them live.
        const phone = root.monitors.find(m => m && m.name === PhoneScreenService.headlessName);
        if (phone)
            PhoneScreenService.adjust(phone);

        const jsonStr = buildProfileJson("__quickshell_live__");

        saveProc.command = ["python3", Quickshell.shellPath("scripts/hyprland/monitor_manager.py"), "--profile-json", jsonStr, "--apply"];
        saveProc.running = true;
    }

    function applyMonitor(m) {
        root.save();
    }

    function applyAndSave(index) {
        root.save();
    }

    function logicalWidth(m) {
        const scale = (m && m.scale) ? m.scale : 1;
        const w = (m.transform === 1 || m.transform === 3) ? m.height : m.width;
        return Math.round(w / scale);
    }

    function logicalHeight(m) {
        const scale = (m && m.scale) ? m.scale : 1;
        const h = (m.transform === 1 || m.transform === 3) ? m.width : m.height;
        return Math.round(h / scale);
    }

    function applyProfile(name) {
        applyProfileProc.command = ["python3", Quickshell.shellPath("scripts/hyprland/monitor_manager.py"), "--apply-profile", name];
        applyProfileProc.running = true;
    }

    function deleteProfile(name) {
        deleteProfileProc.command = ["bash", "-c", "rm -f ~/.config/hyprmon/profiles/\"$1\".json", "--", name];
        deleteProfileProc.running = true;
    }

    function saveProfile(name) {
        if (!name)
            return;
        const jsonStr = buildProfileJson(name);
        saveProfileProc.command = ["python3", Quickshell.shellPath("scripts/hyprland/monitor_manager.py"), "--profile-json", jsonStr, "--save-profile", name];
        saveProfileProc.running = true;
    }

    Process {
        id: fetchProc
        command: ["bash", "-c", "hyprctl monitors all -j && printf '\\n---SPLIT---\\n' && cat ~/.config/hypr/monitors.json 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parts = text.split("\n---SPLIT---\n");
                    const monitorsRaw = JSON.parse(parts[0]);
                    let savedPrimaryName = "";
                    if (parts.length > 1 && parts[1].trim().length > 0) {
                        try {
                            const savedData = JSON.parse(parts[1].trim());
                            const wsList = savedData.workspaces || [];
                            if (wsList.length > 0 && wsList[0].monitors) {
                                for (const [k, v] of Object.entries(wsList[0].monitors)) {
                                    if (v && v.is_primary) {
                                        savedPrimaryName = k;
                                        break;
                                    }
                                }
                            }
                        } catch (e2) {}
                    }
                    const curPrimary = (root.monitors || []).find(m => m && m.isPrimary)?.name;
                    const primaryName = curPrimary || savedPrimaryName;

                    root.monitors = monitorsRaw.map((m, idx) => {
                        // A custom mode (a headless output's, like the phone as a monitor)
                        // is not among the modes the output lists: offer it too.
                        const current = `${m.width}x${m.height}@${m.refreshRate.toFixed(2)}Hz`;
                        const modes = m.availableModes ?? [];
                        const isPrim = primaryName ? (m.name === primaryName || (m.description && primaryName.indexOf(m.description) !== -1)) : (idx === 0);
                        return {
                                name: m.name,
                                description: m.description,
                                width: m.width,
                                height: m.height,
                                refreshRate: m.refreshRate,
                                x: m.x,
                                y: m.y,
                                scale: m.scale,
                                transform: (m.transform !== undefined && m.transform !== null) ? m.transform : 0,
                                disabled: m.disabled,
                                isPrimary: isPrim,
                                availableModes: modes.includes(current) ? modes : [current].concat(modes),
                                currentMode: current,
                                mirrorOf: m.mirrorOf || "none",
                                bitDepth: (m.currentFormat && m.currentFormat.indexOf("2101010") !== -1) ? 10 : 8,
                                colorManagementPreset: m.colorManagementPreset || "srgb",
                                sdrBrightness: m.sdrBrightness !== undefined ? m.sdrBrightness : 1.0,
                                sdrSaturation: m.sdrSaturation !== undefined ? m.sdrSaturation : 1.0,
                                vrr: m.vrr ? 1 : 0
                            };
                    });
                } catch (e) {
                    console.log("[MonitorConfigOption] Error:", e);
                }
            }
        }
    }

    Process {
        id: applyProc
    }
    Process {
        id: saveProc
        onRunningChanged: if (!running) {
            delayFetchTimer.restart();
        }
    }
    Process {
        id: reloadProc
        command: ["hyprctl", "reload"]
    }

    Process {
        id: profilesProc
        command: ["python3", Quickshell.shellPath("scripts/hyprland/monitor_manager.py"), "--list-profiles"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let lines = text.trim().split("\n").filter(l => l.length > 0);
                    let plist = lines.map(line => {
                        let isA = line.endsWith(" *");
                        let name = isA ? line.substring(0, line.length - 2) : line;
                        return {
                            name: name,
                            isActive: isA
                        };
                    }).filter(p => p.name !== "__quickshell_live__");
                    root.profiles = plist;
                } catch (e) {
                    console.log("[MonitorConfigOption] Error profiles:", e);
                }
            }
        }
    }

    Timer {
        id: delayFetchTimer
        interval: 500
        repeat: false
        onTriggered: {
            fetchProc.running = true;
            reloadProfiles();
        }
    }

    Process {
        id: applyProfileProc
        onRunningChanged: if (!running) {
            delayFetchTimer.restart();
        }
    }

    Process {
        id: deleteProfileProc
        onRunningChanged: if (!running) {
            reloadProfiles();
        }
    }

    function reloadFromHyprland() {
        Quickshell.execDetached(["hyprctl", "reload"]);
        // delay fetching so hyprctl reload has time to apply
        delayFetchTimer.restart();
    }

    function buildProfileJson(name) {
        const profile = {
            name: name,
            monitors: root.monitors.filter(m => m.name !== PhoneScreenService.headlessName).map(m => {
                return {
                    name: m.name,
                    make: "",
                    model: m.description || "",
                    PxW: m.width,
                    PxH: m.height,
                    Hz: m.refreshRate,
                    Scale: m.scale,
                    X: m.x,
                    Y: m.y,
                    Active: !m.disabled,
                    IsPrimary: m.isPrimary === true,
                    BitDepth: m.bitDepth || 8,
                    ColorMode: m.colorManagementPreset || "srgb",
                    SDRBrightness: m.sdrBrightness !== undefined ? m.sdrBrightness : 1.0,
                    SDRSaturation: m.sdrSaturation !== undefined ? m.sdrSaturation : 1.0,
                    VRR: m.vrr || 0,
                    Transform: m.transform || 0,
                    IsMirrored: m.mirrorOf && m.mirrorOf !== "none",
                    MirrorSource: m.mirrorOf && m.mirrorOf !== "none" ? m.mirrorOf : ""
                };
            }),
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
        };
        return JSON.stringify(profile, null, 2);
    }

    function saveToHyprland() {
        if (saveToHyprlandProc.running)
            return;
        debounceSaveTimer.stop();
        if (root.monitors.length === 0 || root.monitors.some(m => !m.name))
            return;

        const activeCount = root.monitors.filter(m => m && !m.disabled).length;
        if (activeCount === 0) {
            console.warn("[MonitorConfigOption] Blocked saving profile with no active monitors");
            return;
        }

        const liveJson = buildProfileJson("__quickshell_live__");
        const defaultJson = buildProfileJson("default");

        saveToHyprlandProc.command = ["bash", "-c", "python3 " + Quickshell.shellPath("scripts/hyprland/monitor_manager.py") + " --profile-json '" + defaultJson.replace(/'/g, "'\\''") + "' --save-profile default --apply && notify-send 'Monitors' 'Saved permanently to Hyprland!' -t 3000"];
        saveToHyprlandProc.running = true;
    }

    Process {
        id: saveToHyprlandProc
        onRunningChanged: if (!running) {
            reloadProfiles();
            delayFetchTimer.restart();
        }
    }

    Process {
        id: saveProfileProc
        onRunningChanged: if (!running) {
            reloadProfiles();
        }
    }
}
