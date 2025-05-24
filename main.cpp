#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext> // 用于将 C++ 的对象暴露给 QML

#include "gamelogic.h" // 游戏逻辑类

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    auto context = engine.rootContext(); // 获取根全局对象
    GameLogic logic; // 创建游戏逻辑对象
    context->setContextProperty("gameLogic", &logic); // 将游戏逻辑对象暴露给 QML

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("LinkGame", "Main"); // 导入 Main.qml
    return app.exec();
}
