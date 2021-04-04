#include "wallpaperitem.h"
#include <QPainter>
#include <QPixmapCache>

WallpaperItem::WallpaperItem(QQuickItem *parent)
    : QQuickPaintedItem(parent)
    , m_interface("org.cutefish.Settings",
                  "/Theme", "org.cutefish.Theme",
                  QDBusConnection::sessionBus(), this)
{
    if (m_interface.isValid()) {
        connect(&m_interface, SIGNAL(wallpaperChanged(QString)), this, SLOT(onWallpaperChanged(QString)));
        m_wallpaper = m_interface.property("wallpaper").toString();
        loadWallpaperPixmap();
    }
}

void WallpaperItem::paint(QPainter *painter)
{
    painter->drawPixmap(QRect(0, 0, width(), height()), m_pixmap);
}

void WallpaperItem::geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    Q_UNUSED(newGeometry);
    Q_UNUSED(oldGeometry);

    loadWallpaperPixmap();
}

void WallpaperItem::loadWallpaperPixmap()
{
    // Clear cache.
    m_pixmap = QPixmap();
    QPixmapCache::clear();

    if (m_wallpaper.isEmpty())
        return;

    m_pixmap = QPixmap(m_wallpaper).scaled(QSize(width(), height()),
                                           Qt::KeepAspectRatioByExpanding);

    QQuickPaintedItem::update();
}

void WallpaperItem::onWallpaperChanged(QString wallpaper)
{
    m_wallpaper = wallpaper;
    loadWallpaperPixmap();
}
