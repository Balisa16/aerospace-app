import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Aerospace 1.0

Item {
    id: root

    QtObject {
        id: rocket_state

        property string nose_cone_status: "normal"
        property string avionics_status: "normal"
        property string upper_tank_status: "normal"
        property string lower_tank_status: "normal"
        property string engine_bay_status: "failed"
        property string engine_status: "warning"
        property string left_fin_status: "normal"
        property string right_fin_status: "normal"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 18
        anchors.margins: 20

        Label {
            text: "Launch Control"
            color: Theme.text_primary
            font: Theme.make_font_audio_wave(2, true, false)
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 18
        
            GlassPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                padding: 18
                width: 100

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12

                    Label {
                        text: "Launch Sequence"
                        color: Theme.text_primary
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
                            color: Theme.text_primary
                            font.pixelSize: 20
                            font.bold: true
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Item {
                                id: rocket_container
                                anchors.fill: parent
                                clip: true

                                Item {
                                    id: rocket
                                    width: 260
                                    height: 790
                                    anchors.centerIn: parent
                                    scale: Math.min(
                                        rocket_container.width / width,
                                        rocket_container.height / height,
                                        1.0
                                    )
                                    transformOrigin: Item.Center

                                    // Nose cone
                                    RocketSegment {
                                        id: nose_cone
                                        x: 95
                                        y: 10
                                        width: 70
                                        height: 120
                                        status: rocket_state.nose_cone_status

                                        Canvas {
                                            anchors.fill: parent
                                            onPaint: {
                                                var ctx = getContext("2d")
                                                ctx.clearRect(0, 0, width, height)
                                                ctx.beginPath()
                                                ctx.moveTo(width / 2, 0)
                                                ctx.lineTo(0, height)
                                                ctx.lineTo(width, height)
                                                ctx.closePath()
                                                ctx.fillStyle = nose_cone.current_color
                                                ctx.fill()
                                                ctx.lineWidth = 3
                                                ctx.strokeStyle = "black"
                                                ctx.stroke()
                                            }
                                        }
                                    }

                                    // Avionics bay
                                    RocketSegment {
                                        id: avionics
                                        x: 80
                                        y: 140
                                        width: 100
                                        height: 80
                                        status: rocket_state.avionics_status

                                        Rectangle {
                                            anchors.fill: parent
                                            color: avionics.current_color
                                            border.color: "black"
                                            border.width: 3
                                        }
                                    }

                                    // Upper tank
                                    RocketSegment {
                                        id: upper_tank
                                        x: 60
                                        y: 230
                                        width: 140
                                        height: 210
                                        status: rocket_state.upper_tank_status
                                        radius: 30

                                        Rectangle {
                                            anchors.fill: parent
                                            radius: 30
                                            color: upper_tank.current_color
                                            border.color: "black"
                                            border.width: 3
                                        }
                                    }

                                    // Lower tank
                                    RocketSegment {
                                        id: lowerTank
                                        x: 60
                                        y: 450
                                        width: 140
                                        height: 170
                                        status: rocket_state.lower_tank_status
                                        radius: 26

                                        Rectangle {
                                            anchors.fill: parent
                                            radius: 26
                                            color: lowerTank.current_color
                                            border.color: "black"
                                            border.width: 3
                                        }
                                    }

                                    // Engine bay
                                    RocketSegment {
                                        id: engineBay
                                        x: 75
                                        y: 630
                                        width: 110
                                        height: 90
                                        status: rocket_state.engine_bay_status
                                        radius: 8

                                        Rectangle {
                                            anchors.fill: parent
                                            color: engineBay.current_color
                                            border.color: "black"
                                            border.width: 3
                                        }
                                    }

                                    // Engine nozzle
                                    RocketSegment {
                                        id: engine
                                        x: 95
                                        y: 735
                                        width: 70
                                        height: 45
                                        status: rocket_state.engine_status

                                        Canvas {
                                            anchors.fill: parent
                                            onPaint: {
                                                var ctx = getContext("2d")
                                                ctx.clearRect(0, 0, width, height)
                                                ctx.beginPath()
                                                ctx.moveTo(10, 0)
                                                ctx.lineTo(width - 10, 0)
                                                ctx.lineTo(width - 20, height)
                                                ctx.lineTo(20, height)
                                                ctx.closePath()
                                                ctx.fillStyle = engine.current_color
                                                ctx.fill()
                                                ctx.lineWidth = 3
                                                ctx.strokeStyle = "black"
                                                ctx.stroke()
                                            }
                                        }
                                    }

                                    // Left fin
                                    RocketSegment {
                                        id: left_fin
                                        x: -20
                                        y: 560
                                        width: 70
                                        height: 180
                                        status: rocket_state.left_fin_status

                                        Canvas {
                                            anchors.fill: parent
                                            onPaint: {
                                                var ctx = getContext("2d")
                                                ctx.clearRect(0, 0, width, height)
                                                ctx.beginPath()
                                                ctx.moveTo(width, 0)
                                                ctx.lineTo(0, 120)
                                                ctx.lineTo(0, height)
                                                ctx.lineTo(width, height)
                                                ctx.closePath()
                                                ctx.fillStyle = left_fin.current_color
                                                ctx.fill()
                                                ctx.lineWidth = 3
                                                ctx.strokeStyle = "black"
                                                ctx.stroke()
                                            }
                                        }
                                    }

                                    // Right fin
                                    RocketSegment {
                                        id: right_fin
                                        x: 210
                                        y: 560
                                        width: 70
                                        height: 180
                                        status: rocket_state.right_fin_status

                                        Canvas {
                                            anchors.fill: parent
                                            onPaint: {
                                                var ctx = getContext("2d")
                                                ctx.clearRect(0, 0, width, height)
                                                ctx.beginPath()
                                                ctx.moveTo(0, 0)
                                                ctx.lineTo(width, 120)
                                                ctx.lineTo(width, height)
                                                ctx.lineTo(0, height)
                                                ctx.closePath()
                                                ctx.fillStyle = right_fin.current_color
                                                ctx.fill()
                                                ctx.lineWidth = 3
                                                ctx.strokeStyle = "black"
                                                ctx.stroke()
                                            }
                                        }
                                    }
                                }

                                // demo -> simulate status changes
                                Timer {
                                    interval: 2000
                                    running: true
                                    repeat: true
                                    onTriggered: {
                                        rocket_state.engine_bay_status =
                                                rocket_state.engine_bay_status === "failed" ? "normal" : "failed"
                                    }
                                }
                            }
                        }

                        Label {
                            text: "Safety interlocks are simulated."
                            color: Theme.text_muted
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