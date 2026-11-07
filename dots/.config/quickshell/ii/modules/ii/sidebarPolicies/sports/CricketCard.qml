import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Rectangle {
    id: root

    required property var matchData

    readonly property bool isLive: matchData && matchData.is_live
    readonly property var team1: matchData ? matchData.team1 : null
    readonly property var team2: matchData ? matchData.team2 : null

    color: Appearance.colors.colLayer1
    radius: Appearance.rounding.normal
    border.width: 1
    border.color: isLive ? Qt.rgba(Appearance.colors.colPrimary.r, Appearance.colors.colPrimary.g, Appearance.colors.colPrimary.b, 0.4) : Appearance.colors.colOutlineVariant
    implicitHeight: mainLayout.implicitHeight + 24

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // Header Row: Format, League & Status
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Format Badge (ODI, Test, T20)
            Rectangle {
                color: Appearance.colors.colLayer2
                radius: Appearance.rounding.small
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                implicitWidth: formatText.implicitWidth + 12
                implicitHeight: 22

                StyledText {
                    id: formatText
                    anchors.centerIn: parent
                    text: root.matchData ? (root.matchData.format || "MATCH") : ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colPrimary
                }
            }

            // League / Title
            StyledText {
                Layout.fillWidth: true
                text: root.matchData ? (root.matchData.title || root.matchData.league || "Cricket Match") : ""
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnSurfaceVariant
                elide: Text.ElideRight
            }

            // Live Pulse Pill or Status Chip
            Rectangle {
                visible: root.isLive
                color: Qt.rgba(0.9, 0.2, 0.2, 0.15)
                radius: Appearance.rounding.full
                border.width: 1
                border.color: Qt.rgba(0.9, 0.2, 0.2, 0.5)
                implicitWidth: liveRow.implicitWidth + 10
                implicitHeight: 20

                RowLayout {
                    id: liveRow
                    anchors.centerIn: parent
                    spacing: 4

                    Rectangle {
                        id: liveDot
                        width: 6
                        height: 6
                        radius: 3
                        color: "#E53935"

                        SequentialAnimation on opacity {
                            running: root.isLive
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 0.2; duration: 800; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 0.2; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                        }
                    }

                    StyledText {
                        text: Translation.tr("LIVE")
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        font.weight: Font.Bold
                        color: "#E53935"
                    }
                }
            }

            // Status chip for non-live
            Rectangle {
                visible: !root.isLive && root.matchData && root.matchData.status_desc
                color: Appearance.colors.colLayer2
                radius: Appearance.rounding.full
                implicitWidth: statusText.implicitWidth + 10
                implicitHeight: 18

                StyledText {
                    id: statusText
                    anchors.centerIn: parent
                    text: root.matchData ? root.matchData.status_desc : ""
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }
        }

        // Teams & Scores Area
        Rectangle {
            Layout.fillWidth: true
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.small
            implicitHeight: teamsLayout.implicitHeight + 16

            ColumnLayout {
                id: teamsLayout
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                // Team 1 Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        text: "🏏"
                        font.pixelSize: Appearance.font.pixelSize.small
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: root.team1 ? root.team1.name : "Team 1"
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: root.team1 && root.team1.is_favorite ? Font.Bold : Font.Normal
                        color: root.team1 && root.team1.is_favorite ? Appearance.colors.colPrimary : Appearance.colors.colOnSurface
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: root.team1 && root.team1.score ? root.team1.score : (root.isLive ? "-" : "")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.DemiBold
                        color: Appearance.colors.colOnSurface
                    }
                }

                // Team 2 Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        text: "🏏"
                        font.pixelSize: Appearance.font.pixelSize.small
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: root.team2 ? root.team2.name : "Team 2"
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: root.team2 && root.team2.is_favorite ? Font.Bold : Font.Normal
                        color: root.team2 && root.team2.is_favorite ? Appearance.colors.colPrimary : Appearance.colors.colOnSurface
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: root.team2 && root.team2.score ? root.team2.score : (root.isLive ? "-" : "")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.DemiBold
                        color: Appearance.colors.colOnSurface
                    }
                }
            }
        }

        // Summary / Session / Toss footer
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            visible: !!(root.matchData && (root.matchData.summary || root.matchData.session_text || root.matchData.toss || root.matchData.time_local))

            StyledText {
                visible: !!(root.matchData && root.matchData.summary)
                Layout.fillWidth: true
                text: root.matchData ? root.matchData.summary : ""
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.weight: Font.DemiBold
                color: Appearance.colors.colTertiary
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                StyledText {
                    visible: !!(root.matchData && root.matchData.session_text)
                    text: root.matchData ? root.matchData.session_text : ""
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    color: Appearance.colors.colOnSurfaceVariant
                }

                StyledText {
                    visible: !!(root.matchData && root.matchData.venue)
                    Layout.fillWidth: true
                    text: "• " + (root.matchData ? root.matchData.venue : "")
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    color: Appearance.colors.colOnSurfaceVariant
                    elide: Text.ElideRight
                }

                StyledText {
                    visible: !root.isLive && !!(root.matchData && root.matchData.time_local)
                    text: root.matchData ? root.matchData.time_local : ""
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }
        }
    }
}
