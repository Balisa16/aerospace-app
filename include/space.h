#pragma once

#include <QDateTime>
#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QVector3D>
#include <QtQml/qqmlregistration.h>
#include <cmath>

class Space : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(double earth_radius_km READ get_earth_radius_km CONSTANT)
    Q_PROPERTY(double km_to_unit READ get_km_to_unit CONSTANT)
    Q_PROPERTY(double primitive_sphere_radius READ get_primitive_sphere_radius
                   CONSTANT)
    Q_PROPERTY(double lon_offset_deg READ get_lon_offset_deg CONSTANT)
    Q_PROPERTY(double earth_meridian_offset_deg READ
                   get_earth_meridian_offset_deg CONSTANT)

    Q_PROPERTY(double earth_radius_units READ get_earth_radius_units CONSTANT)
    Q_PROPERTY(double earth_scale READ get_earth_scale CONSTANT)
    Q_PROPERTY(double atmosphere_scale READ get_atmosphere_scale CONSTANT)

  public:
    explicit Space(QObject *parent = nullptr);

    Q_INVOKABLE double clamp(double v, double lo, double hi) const;
    Q_INVOKABLE double lerp(double a, double b, double t) const;
    Q_INVOKABLE double deg_to_rad(double deg) const;
    Q_INVOKABLE double rad_to_deg(double rad) const;

    Q_INVOKABLE QVector3D normalize(const QVector3D &v) const;

    // latitude, longitude, altitude -> cartesian
    Q_INVOKABLE QVector3D lla_to_xyz(double lat_deg, double lon_deg,
                                     double alt_km) const;

    // latitude, longitude -> normalized outward direction
    Q_INVOKABLE QVector3D ll_to_dir(double lat_deg, double lon_deg) const;

    // camera orbit helper
    Q_INVOKABLE QVector3D orbit_camera_position(double yaw_deg,
                                                double pitch_deg,
                                                double distance) const;

    // yaw for ISS orientation from its position
    Q_INVOKABLE double yaw_from_position(const QVector3D &pos) const;

    // unix timestamp -> UTC string
    Q_INVOKABLE QString format_utc(qint64 ts) const;

    Q_INVOKABLE QVariantMap solar_param(const QDateTime &utc_dt) const;
    Q_INVOKABLE QVariantMap subsolar_pt(const QDateTime &utc_dt) const;

    Q_INVOKABLE QVector3D
    sun_direction_from_datetime(const QDateTime &utc_dt) const;
    Q_INVOKABLE QVector3D
    sun_rig_rotation_from_direction(const QVector3D &sun_direction) const;

    Q_INVOKABLE QVariantList build_trail_timestamps(qint64 now_ts,
                                                    int trail_duration_sec,
                                                    int trail_step_sec) const;

    Q_INVOKABLE QVariantList chunk_array(const QVariantList &input,
                                         int chunk_size) const;

    Q_INVOKABLE QVariantList
    rebuild_trail_points(const QVariantList &raw_points, qint64 now_ts,
                         int trail_duration_sec) const;

    Q_INVOKABLE QVariantList
    predict_trajectory_points(const QVariantList &raw_points,
                              int predict_duration_sec, int step_sec) const;

    Q_INVOKABLE QVariantList build_line_segments(
        const QVariantList &points, double thickness = 0.003) const;

    double get_earth_radius_km() const;
    double get_km_to_unit() const;
    double get_primitive_sphere_radius() const;
    double get_lon_offset_deg() const;
    double get_earth_meridian_offset_deg() const;

    double get_earth_radius_units() const;
    double get_earth_scale() const;
    double get_atmosphere_scale() const;

  private:
    int day_of_year_utc(const QDateTime &utc_dt) const;

    QVector3D rotate_around_axis(const QVector3D &v, const QVector3D &axis,
                                 double angle_rad) const;
    QVector3D estimate_orbit_normal(const QVariantList &raw_points) const;
    double angle_between(const QVector3D &a, const QVector3D &b) const;

  private:
    static constexpr double earth_radius_km_ = 6371.0008;
    static constexpr double km_to_unit_ = 0.01;
    static constexpr double primitive_sphere_radius_ = 50.0;
    static constexpr double lon_offset_deg_ = -90.0;
    static constexpr double earth_meridian_offset_deg_ = 0.0;

    double earth_radius_units_;
    double earth_scale_;
    double atmosphere_scale_;
};