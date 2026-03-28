import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Aerospace 1.0

ApplicationWindow {
    id: app
    title: "Aerospace System"
    visible: true
    width: 1480
    height: 920
    minimumWidth: 1100
    minimumHeight: 700

    flags: Qt.FramelessWindowHint
    color: "transparent"

    property int currentPage: 0
    property int resizeMargin: 6
    property bool maximized: visibility === Window.Maximized

    background: Rectangle {
        color: "transparent"
    }
    
    Rectangle {
        anchors.fill: parent
        radius: app.maximized ? 0 : Theme.windowRadius
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.bgTop }
            GradientStop { position: 1.0; color: Theme.bgBottom }
        }
    }

    Item{
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: app.resizeMargin
        z:1000
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.SizeHorCursor
            onPressed: app.startSystemResize(Qt.LeftEdge)
        }
    }

    /* Right Scale */
    Item{
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: app.resizeMargin
        z:1000
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.SizeHorCursor
            onPressed: app.startSystemResize(Qt.RightEdge)
        }
    }

    /* Bottom Scale */
    Item{
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: app.resizeMargin
        z:1000
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.SizeVerCursor
            onPressed: app.startSystemResize(Qt.BottomEdge)
        }
    }

    /* Top Scale*/
    Item{
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: parent.top - app.resizeMargin
        height: app.resizeMargin
        z:1000
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.SizeVerCursor
            onPressed: app.startSystemResize(Qt.TopEdge)
        }
    }

    /* Left-Bottom Scale*/
    Item{
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: app.resizeMargin
        width: app.resizeMargin
        z:1001
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.SizeBDiagCursor
            onPressed: app.startSystemResize(Qt.LeftEdge | Qt.BottomEdge)
        }
    }

    /* Right-Bottom Scale*/
    Item{
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: app.resizeMargin
        width: app.resizeMargin
        z:1001
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.SizeFDiagCursor
            onPressed: app.startSystemResize(Qt.RightEdge | Qt.BottomEdge)
        }
    }

    CustomTitleBar {
        id: titleBar
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        // Layout.fillWidth: true
        Layout.preferredHeight: 40
        windowRadius: Theme.windowRadius
        maximized: app.maximized
        onRequestMinimize: app.showMinimized()
        onRequestMaxRestore: {
            if (app.visibility === Window.Maximized)
                app.showNormal()
            else
                app.showMaximized()
        }
        onRequestClose: exitDialog.open()
        dragTarget: app
        z: 100
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0


        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 18

            GlassPanel {
                Layout.preferredWidth: 310
                title_height: 100
                radius: 20
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 0
                    anchors.leftMargin: 24
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 18
                    spacing: 16

                    Item { Layout.preferredHeight: 8 }

                    RowLayout {
                        spacing: 12
                        anchors.topMargin: 30

                        Rectangle {
                            width: 46
                            height: 46
                            radius: 16
                            color: Theme.accentSoft
                            border.color: Theme.borderStrong
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "🚀"
                                font.pixelSize: 22
                            }
                        }

                        ColumnLayout {
                            spacing: 2

                            Label {
                                text: "Aerospace System"
                                color: Theme.textPrimary
                                font.pixelSize: 22
                                font.bold: true
                            }

                            Label {
                                text: "Mission Control Suite"
                                color: Theme.textMuted
                                font.pixelSize: 12
                            }
                        }
                    }

                    Item { Layout.preferredHeight: 12 }

                    SidebarButton {
                        id: iss_live_btn
                        text: "ISS Live View"
                        iconText: "◫"
                        selected: app.currentPage === 0
                        onClicked: app.currentPage = 0
                    }

                    SidebarButton {
                        text: "Launch Control"
                        iconText: "⬆"
                        selected: app.currentPage === 1
                        onClicked: app.currentPage = 1
                    }

                    SidebarButton {
                        text: "Health Systems"
                        iconText: "◌"
                        selected: app.currentPage === 2
                        onClicked: app.currentPage = 2
                    }

                    SidebarButton {
                        text: "Flight Logs"
                        iconText: "☰"
                        selected: app.currentPage === 3
                        onClicked: app.currentPage = 3
                    }

                    SidebarButton {
                        text: "Settings"
                        iconText: "⚙"
                        selected: app.currentPage === 4
                        onClicked: app.currentPage = 4
                    }

                    Item { Layout.fillHeight: true }

                    GlassPanel {
                        Layout.preferredHeight: 150
                        Layout.preferredWidth: iss_live_btn.buttonWidth
                        padding: 14

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            Label {
                                text: "Mission Status"
                                color: Theme.textMuted
                                font.pixelSize: 12
                            }

                            Label {
                                text: "Vehicle Ready"
                                color: Theme.textPrimary
                                font.pixelSize: 22
                                font.bold: true
                            }

                            Label {
                                text: "All primary systems nominal. Wind and telemetry within launch constraints."
                                color: Theme.textSecondary
                                wrapMode: Text.WrapAnywhere
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }

            Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 20
        color: "transparent"
        clip: true
        layer.enabled: true

        StackLayout {
            anchors.fill: parent
            currentIndex: app.currentPage

            SatelitePage {}
            LaunchPage {}
            HealthPage {}
            LogsPage {}
            SettingsPage {}
        }
    }
        }
    }
    Dialog {
        id: exitDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: 360
        padding: 20
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: 22
            color: Qt.rgba(0.10, 0.14, 0.20, 0.96)
            border.width: 1
            border.color: Theme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: 14

            Label {
                text: "Close Confirmation"
                color: Theme.textPrimary
                font.pixelSize: 18
                font.bold: true
            }

            Label {
                text: "Are you sure you want to close this application?"
                color: Theme.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10

                GlassButton {
                    text: "Cancel"
                    onClicked: exitDialog.close()
                }

                GlassButton {
                    text: "Close"
                    accentColor: Theme.danger
                    onClicked: {
                        exitDialog.close()
                        app.close()
                    }
                }
            }
        }
    }
}