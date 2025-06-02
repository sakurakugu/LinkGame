#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext> // 用于将 C++ 的对象暴露给 QML
#include <QIcon> // 添加 QIcon 头文件
#include <QTranslator> // 添加 QTranslator 头文件
#include <QDebug>

#include "cpp/gamelogic.h" // 游戏逻辑类
#include "cpp/settings.h"
#include "cpp/language.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/image/icon.png")); // 设置窗口图标

    QQmlApplicationEngine engine;

    auto context = engine.rootContext(); // 获取根全局对象
    // 创建并注册Language
    Language language;
    context->setContextProperty("language", &language);

    // 创建并注册Settings
    Settings settings;
    context->setContextProperty("settings", &settings);

    // 连接语言设置变化信号
    QObject::connect(&settings, &Settings::languageChanged, [&language, &settings]() {
        language.setCurrentLanguage(settings.getLanguage());
    });

    // 创建并注册GameLogic
    GameLogic logic; // 创建游戏逻辑对象
    context->setContextProperty("gameLogic", &logic); // 将游戏逻辑对象暴露给 QML

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // 导入 MainMenu.qml
    engine.loadFromModule("LinkGame", "Main");

    return app.exec();
}
