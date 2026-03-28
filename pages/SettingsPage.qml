import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Aerospace 1.0

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 18

        Label {
            text: "Settings"
            color: Theme.textPrimary
            font.pixelSize: 32
            font.bold: true
        }

        GlassPanel {
            width: parent.width
            height: 300
            padding: 18

            ColumnLayout {
                anchors.fill: parent
                spacing: 14

                Label {
                    text: "Appearance"
                    color: Theme.textPrimary
                    font.pixelSize: 20
                    font.bold: true
                }

                Label {
                    text: "Switch between the two built-in themes: Midnight Orbit and Sky Hangar."
                    color: Theme.textSecondary
                    font.pixelSize: 13
                }

                RowLayout {
                    spacing: 12

                    GlassButton {
                        text: "Midnight Orbit"
                        accentColor: Theme.accent
                        onClicked: Theme.darkMode = true
                    }

                    GlassButton {
                        text: "Sky Hangar"
                        accentColor: Theme.secondary
                        onClicked: Theme.darkMode = false
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.border
                }

                Label {
                    text: "Recommended next step: connect this UI to a C++ backend or telemetry service using context properties, QAbstractListModel, or a message bus."
                    color: Theme.textMuted
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }
            }
        }
    }
}