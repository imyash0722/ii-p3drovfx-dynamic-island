import qs
import qs.modules.ii.bar.shared
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root
    popupId: "network"
    stickyHover: true
    readonly property bool sidebarOccludesPopup:
        (root.notifIsLeft && GlobalStates.effectiveLeftOpen)
        || (root.notifIsRight && GlobalStates.effectiveRightOpen)

    active: !sidebarOccludesPopup && (_computedActive || _isClosing)

    readonly property bool notifIsLeft: (Config.options.notifications.position ?? "top_right").endsWith("left")
    readonly property bool notifIsRight: (Config.options.notifications.position ?? "top_right").endsWith("right")
    readonly property bool connected: Network.ethernet || Network.wifiStatus === "connected"

    function getSubtitle() {
        if (Network.ethernet) {
            return Network.ipAddress.length > 0 ? `IP: ${Network.ipAddress}` : Translation.tr("Wired network active");
        }
        if (Network.wifiStatus === "connected") {
            const parts = [];
            if (Network.networkStrength > 0) parts.push(`${Network.networkStrength}% signal`);
            if (Network.ipAddress.length > 0) parts.push(Network.ipAddress);
            return parts.length > 0 ? parts.join(" • ") : Translation.tr("Connected");
        }
        return "";
    }

    ColumnLayout {
        id: mainLayout
        anchors.centerIn: parent
        spacing: 12

        // Connected state
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            Layout.minimumWidth: 320
            visible: root.connected

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10
                Layout.fillWidth: true

                MaterialShape {
                    Layout.alignment: Qt.AlignHCenter
                    shapeString: "Cookie7Sided"
                    implicitSize: 56
                    color: Appearance.colors.colPrimaryContainer

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: Network.materialSymbol
                        iconSize: Appearance.font.pixelSize.hugeass
                        color: Appearance.colors.colOnPrimaryContainer
                    }
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Network.ethernet ? Translation.tr("Ethernet Connected") : (Network.networkName.length > 0 ? Network.networkName : Translation.tr("Wi-Fi Connected"))
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.Bold
                    color: Appearance.colors.colOnSurface
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.getSubtitle()
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }
        }

        // Empty state when disconnected
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 130
            Layout.minimumWidth: 300
            visible: !root.connected

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                MaterialShape {
                    Layout.alignment: Qt.AlignHCenter
                    shapeString: "Cookie6Sided"
                    implicitSize: 56
                    color: Appearance.colors.colSurfaceContainerHighest

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: Network.wifiEnabled ? "signal_wifi_off" : "wifi_off"
                        iconSize: Appearance.font.pixelSize.hugeass
                        color: Appearance.colors.colOnSurfaceVariant
                    }
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Network.wifiEnabled ? Translation.tr("Disconnected") : Translation.tr("Wi-Fi Disabled")
                    font.pixelSize: Appearance.font.pixelSize.large
                    font.weight: Font.Bold
                    color: Appearance.colors.colOnSurface
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Translation.tr("No network connection")
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }
        }

        // Details rows
        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 320
            visible: root.connected
            spacing: 6

            StyledPopupValueRow {
                Layout.fillWidth: true
                icon: "router"
                label: Translation.tr("Network")
                value: Network.networkName.length > 0 ? Network.networkName : Translation.tr("Unknown")
            }

            StyledPopupValueRow {
                Layout.fillWidth: true
                icon: Network.ethernet ? "lan" : "wifi"
                label: Translation.tr("Type")
                value: Network.ethernet ? Translation.tr("Ethernet") : Translation.tr("Wi-Fi")
            }

            StyledPopupValueRow {
                Layout.fillWidth: true
                visible: !Network.ethernet && Network.wifiStatus === "connected"
                icon: "signal_cellular_alt"
                label: Translation.tr("Signal")
                value: `${Network.networkStrength}%`
            }

            StyledPopupValueRow {
                Layout.fillWidth: true
                visible: Network.ipAddress.length > 0
                icon: "dns"
                label: Translation.tr("IP Address")
                value: Network.ipAddress
            }
        }
    }
}
