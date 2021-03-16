#ifndef WALLPAPER_H
#define WALLPAPER_H

#include <QObject>
#include <QDBusInterface>
#include <QProcess>

class Wallpaper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString wallpaper READ wallpaper NOTIFY wallpaperChanged)
    Q_PROPERTY(bool dimsWallpaper READ dimsWallpaper NOTIFY dimsWallpaperChanged)

public:
    explicit Wallpaper(QObject *parent = nullptr);

    QString wallpaper() const;
    bool dimsWallpaper() const;

signals:
    void wallpaperChanged();
    void dimsWallpaperChanged();

private slots:
    void onWallpaperChanged(QString);

private:
    QDBusInterface m_interface;
    QString m_wallpaper;
};

#endif // WALLPAPER_H
