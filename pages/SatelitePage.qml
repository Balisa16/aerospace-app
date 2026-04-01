import QtQuick
import QtQuick3D
import QtQuick3D.AssetUtils
import QtQuick.Effects
import Aerospace 1.0

Item {
    id: root
    width: 500
    height: 500
    focus: true

    // Camera controls
    property real yaw: 0
    property real pitch: -20
    property real distance: 220
    property real minDistance: 90
    property real maxDistance: 900

    // Live ISS telemetry
    property real iss_latitude: 0.0
    property real iss_longitude: 0.0
    property real iss_altitude_km: 420.0
    property real iss_velocity_kmh: 0.0
    property string iss_visibility: ""
    property int iss_timestamp: 0
    property string api_status: "Connecting..."
    property int api_state: Theme.APIState.Init

    // Trail settings
    property int trail_duration_sec: 1 * 60 * 60
    property int trail_step_sec: 2 * 60
    property var trail_points: []
    property bool trail_loading: false

    // Sun
    property vector3d sun_direction: Qt.vector3d(1, 0, 0)
    property string subsolar_lat: "0.00°"
    property string subsolar_lon: "0.00°"

    function api_state_color(state) {
        switch (state) {
        case Theme.APIState.OK:
            return Theme.success
        case Theme.APIState.Init:
            return Theme.warning
        case Theme.APIState.Error:
            return Theme.danger
        default:
            return "#d0d7de"
        }
    }

    Space {
        id: space
    }

    function update_iss_position() {
        const pos = space.lla_to_xyz(
            root.iss_latitude,
            root.iss_longitude,
            root.iss_altitude_km
        )

        iss.position = pos

        const yaw_deg = space.yaw_from_position(pos)
        iss.eulerRotation = Qt.vector3d(0, -yaw_deg, 0)
    }

    function update_camera() {
        const pos = space.orbit_camera_position(root.yaw, root.pitch, root.distance)
        camera.position = pos
        camera.eulerRotation = Qt.vector3d(-root.pitch, root.yaw, 0)
    }

    function update_sun_direction() {
        const now = new Date()

        const subsolar = space.subsolar_pt(now)
        const outward = space.sun_direction_from_datetime(now)
        const rig_rotation = space.sun_rig_rotation_from_direction(outward)

        root.sun_direction = outward
        sunRig.eulerRotation = rig_rotation

        root.subsolar_lat = Number(subsolar.lat).toFixed(2) + "°"
        root.subsolar_lon = Number(subsolar.lon).toFixed(2) + "°"
    }

    function fetch_iss_telemetry() {
        const xhr = new XMLHttpRequest()
        const url = "https://api.wheretheiss.at/v1/satellites/25544"

        xhr.open("GET", url)

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return

            if (xhr.status !== 200) {
                root.api_status = "API Error"
                root.api_state = Theme.APIState.Error
                console.log("ISS API HTTP error:", xhr.status, xhr.responseText)
                return
            }

            try {
                const data = JSON.parse(xhr.responseText)

                root.iss_latitude = Number(data.latitude)
                root.iss_longitude = Number(data.longitude)
                root.iss_altitude_km = Number(data.altitude)
                root.iss_velocity_kmh = Number(data.velocity)
                root.iss_visibility = data.visibility ? String(data.visibility) : ""
                root.iss_timestamp = Number(data.timestamp)

                root.update_iss_position()
                root.api_status = "OK"
                root.api_state = Theme.APIState.OK
                root.fetch_iss_trail()
            } catch (e) {
                root.api_status = "Parse Error"
                root.api_state = Theme.APIState.Error
                console.log("ISS API parse error:", e)
            }
        }

        xhr.onerror = function() {
            root.api_status = "Network Error"
            root.api_state = Theme.APIState.Error
            console.log("ISS API network error")
        }

        xhr.send()
    }

    function fetch_iss_trail() {
        if (!root.iss_timestamp || root.trail_loading)
            return

        root.trail_loading = true

        const timestamps = space.build_trail_timestamps(
            root.iss_timestamp,
            root.trail_duration_sec,
            root.trail_step_sec
        )

        const batches = space.chunk_array(timestamps, 10)
        const collected = []

        let completed = 0
        let failed = false

        for (let i = 0; i < batches.length; ++i) {
            fetch_trail_batch(batches[i], function(ok, items_or_error) {
                completed += 1

                if (!ok) {
                    failed = true
                    console.log("Trail batch failed:", items_or_error)
                } else {
                    for (let j = 0; j < items_or_error.length; ++j)
                        collected.push(items_or_error[j])
                }

                if (completed === batches.length) {
                    root.trail_loading = false

                    if (failed && collected.length === 0) {
                        console.log("All trail batches failed")
                        return
                    }

                    collected.sort(function(a, b) {
                        return a.timestamp - b.timestamp
                    })

                    root.trail_points = space.rebuild_trail_points(
                        collected,
                        root.iss_timestamp,
                        root.trail_duration_sec
                    )
                }
            })
        }
    }

    function fetch_trail_batch(timestamp_batch, callback) {
        const xhr = new XMLHttpRequest()
        const url =
            "https://api.wheretheiss.at/v1/satellites/25544/positions?timestamps="
            + timestamp_batch.join(",")

        xhr.open("GET", url)

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return

            if (xhr.status !== 200) {
                callback(false, "HTTP " + xhr.status)
                return
            }

            try {
                const data = JSON.parse(xhr.responseText)
                callback(true, data)
            } catch (e) {
                console.log("JSON parse failed:", e)
                console.log("Bad payload was:", xhr.responseText)
                callback(false, "Parse error: " + e)
            }
        }

        xhr.onerror = function() {
            callback(false, "Network error")
        }

        xhr.send()
    }

    onIss_latitudeChanged: update_iss_position()
    onIss_longitudeChanged: update_iss_position()
    onIss_altitude_kmChanged: update_iss_position()

    Timer {
        id: telemetry_timer
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.fetch_iss_telemetry()
    }

    Timer {
        id: sun_timer
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.update_sun_direction()
    }

    Component.onCompleted: {
        root.update_camera()
        root.update_iss_position()
        root.fetch_iss_telemetry()
        root.update_sun_direction()
    }

    Rectangle {
        id: roundedMask
        anchors.fill: parent
        radius: Theme.windowRadius
        color: "white"
        layer.enabled: true
        visible: false
    }

    Item {
        id: contentLayer
        anchors.fill: parent
        layer.enabled: true
        visible: false

        Image {
            anchors.fill: parent
            source: "qrc:/qt/qml/Aerospace/assets/images/space_2k.png"
            fillMode: Image.PreserveAspectCrop
        }

        View3D {
            id: view3d
            anchors.fill: parent

            environment: SceneEnvironment {
                backgroundMode: SceneEnvironment.SkyBox
                antialiasingMode: SceneEnvironment.MSAA
                antialiasingQuality: SceneEnvironment.High

                lightProbe: Texture {
                    source: "qrc:/qt/qml/Aerospace/assets/images/space_2k.png"
                }

                probeExposure: 1.2
            }

            PerspectiveCamera {
                id: camera
                clipNear: 0.1
                clipFar: 5000
                fieldOfView: 45
            }

            Node {
                id: sunRig
                position: Qt.vector3d(
                    root.sun_direction.x * 1000,
                    root.sun_direction.y * 1000,
                    root.sun_direction.z * 1000
                )

                DirectionalLight {
                    id: sunLight
                    brightness: 1.8
                    castsShadow: true
                    shadowFactor: 35
                }
            }

            Node {
                id: worldRoot

                Model {
                    id: earth
                    source: "#Sphere"
                    scale: Qt.vector3d(
                        space.earth_scale,
                        space.earth_scale,
                        space.earth_scale
                    )

                    materials: DefaultMaterial {
                        lighting: DefaultMaterial.FragmentLighting
                        diffuseMap: Texture {
                            source: "qrc:/qt/qml/Aerospace/assets/images/earth_nasa.png"
                        }
                    }
                }

                Model {
                    id: atmosphere
                    source: "#Sphere"
                    scale: Qt.vector3d(
                        space.atmosphere_scale,
                        space.atmosphere_scale,
                        space.atmosphere_scale
                    )

                    materials: DefaultMaterial {
                        diffuseColor: "#55aaddff"
                        opacity: 0.10
                        lighting: DefaultMaterial.FragmentLighting
                        cullMode: Material.BackFaceCulling
                    }
                }

                Repeater3D {
                    id: trailRepeater
                    model: root.trail_points.length

                    Model {
                        required property int index
                        source: "#Sphere"

                        property var point_data: root.trail_points[index]

                        position: Qt.vector3d(
                            point_data.x,
                            point_data.y,
                            point_data.z
                        )

                        scale: Qt.vector3d(
                            point_data.size,
                            point_data.size,
                            point_data.size
                        )

                        materials: DefaultMaterial {
                            diffuseColor: Qt.rgba(1.0, 0.5, 0.5, point_data.alpha)
                            opacity: point_data.alpha
                            lighting: DefaultMaterial.NoLighting
                        }
                    }
                }

                Node {
                    id: iss
                    position: Qt.vector3d(0, 0, 0)
                    scale: Qt.vector3d(0.1, 0.1, 0.1)

                    RuntimeLoader {
                        id: issLoader
                        source: "qrc:/qt/qml/Aerospace/assets/ISS.glb"

                        onStatusChanged: {
                            if (status === RuntimeLoader.Error) {
                                console.log("ISS load error:", errorString)
                            } else if (status === RuntimeLoader.Success) {
                                console.log("ISS loaded successfully")
                            }
                        }
                    }
                }
            }

            NumberAnimation {
                target: earth
                property: "eulerRotation.y"
                from: 0
                to: 360
                duration: 86400000
                loops: Animation.Infinite
                running: true
            }

            NumberAnimation {
                target: atmosphere
                property: "eulerRotation.y"
                from: 0
                to: 360
                duration: 86400000
                loops: Animation.Infinite
                running: true
            }
        }
    }

    MultiEffect {
        anchors.fill: parent
        source: contentLayer
        maskEnabled: true
        maskSource: roundedMask
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        property real last_x: 0
        property real last_y: 0

        onPressed: (mouse) => {
            last_x = mouse.x
            last_y = mouse.y
        }

        onPositionChanged: (mouse) => {
            if (!pressed)
                return

            const dx = mouse.x - last_x
            const dy = mouse.y - last_y

            root.yaw += dx * 0.35
            root.pitch = space.clamp(root.pitch - dy * 0.25, -85, 85)
            root.update_camera()

            last_x = mouse.x
            last_y = mouse.y
        }

        onWheel: (wheel) => {
            const delta = wheel.angleDelta.y / 120
            root.distance = space.clamp(
                root.distance - delta * 12,
                root.minDistance,
                root.maxDistance
            )
            root.update_camera()
        }

        onDoubleClicked: {
            root.yaw = 0
            root.pitch = -20
            root.distance = 220
            root.update_camera()
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 16
        width: 350
        height: 230
        radius: 14
        color: '#89101418'
        border.color: '#33f78a8a'

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            Text {
                text: "ISS Live View"
                color: "white"
                font.pixelSize: 22
                font.bold: true
            }

            Text {
                textFormat: Text.RichText

                property string status_color: api_state_color(root.api_state)

                text: space.format_utc(root.iss_timestamp)
                    + " <span style='color:" + status_color + ";'>("
                    + root.api_status + ")</span>"

                color: "#d0d7de"
                font.bold: true
                font.pixelSize: 14
            }

            Text {
                text: "Latitude: " + root.iss_latitude.toFixed(6)
                color: "#d0d7de"
                font.pixelSize: 14
            }

            Text {
                text: "Longitude: " + root.iss_longitude.toFixed(6)
                color: "#d0d7de"
                font.pixelSize: 14
            }

            Text {
                text: "Altitude: " + root.iss_altitude_km.toFixed(2) + " km"
                color: "#d0d7de"
                font.pixelSize: 14
            }

            Text {
                text: "Velocity: " + root.iss_velocity_kmh.toFixed(2) + " km/h"
                color: "#d0d7de"
                font.pixelSize: 14
            }

            Text {
                text: "Visibility: " + root.iss_visibility
                color: "#d0d7de"
                font.pixelSize: 14
            }

            Text {
                text: "Sub-solar Lat: " + root.subsolar_lat
                color: "#d0d7de"
                font.pixelSize: 14
            }

            Text {
                text: "Sub-solar Lon: " + root.subsolar_lon
                color: "#d0d7de"
                font.pixelSize: 14
            }
        }
    }
}