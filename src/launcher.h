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

#ifndef LAUNCHER_H
#define LAUNCHER_H

#include <QGuiApplication>
#include <QQuickView>

class Launcher : public QQuickView
{
    Q_OBJECT
    Q_PROPERTY(QRect screenRect READ screenRect NOTIFY screenRectChanged)
    Q_PROPERTY(QRect screenAvailableRect READ screenAvailableRect NOTIFY screenAvailableGeometryChanged)

public:
    Launcher(QQuickView *w = nullptr);

    void show();
    void hide();
    void toggle();

    QRect screenRect();
    QRect screenAvailableRect();

signals:
    void screenRectChanged();
    void screenAvailableGeometryChanged();

private slots:
    void onGeometryChanged();
    void onAvailableGeometryChanged(const QRect &geometry);

protected:
    void showEvent(QShowEvent *e) override;
    void resizeEvent(QResizeEvent *e) override;

private:
    void onActiveChanged();

private:
    QRect m_screenRect;
    QRect m_screenAvailableRect;
};

#endif // LAUNCHER_H
