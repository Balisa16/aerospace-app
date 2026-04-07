import QtQuick
import Aerospace 1.0

Item {
    id: root

    property string name: ""
    property string status: "normal"
    property color normalColor: "#A8A7C5"
    property color warningColor: Theme.warning_color
    property color failed_color: Theme.danger_color
    property color borderColor: "black"
    property int borderWidth: 2
    property real radius: 12

    // external shape source
    default property alias content: shape_container.data

    readonly property color currentColor: {
        switch (status) {
        case "warning": return warningColor
        case "failed":  return failed_color
        default:        return normalColor
        }
    }

    Item {
        id: shape_container
        anchors.fill: parent
    }

    Rectangle {
        id: blink_overlay
        anchors.fill: parent
        radius: root.radius
        color: root.failed_color
        opacity: 0.0
        visible: root.status === "failed"
        z: 100
    }

    SequentialAnimation {
        id: blink_anim
        running: root.status === "failed"
        loops: Animation.Infinite

        NumberAnimation {
            target: blink_overlay
            property: "opacity"
            from: 0.15
            to: 0.85
            duration: 350
        }
        NumberAnimation {
            target: blink_overlay
            property: "opacity"
            from: 0.85
            to: 0.15
            duration: 350
        }
    }
}