import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Aerospace 1.0

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 18

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 4

                Label {
                    text: "Mission Overview"
                    color: Theme.textPrimary
                    font.pixelSize: 32
                    font.bold: true
                }

                Label {
                    text: "Unified aerospace operations dashboard for launch readiness and flight systems."
                    color: Theme.textSecondary
                    font.pixelSize: 14
                }
            }

            Item { Layout.fillWidth: true }

            GlassButton {
                text: "Run Diagnostics"
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 18

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 18

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 18

                    StatCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 170
                        title: "Vehicle"
                        value: "Neutron-X"
                        subtitle: "Reusable medium-lift launch vehicle configuration."
                    }

                    StatCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 170
                        title: "Launch Window"
                        value: "T-18:42"
                        subtitle: "Primary opportunity within current atmospheric limits."
                        accentColor: Theme.warning
                    }

                    StatCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 170
                        title: "Telemetry"
                        value: "98.4%"
                        subtitle: "Downlink quality stable across ground station network."
                        accentColor: Theme.secondary
                    }
                }

                GlassPanel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    padding: 18

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        Label {
                            text: "Core Readiness"
                            color: Theme.textPrimary
                            font.pixelSize: 20
                            font.bold: true
                        }

                        GaugeBar { label: "Propulsion"; value: 0.93; barColor: Theme.accent }
                        GaugeBar { label: "Guidance / Navigation"; value: 0.89; barColor: Theme.secondary }
                        GaugeBar { label: "Ground Systems"; value: 0.96; barColor: Theme.warning }
                        GaugeBar { label: "Flight Software"; value: 0.91; barColor: Theme.success }
                    }
                }
            }

            GlassPanel {
                Layout.preferredWidth: 360
                Layout.fillHeight: true
                padding: 18

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    Label {
                        text: "Mission Brief"
                        color: Theme.textPrimary
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Label {
                        text: "Payload: LEO Earth observation constellation deployment. Flight profile includes stage separation, circularization burn, and guided return prep."
                        color: Theme.textSecondary
                        wrapMode: Text.WordWrap
                        font.pixelSize: 13
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Theme.border
                        opacity: 0.7
                    }

                    Label { text: "Key Metrics"; color: Theme.textMuted; font.pixelSize: 12 }
                    Label { text: "• Max dynamic pressure expected at T+00:01:14"; color: Theme.textSecondary; font.pixelSize: 13 }
                    Label { text: "• Autonomous FTS armed and verified"; color: Theme.textSecondary; font.pixelSize: 13 }
                    Label { text: "• Sea-state acceptable for recovery corridor"; color: Theme.textSecondary; font.pixelSize: 13 }
                    Label { text: "• Launch pad umbilicals green across all channels"; color: Theme.textSecondary; font.pixelSize: 13 }

                    Item { Layout.fillHeight: true }

                    GlassButton {
                        text: "Open Mission File"
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}