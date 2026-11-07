import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Rectangle {
    id: root

    readonly property var nextRace: SportsService.f1NextRace
    readonly property var drivers: SportsService.f1DriverStandings || []
    readonly property var constructors: SportsService.f1ConstructorStandings || []

    color: Appearance.colors.colLayer1
    radius: Appearance.rounding.normal
    border.width: 1
    border.color: Appearance.colors.colOutlineVariant
    implicitHeight: mainLayout.implicitHeight + 24

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // Header Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                color: Appearance.colors.colLayer2
                radius: Appearance.rounding.small
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                implicitWidth: f1BadgeText.implicitWidth + 12
                implicitHeight: 22

                StyledText {
                    id: f1BadgeText
                    anchors.centerIn: parent
                    text: "FORMULA 1"
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colPrimary
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: root.nextRace ? root.nextRace.race_name : Translation.tr("Next Grand Prix")
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnSurfaceVariant
                elide: Text.ElideRight
            }

            // Countdown Pill
            Rectangle {
                visible: !!(root.nextRace && root.nextRace.countdown_text)
                color: Qt.rgba(Appearance.colors.colTertiary.r, Appearance.colors.colTertiary.g, Appearance.colors.colTertiary.b, 0.15)
                radius: Appearance.rounding.full
                border.width: 1
                border.color: Qt.rgba(Appearance.colors.colTertiary.r, Appearance.colors.colTertiary.g, Appearance.colors.colTertiary.b, 0.4)
                implicitWidth: cdText.implicitWidth + 12
                implicitHeight: 22

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    StyledText {
                        text: "⏱"
                        font.pixelSize: Appearance.font.pixelSize.smallest
                    }

                    StyledText {
                        id: cdText
                        text: root.nextRace ? root.nextRace.countdown_text : ""
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: Font.DemiBold
                        color: Appearance.colors.colTertiary
                    }
                }
            }
        }

        // Next Race & Circuit Details
        Rectangle {
            Layout.fillWidth: true
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.small
            implicitHeight: raceCol.implicitHeight + 16

            ColumnLayout {
                id: raceCol
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: "🏎️ " + (root.nextRace ? root.nextRace.circuit : "Circuit")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.Bold
                        color: Appearance.colors.colOnSurface
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    StyledText {
                        text: root.nextRace ? root.nextRace.location : ""
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colOnSurfaceVariant
                    }
                }

                // Sessions List (P1, P2, P3, Quali, Race)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3
                    visible: !!(root.nextRace && root.nextRace.sessions)

                    Repeater {
                        model: root.nextRace ? root.nextRace.sessions : []
                        delegate: RowLayout {
                            required property var modelData
                            Layout.fillWidth: true

                            StyledText {
                                text: modelData.name
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: modelData.is_past ? Font.Normal : Font.DemiBold
                                color: modelData.is_past ? Appearance.colors.colOutlineVariant : Appearance.colors.colOnSurface
                                Layout.preferredWidth: 100
                            }

                            StyledText {
                                text: modelData.time_local
                                font.pixelSize: Appearance.font.pixelSize.smallest
                                color: modelData.is_past ? Appearance.colors.colOutlineVariant : Appearance.colors.colTertiary
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }
        }

        // Driver Standings: Highlighting Hamilton & Piastri
        Rectangle {
            Layout.fillWidth: true
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.small
            implicitHeight: driverCol.implicitHeight + 16

            ColumnLayout {
                id: driverCol
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                StyledText {
                    text: Translation.tr("Driver Championship")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnSurfaceVariant
                }

                // Favorite Drivers Highlights (Hamilton & Piastri)
                Repeater {
                    model: root.drivers.filter(d => d.is_favorite)
                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        color: Qt.rgba(modelData.color === "#E80020" ? 0.9 : 1.0, modelData.color === "#E80020" ? 0.1 : 0.5, 0.0, 0.12)
                        radius: 6
                        border.width: 1
                        border.color: modelData.color || Appearance.colors.colOutlineVariant
                        implicitHeight: 28

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            Rectangle {
                                width: 4
                                height: 16
                                radius: 2
                                color: modelData.color || Appearance.colors.colPrimary
                            }

                            StyledText {
                                text: "P" + modelData.pos
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Bold
                                color: Appearance.colors.colOnSurface
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.driver + " (" + modelData.constructor + ")"
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Bold
                                color: Appearance.colors.colOnSurface
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: modelData.points + " pts"
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Bold
                                color: modelData.color || Appearance.colors.colPrimary
                            }
                        }
                    }
                }

                // Top 3 Leaderboard context
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Repeater {
                        model: root.drivers.slice(0, 3)
                        delegate: RowLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 6

                            StyledText {
                                text: "P" + modelData.pos
                                font.pixelSize: Appearance.font.pixelSize.smallest
                                font.weight: Font.DemiBold
                                color: Appearance.colors.colOnSurfaceVariant
                                Layout.preferredWidth: 24
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.driver
                                font.pixelSize: Appearance.font.pixelSize.smallest
                                color: modelData.is_favorite ? Appearance.colors.colPrimary : Appearance.colors.colOnSurface
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: modelData.points + " pts"
                                font.pixelSize: Appearance.font.pixelSize.smallest
                                color: Appearance.colors.colOnSurfaceVariant
                            }
                        }
                    }
                }
            }
        }

        // Constructor Standings (Ferrari & McLaren focus)
        Rectangle {
            Layout.fillWidth: true
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.small
            implicitHeight: teamCol.implicitHeight + 14

            ColumnLayout {
                id: teamCol
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                StyledText {
                    text: Translation.tr("Constructors")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnSurfaceVariant
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: root.constructors.slice(0, 4)
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            color: modelData.is_favorite ? Qt.rgba(Appearance.colors.colPrimary.r, Appearance.colors.colPrimary.g, Appearance.colors.colPrimary.b, 0.12) : "transparent"
                            radius: 4
                            implicitHeight: 22

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                StyledText {
                                    text: "P" + modelData.pos
                                    font.pixelSize: Appearance.font.pixelSize.smallest
                                    font.weight: Font.Bold
                                    color: modelData.is_favorite ? (modelData.color || Appearance.colors.colPrimary) : Appearance.colors.colOnSurfaceVariant
                                }

                                StyledText {
                                    text: modelData.team
                                    font.pixelSize: Appearance.font.pixelSize.smallest
                                    font.weight: modelData.is_favorite ? Font.Bold : Font.Normal
                                    color: modelData.is_favorite ? (modelData.color || Appearance.colors.colPrimary) : Appearance.colors.colOnSurface
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    text: modelData.points
                                    font.pixelSize: Appearance.font.pixelSize.smallest
                                    color: Appearance.colors.colOnSurfaceVariant
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
