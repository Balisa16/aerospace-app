import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Aerospace 1.0

Item {
    id: root
    property QtObject theme

    ColumnLayout {
        anchors.fill: parent
        spacing: 18

        Label {
            text: "Health Systems"
            color: Theme.textPrimary
            font.pixelSize: 32
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 18

            GlassPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                padding: 18

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12

                    Label {
                        text: "Subsystem Health"
                        color: Theme.textPrimary
                        font.pixelSize: 20
                        font.bold: true
                    }

                    GaugeBar { label: "Main Engine Cluster"; value: 0.95; barColor: Theme.success }
                    GaugeBar { label: "LOX Feed System"; value: 0.86; barColor: Theme.accent }
                    GaugeBar { label: "Avionics Bay"; value: 0.92; barColor: Theme.secondary }
                    GaugeBar { label: "Battery Bus"; value: 0.79; barColor: Theme.warning }
                    GaugeBar { label: "Thermal Protection"; value: 0.88; barColor: Theme.accent }
                    GaugeBar { label: "Flight Computer"; value: 0.97; barColor: Theme.success }
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 360
                Layout.fillHeight: true
                spacing: 18

                StatCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 170
                    title: "Health Score"
                    value: "91 / 100"
                    subtitle: "No critical faults. Minor battery drift noted on redundant bus B."
                    accentColor: Theme.success
                }

                StatCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 170
                    title: "Alerts"
                    value: "2 Minor"
                    subtitle: "Thermal margin and battery variation remain within acceptable thresholds."
                    accentColor: Theme.warning
                }

                GlassPanel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    padding: 18

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        Label {
                            text: "Health Notes"
                            color: Theme.textPrimary
                            font.pixelSize: 20
                            font.bold: true
                        }

                        Label {
                            text: "• Primary vehicle computers synchronized\n• IMU calibration lock stable\n• Pressurization rate within band\n• GNC watchdog heartbeat nominal"
                            color: Theme.textSecondary
                            wrapMode: Text.WordWrap
                            font.pixelSize: 13
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
}