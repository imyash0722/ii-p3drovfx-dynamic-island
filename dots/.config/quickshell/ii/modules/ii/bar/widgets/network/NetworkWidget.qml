import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    property bool vertical: false

    readonly property bool connected: Network.ethernet || Network.wifiStatus === "connected"
    readonly property string networkName: Network.networkName

    visible: true
    implicitWidth: chip.implicitWidth
    implicitHeight: Appearance.sizes.baseBarHeight
    hoverEnabled: !BarInteraction.clickToShow
    cursorShape: Qt.PointingHandCursor

    Component.onCompleted: {
        if (typeof rootItem !== "undefined" && typeof rootItem.toggleVisible === "function")
            rootItem.toggleVisible(true);
    }

    Item {
        id: chip
        anchors.centerIn: parent
        implicitWidth: layout.implicitWidth + (root.connected && root.networkName.length > 0 ? 20 : 16)
        implicitHeight: Appearance.sizes.baseBarHeight - 6

        RowLayout {
            id: layout
            anchors.centerIn: parent
            spacing: 6

            MaterialSymbol {
                iconSize: Appearance.font.pixelSize.larger
                text: Network.materialSymbol
                color: root.connected ? Appearance.colors.colOnPrimary : Appearance.colors.colOnSurfaceVariant
            }

            StyledText {
                visible: root.connected && root.networkName.length > 0
                text: root.networkName
                font.pixelSize: Appearance.font.pixelSize.normal
                font.family: Appearance.font.family.main
                color: Appearance.colors.colOnPrimary
                Layout.maximumWidth: 80
                elide: Text.ElideRight
            }
        }
    }

    PopupLoader {
        id: popupLoader
        active: BarInteraction.enablePopups
            && (BarInteraction.clickToShow || root.containsMouse || held)
        source: "../../popups/network/NetworkPopup.qml"
        onLoaded: {
            item.hoverTarget = root;
        }
    }
}
