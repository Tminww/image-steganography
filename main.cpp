#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "imageeditor.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    // Register the ImageEditor type to QML
    qmlRegisterType<ImageEditor>("ImageEditor", 1, 0, "ImageEditor");

    QQmlApplicationEngine engine;

    // Load the QML file
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
