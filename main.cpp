// Qt 相关头文件
#include <QDebug>
#include <QGuiApplication>
#include <QIcon> // 添加 QIcon 头文件
#include <QQmlApplicationEngine>
#include <QQmlContext> // 用于将 C++ 的对象暴露给 QML
#include <QTranslator> // 添加 QTranslator 头文件
// Windows 相关头文件
#ifdef Q_OS_WIN
#include <windows.h>
#endif
// 自定义头文件
#include "cpp/gamelogic.h" // 游戏逻辑类
#include "cpp/language.h"
#include "cpp/logger.h"
#include "cpp/settings.h"

int main(int argc, char *argv[]) {
#if defined(Q_OS_WIN) && defined(QT_DEBUG)
    // Windows平台
    UINT cp = GetACP();
    if (cp == 65001) {
        // 设置 Windows 控制台输入输出为 UTF-8
        SetConsoleCP(CP_UTF8);
        SetConsoleOutputCP(CP_UTF8);
    } else if (cp == 936) {
        // 设置 Windows 控制台输入输出为 GBK
        SetConsoleCP(936);
        SetConsoleOutputCP(936);
    }
#endif

    QGuiApplication app(argc, argv);

    // 设置 Qt Quick Controls 样式为 Basic 以支持自定义
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");

    app.setWindowIcon(QIcon(":/image/icon.png")); // 设置窗口图标

    // 初始化日志系统
    Logger &logger = Logger::GetInstance();
    qInstallMessageHandler(Logger::messageHandler);
    // 应用日志设置
    logger.setLogLevel(static_cast<Logger::LogLevel>(Logger::Info));
    // 暂时使用默认设置，因为Config类没有提供日志相关的getter方法
    // logger.setLogToFile(config.getLogToFile());
    // logger.setLogToConsole(config.getLogToConsole());
    // logger.setMaxLogFileSize(config.getMaxLogFileSize());
    // logger.setMaxLogFiles(config.getMaxLogFiles());

    qInfo() << "日志系统初始化完成";

    // 记录应用启动
    qInfo() << "LinkGame 应用程序启动";

    QQmlApplicationEngine engine;
    auto context = engine.rootContext(); // 获取根全局对象

    // 创建并注册Language
    Language language;
    context->setContextProperty("language", &language);

    // 创建并注册Settings
    Settings settings;
    context->setContextProperty("settings", &settings);

    // 连接语言设置变化信号
    QObject::connect(&settings, &Settings::languageChanged,
                     [&language, &settings]() { language.setCurrentLanguage(settings.getLanguage()); });

    // 添加主题变化的调试输出
    QObject::connect(&settings, &Settings::themeChanged, []() { qDebug() << "C++中检测到主题变化信号"; });

    // 创建并注册GameLogic，传入已创建的Settings实例
    GameLogic logic(&settings);                       // 创建游戏逻辑对象，使用已经创建的settings
    context->setContextProperty("gameLogic", &logic); // 将游戏逻辑对象暴露给 QML

    // 连接游戏逻辑(C++)的信号到 QML
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // 导入 MainMenu.qml
    engine.loadFromModule("LinkGame", "Main");

    return app.exec();
}
