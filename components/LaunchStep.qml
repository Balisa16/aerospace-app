import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
    border.color: done ? Theme.success : active ? Theme.accent : Theme.border

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Rectangle {
            width: 36
            height: 36
            radius: 18
            color: done ? Theme.success : active ? Theme.accent : Qt.rgba(1,1,1,0.12)

            Label {
                anchors.centerIn: parent
                text: done ? "✓" : active ? "●" : "…"
                color: done || active ? "#0A1424" : Theme.textSecondary
                font.bold: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Label {
                text: root.stepName
                color: Theme.textPrimary
                font.pixelSize: 14
                font.bold: true
            }

            Label {
                text: root.statusText
                color: Theme.textSecondary
                font.pixelSize: 12
            }
        }
    }
}