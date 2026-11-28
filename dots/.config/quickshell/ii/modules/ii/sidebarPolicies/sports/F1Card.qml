import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Rectangle {
    id: root

    readonly property var latestSession: SportsTrackerService.f1LatestSession
    readonly property var nextRace: SportsTrackerService.f1NextRace
    readonly property var drivers: SportsTrackerService.f1DriverStandings || []
    readonly property var constructors: SportsTrackerService.f1ConstructorStandings || []

    readonly property string timingFont: "Fira Sans Condensed"
    readonly property string monoFont: Appearance.font.family.monospace

    color: Appearance.colors.colLayer1
    radius: Appearance.rounding.large
    border.width: 1
    border.color: Appearance.colors.colOutlineVariant
    implicitHeight: mainLayout.implicitHeight + 28

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // Header Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                color: Appearance.colors.colLayer2
                radius: Appearance.rounding.small
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                implicitWidth: f1BadgeText.implicitWidth + 16
                implicitHeight: 24

                StyledText {
                    id: f1BadgeText
                    anchors.centerIn: parent
                    text: "F1"
                    font.family: root.timingFont
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.ExtraBold
                    font.letterSpacing: 1.0
                    color: Appearance.colors.colOnSurface
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: root.nextRace ? root.nextRace.race_name.toUpperCase() : Translation.tr("FORMULA 1")
                font.family: root.timingFont
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Bold
                font.letterSpacing: 0.5
                color: Appearance.colors.colOnSurface
                elide: Text.ElideRight
            }

            // Countdown Pill
            Rectangle {
                visible: !!(root.nextRace && root.nextRace.countdown_text)
                color: Appearance.colors.colLayer2
                radius: Appearance.rounding.full
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                implicitWidth: cdRow.implicitWidth + 14
                implicitHeight: 24

                RowLayout {
                    id: cdRow
                    anchors.centerIn: parent
                    spacing: 5

                    MaterialSymbol {
                        text: "schedule"
                        iconSize: 14
                        color: Appearance.colors.colOnSurfaceVariant
                    }

                    StyledText {
                        text: root.nextRace ? root.nextRace.countdown_text : ""
                        font.family: root.timingFont
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: Font.Bold
                        color: Appearance.colors.colOnSurface
                    }
                }
            }
        }

        // 1. Latest Session Timing Tower
        Rectangle {
            visible: !!(root.latestSession && root.latestSession.results && root.latestSession.results.length > 0)
            Layout.fillWidth: true
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.normal
            implicitHeight: latestCol.implicitHeight + 24

            ColumnLayout {
                id: latestCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        text: root.latestSession ? (root.latestSession.session_name || "SESSION").toUpperCase() : ""
                        font.family: root.timingFont
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.Bold
                        font.letterSpacing: 0.6
                        color: Appearance.colors.colOnSurface
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: root.latestSession ? (root.latestSession.event_name || "") : ""
                        font.family: root.timingFont
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colOnSurfaceVariant
                        elide: Text.ElideRight
                    }
                }

                // Timing Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText { text: "POS"; font.family: root.timingFont; font.pixelSize: Appearance.font.pixelSize.smallest; font.weight: Font.Bold; color: Appearance.colors.colOnSurfaceVariant; Layout.preferredWidth: 24 }
                    Item { Layout.preferredWidth: 4 }
                    StyledText { text: "DRIVER"; font.family: root.timingFont; font.pixelSize: Appearance.font.pixelSize.smallest; font.weight: Font.Bold; color: Appearance.colors.colOnSurfaceVariant; Layout.preferredWidth: 46 }
                    StyledText { text: "TEAM"; font.family: root.timingFont; font.pixelSize: Appearance.font.pixelSize.smallest; font.weight: Font.Bold; color: Appearance.colors.colOnSurfaceVariant; Layout.fillWidth: true }
                    StyledText { text: "TIME / GAP"; font.family: root.timingFont; font.pixelSize: Appearance.font.pixelSize.smallest; font.weight: Font.Bold; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 78 }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Appearance.colors.colOutlineVariant
                    opacity: 0.5
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: root.latestSession && root.latestSession.results ? root.latestSession.results.slice(0, 8) : []
                        delegate: RowLayout {
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            spacing: 8

                            StyledText {
                                text: String(modelData.pos)
                                font.family: root.timingFont
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Bold
                                color: index === 0 ? Appearance.colors.colOnSurface : Appearance.colors.colOnSurfaceVariant
                                Layout.preferredWidth: 24
                            }

                            Rectangle {
                                Layout.preferredWidth: 4
                                Layout.preferredHeight: 16
                                radius: 2
                                color: modelData.color || "#888888"
                            }

                            StyledText {
                                text: (modelData.short || modelData.driver || "").toUpperCase()
                                font.family: root.timingFont
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.ExtraBold
                                font.letterSpacing: 0.8
                                color: Appearance.colors.colOnSurface
                                Layout.preferredWidth: 46
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.team || ""
                                font.family: root.timingFont
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnSurfaceVariant
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: modelData.gap || modelData.time || ""
                                font.family: root.monoFont
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: index === 0 ? Font.Bold : Font.Medium
                                color: index === 0 ? Appearance.colors.colOnSurface : Appearance.colors.colOnSurfaceVariant
                                horizontalAlignment: Text.AlignRight
                                Layout.preferredWidth: 78
                            }
                        }
                    }
                }
            }
        }

        // 2. Driver Standings Timing Tower
        Rectangle {
            visible: root.drivers.length > 0
            Layout.fillWidth: true
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.normal
            implicitHeight: driverCol.implicitHeight + 24

            ColumnLayout {
                id: driverCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        text: Translation.tr("DRIVER STANDINGS").toUpperCase()
                        font.family: root.timingFont
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.Bold
                        font.letterSpacing: 0.6
                        color: Appearance.colors.colOnSurface
                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: "PTS"
                        font.family: root.timingFont
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        font.weight: Font.Bold
                        color: Appearance.colors.colOnSurfaceVariant
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Appearance.colors.colOutlineVariant
                    opacity: 0.5
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: root.drivers.slice(0, 10)
                        delegate: RowLayout {
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            spacing: 8

                            StyledText {
                                text: String(modelData.pos)
                                font.family: root.timingFont
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Bold
                                color: index === 0 ? Appearance.colors.colOnSurface : Appearance.colors.colOnSurfaceVariant
                                Layout.preferredWidth: 24
                            }

                            Rectangle {
                                Layout.preferredWidth: 4
                                Layout.preferredHeight: 16
                                radius: 2
                                color: modelData.color || "#888888"
                            }

                            StyledText {
                                text: (modelData.short || modelData.driver || "").toUpperCase()
                                font.family: root.timingFont
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.ExtraBold
                                font.letterSpacing: 0.8
                                color: Appearance.colors.colOnSurface
                                Layout.preferredWidth: 46
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.constructor || ""
                                font.family: root.timingFont
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: Appearance.colors.colOnSurfaceVariant
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: modelData.points
                                font.family: root.monoFont
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Bold
                                color: Appearance.colors.colOnSurface
                                horizontalAlignment: Text.AlignRight
                                Layout.preferredWidth: 42
                            }
                        }
                    }
                }
            }
        }

        // 3. Constructor Standings
        Rectangle {
            visible: root.constructors.length > 0
            Layout.fillWidth: true
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.normal
            implicitHeight: teamCol.implicitHeight + 24

            ColumnLayout {
                id: teamCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        text: Translation.tr("CONSTRUCTORS").toUpperCase()
                        font.family: root.timingFont
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.Bold
                        font.letterSpacing: 0.6
                        color: Appearance.colors.colOnSurface
                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: "PTS"
                        font.family: root.timingFont
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        font.weight: Font.Bold
                        color: Appearance.colors.colOnSurfaceVariant
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Appearance.colors.colOutlineVariant
                    opacity: 0.5
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: root.constructors.slice(0, 5)
                        delegate: RowLayout {
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            spacing: 8

                            StyledText {
                                text: String(modelData.pos)
                                font.family: root.timingFont
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Bold
                                color: index === 0 ? Appearance.colors.colOnSurface : Appearance.colors.colOnSurfaceVariant
                                Layout.preferredWidth: 24
                            }

                            Rectangle {
                                Layout.preferredWidth: 4
                                Layout.preferredHeight: 16
                                radius: 2
                                color: modelData.color || "#888888"
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.team.toUpperCase()
                                font.family: root.timingFont
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Bold
                                font.letterSpacing: 0.4
                                color: Appearance.colors.colOnSurface
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: modelData.points
                                font.family: root.monoFont
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Bold
                                color: Appearance.colors.colOnSurface
                                horizontalAlignment: Text.AlignRight
                                Layout.preferredWidth: 42
                            }
                        }
                    }
                }
            }
        }

        // 4. Weekend Schedule
        Rectangle {
            visible: !!(root.nextRace && root.nextRace.sessions && root.nextRace.sessions.length > 0)
            Layout.fillWidth: true
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.normal
            implicitHeight: raceCol.implicitHeight + 24

            ColumnLayout {
                id: raceCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        text: root.nextRace ? root.nextRace.circuit.toUpperCase() : Translation.tr("SCHEDULE")
                        font.family: root.timingFont
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.Bold
                        font.letterSpacing: 0.5
                        color: Appearance.colors.colOnSurface
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: root.nextRace ? root.nextRace.location : ""
                        font.family: root.timingFont
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colOnSurfaceVariant
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Appearance.colors.colOutlineVariant
                    opacity: 0.5
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: root.nextRace ? root.nextRace.sessions : []
                        delegate: RowLayout {
                            required property var modelData
                            Layout.fillWidth: true

                            StyledText {
                                text: modelData.name.toUpperCase()
                                font.family: root.timingFont
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: modelData.is_past ? Font.Normal : Font.Bold
                                font.letterSpacing: 0.4
                                color: modelData.is_past ? Appearance.colors.colOnSurfaceVariant : Appearance.colors.colOnSurface
                                opacity: modelData.is_past ? 0.5 : 1.0
                                Layout.preferredWidth: 130
                            }

                            StyledText {
                                text: modelData.time_local
                                font.family: root.monoFont
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: modelData.is_past ? Appearance.colors.colOnSurfaceVariant : Appearance.colors.colOnSurface
                                opacity: modelData.is_past ? 0.5 : 0.9
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }
        }
    }
}
