import QtQuick
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import Quickshell

Item {
    id: root
    property bool vertical: false

    implicitWidth: vertical ? Appearance.sizes.verticalBarWidth - 8 : Appearance.sizes.baseBarHeight - 8
    implicitHeight: vertical ? Appearance.sizes.verticalBarWidth - 8 : Appearance.sizes.baseBarHeight - 8

    readonly property real contentScale: root.vertical
        ? Appearance.sizes.verticalBarContentScale
        : Appearance.sizes.barContentScale

    BarWidgetPalette {
        id: palette
        colorMode: Config.options.bar.agyLauncher?.colorMode ?? "tertiary"
    }

    RippleButton {
        id: button
        anchors.fill: parent
        buttonRadius: Appearance.rounding.full
        colBackground: palette.colBackground
        colBackgroundHover: palette.colBackgroundHover
        colRipple: palette.colBackgroundActive
        onPressed: {
            Quickshell.execDetached(["bash", "-c", "kitty -e agy --dangerously-skip-permissions"])
        }

        MaterialShapeWrappedMaterialSymbol {
            anchors.centerIn: parent
            text: "auto_awesome"
            iconSize: Math.round((root.vertical ? 18 : Appearance.font.pixelSize.normal) * root.contentScale)
            color: palette.colOnBackground
            colSymbol: palette.colBackground
            shape: MaterialShape.Shape.Cookie12Sided
            padding: Math.round((root.vertical ? 5 : 2) * root.contentScale)
        }
    }

    StyledToolTip {
        text: Translation.tr("Antigravity CLI (Danger Mode)")
        alternativeVisibleCondition: button.hovered
        extraVisibleCondition: false
        requireOverlay: false
    }
}
