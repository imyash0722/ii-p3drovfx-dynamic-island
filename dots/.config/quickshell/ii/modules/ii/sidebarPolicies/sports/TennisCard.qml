import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Rectangle {
    id: root

    readonly property var favorites: SportsTrackerService.tennisFavorites || []
    readonly property var rankings: SportsTrackerService.tennisRankings || []
    readonly property var matches: SportsTrackerService.tennisMatches || []
    readonly property bool hasLiveMatch: matches.length > 0 && matches.some(m => m.is_live)

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
                implicitWidth: tagText.implicitWidth + 14
                implicitHeight: 24

                StyledText {
                    id: tagText
                    anchors.centerIn: parent
                    text: "ATP TOUR"
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnSurface
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("Rankings & Live")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                color: Appearance.colors.colOnSurfaceVariant
                elide: Text.ElideRight
            }

            // Live indicator if match is active
            Rectangle {
                visible: root.hasLiveMatch
                color: Appearance.colors.colLayer2
                radius: Appearance.rounding.full
                border.width: 1
                border.color: Appearance.colors.colOutlineVariant
                implicitWidth: liveTennisRow.implicitWidth + 14
                implicitHeight: 22

                RowLayout {
                    id: liveTennisRow
                    anchors.centerIn: parent
                    spacing: 5

                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: "#E53935"

                        SequentialAnimation on opacity {
                            running: root.hasLiveMatch
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
        }

        // Live Matches section (if any)
        Repeater {
            model: root.matches
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                color: Appearance.colors.colLayer2
                radius: Appearance.rounding.normal
                implicitHeight: matchCol.implicitHeight + 24

                ColumnLayout {
                    id: matchCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        StyledText {
                            text: modelData.tournament + " · " + modelData.round
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.DemiBold
                            color: Appearance.colors.colOnSurfaceVariant
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        StyledText {
                            text: modelData.status_desc || ""
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnSurfaceVariant
                        }
                    }

                    // Player 1
                    RowLayout {
                        Layout.fillWidth: true
                        StyledText {
                            text: modelData.player1.name || ""
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: modelData.player1.is_favorite ? Font.DemiBold : Font.Normal
                            color: Appearance.colors.colOnSurface
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        StyledText {
                            text: (modelData.player1.sets || []).join("  ")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Bold
                            color: Appearance.colors.colOnSurface
                        }
                    }

                    // Player 2
                    RowLayout {
                        Layout.fillWidth: true
                        StyledText {
                            text: modelData.player2.name || ""
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: modelData.player2.is_favorite ? Font.DemiBold : Font.Normal
                            color: Appearance.colors.colOnSurface
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        StyledText {
                            text: (modelData.player2.sets || []).join("  ")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Bold
                            color: Appearance.colors.colOnSurface
                        }
                    }
                }
            }
        }

        // Favorite Player Cards
        RowLayout {
            visible: root.favorites.length > 0
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: root.favorites
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    color: Appearance.colors.colLayer2
                    radius: Appearance.rounding.normal
                    implicitHeight: favCol.implicitHeight + 24

                    ColumnLayout {
                        id: favCol
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.name || ""
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.DemiBold
                                color: Appearance.colors.colOnSurface
                                elide: Text.ElideRight
                            }

                            StyledText {
                                visible: !!(modelData.country)
                                text: modelData.country || ""
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.colors.colOnSurfaceVariant
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Rectangle {
                                color: Appearance.colors.colLayer1
                                radius: Appearance.rounding.small
                                border.width: 1
                                border.color: Appearance.colors.colOutlineVariant
                                implicitWidth: rankBadgeText.implicitWidth + 12
                                implicitHeight: 22

                                StyledText {
                                    id: rankBadgeText
                                    anchors.centerIn: parent
                                    text: "#" + modelData.rank
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    font.weight: Font.DemiBold
                                    color: Appearance.colors.colOnSurface
                                }
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.points + " pts"
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Medium
                                color: Appearance.colors.colOnSurfaceVariant
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }
        }

        // Top 5 ATP Rankings
        Rectangle {
            visible: root.rankings.length > 0
            Layout.fillWidth: true
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.normal
            implicitHeight: top5Col.implicitHeight + 24

            ColumnLayout {
                id: top5Col
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                StyledText {
                    text: Translation.tr("Top 5 Standings")
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnSurfaceVariant
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: root.rankings
                        delegate: RowLayout {
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            spacing: 8

                            StyledText {
                                text: "#" + modelData.rank
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.DemiBold
                                color: index === 0 ? Appearance.colors.colOnSurface : Appearance.colors.colOnSurfaceVariant
                                Layout.preferredWidth: 26
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.name || ""
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: index === 0 ? Font.DemiBold : Font.Normal
                                color: Appearance.colors.colOnSurface
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: modelData.points + " pts"
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Medium
                                color: Appearance.colors.colOnSurfaceVariant
                            }
                        }
                    }
                }
            }
        }
    }
}
