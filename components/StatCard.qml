import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Aerospace 1.0

GlassPanel {
    id: root

    property QtObject theme
    property string title: ""
    property string value: ""
    property string subtitle: ""
    property color accentColor: Theme.accent

    radius: 26
    padding: 16

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Label {
            text: root.title
            color: Theme.textMuted
            font.pixelSize: 12
        }

        Label {
            text: root.value
            color: Theme.textPrimary
            font.pixelSize: 28
            font.bold: true
        }

        Rectangle {
            width: 42
            height: 5
            radius: 3
            color: root.accentColor
            opacity: 0.8
        }

        Label {
            text: root.subtitle
            color: Theme.textSecondary
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }
}