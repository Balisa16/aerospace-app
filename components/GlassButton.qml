import QtQuick
import QtQuick.Controls
import Aerospace 1.0

Button {
    id: root
    property color buttonColor: Theme.accent
    implicitHeight: 48
    implicitWidth: 150

    background: Rectangle {
        radius: 18
        color: root.down ? Qt.rgba(1, 1, 1, 0.10)
                         : root.hovered ? Qt.rgba(1, 1, 1, 0.18)
                                        : Qt.rgba(1, 1, 1, 0.12)
        border.width: 1
        border.color: root.hovered ? root.buttonColor : Theme.border_color

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: root.buttonColor
            opacity: root.down ? 0.22 : 0.12
        }
    }

    contentItem: Text {
        text: root.text
        color: Theme.text_primary
        font.pixelSize: 14
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}