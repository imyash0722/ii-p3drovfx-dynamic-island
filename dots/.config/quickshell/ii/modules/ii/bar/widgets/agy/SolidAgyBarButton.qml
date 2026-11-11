pragma ComponentBehavior: Bound

import QtQuick
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import Quickshell

Item {
    id: root

    property bool vertical: false

    readonly property real side: (root.vertical
        ? Appearance.sizes.verticalBarWidth
        : Appearance.sizes.baseBarHeight) - 8

    readonly property real contentScale: root.vertical
        ? Appearance.sizes.verticalBarContentScale
        : Appearance.sizes.barContentScale

    implicitWidth: root.side
    implicitHeight: root.side

    BarWidgetPalette {
        id: palette
        colorMode: Config.options.bar.agyLauncher?.colorMode ?? "tertiaryContainer"
    }

    RippleButton {
        id: button
        anchors.fill: parent
        buttonRadius: Appearance.rounding.full

        colBackground: palette.colBackground
        colBackgroundHover: palette.colBackgroundHover
        colBackgroundActive: palette.colBackgroundActive
        colRipple: palette.colBackgroundActive

        onPressed: {
            Quickshell.execDetached(["bash", "-c", "kitty -e agy --dangerously-skip-permissions"])
        }

        MaterialSymbol {
            id: glyph
            anchors.centerIn: parent
            text: "auto_awesome"
            iconSize: Math.round(root.side * 0.52 * root.contentScale)
            color: palette.colOnBackground

            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(glyph)
            }
        }
    }

    StyledToolTip {
        text: Translation.tr("Antigravity CLI (Danger Mode)")
        alternativeVisibleCondition: button.hovered
        extraVisibleCondition: false
        requireOverlay: false
    }
}
