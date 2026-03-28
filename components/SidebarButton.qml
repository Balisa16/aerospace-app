import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Aerospace 1.0

Button {
    id: root

    property string iconText: ""
    property bool selected: false

    property int buttonWidth: 260

    implicitHeight: 52
    implicitWidth: buttonWidth

    background: Rectangle {
        radius: 20
        color: root.selected
               ? Qt.rgba(1, 1, 1, 0.18)
               : root.hovered
                 ? Qt.rgba(1, 1, 1, 0.10)
                 : "transparent"

        border.width: 1
        border.color: root.selected ? Theme.borderStrong : "transparent"

        // Left accent indicator (like macOS sidebar)
        Rectangle {
            visible: root.selected
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8
            width: 4
            height: parent.height - 24
            radius: 2
            color: Theme.accent
        }
    }

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        spacing: 12

        Label {
            text: root.iconText
            color: root.selected ? Theme.accent : Theme.textSecondary
            font.pixelSize: 17
        }

        Label {
            text: root.text
            color: root.selected ? Theme.textPrimary : Theme.textSecondary
            font.pixelSize: 14
            font.bold: root.selected
            Layout.fillWidth: true
        }
    }
}