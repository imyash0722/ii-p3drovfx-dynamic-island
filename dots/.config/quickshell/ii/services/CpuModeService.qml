pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.modules.common
import qs.services

Singleton {
    id: root

    readonly property string statePath: "/etc/cpumode_current"
    property string currentMode: "smart-battery"
    property bool hasCpuMode: false

    // Step 0: Check if /usr/local/bin/cpumode or state file exists
    Process {
        id: checkCpuModeProc
        command: ["bash", "-c", "test -x /usr/local/bin/cpumode || test -f /etc/cpumode_current"]
        onExited: exitCode => {
            root.hasCpuMode = (exitCode === 0);
            if (root.hasCpuMode) {
                stateFile.reload();
            }
        }
    }

    // 0 = powersave (left), 1 = smart-battery / balanced (center), 2 = coding / performance (right)
    readonly property int currentIndex: {
        if (!hasCpuMode) {
            if (PowerProfiles.profile === PowerProfile.PowerSaver) return 0;
            if (PowerProfiles.profile === PowerProfile.Performance) return 2;
            return 1;
        }
        if (currentMode === "powersave" || currentMode === "power" || currentMode === "saver" || currentMode === "power-saver") return 0;
        if (currentMode === "coding" || currentMode === "perf" || currentMode === "performance") return 2;
        return 1;
    }

    readonly property string icon: {
        if (currentIndex === 0) return "energy_savings_leaf";
        if (currentIndex === 2) return "local_fire_department";
        return "airwave";
    }

    readonly property string statusText: {
        if (!hasCpuMode) {
            if (currentIndex === 0) return Translation.tr("Power Saver");
            if (currentIndex === 2) return Translation.tr("Performance");
            return Translation.tr("Balanced");
        }
        if (currentIndex === 0) return Translation.tr("Power Saver");
        if (currentIndex === 2) return Translation.tr("Coding Mode");
        return Translation.tr("Smart Battery");
    }

    readonly property string profileName: {
        if (currentIndex === 0) return "saver";
        if (currentIndex === 2) return "performance";
        return "balanced";
    }

    readonly property bool isCustomActive: currentIndex !== 1

    function setIndex(idx) {
        if (hasCpuMode) {
            if (idx === 0) {
                setMode("powersave");
            } else if (idx === 2) {
                setMode("coding");
            } else {
                setMode("smart-battery");
            }
        } else {
            if (idx === 0) PowerProfiles.profile = PowerProfile.PowerSaver;
            else if (idx === 2) PowerProfiles.profile = PowerProfile.Performance;
            else PowerProfiles.profile = PowerProfile.Balanced;
        }
    }

    function setMode(mode) {
        if (hasCpuMode) {
            Quickshell.execDetached(["/usr/local/bin/cpumode", mode]);
            root.currentMode = mode;
        }
    }

    function cycle() {
        if (currentIndex === 1) setIndex(2);
        else if (currentIndex === 2) setIndex(0);
        else setIndex(1);
    }

    function toggle() {
        if (hasCpuMode) {
            Quickshell.execDetached(["/usr/local/bin/cpumode", "toggle"]);
        } else {
            cycle();
        }
    }

    FileView {
        id: stateFile
        path: root.statePath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const val = text().trim();
            if (val.length > 0) {
                root.currentMode = val;
            }
        }
    }

    Timer {
        id: pollTimer
        interval: 3000
        repeat: true
        running: root.hasCpuMode
        onTriggered: stateFile.reload()
    }

    // Auto-switch to the highest profile (coding) while on AC power (opt-in via Config), and
    // restore the previous mode when unplugged.
    readonly property bool autoCodingOnAc: Config.options?.battery?.autoCodingOnAc ?? false
    property string modeBeforeAc: ""
    readonly property bool onAcPower: Battery.available && Battery.onAc

    function applyPowerSource(initial) {
        if (!root.autoCodingOnAc)
            return;
        if (root.onAcPower) {
            if (root.currentIndex !== 2) {
                if (!initial) root.modeBeforeAc = root.currentMode;
                root.setMode("coding");
            }
        } else if (root.modeBeforeAc.length > 0) {
            root.setMode(root.modeBeforeAc);
            root.modeBeforeAc = "";
        }
    }

    onOnAcPowerChanged: applyPowerSource(false)

    Timer {
        id: startupApply
        interval: 3000
        running: true
        onTriggered: root.applyPowerSource(true)
    }

    Component.onCompleted: {
        checkCpuModeProc.running = true;
        stateFile.reload();
    }
}
