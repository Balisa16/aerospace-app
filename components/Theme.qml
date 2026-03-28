pragma Singleton
import QtQuick

QtObject {
    id: root

    property bool darkMode: true

    readonly property color windowBg: darkMode ? '#212121' : '#ffeeee'
    readonly property color bgTop: darkMode ? '#070707' : '#ffe8e8'
    readonly property color bgBottom: darkMode ? '#010101' : '#ead5d5'

    readonly property color panelFill: darkMode ? "#80FFFFFF" : "#90FFFFFF"
    readonly property color panelTint: darkMode ? '#272727' : "#BFD7F2"
    readonly property color panelOverlay: darkMode ? "#1FFFFFFF" : '#ccd6d6d6'

    readonly property color textPrimary: darkMode ? "#F4F8FF" : "#16324F"
    readonly property color textSecondary: darkMode ? "#D5E4F7" : "#36526E"
    readonly property color textMuted: darkMode ? "#93A9C3" : "#5D7793"

    readonly property color accent: darkMode ? "#6FCBFF" : "#198CFF"
    readonly property color accentSoft: darkMode ? "#335E8FFF" : "#804AA3FF"
    readonly property color secondary: darkMode ? "#8DFFDA" : "#00BFA5"
    readonly property color secondarySoft: darkMode ? "#3345D6B8" : "#6644D4C7"
    readonly property color warning: darkMode ? "#FFB86B" : "#F59E0B"
    readonly property color danger: darkMode ? "#FF7C91" : "#E54B6B"
    readonly property color success: darkMode ? "#7EF0AE" : "#22C55E"

    readonly property color border: darkMode ? "#40FFFFFF" : "#66FFFFFF"
    readonly property color borderStrong: darkMode ? "#70BFE2FF" : "#70A7C4E9"
    readonly property color shadow: darkMode ? "#60000000" : "#220B2948"
    
    readonly property int windowRadius: 26

    enum APIState{
        OK,
        Init,
        Error
    }
}