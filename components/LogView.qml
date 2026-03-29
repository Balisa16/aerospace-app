import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Aerospace 1.0

GlassPanel {
    id: root
    title_height: 0
    property var modelData: []

    radius: 28
    padding: 14

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: root.modelData

            delegate: Rectangle {
                width: ListView.view.width
                height: 74
                radius: 20
                color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1
                border.color: Theme.border

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        width: 10
                        height: 10
                        radius: 5
                        color: modelData.level === "WARN" ? Theme.warning
                               : modelData.level === "ERROR" ? Theme.danger
                               : Theme.success
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Label {
                            text: modelData.time + "  ·  " + modelData.level
                            color: Theme.textMuted
                            font.pixelSize: 11
                        }

                        Label {
                            text: modelData.message
                            color: Theme.textPrimary
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
}