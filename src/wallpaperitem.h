#ifndef WALLPAPERITEM_H
#define WALLPAPERITEM_H

#include <QQuickPaintedItem>
#include <QDBusInterface>
#include <QPixmap>

class WallpaperItem : public QQuickPaintedItem
{
    Q_OBJECT

public:
    explicit WallpaperItem(QQuickItem *parent = nullptr);

    void paint(QPainter *painter) override;
    void geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry) override;

private:
    void loadWallpaperPixmap();

private slots:
    void onWallpaperChanged(QString wallpaper);

private:
    QPixmap m_pixmap;
    QDBusInterface m_interface;
    QString m_wallpaper;
};

#endif // WALLPAPERITEM_H
