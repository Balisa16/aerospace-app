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
        const double size = lerp(0.006, 0.020, age01);

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