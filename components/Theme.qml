pragma Singleton
import QtQuick

QtObject {
    id: root

    property bool dark_mode: true

    readonly property FontLoader audio_wave_font: FontLoader {
        source: "qrc:/qt/qml/Aerospace/assets/fonts/Audiowide/Audiowide-Regular.ttf"
    }

    readonly property FontLoader sn_pro_font: FontLoader {
        source: "qrc:/qt/qml/Aerospace/assets/fonts/SN_Pro/static/SNPro-Regular.ttf"
    }

    Component.onCompleted: {
        console.log("Status:", audio_wave_font.status === 1 ? "Success": "Failed")
        console.log("Font name:", audio_wave_font.name)

        console.log("Status:", sn_pro_font.status === 1 ? "Success": "Failed")
        console.log("Font name:", sn_pro_font.name)
    }

    function make_font_sn_pro(size_multiplier, is_bold, is_italic) {
        return Qt.font({
            family: sn_pro_font.status === FontLoader.Ready ? sn_pro_font.name : "Helvetica",
            pixelSize: 12 * size_multiplier,
            bold: is_bold || false,
            italic: is_italic || false
        })
    }

    function make_font_audio_wave(size_multiplier, is_bold, is_italic) {
        return Qt.font({
            family: audio_wave_font.status === FontLoader.Ready ? audio_wave_font.name : "Helvetica",
            pixelSize: 12 * size_multiplier,
            bold: is_bold || false,
            italic: is_italic || false
        })
    }


    readonly property color window_bg: dark_mode ? '#212121' : '#ffeeee'
    readonly property color top_bg: dark_mode ? '#070707' : '#ffe8e8'
    readonly property color bottom_bg: dark_mode ? '#010101' : '#ead5d5'

    readonly property color panel_fill: dark_mode ? "#80FFFFFF" : "#90FFFFFF"
    readonly property color panel_tint: dark_mode ? '#272727' : "#BFD7F2"
    readonly property color panel_overlay: dark_mode ? "#1FFFFFFF" : '#ccd6d6d6'

    readonly property color text_primary: dark_mode ? "#F4F8FF" : "#16324F"
    readonly property color text_secondary: dark_mode ? "#D5E4F7" : "#36526E"
    readonly property color text_muted: dark_mode ? "#93A9C3" : "#5D7793"
    readonly property color button_color: dark_mode ? "#80FFFFFF" : "#90FFFFFF"

    readonly property color accent: dark_mode ? "#6FCBFF" : "#198CFF"
    readonly property color accent_soft: dark_mode ? "#335E8FFF" : "#804AA3FF"
    readonly property color secondary: dark_mode ? "#8DFFDA" : "#00BFA5"
    readonly property color secondary_soft: dark_mode ? "#3345D6B8" : "#6644D4C7"
    readonly property color warning_color: dark_mode ? "#FFB86B" : "#F59E0B"
    readonly property color danger_color: dark_mode ? "#FF7C91" : "#E54B6B"
    readonly property color success_color: dark_mode ? "#7EF0AE" : "#22C55E"

    readonly property color border_color: dark_mode ? "#40FFFFFF" : "#66FFFFFF"
    readonly property color border_color_strong: dark_mode ? "#70BFE2FF" : "#70A7C4E9"
    readonly property color shadow_color: dark_mode ? "#60000000" : "#220B2948"
    
    readonly property int window_radius: 26

    enum APIState{
        OK,
        Init,
        Error
    }

    enum ButtonMode{
        Text,
        Icon
    }
}