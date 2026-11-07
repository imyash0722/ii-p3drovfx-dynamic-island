pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.modules.common
import qs.services

Singleton {
    id: root

    readonly property string dataPath: Quickshell.env("HOME") + "/.local/state/quickshell/sports/sports_data.json"
    readonly property string scriptPath: Quickshell.env("HOME") + "/.config/quickshell/ii/scripts/sports/sports_fetcher.py"

    property bool ready: false
    property bool isRefreshing: false
    property string lastUpdated: ""
    property bool isLiveActive: false

    property var cricketMatches: []
    property var tennisFavorites: []
    property var tennisRankings: []
    property var tennisMatches: []
    property var f1NextRace: null
    property var f1DriverStandings: []
    property var f1ConstructorStandings: []

    function refresh() {
        if (root.isRefreshing) return;
        root.isRefreshing = true;
        refreshProcess.running = true;
    }

    Process {
        id: refreshProcess
        command: ["python3", root.scriptPath, "--once"]
        running: false
        onExited: {
            root.isRefreshing = false;
            dataFile.reload();
        }
    }

    FileView {
        id: dataFile
        path: root.dataPath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const raw = text().trim();
            if (!raw || raw.length === 0) return;
            try {
                const data = JSON.parse(raw);
                root.lastUpdated = data.updated_at || "";
                root.isLiveActive = !!data.is_live_active;

                if (data.cricket && Array.isArray(data.cricket.matches)) {
                    root.cricketMatches = data.cricket.matches;
                }
                if (data.tennis) {
                    root.tennisFavorites = data.tennis.favorites || [];
                    root.tennisRankings = data.tennis.top_rankings || [];
                    root.tennisMatches = data.tennis.matches || [];
                }
                if (data.f1) {
                    root.f1NextRace = data.f1.next_race || null;
                    root.f1DriverStandings = data.f1.driver_standings || [];
                    root.f1ConstructorStandings = data.f1.constructor_standings || [];
                }
                root.ready = true;
            } catch (e) {
                console.warn("[SportsTrackerService] JSON parse error:", e);
            }
        }
    }

    // Adaptive auto-poll timer:
    // Only runs active background polling if the Left Sidebar is open or a live event is on
    Timer {
        id: autoPollTimer
        interval: {
            if (GlobalStates.policiesPanelOpen && root.isLiveActive) return 35000; // 35s live
            if (GlobalStates.policiesPanelOpen) return 300000; // 5 mins if sidebar open but idle
            return 900000; // 15 mins when sidebar closed
        }
        repeat: true
        running: true
        onTriggered: {
            if (GlobalStates.policiesPanelOpen || root.isLiveActive) {
                root.refresh();
            } else {
                dataFile.reload();
            }
        }
    }

    // When the user opens the left sidebar, ensure fresh data if data is not yet ready
    Connections {
        target: GlobalStates
        function onPoliciesPanelOpenChanged() {
            if (GlobalStates.policiesPanelOpen) {
                dataFile.reload();
                if (!root.ready) {
                    root.refresh();
                }
            }
        }
    }

    Component.onCompleted: {
        dataFile.reload();
        if (!root.ready) {
            root.refresh();
        }
    }
}
