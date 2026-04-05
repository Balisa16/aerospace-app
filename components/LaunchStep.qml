import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Aerospace 1.0

Rectangle {
    id: root

    property string stepName: ""
    property string statusText: "Pending"
    property bool active: false
    property bool done: false

    radius: 22
    color: done ? Qt.rgba(0.49, 0.94, 0.68, 0.12)
                : active ? Qt.rgba(0.44, 0.80, 1.0, 0.16)
                         : Qt.rgba(1, 1, 1, 0.06)
    border.width: 1
    border.color: done ? Theme.success_color : active ? Theme.accent : Theme.border_color

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Rectangle {
            width: 36
            height: 36
            radius: 18
            color: root.done ? Theme.success_color : root.active ? Theme.accent : Qt.rgba(1,1,1,0.12)

            Label {
                anchors.centerIn: parent
                text: root.done ? "✓" : root.active ? "●" : "•"
                color: root.done || root.active ? "#0A1424" : Theme.text_secondary
                font.bold: true
            }
        }

        ColumnLayout {
            id: descr
            Layout.fillWidth: true
            spacing: 2

            Label {
                text: root.stepName
                color: Theme.text_primary
                font.pixelSize: 14
                font.bold: true

                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                text: root.statusText
                color: Theme.text_secondary
                font.pixelSize: 12

                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
            }
        }
    }
}