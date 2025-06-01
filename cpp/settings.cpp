#include "settings.h"
#include <QDebug>
#include <algorithm>

Settings::Settings(QObject *parent) : QObject{parent}, window(nullptr) {
    // 加载配置
    configManager.loadConfig(config);

    // 获取主窗口
    QWindowList windows = QGuiApplication::allWindows();
    if (!windows.isEmpty()) {
        // 尝试将 QWindow 转换为 QQuickWindow
        window = qobject_cast<QQuickWindow*>(windows.first());
        if (!window) {
            qWarning() << "无法获取 QQuickWindow 实例";
        }
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
    saveConfig();             // 保存配置
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
    if (config.volume != newVolume) {
        config.volume = newVolume;
        emit volumeChanged();
        saveConfig();
    }
}

void Settings::resizeWindow(int width, int height) {
    if (window) {
        // 获取屏幕尺寸
        QScreen *screen = window->screen();        // 获取窗口所在的屏幕
        QRect screenGeometry = screen->geometry(); // 获取屏幕几何尺寸

        // 确保窗口不会超出屏幕
        width = qMin(width, screenGeometry.width());
        height = qMin(height, screenGeometry.height());

        // 计算窗口位置，使其居中
        int x = (screenGeometry.width() - width) / 2;
        int y = (screenGeometry.height() - height) / 2;

        // 设置窗口大小和位置
        window->setGeometry(x, y, width, height);

        // 更新配置
        config.screenWidth = width;
        config.screenHeight = height;
        saveConfig();

        emit windowSizeChanged();
    }
}

QString Settings::getScreenSize() const {
    if (window) {
        return QString("%1x%2").arg(window->width()).arg(window->height());
    }
    return QString("%1x%2").arg(config.screenWidth).arg(config.screenHeight);
}

void Settings::setFullscreen(bool fullscreen) {
    if (window && config.fullscreen != fullscreen) { // 如果窗口存在且全屏状态不同
        config.fullscreen = fullscreen;
        if (fullscreen) {
            window->showFullScreen(); // 全屏显示
        } else {
            window->showNormal();                                  // 非全屏显示
            resizeWindow(config.screenWidth, config.screenHeight); // 调整窗口大小
        }
        saveConfig(); // 保存配置
        emit windowSizeChanged();         // 窗口大小变化信号
    }
}

bool Settings::isFullscreen() const {
    return window ? (window->windowState() & Qt::WindowFullScreen) : config.fullscreen;
}

void Settings::setScreenSize(int width, int height) {
    if (config.screenWidth != width || config.screenHeight != height) {
        config.screenWidth = width;
        config.screenHeight = height;
        if (!config.fullscreen) {
            resizeWindow(width, height);
        }
        saveConfig();
    }
}

void Settings::saveConfig() {
    configManager.saveConfig(config);
}