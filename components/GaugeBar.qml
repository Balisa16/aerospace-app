import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Aerospace 1.0

Item {
    id: root

    property string label: ""
    property real value: 0.5
    property color barColor: Theme.accent

    implicitHeight: 56

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: root.label
                color: Theme.text_secondary
                font.pixelSize: 13
            }

            Item { Layout.fillWidth: true }

            Label {
                text: Math.round(root.value * 100) + "%"
                color: Theme.text_primary
                font.pixelSize: 13
                font.bold: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 14
            radius: 7
            color: Qt.rgba(1, 1, 1, 0.10)
            border.width: 1
            border.color: Theme.border_color

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, root.value))
                height: parent.height
                radius: parent.radius
                color: root.barColor
                opacity: 0.85
            }
        }
    }
}