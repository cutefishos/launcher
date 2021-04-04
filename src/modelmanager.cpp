#include "modelmanager.h"

ModelManager::ModelManager(QObject *parent) : QObject(parent)
{

}

int ModelManager::count() const
{
    return m_appList.count();
}
