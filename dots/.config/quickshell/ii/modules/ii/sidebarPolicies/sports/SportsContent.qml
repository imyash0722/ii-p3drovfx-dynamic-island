pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Item {
    id: root

    property string activeFilter: "all"
    readonly property bool showingScorecard: SportsTrackerService.selectedCricketMatch !== null

    CricketScorecardView {
        anchors.fill: parent
        visible: root.showingScorecard
    }

    ColumnLayout {
        anchors.fill: parent
        visible: !root.showingScorecard
        spacing: 12

        // Top Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                width: 38
                height: 38
                radius: Appearance.rounding.normal
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "sports_and_outdoors"
                    iconSize: 20
                    color: Appearance.colors.colOnSurface
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                StyledText {
                    text: Translation.tr("Sports")
                    font.pixelSize: Appearance.font.pixelSize.large
                    font.weight: Font.Bold
                    color: Appearance.colors.colOnSurface
                }

                StyledText {
                    text: SportsTrackerService.lastUpdated ? Translation.tr("Updated ") + SportsTrackerService.lastUpdated : Translation.tr("Live Tracker")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }

            // Refresh Button
            RippleButton {
                implicitWidth: 36
                implicitHeight: 36
                buttonRadius: Appearance.rounding.full
                colBackground: Appearance.colors.colLayer1
                colBackgroundHover: Appearance.colors.colLayer2
                borderWidth: 1
                borderColor: Appearance.colors.colOutlineVariant
                onPressed: SportsTrackerService.refresh()

                MaterialSymbol {
                    id: refreshGlyph
                    anchors.centerIn: parent
                    text: "refresh"
                    iconSize: 18
                    color: Appearance.colors.colOnSurfaceVariant

                    RotationAnimation on rotation {
                        running: SportsTrackerService.isRefreshing
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 900
                    }
                }

                StyledToolTip {
                    text: Translation.tr("Refresh Sports Data")
                    extraVisibleCondition: false
                    requireOverlay: false
                }
            }
        }

        // Filter Chips (All, Cricket, Tennis, Formula 1)
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: [
                    { id: "all", label: Translation.tr("All") },
                    { id: "cricket", label: Translation.tr("Cricket") },
                    { id: "tennis", label: Translation.tr("Tennis") },
                    { id: "f1", label: Translation.tr("Formula 1") }
                ]

                delegate: RippleButton {
                    required property var modelData
                    readonly property bool isSelected: root.activeFilter === modelData.id

                    Layout.fillWidth: true
                    implicitHeight: 32
                    buttonRadius: Appearance.rounding.full
                    colBackground: isSelected ? Appearance.colors.colSecondaryContainer : Appearance.colors.colLayer1
                    colBackgroundHover: isSelected ? Appearance.colors.colSecondaryContainerHover : Appearance.colors.colLayer2
                    borderWidth: 1
                    borderColor: isSelected ? Appearance.colors.colSecondaryContainer : Appearance.colors.colOutlineVariant

                    onPressed: root.activeFilter = modelData.id

                    StyledText {
                        anchors.centerIn: parent
                        text: modelData.label
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: parent.isSelected ? Font.DemiBold : Font.Normal
                        color: parent.isSelected ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnSurfaceVariant
                    }
                }
            }
        }

        // Scrollable Content
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: contentCol.implicitHeight + 16
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            ColumnLayout {
                id: contentCol
                width: parent.width
                spacing: 16

                // CRICKET SECTION
                ColumnLayout {
                    visible: root.activeFilter === "all" || root.activeFilter === "cricket"
                    Layout.fillWidth: true
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        StyledText {
                            text: Translation.tr("Cricket")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.DemiBold
                            color: Appearance.colors.colOnSurface
                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: SportsTrackerService.cricketMatches.length > 0 ? (SportsTrackerService.cricketMatches.length + " matches") : ""
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnSurfaceVariant
                        }
                    }

                    Repeater {
                        model: SportsTrackerService.cricketMatches
                        delegate: CricketCard {
                            required property var modelData
                            Layout.fillWidth: true
                            matchData: modelData
                        }
                    }

                    Rectangle {
                        visible: SportsTrackerService.cricketMatches.length === 0
                        Layout.fillWidth: true
                        implicitHeight: 68
                        color: Appearance.colors.colLayer1
                        radius: Appearance.rounding.large
                        border.width: 1
                        border.color: Appearance.colors.colOutlineVariant

                        StyledText {
                            anchors.centerIn: parent
                            text: Translation.tr("No live or upcoming matches for IND / AUS")
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colOnSurfaceVariant
                        }
                    }
                }

                // TENNIS SECTION
                ColumnLayout {
                    visible: root.activeFilter === "all" || root.activeFilter === "tennis"
                    Layout.fillWidth: true
                    spacing: 10

                    StyledText {
                        text: Translation.tr("Tennis")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.DemiBold
                        color: Appearance.colors.colOnSurface
                    }

                    TennisCard {
                        Layout.fillWidth: true
                    }
                }

                // FORMULA 1 SECTION
                ColumnLayout {
                    visible: root.activeFilter === "all" || root.activeFilter === "f1"
                    Layout.fillWidth: true
                    spacing: 10

                    StyledText {
                        text: Translation.tr("Formula 1")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.DemiBold
                        color: Appearance.colors.colOnSurface
                    }

                    F1Card {
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
