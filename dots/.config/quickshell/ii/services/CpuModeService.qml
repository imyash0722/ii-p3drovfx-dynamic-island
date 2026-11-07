pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.services

Singleton {
    id: root

    readonly property string statePath: "/etc/cpumode_current"
    property string currentMode: "smart-battery"

    // 0 = powersave (left), 1 = smart-battery (center), 2 = coding (right)
    readonly property int currentIndex: {
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
        if (idx === 0) {
            setMode("powersave");
        } else if (idx === 2) {
            setMode("coding");
        } else {
            setMode("smart-battery");
        }
    }

    function setMode(mode) {
        Quickshell.execDetached(["/usr/local/bin/cpumode", mode]);
        root.currentMode = mode;
    }

    function cycle() {
        if (currentIndex === 1) setIndex(2);
        else if (currentIndex === 2) setIndex(0);
        else setIndex(1);
    }

    function toggle() {
        Quickshell.execDetached(["/usr/local/bin/cpumode", "toggle"]);
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
        running: true
        onTriggered: stateFile.reload()
    }

    Component.onCompleted: {
        stateFile.reload();
    }
}
