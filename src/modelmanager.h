#ifndef MODELMANAGER_H
#define MODELMANAGER_H

#include <QObject>

struct ApplicationData {
    QString name;
    QString icon;
    QStringList args;
};

class ModelManager : public QObject
{
    Q_OBJECT

public:
    explicit ModelManager(QObject *parent = nullptr);

    int count() const;

private:
    QList<ApplicationData> m_appList;
};

#endif // MODELMANAGER_H
