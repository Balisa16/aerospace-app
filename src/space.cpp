#include "space.h"

#include <QDate>
#include <QTime>
#include <algorithm>

Space::Space(QObject *parent)
    : QObject(parent), earth_radius_units_(earth_radius_km_ * km_to_unit_),
      earth_scale_(earth_radius_units_ / primitive_sphere_radius_),
      atmosphere_scale_((earth_radius_units_ * 1.015) /
                        primitive_sphere_radius_) {}

double Space::clamp(double v, double lo, double hi) const {
    return std::max(lo, std::min(hi, v));
}

double Space::lerp(double a, double b, double t) const {
    return a + (b - a) * t;
}

double Space::deg_to_rad(double deg) const { return deg * M_PI / 180.0; }

double Space::rad_to_deg(double rad) const { return rad * 180.0 / M_PI; }

QVector3D Space::normalize(const QVector3D &v) const {
    const float len = v.length();
    if (len < 1e-6f)
        return QVector3D(1.0f, 0.0f, 0.0f);

    return v / len;
}

QVector3D Space::lla_to_xyz(double lat_deg, double lon_deg,
                            double alt_km) const {
    const double radius_units = (earth_radius_km_ + alt_km) * km_to_unit_;

    const double lat_rad = deg_to_rad(lat_deg);
    const double lon_rad = deg_to_rad(lon_deg + lon_offset_deg_);

    const double x = radius_units * std::cos(lat_rad) * std::cos(lon_rad);
    const double y = radius_units * std::sin(lat_rad);
    const double z = -radius_units * std::cos(lat_rad) * std::sin(lon_rad);

    return QVector3D(static_cast<float>(x), static_cast<float>(y),
                     static_cast<float>(z));
}

QVector3D Space::ll_to_dir(double lat_deg, double lon_deg) const {
    const double lat_rad = deg_to_rad(lat_deg);
    const double lon_rad = deg_to_rad(lon_deg + earth_meridian_offset_deg_);

    const double x = std::cos(lat_rad) * std::cos(lon_rad);
    const double y = std::sin(lat_rad);
    const double z = std::cos(lat_rad) * std::sin(lon_rad);

    return normalize(QVector3D(static_cast<float>(x), static_cast<float>(y),
                               static_cast<float>(z)));
}

QVector3D Space::orbit_camera_position(double yaw_deg, double pitch_deg,
                                       double distance) const {
    const double yaw_rad = deg_to_rad(yaw_deg);
    const double pitch_rad = deg_to_rad(pitch_deg);

    const double x = distance * std::cos(pitch_rad) * std::sin(yaw_rad);
    const double y = distance * std::sin(pitch_rad);
    const double z = distance * std::cos(pitch_rad) * std::cos(yaw_rad);

    return QVector3D(static_cast<float>(x), static_cast<float>(y),
                     static_cast<float>(z));
}

double Space::yaw_from_position(const QVector3D &pos) const {
    return std::atan2(static_cast<double>(pos.z()),
                      static_cast<double>(pos.x())) *
           180.0 / M_PI;
}

QString Space::format_utc(qint64 ts) const {
    if (ts <= 0)
        return "-";

    return QDateTime::fromSecsSinceEpoch(ts, Qt::UTC)
        .toString("ddd, dd MMM yyyy hh:mm:ss 'GMT'");
}

int Space::day_of_year_utc(const QDateTime &utc_dt) const {
    return utc_dt.toUTC().date().dayOfYear();
}

QVector3D Space::rotate_around_axis(const QVector3D &v, const QVector3D &axis,
                                    double angle_rad) const {
    const QVector3D k = normalize(axis);

    const double c = std::cos(angle_rad);
    const double s = std::sin(angle_rad);

    return v * c + QVector3D::crossProduct(k, v) * s +
           k * QVector3D::dotProduct(k, v) * (1.0 - c);
}

QVector3D Space::estimate_orbit_normal(const QVariantList &raw_points) const {
    if (raw_points.size() < 3)
        return QVector3D(0.0f, 1.0f, 0.0f);

    QVector3D accum(0.0f, 0.0f, 0.0f);

    for (qsizetype i = 1; i + 1 < raw_points.size(); ++i) {
        const QVariantMap p0 = raw_points[i - 1].toMap();
        const QVariantMap p1 = raw_points[i].toMap();
        const QVariantMap p2 = raw_points[i + 1].toMap();

        const QVector3D v0 = normalize(lla_to_xyz(
            p0.value("latitude").toDouble(), p0.value("longitude").toDouble(),
            p0.value("altitude").toDouble()));

        const QVector3D v1 = normalize(lla_to_xyz(
            p1.value("latitude").toDouble(), p1.value("longitude").toDouble(),
            p1.value("altitude").toDouble()));

        const QVector3D v2 = normalize(lla_to_xyz(
            p2.value("latitude").toDouble(), p2.value("longitude").toDouble(),
            p2.value("altitude").toDouble()));

        QVector3D n1 = QVector3D::crossProduct(v0, v1);
        QVector3D n2 = QVector3D::crossProduct(v1, v2);

        if (n1.lengthSquared() > 1e-8f)
            accum += normalize(n1);

        if (n2.lengthSquared() > 1e-8f)
            accum += normalize(n2);
    }

    if (accum.lengthSquared() < 1e-8f)
        return QVector3D(0.0f, 1.0f, 0.0f);

    return normalize(accum);
}
double Space::angle_between(const QVector3D &a, const QVector3D &b) const {
    const QVector3D na = normalize(a);
    const QVector3D nb = normalize(b);

    const double d = clamp(QVector3D::dotProduct(na, nb), -1.0, 1.0);
    return std::acos(d);
}

QVariantMap Space::solar_param(const QDateTime &utc_dt) const {
    const QDateTime utc = utc_dt.toUTC();
    const int year = utc.date().year();
    const bool is_leap = QDate::isLeapYear(year);
    const int days_in_year = is_leap ? 366 : 365;

    const int doy = day_of_year_utc(utc);
    const QTime t = utc.time();

    const double frac_hour = static_cast<double>(t.hour()) +
                             static_cast<double>(t.minute()) / 60.0 +
                             static_cast<double>(t.second()) / 3600.0;

    const double gamma =
        2.0 * M_PI / static_cast<double>(days_in_year) *
        (static_cast<double>(doy) - 1.0 + (frac_hour - 12.0) / 24.0);

    const double eqtime_min =
        229.18 *
        (0.000075 + 0.001868 * std::cos(gamma) - 0.032077 * std::sin(gamma) -
         0.014615 * std::cos(2.0 * gamma) - 0.040849 * std::sin(2.0 * gamma));

    const double decl_rad =
        0.006918 - 0.399912 * std::cos(gamma) + 0.070257 * std::sin(gamma) -
        0.006758 * std::cos(2.0 * gamma) + 0.000907 * std::sin(2.0 * gamma) -
        0.002697 * std::cos(3.0 * gamma) + 0.001480 * std::sin(3.0 * gamma);

    QVariantMap result;
    result["eqtime_min"] = eqtime_min;
    result["decl_rad"] = decl_rad;
    return result;
}

QVariantMap Space::subsolar_pt(const QDateTime &utc_dt) const {
    const QDateTime utc = utc_dt.toUTC();
    const QVariantMap solar = solar_param(utc);

    const double decl_rad = solar.value("decl_rad").toDouble();
    const double eqtime_min = solar.value("eqtime_min").toDouble();

    const QTime t = utc.time();
    const double utc_minutes = static_cast<double>(t.hour()) * 60.0 +
                               static_cast<double>(t.minute()) +
                               static_cast<double>(t.second()) / 60.0;

    QVariantMap result;
    result["lat"] = rad_to_deg(decl_rad);
    result["lon"] = 180.0 - (utc_minutes + eqtime_min) / 4.0;
    return result;
}

QVector3D Space::sun_direction_from_datetime(const QDateTime &utc_dt) const {
    const QVariantMap subsolar = subsolar_pt(utc_dt);
    const double lat = subsolar.value("lat").toDouble();
    const double lon = subsolar.value("lon").toDouble();
    return ll_to_dir(lat, lon);
}

QVector3D
Space::sun_rig_rotation_from_direction(const QVector3D &sun_direction) const {
    const QVector3D d = normalize(-sun_direction);
    const double yaw_deg =
        std::atan2(static_cast<double>(d.x()), static_cast<double>(d.z())) *
        180.0 / M_PI;

    const double pitch_deg =
        -std::atan2(
            static_cast<double>(d.y()),
            std::sqrt(static_cast<double>(d.x() * d.x() + d.z() * d.z()))) *
        180.0 / M_PI;

    return QVector3D(static_cast<float>(pitch_deg), static_cast<float>(yaw_deg),
                     0.0f);
}

QVariantList Space::build_trail_timestamps(qint64 now_ts,
                                           int trail_duration_sec,
                                           int trail_step_sec) const {
    QVariantList result;

    if (now_ts <= 0 || trail_duration_sec <= 0 || trail_step_sec <= 0)
        return result;

    const qint64 start_ts = now_ts - trail_duration_sec;

    for (qint64 ts = start_ts; ts <= now_ts; ts += trail_step_sec)
        result.push_back(ts);

    if (result.isEmpty() || result.back().toLongLong() != now_ts)
        result.push_back(now_ts);

    return result;
}

QVariantList Space::chunk_array(const QVariantList &input,
                                int chunk_size) const {
    QVariantList chunks;

    if (chunk_size <= 0)
        return chunks;

    for (qsizetype i = 0; i < input.size(); i += chunk_size) {
        QVariantList chunk;

        const qsizetype end = std::min(i + chunk_size, input.size());

        for (qsizetype j = i; j < end; ++j)
            chunk.push_back(input[j]);

        chunks.push_back(chunk);
    }

    return chunks;
}

QVariantList Space::predict_trajectory_points(const QVariantList &raw_points,
                                              int predict_duration_sec,
                                              int step_sec) const {
    QVariantList pts;

    if (raw_points.size() < 2 || predict_duration_sec <= 0 || step_sec <= 0)
        return pts;

    QVariantList sorted = raw_points;
    std::sort(sorted.begin(), sorted.end(),
              [](const QVariant &a, const QVariant &b) {
                  return a.toMap().value("timestamp").toLongLong() <
                         b.toMap().value("timestamp").toLongLong();
              });

    const QVariantMap last0 = sorted[sorted.size() - 2].toMap();
    const QVariantMap last1 = sorted[sorted.size() - 1].toMap();

    const qint64 ts0 = last0.value("timestamp").toLongLong();
    const qint64 ts1 = last1.value("timestamp").toLongLong();
    const qint64 dt = ts1 - ts0;

    if (dt <= 0)
        return pts;

    const QVector3D p0 = lla_to_xyz(last0.value("latitude").toDouble(),
                                    last0.value("longitude").toDouble(),
                                    last0.value("altitude").toDouble());

    const QVector3D p1 = lla_to_xyz(last1.value("latitude").toDouble(),
                                    last1.value("longitude").toDouble(),
                                    last1.value("altitude").toDouble());

    const QVector3D orbit_normal = estimate_orbit_normal(sorted);

    const double r0 = p0.length();
    const double r1 = p1.length();
    const double orbit_radius = (r0 + r1) * 0.5;

    QVector3D cur = normalize(p1) * orbit_radius;

    double ang_step = angle_between(p0, p1) / static_cast<double>(dt);

    const double orient =
        QVector3D::dotProduct(orbit_normal, QVector3D::crossProduct(p0, p1));

    if (orient < 0.0)
        ang_step = -ang_step;

    for (int t = step_sec; t <= predict_duration_sec; t += step_sec) {
        const double ang = ang_step * static_cast<double>(t);
        const QVector3D pos = rotate_around_axis(cur, orbit_normal, ang);

        QVariantMap pt;
        pt["x"] = pos.x();
        pt["y"] = pos.y();
        pt["z"] = pos.z();
        pt["alpha"] = lerp(0.95, 0.25,
                           static_cast<double>(t) /
                               static_cast<double>(predict_duration_sec));
        pt["size"] = lerp(0.010, 0.006,
                          static_cast<double>(t) /
                              static_cast<double>(predict_duration_sec));
        pt["t_sec"] = t;

        pts.push_back(pt);
    }

    return pts;
}

QVariantList Space::build_line_segments(const QVariantList &points,
                                        double thickness) const {
    QVariantList segments;

    if (points.size() < 2)
        return segments;

    for (qsizetype i = 1; i < points.size(); ++i) {
        const QVariantMap a = points[i - 1].toMap();
        const QVariantMap b = points[i].toMap();

        const QVector3D p0(a.value("x").toFloat(), a.value("y").toFloat(),
                           a.value("z").toFloat());

        const QVector3D p1(b.value("x").toFloat(), b.value("y").toFloat(),
                           b.value("z").toFloat());

        const QVector3D d = p1 - p0;
        const float len = d.length();

        if (len < 1e-6f)
            continue;

        const QVector3D mid = (p0 + p1) * 0.5f;
        const QVector3D dir = d / len;

        const QVector3D yAxis(0.0f, 1.0f, 0.0f);
        const QVector3D rotAxis = QVector3D::crossProduct(yAxis, dir);

        const double dot = clamp(QVector3D::dotProduct(yAxis, dir), -1.0, 1.0);
        const double angleDeg = rad_to_deg(std::acos(dot));

        QVariantMap seg;
        seg["mx"] = mid.x();
        seg["my"] = mid.y();
        seg["mz"] = mid.z();

        seg["ax"] = rotAxis.x();
        seg["ay"] = rotAxis.y();
        seg["az"] = rotAxis.z();
        seg["angleDeg"] = angleDeg;

        seg["length"] = len;
        seg["thickness"] = thickness;

        seg["alpha"] = b.value("alpha").toDouble(); // far segments will fade

        segments.push_back(seg);
    }

    return segments;
}

QVariantList Space::rebuild_trail_points(const QVariantList &raw_points,
                                         qint64 now_ts,
                                         int trail_duration_sec) const {
    QVariantList pts;

    if (trail_duration_sec <= 0)
        return pts;

    const double trail_start_ts =
        static_cast<double>(now_ts - trail_duration_sec);

    for (const QVariant &item : raw_points) {
        const QVariantMap p = item.toMap();

        const double lat = p.value("latitude").toDouble();
        const double lon = p.value("longitude").toDouble();
        const double alt = p.value("altitude").toDouble();
        const qint64 ts = p.value("timestamp").toLongLong();

        const QVector3D pos = lla_to_xyz(lat, lon, alt);

        const double age01 = clamp((static_cast<double>(ts) - trail_start_ts) /
                                       static_cast<double>(trail_duration_sec),
                                   0.0, 1.0);

        const double alpha = lerp(0.10, 0.95, age01);
        const double size = lerp(0.006, 0.010, age01);

        QVariantMap pt;
        pt["x"] = pos.x();
        pt["y"] = pos.y();
        pt["z"] = pos.z();
        pt["age01"] = age01;
        pt["alpha"] = alpha;
        pt["size"] = size;
        pt["timestamp"] = ts;

        pts.push_back(pt);
    }

    return pts;
}

double Space::get_earth_radius_km() const { return earth_radius_km_; }

double Space::get_km_to_unit() const { return km_to_unit_; }

double Space::get_primitive_sphere_radius() const {
    return primitive_sphere_radius_;
}

double Space::get_lon_offset_deg() const { return lon_offset_deg_; }

double Space::get_earth_meridian_offset_deg() const {
    return earth_meridian_offset_deg_;
}

double Space::get_earth_radius_units() const { return earth_radius_units_; }

double Space::get_earth_scale() const { return earth_scale_; }

double Space::get_atmosphere_scale() const { return atmosphere_scale_; }