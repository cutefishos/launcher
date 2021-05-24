/*
 * Copyright (C) 2021 CutefishOS.
 *
 * Author:     revenmartin <revenmartin@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "wallpaper.h"

Wallpaper::Wallpaper(QObject *parent)
    : QObject(parent)
    , m_interface("org.cutefish.Settings",
                  "/Theme", "org.cutefish.Theme",
                  QDBusConnection::sessionBus(), this)
{
    if (m_interface.isValid()) {
        connect(&m_interface, SIGNAL(wallpaperChanged(QString)), this, SLOT(onWallpaperChanged(QString)));
        connect(&m_interface, SIGNAL(darkModeDimsWallpaerChanged()), this, SIGNAL(dimsWallpaperChanged()));

        m_wallpaper = m_interface.property("wallpaper").toString();
        emit wallpaperChanged();
    }
}

QString Wallpaper::wallpaper() const
{
    return m_wallpaper;
}

bool Wallpaper::dimsWallpaper() const
{
    return m_interface.property("darkModeDimsWallpaer").toBool();
}

void Wallpaper::onWallpaperChanged(QString path)
{
    if (path != m_wallpaper) {
        m_wallpaper = path;
        emit wallpaperChanged();
    }
}
