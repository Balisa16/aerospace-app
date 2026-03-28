import QtQuick
import QtQuick.Controls

Button {
    id: root

    property color accentColor: Theme.accent

    implicitHeight: 48
    implicitWidth: 150

    background: Rectangle {
        radius: 18
        color: root.down ? Qt.rgba(1, 1, 1, 0.10)
                         : root.hovered ? Qt.rgba(1, 1, 1, 0.18)
                                        : Qt.rgba(1, 1, 1, 0.12)
        border.width: 1
        border.color: root.hovered ? accentColor : Theme.border

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: accentColor
            opacity: root.down ? 0.22 : 0.12
        }
    }

    contentItem: Text {
        text: root.text
        color: Theme.textPrimary
        font.pixelSize: 14
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}