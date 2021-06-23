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

#include "launcher.h"
#include "launcheradaptor.h"
#include "iconthemeimageprovider.h"

#include <QDBusConnection>
#include <QQmlContext>
#include <QScreen>
#include <QTimer>

#include <KWindowSystem>

Launcher::Launcher(QQuickView *w)
  : QQuickView(w)
  , m_hideTimer(new QTimer)
  , m_showed(false)
{
    m_screenAvailableRect = qApp->primaryScreen()->availableGeometry();

    new LauncherAdaptor(this);

    engine()->rootContext()->setContextProperty("launcher", this);

    setColor(Qt::transparent);
    setFlags(Qt::FramelessWindowHint);
    setResizeMode(QQuickView::SizeRootObjectToView);
    setClearBeforeRendering(true);
    setScreen(qApp->primaryScreen());
    onGeometryChanged();

    setSource(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    setTitle(tr("Launcher"));
    setVisible(false);

    // Let the animation in qml be hidden after the execution is complete
    m_hideTimer->setInterval(200);
    m_hideTimer->setSingleShot(true);
    connect(m_hideTimer, &QTimer::timeout, this, [=] { setVisible(false); });

    connect(qApp->primaryScreen(), &QScreen::virtualGeometryChanged, this, &Launcher::onGeometryChanged);
    connect(qApp->primaryScreen(), &QScreen::geometryChanged, this, &Launcher::onGeometryChanged);
    connect(qApp->primaryScreen(), &QScreen::availableGeometryChanged, this, &Launcher::onAvailableGeometryChanged);
    connect(this, &QQuickView::activeChanged, this, &Launcher::onActiveChanged);
}

bool Launcher::showed()
{
    return m_showed;
}

void Launcher::showWindow()
{
    m_showed = true;
    emit showedChanged();

    setVisible(true);
}

void Launcher::hideWindow()
{
    m_showed = false;
    emit showedChanged();

    setVisible(false);
}

void Launcher::toggle()
{
    isVisible() ? Launcher::hideWindow() : Launcher::showWindow();
}

QRect Launcher::screenRect()
{
    return m_screenRect;
}

QRect Launcher::screenAvailableRect()
{
    return m_screenAvailableRect;
}

void Launcher::onGeometryChanged()
{
    if (m_screenRect != qApp->primaryScreen()->geometry()) {
        m_screenRect = qApp->primaryScreen()->geometry();
        setGeometry(m_screenRect);
        emit screenRectChanged();
    }
}

void Launcher::onAvailableGeometryChanged(const QRect &geometry)
{
    m_screenAvailableRect = geometry;
    emit screenAvailableGeometryChanged();
}

void Launcher::showEvent(QShowEvent *e)
{
    KWindowSystem::setState(winId(), NET::SkipTaskbar | NET::SkipPager);

    QQuickView::showEvent(e);
}

void Launcher::resizeEvent(QResizeEvent *e)
{
    // The window manager forces the size.
    e->ignore();
}

void Launcher::onActiveChanged()
{
    if (!isActive())
        Launcher::hide();
}

