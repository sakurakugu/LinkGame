#include "settings.h"
#include <QDebug>
#include <QTimer>
#include <algorithm>

Settings::Settings(QObject *parent) : QObject{parent}, window(nullptr) {
    // 加载配置
    configManager.loadConfig(config);

    // 使用定时器延迟初始化窗口
    QTimer::singleShot(100, this, &Settings::initWindow);
}

void Settings::initWindow() {
    if (window) {
        return; // 如果已经初始化过，直接返回
    }

    // 获取主窗口
    QWindowList windows = QGuiApplication::allWindows();
    for (QWindow *w : windows) {
        window = qobject_cast<QQuickWindow *>(w);
        if (window) {
            qDebug() << "成功获取 QQuickWindow 实例";
            break;
        }
    }

    if (!window) {
        qWarning() << "无法获取 QQuickWindow 实例，将在下一次尝试";
        // 如果还是获取不到，再次尝试
        QTimer::singleShot(500, this, &Settings::initWindow);
    }
}

Settings::~Settings() {
    // 保存配置
    saveConfig();
}

QString Settings::getPlayerName() const {
    return config.playerName;
}

void Settings::setPlayerName(const QString &name) {
    if (config.playerName != name) {
        config.playerName = name;
        saveConfig();
    }
}

QVariantList Settings::getLeaderboard() const {
    QVariantList result;
    for (const auto &entry : config.leaderboard) {
        QVariantMap item;
        item["name"] = entry.name;
        item["score"] = entry.score;
        result.append(item);
    }
    return result;
}

void Settings::addScoreToLeaderboard(const QString &name, int score) {
    auto it = std::find_if(config.leaderboard.begin(), config.leaderboard.end(),
                           [&name](const Config::LeaderboardEntry &entry) { return entry.name == name; });

    if (it != config.leaderboard.end()) {
        // 如果找到相同用户名，更新分数
        it->score = std::max(it->score, score); // 保留更高分数
    } else {
        // 如果没有相同用户名，添加新的分数
        Config::LeaderboardEntry entry;
        entry.name = name;
        entry.score = score;
        config.leaderboard.append(entry);
    }

    // 按分数降序排序
    std::sort(config.leaderboard.begin(), config.leaderboard.end(),
              [](const Config::LeaderboardEntry &a, const Config::LeaderboardEntry &b) { return a.score > b.score; });

    // 只保留前100名
    if (config.leaderboard.size() > 100) {
        config.leaderboard.resize(100);
    }

    emit leaderboardChanged(); // 排行榜变化信号
    saveConfig();              // 保存配置
}

QString Settings::getDifficulty() const {
    return config.difficulty;
}

void Settings::setDifficulty(const QString &difficulty) {
    if (config.difficulty != difficulty) {
        config.difficulty = difficulty;
        saveConfig();
    }
}

int Settings::getGameTime() const {
    return config.gameTime;
}

void Settings::setGameTime(int seconds) {
    if (config.gameTime != seconds) {
        config.gameTime = seconds;
        emit gameTimeChanged();
        saveConfig();
    }
}

double Settings::getVolume() const {
    return config.volume;
}

void Settings::setVolume(double volume) {
    double newVolume = qBound(0.0, volume, 1.0);
    newVolume = qRound(newVolume * 100.0) / 100.0; // 保留两位小数
    if (config.volume != newVolume) {
        config.volume = newVolume;
        emit volumeChanged();
        saveConfig();
    }
}

void Settings::resizeWindow(int width, int height) {
    if (!window) {
        qWarning() << "resizeWindow: window 为空，尝试重新初始化窗口";
        initWindow();
        if (!window) {
            qWarning() << "resizeWindow: 无法获取窗口，操作取消";
            return;
        }
    }

    // 获取屏幕尺寸
    QScreen *screen = window->screen();
    if (!screen) {
        qWarning() << "resizeWindow: 无法获取屏幕";
        return;
    }

    QRect screenGeometry = screen->geometry();
    qDebug() << "当前屏幕尺寸:" << screenGeometry.width() << "x" << screenGeometry.height();

    // 确保窗口不会超出屏幕
    width = qMin(width, screenGeometry.width());
    height = qMin(height, screenGeometry.height());

    // 确保窗口不小于最小尺寸
    width = qMax(width, 800);
    height = qMax(height, 600);

    qDebug() << "尝试调整窗口大小到:" << width << "x" << height;

    // 计算窗口位置，使其居中
    int x = (screenGeometry.width() - width) / 2;
    int y = (screenGeometry.height() - height) / 2;

    // 先退出全屏和无边框模式
    if (window->windowState() & Qt::WindowFullScreen) {
        window->showNormal();
    }
    if (window->flags() & Qt::FramelessWindowHint) {
        window->setFlags(window->flags() & ~Qt::FramelessWindowHint);
    }

    // 设置窗口大小和位置
    window->setGeometry(x, y, width, height);
    window->show();

    // 更新配置
    config.screenWidth = width;
    config.screenHeight = height;
    config.fullscreen = false;
    config.borderless = false;
    saveConfig();

    qDebug() << "窗口大小调整完成";
    emit windowSizeChanged();
}

QString Settings::getScreenSize() const {
    if (window) {
        qreal dpr = window->effectiveDevicePixelRatio();
        int realWidth = qFloor(window->width() * dpr);
        int realHeight = qFloor(window->height() * dpr);

        if (window->flags() & Qt::FramelessWindowHint && window->windowState() & Qt::WindowFullScreen) {
            return QString("无边框全屏 (%1x%2)").arg(realWidth).arg(realHeight);
        } else if (window->windowState() & Qt::WindowFullScreen) {
            return QString("全屏 (%1x%2)").arg(realWidth).arg(realHeight);
        } else {
            return QString("%1x%2").arg(realWidth).arg(realHeight);
        }
    }
    return QString("%1x%2").arg(config.screenWidth).arg(config.screenHeight);
}

void Settings::setFullscreen(bool fullscreen) {
    if (window && config.fullscreen != fullscreen) {
        config.fullscreen = fullscreen;
        if (fullscreen) {
            // 进入全屏模式
            window->showFullScreen();
        } else {
            window->showNormal();
            resizeWindow(config.screenWidth, config.screenHeight);
        }
        saveConfig();
        emit windowSizeChanged();
    }
}

bool Settings::isFullscreen() const {
    return window ? (window->windowState() & Qt::WindowFullScreen) : config.fullscreen;
}

void Settings::setBorderless(bool borderless) {
    if (window && config.borderless != borderless) {
        config.borderless = borderless;
        if (borderless) {
            // 进入无边框模式
            window->setFlags(window->flags() | Qt::FramelessWindowHint);
        } else {
            // 回到普通窗口模式
            window->setFlags(window->flags() & ~Qt::FramelessWindowHint);
            resizeWindow(config.screenWidth, config.screenHeight);
        }
        saveConfig();
        emit windowSizeChanged();
    }
}

bool Settings::isBorderless() const {
    return config.borderless;
}

void Settings::updateWindowSize() {
    if (window) {
        // 只有在非全屏和非无边框模式下才更新配置
        if (!(window->windowState() & Qt::WindowFullScreen) && !(window->flags() & Qt::FramelessWindowHint)) {
            config.screenWidth = window->width();
            config.screenHeight = window->height();
            saveConfig();
            emit windowSizeChanged();
        }
    }
}

void Settings::setScreenSize(int width, int height) {
    if (config.screenWidth != width || config.screenHeight != height) {
        config.screenWidth = width;
        config.screenHeight = height;
        if (!config.fullscreen && !config.borderless) {
            resizeWindow(width, height);
        }
        saveConfig();
    }
}

void Settings::saveConfig() {
    configManager.saveConfig(config);
}

int Settings::getBlockCount() const {
    return config.blockCount;
}

void Settings::setBlockCount(int count) {
    if (config.blockCount != count) {
        config.blockCount = count;
        emit blockSettingsChanged();
        saveConfig();
    }
}

int Settings::getBlockTypes() const {
    QString difficulty = getDifficulty();
    if (difficulty == "easy") {
        return DefaultValues::block_types_easy;
    } else if (difficulty == "medium") {
        return DefaultValues::block_types_medium;
    } else if (difficulty == "hard") {
        return DefaultValues::block_types_hard;
    }
    return DefaultValues::block_types;
}

void Settings::setBlockTypes(int types) {
    if (config.blockTypes != types) {
        config.blockTypes = types;
        emit blockSettingsChanged();
        saveConfig();
    }
}

QPair<int, int> Settings::getPhysicalScreenSize() const {
    QScreen *screen = QGuiApplication::primaryScreen();
    if (screen) {
        QSize logicalSize = screen->geometry().size(); // 获取屏幕的逻辑像素大小
        return logicalToPhysical(logicalSize.width(), logicalSize.height());
    }
    return QPair<int, int>(1920, 1080); // 默认值
}

QPair<int, int> Settings::getAvailableScreenSize() const {
    QScreen *screen = QGuiApplication::primaryScreen();
    if (screen) {
        QRect availableGeometry = screen->availableGeometry(); // 不包括任务栏等系统区域
        return logicalToPhysical(availableGeometry.width(), availableGeometry.height());
    }
    return QPair<int, int>(1920, 1080); // 默认值
}

QPair<int, int> Settings::logicalToPhysical(int width, int height) const {
    qreal dpr = window->effectiveDevicePixelRatio();
    return {qFloor(width * dpr), qFloor(height * dpr)};
}

int Settings::logicalToPhysical(int number) const {
    qreal dpr = window->effectiveDevicePixelRatio();
    return qFloor(number * dpr);
}

QStringList Settings::getWindowSizeModel() const {
    QStringList model;
    QPair<int, int> physicalSize = getPhysicalScreenSize();
    QPair<int, int> availableSize = getAvailableScreenSize();

    // 添加预设的分辨率
    model << QString("全屏 (%1x%2)").arg(physicalSize.first).arg(physicalSize.second)
          << QString("无边框全屏 (%1x%2)").arg(physicalSize.first).arg(physicalSize.second)
          << QString("%1x%2").arg(availableSize.first).arg(availableSize.second)
          << QString("%1x%2").arg(logicalToPhysical(1920)).arg(logicalToPhysical(1080))
          << QString("%1x%2").arg(logicalToPhysical(1280)).arg(logicalToPhysical(720))
          << QString("%1x%2").arg(logicalToPhysical(1024)).arg(logicalToPhysical(768))
          << QString("%1x%2").arg(logicalToPhysical(800)).arg(logicalToPhysical(600));
    return model;
}

int Settings::getWindowWidth() const {
    if (window) {
        return window->width();
    }
    return config.screenWidth;
}

int Settings::getWindowHeight() const {
    if (window) {
        return window->height();
    }
    return config.screenHeight;
}
