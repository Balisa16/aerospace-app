import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
    id: root

    property string symbol: "×"
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
        border.color: mouse.containsMouse ? Theme.borderStrong : Theme.border

        Behavior on color { ColorAnimation { duration: 140 } }
        Behavior on border.color { ColorAnimation { duration: 140 } }
    }

    Text {
        anchors.centerIn: parent
        text: root.symbol
        color: Theme.textPrimary
        font.pixelSize: 14
        font.bold: true
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