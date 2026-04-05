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
        id: app_frame
        anchors.fill: parent
        radius: app.maximized ? 0 : Theme.window_radius
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.top_bg }
            GradientStop { position: 1.0; color: Theme.bottom_bg }
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

    TitleBar {
        id: titleBar
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        // Layout.fillWidth: true
        Layout.preferredHeight: 40
        window_radius: Theme.window_radius
        maximized: app.maximized
        onRequestMinimize: app.showMinimized()
        onRequestMaxRestore: {
            if (app.visibility === Window.Maximized)
            {
                app.showNormal()
                app_frame.radius = Theme.window_radius
                satellites_page.window_radius = Theme.window_radius
            }
            else
            {
                app.showMaximized()
                app_frame.radius = 0
                satellites_page.window_radius = 0
            }
        }
        onRequestClose: exitDialog.open()
        dragTarget: app
        z: 100
        onPageChanged: function(page){
            app.currentPage = page
        }
    }


    StackLayout {
        anchors.fill: parent
        currentIndex: app.currentPage

        SatelitePage {
            id:satellites_page
        }
        LaunchPage {}
        LogsPage {}
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
            border.color: Theme.border_color_strong
        }

        contentItem: ColumnLayout {
            spacing: 14

            Label {
                text: "Close Confirmation"
                color: Theme.text_primary
                font: Theme.make_font_audio_wave(1.2, true, false)
            }

            Label {
                text: "Are you sure you want to close this application?"
                color: Theme.text_secondary
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
                    buttonColor: Theme.danger_color
                    onClicked: {
                        exitDialog.close()
                        app.close()
                    }
                }
            }
        }
    }
}