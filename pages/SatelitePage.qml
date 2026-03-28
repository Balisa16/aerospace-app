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

    // World scaling
    readonly property real kmToUnit: 0.01
    readonly property real primitiveSphereRadius: 50.0
    readonly property real earthRadiusKm: 6371.0

    property real earthRadiusUnits: earthRadiusKm * kmToUnit
    property real earthScale: earthRadiusUnits / primitiveSphereRadius
    property real atmosphereScale: (earthRadiusUnits * 1.015) / primitiveSphereRadius

    // Live ISS telemetry
    property real issLatitude: 0.0
    property real issLongitude: 0.0
    property real issAltitudeKm: 420.0
    property real issVelocityKmh: 0.0
    property string issVisibility: ""
    property int issTimestamp: 0
    property string apiStatus: "Connecting..."
    property int apiState: Theme.APIState.Init

    // Trail settings
    property int trailDurationSec: 1 * 60 * 60
    property int trailStepSec: 2 * 60
    property var trailPoints: []
    property bool trailLoading: false

    function apiStateColor(state) {
        switch (state) {
        case Theme.APIState.OK:   return Theme.success
        case Theme.APIState.Init: return Theme.warning
        case Theme.APIState.Error:return Theme.danger
        default:            return "#d0d7de"
        }
    }

    function clamp(v, lo, hi) {
        return Math.max(lo, Math.min(hi, v))
    }

    function lerp(a, b, t) {
        return a + (b - a) * t
    }

    function degToRad(d) {
        return d * Math.PI / 180.0
    }

    function formatUtc(ts) {
        if (!ts || ts <= 0)
            return "-"
        return new Date(ts * 1000).toUTCString()
    }

    function latLonAltToXYZ(latDeg, lonDeg, altKm) {
        const r = (earthRadiusKm + altKm) * kmToUnit

        const lat = degToRad(latDeg)
        const lon = degToRad(lonDeg)

        const x = r * Math.cos(lat) * Math.cos(lon)
        const y = r * Math.sin(lat)
        const z = r * Math.cos(lat) * Math.sin(lon)

        return Qt.vector3d(x, y, z)
    }

    function updateIssPosition() {
        iss.position = latLonAltToXYZ(issLatitude, issLongitude, issAltitudeKm)

        const p = iss.position
        const yawDeg = Math.atan2(p.z, p.x) * 180.0 / Math.PI
        iss.eulerRotation = Qt.vector3d(0, -yawDeg, 0)
    }

    function updateCamera() {
        const yawRad = degToRad(yaw)
        const pitchRad = degToRad(pitch)

        const x = distance * Math.cos(pitchRad) * Math.sin(yawRad)
        const y = distance * Math.sin(pitchRad)
        const z = distance * Math.cos(pitchRad) * Math.cos(yawRad)

        camera.position = Qt.vector3d(x, y, z)
        camera.eulerRotation = Qt.vector3d(-pitch, yaw, 0)
    }

    function fetchIssTelemetry() {
        const xhr = new XMLHttpRequest()
        const url = "https://api.wheretheiss.at/v1/satellites/25544"

        xhr.open("GET", url)

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return

            if (xhr.status !== 200) {
                apiStatus = "API Error"
                apiState = Theme.APIState.Error

                console.log("ISS API HTTP error:", xhr.status, xhr.responseText)
                return
            }

            try {
                const data = JSON.parse(xhr.responseText)

                issLatitude = Number(data.latitude)
                issLongitude = Number(data.longitude)
                issAltitudeKm = Number(data.altitude)
                issVelocityKmh = Number(data.velocity)
                issVisibility = data.visibility ? String(data.visibility) : ""
                issTimestamp = Number(data.timestamp)

                updateIssPosition()
                apiStatus = "OK"
                apiState = Theme.APIState.OK
                fetchIssTrail()
            } catch (e) {
                apiStatus = "Parse Error"
                apiState = Theme.APIState.Error
                console.log("ISS API parse error:", e)
            }
        }

        xhr.onerror = function() {
            apiStatus = "Network Error"
            apiState = Theme.APIState.Error
            console.log("ISS API network error")
        }

        xhr.send()
    }

    function buildTrailTimestamps(nowTs) {
        const result = []
        const startTs = nowTs - trailDurationSec

        for (let ts = startTs; ts <= nowTs; ts += trailStepSec)
            result.push(ts)

        if (result.length === 0 || result[result.length - 1] !== nowTs)
            result.push(nowTs)

        return result
    }

    function chunkArray(input, chunkSize) {
        const chunks = []
        for (let i = 0; i < input.length; i += chunkSize)
            chunks.push(input.slice(i, i + chunkSize))
        return chunks
    }

    function fetchIssTrail() {
        if (!issTimestamp || trailLoading)
            return

        trailLoading = true
        const timestamps = buildTrailTimestamps(issTimestamp)
        const batches = chunkArray(timestamps, 10)
        const collected = []
        let completed = 0
        let failed = false

        for (let i = 0; i < batches.length; ++i) {
            fetchTrailBatch(batches[i], function(ok, itemsOrError) {
                completed += 1

                if (!ok) {
                    failed = true
                    console.log("Trail batch failed:", itemsOrError)
                } else {
                    for (let j = 0; j < itemsOrError.length; ++j)
                        collected.push(itemsOrError[j])
                }

                if (completed === batches.length) {
                    trailLoading = false

                    if (failed && collected.length === 0) {
                        console.log("All trail batches failed")
                        return
                    }

                    collected.sort(function(a, b) { return a.timestamp - b.timestamp })
                    rebuildTrailPoints(collected, issTimestamp)
                }
            })
        }
    }

    function fetchTrailBatch(timestampBatch, callback) {
        const xhr = new XMLHttpRequest()
        const url = "https://api.wheretheiss.at/v1/satellites/25544/positions?timestamps="
                    + timestampBatch.join(",")

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
                callback(false, "Parse error")
            }
        }

        xhr.onerror = function() {
            callback(false, "Network error")
        }

        xhr.send()
    }

    function rebuildTrailPoints(rawPoints, nowTs) {
        const pts = []

        for (let i = 0; i < rawPoints.length; ++i) {
            const p = rawPoints[i]
            const lat = Number(p.latitude)
            const lon = Number(p.longitude)
            const alt = Number(p.altitude)
            const ts = Number(p.timestamp)

            const pos = latLonAltToXYZ(lat, lon, alt)

            const age01 = clamp((ts - (nowTs - trailDurationSec)) / trailDurationSec, 0.0, 1.0)

            const alpha = lerp(0.10, 0.95, age01)
            const size = lerp(0.006, 0.020, age01)

            pts.push({
                x: pos.x,
                y: pos.y,
                z: pos.z,
                age01: age01,
                alpha: alpha,
                size: size,
                timestamp: ts
            })
        }

        trailPoints = pts
    }

    onIssLatitudeChanged: updateIssPosition()
    onIssLongitudeChanged: updateIssPosition()
    onIssAltitudeKmChanged: updateIssPosition()

    Timer {
        id: telemetryTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.fetchIssTelemetry()
    }

    // Sun Light
    property vector3d sunDirection: Qt.vector3d(1, 0, 0)
    property real earthPrimeMeridianOffsetDeg: 0

    function radToDeg(r) {
        return r * 180.0 / Math.PI
    }

    function normalize(v) {
        const len = Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
        if (len < 0.000001)
            return Qt.vector3d(1, 0, 0)
        return Qt.vector3d(v.x / len, v.y / len, v.z / len)
    }

    function dayOfYearUtc(date) {
        const start = Date.UTC(date.getUTCFullYear(), 0, 1)
        const now = Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate())
        return Math.floor((now - start) / 86400000) + 1
    }

    function solarDeclinationAndEqTime(date) {
        const year = date.getUTCFullYear()
        const isLeap = ((year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0))
        const daysInYear = isLeap ? 366 : 365

        const doy = dayOfYearUtc(date)
        const hour = date.getUTCHours()
        const minute = date.getUTCMinutes()
        const second = date.getUTCSeconds()

        const fracHour = hour + minute / 60.0 + second / 3600.0

        const gamma = 2.0 * Math.PI / daysInYear *
                    (doy - 1 + (fracHour - 12.0) / 24.0)

        const eqtime =
                229.18 * (0.000075
                        + 0.001868 * Math.cos(gamma)
                        - 0.032077 * Math.sin(gamma)
                        - 0.014615 * Math.cos(2 * gamma)
                        - 0.040849 * Math.sin(2 * gamma))

        const decl =
                0.006918
                - 0.399912 * Math.cos(gamma)
                + 0.070257 * Math.sin(gamma)
                - 0.006758 * Math.cos(2 * gamma)
                + 0.000907 * Math.sin(2 * gamma)
                - 0.002697 * Math.cos(3 * gamma)
                + 0.00148  * Math.sin(3 * gamma)

        return {
            eqtimeMin: eqtime,
            declRad: decl
        }
    }

    function subsolarPoint(date) {
        const solar = solarDeclinationAndEqTime(date)
        const declDeg = radToDeg(solar.declRad)

        const utcMinutes =
                date.getUTCHours() * 60 +
                date.getUTCMinutes() +
                date.getUTCSeconds() / 60.0

        const lonDeg = 180.0 - (utcMinutes + solar.eqtimeMin) / 4.0

        return {
            latDeg: declDeg,
            lonDeg: lonDeg
        }
    }

    function latLonToDirection(latDeg, lonDeg) {
        const lat = degToRad(latDeg)
        const lon = degToRad(lonDeg + earthPrimeMeridianOffsetDeg)

        const x = Math.cos(lat) * Math.cos(lon)
        const y = Math.sin(lat)
        const z = Math.cos(lat) * Math.sin(lon)

        return normalize(Qt.vector3d(x, y, z))
    }

    function updateSunRigRotation() {
        const d = normalize(Qt.vector3d(-sunDirection.x, -sunDirection.y, -sunDirection.z))
        const yaw = Math.atan2(d.x, d.z) * 180.0 / Math.PI
        const pitch = -Math.atan2(d.y, Math.sqrt(d.x * d.x + d.z * d.z)) * 180.0 / Math.PI
        sunRig.eulerRotation = Qt.vector3d(pitch, yaw, 0)
    }

    property string subsolar_lat: "0.00°"
    property string subsolar_lon: "0.00°"
    function updateSunDirection() {
        const now = new Date()
        const subsolar = subsolarPoint(now)
        const outward = latLonToDirection(subsolar.latDeg, subsolar.lonDeg)

        sunDirection = Qt.vector3d(outward.x, outward.y, outward.z)
        updateSunRigRotation()

        subsolar_lat = subsolar.lonDeg.toFixed(2) + "°"
        subsolar_lon = subsolar.lonDeg.toFixed(2) + "°"
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.updateSunDirection()
    }

    Component.onCompleted: {
        updateCamera()
        updateIssPosition()
        fetchIssTelemetry()
        updateSunDirection()
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

        // Sky you want to keep
        Image {
            anchors.fill: parent
            source: "qrc:/qt/qml/Aerospace/assets/images/space_2k.png"
            fillMode: Image.PreserveAspectCrop
        }


    View3D {
        id: view3d
        anchors.fill: parent
        // visible: false

        environment: SceneEnvironment {
            backgroundMode: SceneEnvironment.SkyBox
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
            // clearColor: "black"

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
                root.sunDirection.x * 1000,
                root.sunDirection.y * 1000,
                root.sunDirection.z * 1000
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
                scale: Qt.vector3d(root.earthScale, root.earthScale, root.earthScale)

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
                scale: Qt.vector3d(root.atmosphereScale, root.atmosphereScale, root.atmosphereScale)

                materials: DefaultMaterial {
                    diffuseColor: "#55aaddff"
                    opacity: 0.10
                    lighting: DefaultMaterial.FragmentLighting
                    cullMode: Material.BackFaceCulling
                }
            }

            Repeater3D {
                id: trailRepeater
                model: root.trailPoints.length

                Model {
                    required property int index
                    source: "#Sphere"

                    property var pointData: root.trailPoints[index]

                    position: Qt.vector3d(pointData.x, pointData.y, pointData.z)
                    scale: Qt.vector3d(pointData.size, pointData.size, pointData.size)

                    materials: DefaultMaterial {
                        // White trail with alpha fading by age
                        diffuseColor: Qt.rgba(1.0, .5, .5, pointData.alpha)
                        opacity: pointData.alpha
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

            // Model {
            //     id: issDebugMarker
            //     source: "#Sphere"
            //     position: iss.position
            //     scale: Qt.vector3d(0.025, 0.025, 0.025)

            //     materials: DefaultMaterial {
            //         diffuseColor: "red"
            //         lighting: DefaultMaterial.NoLighting
            //     }
            // }
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

        property real lastX: 0
        property real lastY: 0

        onPressed: (mouse) => {
            lastX = mouse.x
            lastY = mouse.y
        }

        onPositionChanged: (mouse) => {
            if (!pressed)
                return

            const dx = mouse.x - lastX
            const dy = mouse.y - lastY

            root.yaw += dx * 0.35
            root.pitch = root.clamp(root.pitch - dy * 0.25, -85, 85)
            root.updateCamera()

            lastX = mouse.x
            lastY = mouse.y
        }

        onWheel: (wheel) => {
            const delta = wheel.angleDelta.y / 120
            root.distance = root.clamp(root.distance - delta * 12, root.minDistance, root.maxDistance)
            root.updateCamera()
        }

        onDoubleClicked: {
            root.yaw = 0
            root.pitch = -20
            root.distance = 220
            root.updateCamera()
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

                property string statusColor: apiStateColor(root.apiState)

                text: root.formatUtc(root.issTimestamp)
                    + " <span style='color:" + statusColor + ";'>("
                    + root.apiStatus + ")</span>"

                color: "#d0d7de"
                font.bold: true
                font.pixelSize: 14
            }

            Text {
                text: "Latitude: " + root.issLatitude.toFixed(6)
                color: "#d0d7de"
                font.pixelSize: 14
            }

            Text {
                text: "Longitude: " + root.issLongitude.toFixed(6)
                color: "#d0d7de"
                font.pixelSize: 14
            }

            Text {
                text: "Altitude: " + root.issAltitudeKm.toFixed(2) + " km"
                color: "#d0d7de"
                font.pixelSize: 14
            }

            Text {
                text: "Velocity: " + root.issVelocityKmh.toFixed(2) + " km/h"
                color: "#d0d7de"
                font.pixelSize: 14
            }

            Text {
                text: "Visibility: " + root.issVisibility
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