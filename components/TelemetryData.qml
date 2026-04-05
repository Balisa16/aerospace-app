import QtQuick
import QtQuick.Effects
import Aerospace 1.0

Item {
    id: root

    property alias text: label.text
    property alias textFormat: label.textFormat
    property alias font: label.font
    property alias color: label.color

    property bool hovered: false
    property real maximumWidth: Number.POSITIVE_INFINITY

    implicitWidth: Math.min(chip.implicitWidth, maximumWidth)
    implicitHeight: chip.implicitHeight

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited: root.hovered = false
        cursorShape: Qt.PointingHandCursor
    }

    MultiEffect {
        anchors.fill: chip
        source: chip

        shadowEnabled: true
        shadowHorizontalOffset: 0
        shadowVerticalOffset: root.hovered ? 5 : 3
        shadowBlur: root.hovered ? 0.5 : 0.35
        shadowOpacity: root.hovered ? 0.38 : 0.28

        blurEnabled: true
        blur: 0.08
    }

    Rectangle {
        id: chip

        y: root.hovered ? -2 : 0

        implicitWidth: Math.min(label.implicitWidth + 20, root.maximumWidth)
        implicitHeight: label.implicitHeight + 14
        radius: 12

        color: root.hovered ? "#E0243038" : "#CC1A2228"
        border.color: root.hovered ? "#66FFFFFF" : "#33FFFFFF"

        Behavior on y {
            NumberAnimation { duration: 120 }
        }

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Behavior on border.color {
            ColorAnimation { duration: 120 }
        }

        Text {
            id: label
            anchors.centerIn: parent

            width: Math.max(0, parent.width - 20)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight

            color: Theme.text_primary
            font: Theme.make_font_audio_wave(1, false, false)
        }
    }
}