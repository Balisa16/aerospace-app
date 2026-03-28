import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Aerospace 1.0

Item {
    id: root

    property QtObject theme
    property var dragTarget
    property int windowRadius: implicitHeight
    property bool maximized: false

    signal requestMinimize()
    signal requestMaxRestore()
    signal requestClose()

    implicitHeight: 40
    implicitWidth: 400

    // Rectangle {
    //     id: barBg
    //     anchors.fill: parent
    //     bottomLeftRadius: root.windowRadius
    //     bottomRightRadius: root.windowRadius
    //     color: Qt.rgba(1, 1, 1, 0.06)
    //     border.width: 1
    //     border.color: Theme.border
    // }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        bottomLeftRadius: root.windowRadius
        bottomRightRadius: root.windowRadius
        color: Theme.panelTint
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

        Item { Layout.fillWidth: true }

        Label {
            text: "Aerospace System"
            color: Theme.textPrimary
            font.pixelSize: 16
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Item { Layout.fillWidth: true }

        RowLayout {
            spacing: 8

            WindowControlButton {
                symbol: "—"
                hoverTint: Qt.rgba(1.0, 0.85, 0.2, 0.22)
                onClicked: root.requestMinimize()
            }

            WindowControlButton {
                symbol: root.maximized ? "❐" : "□"
                hoverTint: Qt.rgba(0.3, 1.0, 0.5, 0.20)
                onClicked: root.requestMaxRestore()
            }

            WindowControlButton {
                symbol: "×"
                hoverTint: Qt.rgba(1.0, 0.35, 0.35, 0.24)
                onClicked: root.requestClose()
            }
        }
    }
}