import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Aerospace 1.0

Item {
    id: root

    property QtObject theme
    property var dragTarget
    property int window_radius: implicitHeight
    property bool maximized: false

    signal requestMinimize()
    signal requestMaxRestore()
    signal requestClose()
    signal pageChanged(int page)

    implicitHeight: 40
    implicitWidth: 500

    // Rectangle {
    //     id: barBg
    //     anchors.fill: parent
    //     bottomLeftRadius: root.window_radius
    //     bottomRightRadius: root.window_radius
    //     color: Qt.rgba(1, 1, 1, 0.06)
    //     border.width: 1
    //     border.color: Theme.border_color
    // }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        bottomLeftRadius: root.window_radius
        bottomRightRadius: root.window_radius
        color: Theme.panel_tint
        // opacity: 0.3
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true

        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton && root.dragTarget)
                root.dragTarget.startSystemMove()
        }

        onDoubleClicked: root.requestMaxRestore()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 16
        spacing: 12

        RowLayout {
            id: pageBtn
            spacing: 8

            ControlButton {
                content: "qrc:/qt/qml/Aerospace/assets/icons/rocket-lunch.png"
                mode: Theme.ButtonMode.Icon
                contentColor: Theme.text_primary
                hoverTint: Theme.button_color
                onClicked: root.pageChanged(0)
            }

            ControlButton {
                content: "qrc:/qt/qml/Aerospace/assets/icons/cloud-sun.png"
                mode: Theme.ButtonMode.Icon
                contentColor: Theme.text_primary
                hoverTint: Theme.button_color
                onClicked: root.pageChanged(1)
            }

            ControlButton {
                content: "qrc:/qt/qml/Aerospace/assets/icons/bell.png"
                mode: Theme.ButtonMode.Icon
                contentColor: Theme.text_primary
                hoverTint: Theme.button_color
                onClicked: root.pageChanged(2)
            }
        }

        Item { Layout.fillWidth: true }

        Label {
            text: "Aerospace System"
            color: Theme.text_primary
            font: Theme.make_font_audio_wave(1.2, true, false)
            Layout.alignment: Qt.AlignHCenter
        }

        Item { Layout.fillWidth: true }

        RowLayout {
            spacing: 8

            ControlButton {
                content: "qrc:/qt/qml/Aerospace/assets/icons/minus-small.png"
                mode: Theme.ButtonMode.Icon
                contentColor: Theme.text_primary
                hoverTint: Qt.rgba(1.0, 0.85, 0.2, 0.22)
                onClicked: root.requestMinimize()
            }

            ControlButton {
                content: root.maximized ? "qrc:/qt/qml/Aerospace/assets/icons/square.png" : "qrc:/qt/qml/Aerospace/assets/icons/expand.png"
                mode: Theme.ButtonMode.Icon
                contentColor: Theme.text_primary
                hoverTint: Qt.rgba(0.3, 1.0, 0.5, 0.20)
                onClicked: root.requestMaxRestore()
            }

            ControlButton {
                content: "qrc:/qt/qml/Aerospace/assets/icons/power.png"
                mode: Theme.ButtonMode.Icon
                contentColor: Theme.text_primary
                hoverTint: Theme.danger_color
                onClicked: root.requestClose()
            }
        }
    }
}