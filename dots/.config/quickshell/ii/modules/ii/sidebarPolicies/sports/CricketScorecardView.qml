pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

ColumnLayout {
    id: root

    readonly property var matchData: SportsTrackerService.selectedCricketMatch
    readonly property var scorecard: SportsTrackerService.cricketScorecard
    readonly property var innings: (scorecard && scorecard.innings) ? scorecard.innings : []
    readonly property bool isLive: !!(matchData && matchData.is_live)

    spacing: 12

    // Back Header
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        RippleButton {
            implicitWidth: backRow.implicitWidth + 20
            implicitHeight: 34
            buttonRadius: Appearance.rounding.full
            colBackground: Appearance.colors.colLayer1
            colBackgroundHover: Appearance.colors.colLayer2
            borderWidth: 1
            borderColor: Appearance.colors.colOutlineVariant
            onPressed: SportsTrackerService.closeCricketScorecard()

            RowLayout {
                id: backRow
                anchors.centerIn: parent
                spacing: 6

                MaterialSymbol {
                    text: "arrow_back"
                    iconSize: 18
                    color: Appearance.colors.colOnSurface
                }

                StyledText {
                    text: Translation.tr("Back")
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnSurface
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            StyledText {
                Layout.fillWidth: true
                text: root.matchData ? (root.matchData.short_name || root.matchData.title || Translation.tr("Scorecard")) : Translation.tr("Scorecard")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Bold
                color: Appearance.colors.colOnSurface
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: root.matchData ? (root.matchData.league || "") : ""
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnSurfaceVariant
                elide: Text.ElideRight
            }
        }

        RippleButton {
            implicitWidth: 34
            implicitHeight: 34
            buttonRadius: Appearance.rounding.full
            colBackground: Appearance.colors.colLayer1
            colBackgroundHover: Appearance.colors.colLayer2
            borderWidth: 1
            borderColor: Appearance.colors.colOutlineVariant
            onPressed: SportsTrackerService.openCricketScorecard(root.matchData)

            MaterialSymbol {
                anchors.centerIn: parent
                text: "refresh"
                iconSize: 18
                color: Appearance.colors.colOnSurfaceVariant

                RotationAnimation on rotation {
                    running: SportsTrackerService.isLoadingScorecard
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 900
                }
            }
        }
    }

    // Scrollable Scorecard Body
    Flickable {
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentHeight: bodyCol.implicitHeight + 16
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        ColumnLayout {
            id: bodyCol
            width: parent.width
            spacing: 12

            // Match Overview Card
            Rectangle {
                Layout.fillWidth: true
                color: Appearance.colors.colLayer1
                radius: Appearance.rounding.large
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                implicitHeight: summaryCol.implicitHeight + 28

                ColumnLayout {
                    id: summaryCol
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        StyledText {
                            Layout.fillWidth: true
                            text: root.matchData ? (root.matchData.title || "") : ""
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.DemiBold
                            color: Appearance.colors.colOnSurfaceVariant
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: root.matchData ? (root.matchData.status_desc || "") : ""
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnSurfaceVariant
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        color: Appearance.colors.colLayer2
                        radius: Appearance.rounding.normal
                        implicitHeight: scoreCol.implicitHeight + 20

                        ColumnLayout {
                            id: scoreCol
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                StyledText {
                                    Layout.fillWidth: true
                                    text: root.matchData && root.matchData.team1 ? root.matchData.team1.name : ""
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: Font.DemiBold
                                    color: Appearance.colors.colOnSurface
                                }
                                StyledText {
                                    text: root.matchData && root.matchData.team1 ? (root.matchData.team1.score || "-") : "-"
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: Font.Bold
                                    color: Appearance.colors.colOnSurface
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                StyledText {
                                    Layout.fillWidth: true
                                    text: root.matchData && root.matchData.team2 ? root.matchData.team2.name : ""
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: Font.DemiBold
                                    color: Appearance.colors.colOnSurface
                                }
                                StyledText {
                                    text: root.matchData && root.matchData.team2 ? (root.matchData.team2.score || "-") : "-"
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: Font.Bold
                                    color: Appearance.colors.colOnSurface
                                }
                            }
                        }
                    }

                    StyledText {
                        visible: !!(root.matchData && root.matchData.summary)
                        Layout.fillWidth: true
                        text: root.matchData ? (root.matchData.summary || "") : ""
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnSurface
                        wrapMode: Text.WordWrap
                    }

                    StyledText {
                        visible: !!(root.matchData && root.matchData.venue)
                        Layout.fillWidth: true
                        text: root.matchData ? (root.matchData.venue || "") : ""
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colOnSurfaceVariant
                        elide: Text.ElideRight
                    }
                }
            }

            // Loading / Empty State
            Rectangle {
                visible: SportsTrackerService.isLoadingScorecard || root.innings.length === 0
                Layout.fillWidth: true
                color: Appearance.colors.colLayer1
                radius: Appearance.rounding.large
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                implicitHeight: 84

                StyledText {
                    anchors.centerIn: parent
                    text: SportsTrackerService.isLoadingScorecard
                        ? Translation.tr("Loading scorecard...")
                        : (root.scorecard && root.scorecard.error ? root.scorecard.error : Translation.tr("Scorecard not available yet"))
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }

            // Innings Cards
            Repeater {
                model: root.innings
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    color: Appearance.colors.colLayer1
                    radius: Appearance.rounding.large
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant
                    implicitHeight: innCol.implicitHeight + 28

                    ColumnLayout {
                        id: innCol
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        // Innings Title
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.batting_team || Translation.tr("Innings ") + modelData.innings_number
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Bold
                                color: Appearance.colors.colOnSurface
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: (modelData.runs ? modelData.runs + " " : "") + (modelData.total || "")
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.DemiBold
                                color: Appearance.colors.colOnSurface
                            }
                        }

                        // Batting Table
                        Rectangle {
                            visible: modelData.batting && modelData.batting.length > 0
                            Layout.fillWidth: true
                            color: Appearance.colors.colLayer2
                            radius: Appearance.rounding.normal
                            implicitHeight: batCol.implicitHeight + 22

                            ColumnLayout {
                                id: batCol
                                anchors.fill: parent
                                anchors.margins: 11
                                spacing: 7

                                // Header
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: Translation.tr("Batter")
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        font.weight: Font.DemiBold
                                        color: Appearance.colors.colOnSurfaceVariant
                                    }
                                    StyledText { text: "R"; font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.DemiBold; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 28 }
                                    StyledText { text: "B"; font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.DemiBold; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 28 }
                                    StyledText { text: "4s"; font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.DemiBold; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 24 }
                                    StyledText { text: "6s"; font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.DemiBold; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 24 }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: Appearance.colors.colOutlineVariant
                                    opacity: 0.6
                                }

                                Repeater {
                                    model: modelData.batting || []
                                    delegate: ColumnLayout {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        spacing: 2

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 6

                                            StyledText {
                                                Layout.fillWidth: true
                                                text: modelData.name || ""
                                                font.pixelSize: Appearance.font.pixelSize.small
                                                font.weight: Font.Medium
                                                color: Appearance.colors.colOnSurface
                                                elide: Text.ElideRight
                                            }
                                            StyledText { text: modelData.runs; font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.DemiBold; color: Appearance.colors.colOnSurface; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 28 }
                                            StyledText { text: modelData.balls; font.pixelSize: Appearance.font.pixelSize.small; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 28 }
                                            StyledText { text: modelData.fours; font.pixelSize: Appearance.font.pixelSize.small; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 24 }
                                            StyledText { text: modelData.sixes; font.pixelSize: Appearance.font.pixelSize.small; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 24 }
                                        }

                                        StyledText {
                                            visible: !!(modelData.dismissal)
                                            Layout.fillWidth: true
                                            text: modelData.dismissal || ""
                                            font.pixelSize: Appearance.font.pixelSize.smallest
                                            color: Appearance.colors.colOnSurfaceVariant
                                            elide: Text.ElideRight
                                        }
                                    }
                                }

                                StyledText {
                                    visible: !!(modelData.extras)
                                    Layout.fillWidth: true
                                    Layout.topMargin: 2
                                    text: Translation.tr("Extras: ") + (modelData.extras || "")
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: Appearance.colors.colOnSurfaceVariant
                                }
                            }
                        }

                        // Bowling Table
                        Rectangle {
                            visible: modelData.bowling && modelData.bowling.length > 0
                            Layout.fillWidth: true
                            color: Appearance.colors.colLayer2
                            radius: Appearance.rounding.normal
                            implicitHeight: bowlCol.implicitHeight + 22

                            ColumnLayout {
                                id: bowlCol
                                anchors.fill: parent
                                anchors.margins: 11
                                spacing: 7

                                // Header
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: modelData.bowling_team ? (modelData.bowling_team + " " + Translation.tr("Bowling")) : Translation.tr("Bowler")
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        font.weight: Font.DemiBold
                                        color: Appearance.colors.colOnSurfaceVariant
                                        elide: Text.ElideRight
                                    }
                                    StyledText { text: "O"; font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.DemiBold; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 32 }
                                    StyledText { text: "M"; font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.DemiBold; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 22 }
                                    StyledText { text: "R"; font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.DemiBold; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 28 }
                                    StyledText { text: "W"; font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.DemiBold; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 22 }
                                    StyledText { text: "ER"; font.pixelSize: Appearance.font.pixelSize.smaller; font.weight: Font.DemiBold; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 38 }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: Appearance.colors.colOutlineVariant
                                    opacity: 0.6
                                }

                                Repeater {
                                    model: modelData.bowling || []
                                    delegate: RowLayout {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        spacing: 6

                                        StyledText {
                                            Layout.fillWidth: true
                                            text: modelData.name || ""
                                            font.pixelSize: Appearance.font.pixelSize.small
                                            font.weight: Font.Medium
                                            color: Appearance.colors.colOnSurface
                                            elide: Text.ElideRight
                                        }
                                        StyledText { text: modelData.overs; font.pixelSize: Appearance.font.pixelSize.small; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 32 }
                                        StyledText { text: modelData.maidens; font.pixelSize: Appearance.font.pixelSize.small; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 22 }
                                        StyledText { text: modelData.runs; font.pixelSize: Appearance.font.pixelSize.small; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 28 }
                                        StyledText { text: modelData.wickets; font.pixelSize: Appearance.font.pixelSize.small; font.weight: Font.DemiBold; color: Appearance.colors.colOnSurface; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 22 }
                                        StyledText { text: modelData.econ; font.pixelSize: Appearance.font.pixelSize.small; color: Appearance.colors.colOnSurfaceVariant; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 38 }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
