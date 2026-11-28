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

    color: cardMouse.containsMouse ? Appearance.colors.colLayer2 : Appearance.colors.colLayer1
    radius: Appearance.rounding.large
    border.width: 1
    border.color: cardMouse.containsMouse ? Appearance.colors.colOutline : Appearance.colors.colOutlineVariant
    implicitHeight: mainLayout.implicitHeight + 28

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: SportsTrackerService.openCricketScorecard(root.matchData)
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // Header Row: Format, League & Status
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                color: Appearance.colors.colLayer2
                radius: Appearance.rounding.small
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                implicitWidth: formatText.implicitWidth + 14
                implicitHeight: 24

                StyledText {
                    id: formatText
                    anchors.centerIn: parent
                    text: root.matchData ? (root.matchData.format || "MATCH") : ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnSurface
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: root.matchData ? (root.matchData.title || root.matchData.league || Translation.tr("Cricket Match")) : ""
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                color: Appearance.colors.colOnSurfaceVariant
                elide: Text.ElideRight
            }

            // Live indicator
            Rectangle {
                visible: root.isLive
                color: Appearance.colors.colLayer2
                radius: Appearance.rounding.full
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                implicitWidth: liveRow.implicitWidth + 14
                implicitHeight: 22

                RowLayout {
                    id: liveRow
                    anchors.centerIn: parent
                    spacing: 5

                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: "#E53935"

                        SequentialAnimation on opacity {
                            running: root.isLive
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 0.25; duration: 800; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 0.25; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                        }
                    }

                    StyledText {
                        text: Translation.tr("LIVE")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: Font.Bold
                        color: Appearance.colors.colOnSurface
                    }
                }
            }

            // Status chip for non-live
            Rectangle {
                visible: !root.isLive && !!(root.matchData && root.matchData.status_desc)
                color: Appearance.colors.colLayer2
                radius: Appearance.rounding.full
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                implicitWidth: statusText.implicitWidth + 14
                implicitHeight: 22

                StyledText {
                    id: statusText
                    anchors.centerIn: parent
                    text: root.matchData ? root.matchData.status_desc : ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }
        }

        // Teams & Scores Area
        Rectangle {
            Layout.fillWidth: true
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.normal
            implicitHeight: teamsLayout.implicitHeight + 24

            ColumnLayout {
                id: teamsLayout
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // Team 1 Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: root.team1 ? root.team1.name : "Team 1"
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: root.team1 && root.team1.is_favorite ? Font.DemiBold : Font.Normal
                        color: Appearance.colors.colOnSurface
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: root.team1 && root.team1.score ? root.team1.score : (root.isLive ? "-" : "")
                        font.pixelSize: Appearance.font.pixelSize.large
                        font.weight: Font.Bold
                        color: Appearance.colors.colOnSurface
                    }
                }

                // Team 2 Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: root.team2 ? root.team2.name : "Team 2"
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: root.team2 && root.team2.is_favorite ? Font.DemiBold : Font.Normal
                        color: Appearance.colors.colOnSurface
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: root.team2 && root.team2.score ? root.team2.score : (root.isLive ? "-" : "")
                        font.pixelSize: Appearance.font.pixelSize.large
                        font.weight: Font.Bold
                        color: Appearance.colors.colOnSurface
                    }
                }
            }
        }

        // Summary / Session / Venue footer
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            StyledText {
                visible: !!(root.matchData && root.matchData.summary)
                Layout.fillWidth: true
                text: root.matchData ? root.matchData.summary : ""
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                color: Appearance.colors.colOnSurface
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                StyledText {
                    visible: !!(root.matchData && root.matchData.session_text)
                    text: root.matchData ? root.matchData.session_text : ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSurfaceVariant
                }

                StyledText {
                    visible: !!(root.matchData && root.matchData.venue)
                    Layout.fillWidth: true
                    text: (root.matchData && root.matchData.session_text ? "· " : "") + (root.matchData ? root.matchData.venue : "")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSurfaceVariant
                    elide: Text.ElideRight
                }

                StyledText {
                    visible: !root.isLive && !!(root.matchData && root.matchData.time_local)
                    text: root.matchData ? root.matchData.time_local : ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSurfaceVariant
                }

                MaterialSymbol {
                    text: "chevron_right"
                    iconSize: 16
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }
        }
    }
}
