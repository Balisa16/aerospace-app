import QtQuick
import QtQuick.Effects
import Aerospace 1.0

Item {
    id: root

    property real radius: 28
    property real padding: 0
    property int title_height: parent.height * 0.33

    default property alias content: contentItem.data

    clip: true

    // Rectangle {
    //     id: base
    //     anchors.fill: parent
    //     radius: root.radius
    //     color: Theme.panel_fill
    //     border.width: 1
    //     border.color: Theme.border_color
    //     opacity: 0.18
    // }

    Rectangle {
        id: tintLayer
        anchors.fill: parent
        radius: root.radius
        color: Theme.panel_tint
        opacity: 0.26
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Theme.panel_overlay
        opacity: 0.12
        border.width: 1
        border.color: Theme.border_color_strong
    }

    Rectangle {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        height: root.title_height
        radius: root.radius
        color: "white"
        opacity: 0.08
        visible: root.title_height < 1 ? false : true;
    }

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.margins: root.padding
    }
}