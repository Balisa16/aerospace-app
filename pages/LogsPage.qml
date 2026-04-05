import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Aerospace 1.0

Item {
    id: root
    property QtObject theme

    property var logModel: [
        { "time": "18:02:11", "level": "INFO",  "message": "Ground network sync completed." },
        { "time": "18:03:47", "level": "INFO",  "message": "Vehicle power bus transferred to internal mode." },
        { "time": "18:05:19", "level": "WARN",  "message": "Battery bus B drift detected. Monitoring trend." },
        { "time": "18:06:03", "level": "INFO",  "message": "Propellant loading valve response nominal." },
        { "time": "18:07:28", "level": "INFO",  "message": "Autosequence controller heartbeat green." },
        { "time": "18:08:50", "level": "ERROR", "message": "Simulated sensor timeout on non-critical thermal channel." },
        { "time": "18:09:22", "level": "INFO",  "message": "Fallback telemetry route engaged successfully." },
        { "time": "18:09:23", "level": "INFO",  "message": "Fallback telemetry route engaged successfully." },
        { "time": "18:09:24", "level": "INFO",  "message": "Fallback telemetry route engaged successfully." }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 18
        anchors.margins: 20

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: "Flight Logs"
                color: Theme.text_primary
                font: Theme.make_font_audio_wave(2, true, false)
            }

            Item { Layout.fillWidth: true }

            GlassButton {
                text: "Export Logs"
            }
        }

        LogView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            modelData: root.logModel
        }
    }
}