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

#include "launchermodel.h"
#include "desktopproperties.h"
#include "launcheritem.h"

#include <QtConcurrent/QtConcurrentRun>
#include <QRegularExpression>
#include <QFileSystemWatcher>
#include <QScopedPointer>
#include <QDirIterator>
#include <QProcess>
#include <QDebug>
#include <QIcon>
#include <QDir>

static QByteArray detectDesktopEnvironment()
{
    const QByteArray desktop = qgetenv("XDG_CURRENT_DESKTOP");

    if (!desktop.isEmpty())
        return desktop.toUpper();

    return QByteArray("UNKNOWN");
}

LauncherModel::LauncherModel(QObject *parent)
    : QAbstractListModel(parent),
      m_mode(NormalMode)
{
    QtConcurrent::run(LauncherModel::refresh, this);

    QFileSystemWatcher *watcher = new QFileSystemWatcher(this);
    watcher->addPath("/usr/share/applications");
    connect(watcher, &QFileSystemWatcher::directoryChanged, this, [this](const QString &) {
        QtConcurrent::run(LauncherModel::refresh, this);
    });

    connect(this, &QAbstractItemModel::rowsInserted, this, &LauncherModel::countChanged);
    connect(this, &QAbstractItemModel::rowsRemoved, this, &LauncherModel::countChanged);
    connect(this, &QAbstractItemModel::modelReset, this, &LauncherModel::countChanged);
    connect(this, &QAbstractItemModel::layoutChanged, this, &LauncherModel::countChanged);
}

LauncherModel::~LauncherModel()
{
    while (!m_items.isEmpty())
        delete m_items.takeFirst();
}

int LauncherModel::count() const
{
    return rowCount();
}

int LauncherModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);

    if (m_mode == SearchMode)
        return m_searchItems.size();

    return m_items.size();
}

QHash<int, QByteArray> LauncherModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(AppIdRole, "appId");
    roles.insert(ApplicationRole, "application");
    roles.insert(NameRole, "name");
    roles.insert(GenericNameRole, "genericName");
    roles.insert(CommentRole, "comment");
    roles.insert(IconNameRole, "iconName");
    roles.insert(CategoriesRole, "categories");
    roles.insert(FilterInfoRole, "filterInfo");
    roles.insert(PinnedRole, "pinned");
    roles.insert(PinnedIndexRole, "pinnedIndex");
    return roles;
}

QVariant LauncherModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    LauncherItem *item = m_mode == NormalMode
                       ? m_items.at(index.row())
                       : m_searchItems.at(index.row());

    if (!item)
        return QVariant();

    switch (role) {
    case AppIdRole:
        return item->id;
    case NameRole:
        return item->name;
    case IconNameRole:
        return item->iconName;
    case FilterInfoRole:
        return QString(item->name + QStringLiteral(" ") + item->genericName + QStringLiteral(" ") + item->comment);
    default:
        return QVariant();
    }
}

void LauncherModel::search(const QString &key)
{
    m_mode = key.isEmpty() ? NormalMode : SearchMode;
    m_searchItems.clear();

    for (LauncherItem *item : qAsConst(m_items)) {
        const QString &name = item->name;
        const QString &fileName = item->id;

        if (name.contains(key, Qt::CaseInsensitive) ||
            fileName.contains(key, Qt::CaseInsensitive)) {
            m_searchItems.append(item);
            continue;
        }
    }

    emit layoutChanged();
}

LauncherItem *LauncherModel::findApplication(const QString &appId)
{
    for (LauncherItem *item : qAsConst(m_items)) {
        if (item->id == appId)
            return item;
    }

    return nullptr;
}

void LauncherModel::refresh(LauncherModel *manager)
{
    QStringList addedEntries;
    for (LauncherItem *item : qAsConst(manager->m_items))
        addedEntries.append(item->id);

    QStringList allEntries;
    QDirIterator it("/usr/share/applications", { "*.desktop" }, QDir::NoFilter, QDirIterator::Subdirectories);

    while (it.hasNext()) {
        const auto fileName = it.next();
        if (!QFile::exists(fileName))
            continue;

        allEntries.append(fileName);
    }

    for (const QString &fileName : allEntries) {
        if (!addedEntries.contains(fileName))
            QMetaObject::invokeMethod(manager, "addApp", Q_ARG(QString, fileName));
    }

    for (LauncherItem *item : qAsConst(manager->m_items)) {
        if (!allEntries.contains(item->id))
            QMetaObject::invokeMethod(manager, "removeApp", Q_ARG(QObject*, qobject_cast<QObject*>(item)));
    }

    // Signal the model was refreshed
    QMetaObject::invokeMethod(manager, "refreshed");
}

LauncherItem *LauncherModel::get(int index) const
{
    if (index < 0 || index >= m_items.size())
        return nullptr;

    return m_items.at(index);
}

QString LauncherModel::getIconName(const QString &appId)
{
    LauncherItem *item = get(indexFromAppId(appId));
    if (item)
        return item->iconName;

    return QString();
}

int LauncherModel::indexFromAppId(const QString &appId) const
{
    for (int i = 0; i < m_items.size(); i++) {
        if (m_items.at(i)->id == appId)
            return i;
    }

    return -1;
}

void LauncherModel::move(int from, int to)
{
    if (from == to)
        return;

    m_items.move(from, to);

    if (from < to)
        beginMoveRows(QModelIndex(), from, from, QModelIndex(), to + 1);
    else
        beginMoveRows(QModelIndex(), from, from, QModelIndex(), to);

    endMoveRows();
}

bool LauncherModel::launch(const QString &path)
{
    LauncherItem *app = findApplication(path);
    if (app) {
        QStringList args = app->args;
        QScopedPointer<QProcess> p(new QProcess);
        p->setStandardInputFile(QProcess::nullDevice());
        p->setProcessChannelMode(QProcess::ForwardedChannels);

        QString cmd = args.takeFirst();
        p->setProgram(cmd);
        p->setArguments(args);

        Q_EMIT applicationLaunched();

        return p->startDetached();
    }

    return false;
}

void LauncherModel::addApp(const QString &fileName)
{
    if (findApplication(fileName))
        return;

    DesktopProperties desktop(fileName, "Desktop Entry");
    if (desktop.contains("OnlyShowIn")) {
        const QString &value = desktop.value("OnlyShowIn").toString();
        if (!value.contains(detectDesktopEnvironment(), Qt::CaseInsensitive)) {
            return;
        }
    }

    if (desktop.value("NoDisplay").toBool() ||
        desktop.value("Hidden").toBool())
        return;

    QString appName = desktop.value(QString("Name[%1]").arg(QLocale::system().name())).toString();
    QString appExec = desktop.value("Exec").toString();

    if (appName.isEmpty())
        appName = desktop.value("Name").toString();

    appExec.remove(QRegularExpression("%."));
    appExec.remove(QRegularExpression("^\""));
    // appExec.remove(QRegularExpression(" *$"));
    appExec = appExec.simplified();

    LauncherItem *item = new LauncherItem;
    item->id = fileName;
    item->name = appName;
    item->genericName = desktop.value("Comment").toString();
    item->comment = desktop.value("Comment").toString();
    item->iconName = desktop.value("Icon").toString();
    item->args = appExec.split(" ");

    beginInsertRows(QModelIndex(), m_items.count(), m_items.count());
    m_items.append(item);
    qDebug() << "added: " << item->name;
    Q_EMIT applicationAdded(item);
    endInsertRows();
}

void LauncherModel::removeApp(QObject *object)
{
    LauncherItem *item = qobject_cast<LauncherItem *>(object);
    if (!item)
        return;

    int index = m_items.indexOf(item);
    if (index < 0)
        return;

    beginRemoveRows(QModelIndex(), index, index);
    qDebug() << "removed: " << item->name;
    m_items.removeAt(index);
    endRemoveRows();

    Q_EMIT applicationRemoved(item);
    item->deleteLater();
}
