import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Aerospace 1.0

Item {
    id: root

    property int mode: Theme.ButtonMode.Text
    property string content: ""
    property int contentSize: 14
    property color contentColor: Theme.text_primary
    property color hoverTint: Qt.rgba(1, 1, 1, 0.15)

    signal clicked()

    width: 28
    height: 28

    property real scaleValue: 1.0

    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: root.scaleValue
        yScale: root.scaleValue
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: width / 2
        color: mouse.containsMouse ? root.hoverTint : Qt.rgba(1, 1, 1, 0.08)
        border.width: 1
        border.color: mouse.containsMouse ? Theme.border_color_strong : Theme.border_color

        Behavior on color { ColorAnimation { duration: 140 } }
        Behavior on border.color { ColorAnimation { duration: 140 } }
    }

    Text {
        anchors.centerIn: parent
        text: root.mode === Theme.ButtonMode.Text ? root.content : ""
        color: root.contentColor
        font.pixelSize: root.contentSize
        font.bold: true
        visible: root.mode === Theme.ButtonMode.Text
    }

    Image {
        id: iconMask
        anchors.centerIn: parent
        source: root.mode === Theme.ButtonMode.Icon ? root.content : ""
        width: root.contentSize
        height: root.contentSize
        visible: false
        smooth: true
        mipmap: true
    }

    Rectangle {
        id: iconColorSource
        anchors.centerIn: parent
        width: root.contentSize
        height: root.contentSize
        color: root.contentColor
        visible: false
    }

    OpacityMask {
        anchors.centerIn: parent
        width: root.contentSize
        height: root.contentSize
        visible: root.mode === Theme.ButtonMode.Icon

        source: iconColorSource
        maskSource: iconMask
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: root.scaleValue = 0.90
        onReleased: {
            root.scaleValue = 1.0
            root.clicked()
        }
        onCanceled: root.scaleValue = 1.0
    }

    Behavior on scaleValue {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }
}