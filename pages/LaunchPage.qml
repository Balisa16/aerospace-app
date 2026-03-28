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
            text: "Launch Control"
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
                        text: "Launch Sequence"
                        color: Theme.textPrimary
                        font.pixelSize: 20
                        font.bold: true
                    }

                    LaunchStep { stepName: "Pad Power On"; statusText: "Completed"; done: true; height: 70; width: parent.width }
                    LaunchStep { stepName: "Engine Chill"; statusText: "Completed"; done: true; height: 70; width: parent.width }
                    LaunchStep { stepName: "Tank Pressurization"; statusText: "In progress"; active: true; height: 70; width: parent.width }
                    LaunchStep { stepName: "Guidance Final Alignment"; statusText: "Awaiting gate"; height: 70; width: parent.width }
                    LaunchStep { stepName: "Terminal Count"; statusText: "Pending"; height: 70; width: parent.width }
                    LaunchStep { stepName: "Liftoff"; statusText: "Pending"; height: 70; width: parent.width }

                    Item { Layout.fillHeight: true }
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 360
                Layout.fillHeight: true
                spacing: 18

                // StatCard {
                //     Layout.fillWidth: true
                //     Layout.preferredHeight: 170
                //     title: "Current Phase"
                //     value: "Tanking"
                //     subtitle: "Cryogenic loading and pressurization sequence active."
                //     accentColor: Theme.accent
                // }

                GlassPanel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    padding: 18
                    title_height: 0

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        Label {
                            text: "Control Actions"
                            color: Theme.textPrimary
                            font.pixelSize: 20
                            font.bold: true
                        }

                        GlassButton { text: "Hold Countdown"; accentColor: Theme.warning; Layout.fillWidth: true }
                        GlassButton { text: "Resume Sequence"; accentColor: Theme.success; Layout.fillWidth: true }
                        GlassButton { text: "Abort Mission"; accentColor: Theme.danger; Layout.fillWidth: true }

                        Item { Layout.fillHeight: true }

                        Label {
                            text: "Safety interlocks are simulated."
                            color: Theme.textMuted
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
}