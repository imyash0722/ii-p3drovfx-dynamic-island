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
    radius: Appearance.rounding.normal
    border.width: 1
    border.color: hasLiveMatch ? Qt.rgba(Appearance.colors.colPrimary.r, Appearance.colors.colPrimary.g, Appearance.colors.colPrimary.b, 0.4) : Appearance.colors.colOutlineVariant
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
                implicitWidth: tagText.implicitWidth + 12
                implicitHeight: 22

                StyledText {
                    id: tagText
                    anchors.centerIn: parent
                    text: "ATP TOUR"
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colPrimary
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("World Rankings & Live")
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnSurfaceVariant
                elide: Text.ElideRight
            }

            // Live indicator if match is active
            Rectangle {
                visible: root.hasLiveMatch
                color: Qt.rgba(0.9, 0.2, 0.2, 0.15)
                radius: Appearance.rounding.full
                border.width: 1
                border.color: Qt.rgba(0.9, 0.2, 0.2, 0.5)
                implicitWidth: liveTennisRow.implicitWidth + 10
                implicitHeight: 20

                RowLayout {
                    id: liveTennisRow
                    anchors.centerIn: parent
                    spacing: 4

                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: "#E53935"

                        SequentialAnimation on opacity {
                            running: root.hasLiveMatch
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
        }

        // Live Matches section (if any)
        Repeater {
            model: root.matches
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                color: Appearance.colors.colLayer2
                radius: Appearance.rounding.small
                implicitHeight: matchCol.implicitHeight + 16

                ColumnLayout {
                    id: matchCol
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        StyledText {
                            text: modelData.tournament + " • " + modelData.round
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.weight: Font.DemiBold
                            color: Appearance.colors.colTertiary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        StyledText {
                            text: modelData.status_desc || ""
                            font.pixelSize: Appearance.font.pixelSize.smallest
                            color: Appearance.colors.colOnSurfaceVariant
                        }
                    }

                    // Player 1
                    RowLayout {
                        Layout.fillWidth: true
                        StyledText {
                            text: "🎾 " + (modelData.player1.name || "")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: modelData.player1.is_favorite ? Font.Bold : Font.Normal
                            color: modelData.player1.is_favorite ? Appearance.colors.colPrimary : Appearance.colors.colOnSurface
                            Layout.fillWidth: true
                        }
                        StyledText {
                            text: (modelData.player1.sets || []).join("  ")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.DemiBold
                            color: Appearance.colors.colOnSurface
                        }
                    }

                    // Player 2
                    RowLayout {
                        Layout.fillWidth: true
                        StyledText {
                            text: "🎾 " + (modelData.player2.name || "")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: modelData.player2.is_favorite ? Font.Bold : Font.Normal
                            color: modelData.player2.is_favorite ? Appearance.colors.colPrimary : Appearance.colors.colOnSurface
                            Layout.fillWidth: true
                        }
                        StyledText {
                            text: (modelData.player2.sets || []).join("  ")
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.DemiBold
                            color: Appearance.colors.colOnSurface
                        }
                    }
                }
            }
        }

        // Dedicated Favorite Player Cards (Jannik Sinner & Carlos Alcaraz)
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: root.favorites
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    color: Appearance.colors.colLayer2
                    radius: Appearance.rounding.small
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant
                    implicitHeight: favCol.implicitHeight + 16

                    ColumnLayout {
                        id: favCol
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            StyledText {
                                text: modelData.flag || "🎾"
                                font.pixelSize: Appearance.font.pixelSize.normal
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.name || ""
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Bold
                                color: Appearance.colors.colOnSurface
                                elide: Text.ElideRight
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Rectangle {
                                color: Appearance.colors.colPrimary
                                radius: 4
                                implicitWidth: rankBadgeText.implicitWidth + 8
                                implicitHeight: 18

                                StyledText {
                                    id: rankBadgeText
                                    anchors.centerIn: parent
                                    text: "#" + modelData.rank
                                    font.pixelSize: Appearance.font.pixelSize.smallest
                                    font.weight: Font.Bold
                                    color: Appearance.colors.colOnPrimary
                                }
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.points + " pts"
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.DemiBold
                                color: Appearance.colors.colTertiary
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }
        }

        // Top 5 ATP Rankings Ribbon
        Rectangle {
            Layout.fillWidth: true
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.small
            implicitHeight: top5Col.implicitHeight + 14

            ColumnLayout {
                id: top5Col
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                StyledText {
                    text: Translation.tr("Top 5 Standings")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnSurfaceVariant
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: root.rankings
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            color: modelData.is_favorite ? Qt.rgba(Appearance.colors.colPrimary.r, Appearance.colors.colPrimary.g, Appearance.colors.colPrimary.b, 0.15) : "transparent"
                            radius: 4
                            implicitHeight: 22

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 3

                                StyledText {
                                    text: "#" + modelData.rank
                                    font.pixelSize: Appearance.font.pixelSize.smallest
                                    font.weight: Font.Bold
                                    color: modelData.is_favorite ? Appearance.colors.colPrimary : Appearance.colors.colOnSurfaceVariant
                                }

                                StyledText {
                                    text: (modelData.name || "").split(" ").pop()
                                    font.pixelSize: Appearance.font.pixelSize.smallest
                                    font.weight: modelData.is_favorite ? Font.Bold : Font.Normal
                                    color: modelData.is_favorite ? Appearance.colors.colPrimary : Appearance.colors.colOnSurface
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
