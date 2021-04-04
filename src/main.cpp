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

#include <QApplication>
#include <QDBusConnection>
#include <QDBusInterface>

#include "launcher.h"
#include "launcheritem.h"
#include "launchermodel.h"
#include "pagemodel.h"
#include "wallpaper.h"
#include "iconitem.h"

#include <QDebug>
#include <QTranslator>
#include <QLocale>

#define DBUS_NAME "org.cutefish.Launcher"
#define DBUS_PATH "/Launcher"
#define DBUS_INTERFACE "org.cutefish.Launcher"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QByteArray uri = "Cutefish.Launcher";
    qmlRegisterAnonymousType<QAbstractItemModel>(uri, 1);
    qmlRegisterUncreatableType<LauncherItem>(uri, 1, 0, "LauncherItem", "cannot init application");
    qmlRegisterType<LauncherModel>(uri, 1, 0, "LauncherModel");
    qmlRegisterType<PageModel>(uri, 1, 0, "PageModel");
    qmlRegisterType<Wallpaper>(uri, 1, 0, "Wallpaper");
    qmlRegisterType<IconItem>(uri, 1, 0, "IconItem");

    QApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("cutefish-launcher"));

    // QCommandLineParser parser;
    // QCommandLineOption showOption(QStringLiteral("show"), "Show Launcher");
    // parser.addOption(showOption);
    // QCommandLineOption hideOption(QStringLiteral("hide"), "Hide Launcher");
    // parser.addOption(hideOption);
    // QCommandLineOption toggleOption(QStringLiteral("toggle"), "Toggle Launcher");
    // parser.addOption(toggleOption);
    // parser.process(app.arguments());

    QDBusConnection dbus = QDBusConnection::sessionBus();
    if (!dbus.registerService(DBUS_NAME)) {
        QDBusInterface iface(DBUS_NAME, DBUS_PATH, DBUS_INTERFACE, dbus);
        iface.call("toggle");
        return -1;
    }

    QLocale locale;
    QString qmFilePath = QString("%1/%2.qm").arg("/usr/share/cutefish-launcher/translations/").arg(locale.name());
    if (QFile::exists(qmFilePath)) {
        QTranslator *translator = new QTranslator(app.instance());
        if (translator->load(qmFilePath)) {
            app.installTranslator(translator);
        } else {
            translator->deleteLater();
        }
    }

    Launcher launcher;

    if (!dbus.registerObject(DBUS_PATH, DBUS_INTERFACE, &launcher))
        return -1;

    return app.exec();
}
