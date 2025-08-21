#include "settings.h"

Settings::Settings(QObject *parent) : QObject{parent}, window(nullptr), configManager(Config::GetInstance()) {

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
            break;
        }
    }

    if (!window) {
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

QVariantList Settings::getLeaderboardByDifficulty(const QString &difficulty) const {
    QVariantList result;

    // 获取当前难度下的排行榜
    for (const auto &entry : config.leaderboard) {
        QVariantMap item;
        item["name"] = entry.name;
        item["score"] = entry.score;
        item["difficulty"] = entry.difficulty; // 添加难度属性

        // 如果未指定难度或难度匹配，则添加到结果中
        if (difficulty.isEmpty() || entry.difficulty == difficulty) {
            result.append(item);
        }
    }

    return result;
}

QVariantList Settings::getLeaderboard() const {
    // 默认返回所有难度的排行榜
    return getLeaderboardByDifficulty("");
}

void Settings::addScoreToLeaderboard(const QString &name, int score) {
    QString currentDifficulty = getDifficulty();

    // 查找是否有同名同难度的记录
    auto it = std::find_if(config.leaderboard.begin(), config.leaderboard.end(),
                           [&name, &currentDifficulty](const Config::LeaderboardEntry &entry) {
                               return entry.name == name && entry.difficulty == currentDifficulty;
                           });

    if (it != config.leaderboard.end()) {
        // 如果找到相同用户名和难度，更新分数
        it->score = std::max(it->score, score); // 保留更高分数
    } else {
        // 如果没有相同用户名和难度，添加新的分数
        Config::LeaderboardEntry entry;
        entry.name = name;
        entry.score = score;
        entry.difficulty = currentDifficulty;
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

bool Settings::getJoinLeaderboard() const {
    QString difficulty = getDifficulty();
    if (difficulty == "简单") {
        return DefaultValues::join_leaderboard_easy;
    } else if (difficulty == "普通") {
        return DefaultValues::join_leaderboard_medium;
    } else if (difficulty == "困难") {
        return DefaultValues::join_leaderboard_hard;
    } else if (difficulty == "自定义") {
        // 自定义模式下不能参加排行榜
        return false;
    }
    return config.joinLeaderboard;
}

void Settings::setJoinLeaderboard(bool join) {
    config.joinLeaderboard = join;
    saveConfig();
}

QString Settings::getDifficulty() const {
    return config.difficulty;
}

void Settings::setDifficulty(const QString &difficulty) {
    if (config.difficulty != difficulty) {
        config.difficulty = difficulty;
        emit blockSettingsChanged(); // 发出方块设置变化信号
        saveConfig();
    }
}

int Settings::getGameTime() const {
    QString difficulty = getDifficulty();
    if (difficulty == "简单") {
        return DefaultValues::game_time_easy;
    } else if (difficulty == "普通") {
        return DefaultValues::game_time_medium;
    } else if (difficulty == "困难") {
        return DefaultValues::game_time_hard;
    }
    return config.gameTime; // 自定义难度
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

    // 将逻辑像素转换为物理像素
    width = physicalToLogical(width);
    height = physicalToLogical(height);

    // 确保窗口不会超出屏幕
    width = qMin(width, screenGeometry.width());
    height = qMin(height, screenGeometry.height());

    // 确保窗口不小于最小尺寸
    width = qMax(width, 800);
    height = qMax(height, 600);

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
            return tr("无边框全屏 (%1x%2)").arg(realWidth).arg(realHeight);
        } else if (window->windowState() & Qt::WindowFullScreen) {
            return tr("全屏 (%1x%2)").arg(realWidth).arg(realHeight);
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
    QString difficulty = getDifficulty();
    if (difficulty == "简单") {
        return DefaultValues::block_count_easy;
    } else if (difficulty == "普通") {
        return DefaultValues::block_count_medium;
    } else if (difficulty == "困难") {
        return DefaultValues::block_count_hard;
    }
    return config.blockCount; // 自定义难度
}

int Settings::getRealBlockCount() const {
    QString difficulty = getDifficulty();
    if (difficulty == "简单") {
        return DefaultValues::block_count_easy;
    } else if (difficulty == "普通") {
        return DefaultValues::block_count_medium;
    } else if (difficulty == "困难") {
        return DefaultValues::block_count_hard;
    } else {
        return getBlockCount(); // 默认值
    }
}

void Settings::setBlockCount(int count) {
    if (config.blockCount != count) {
        config.blockCount = count;
        emit blockSettingsChanged(); // 发出方块设置变化信号
        saveConfig();
    }
}

int Settings::getBlockTypes() const {
    QString difficulty = getDifficulty();
    if (difficulty == "简单") {
        return DefaultValues::block_types_easy;
    } else if (difficulty == "普通") {
        return DefaultValues::block_types_medium;
    } else if (difficulty == "困难") {
        return DefaultValues::block_types_hard;
    }
    return config.blockTypes; // 自定义难度
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

QPair<int, int> Settings::physicalToLogical(int width, int height) const {
    qreal dpr = window->effectiveDevicePixelRatio();
    return {qFloor(width / dpr), qFloor(height / dpr)};
}

int Settings::physicalToLogical(int number) const {
    qreal dpr = window->effectiveDevicePixelRatio();
    return qFloor(number / dpr);
}

QStringList Settings::getWindowSizeModel() const {
    QStringList model;
    QPair<int, int> physicalSize = getPhysicalScreenSize();
    QPair<int, int> availableSize = getAvailableScreenSize();

    // 始终添加全屏和无边框全屏选项
    model << tr("全屏 (%1x%2)").arg(physicalSize.first).arg(physicalSize.second)
          << tr("无边框全屏 (%1x%2)").arg(physicalSize.first).arg(physicalSize.second)
          << QString("%1x%2").arg(availableSize.first).arg(availableSize.second);

    // 使用 DefaultValues 中的预设分辨率列表
    for (const auto &resolution : DefaultValues::presetResolutions) {
        int width = logicalToPhysical(resolution.first);
        int height = logicalToPhysical(resolution.second);

        // 检查分辨率是否小于或等于屏幕物理尺寸
        if (width <= physicalSize.first && height <= physicalSize.second) {
            model << QString("%1x%2").arg(width).arg(height);
        }
    }

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

bool Settings::getSoundState() const {
    return config.soundState;
}

/**
 * @brief 设置音效状态
 * @param state 音效状态
 * @return 音效状态
 */
void Settings::setSoundState(bool state) {
    if (config.soundState != state) {
        config.soundState = state;
        saveConfig();
        emit soundStateChanged(state);
    }
}

QString Settings::getTheme() const {
    return config.theme;
}

void Settings::setTheme(const QString &theme) {
    if (config.theme != theme) {
        config.theme = theme;
        emit themeChanged();
        saveConfig();
    }
}

QStringList Settings::getThemeList() const {
    // 返回所有可用的主题名称
    return QStringList() << "Light" << "Dark" << "Pink";
}

int Settings::getThemeIndex() const {
    // 获取当前主题的索引
    QString currentTheme = getTheme();
    QStringList themes = getThemeList();
    int index = themes.indexOf(currentTheme);
    return index != -1 ? index : 0; // 如果找不到当前主题，默认返回第一个
}

QString Settings::getLanguage() const {
    return config.language;
}

void Settings::setLanguage(const QString &lang) {
    if (config.language != lang) {
        config.language = lang;
        emit languageChanged();
        saveConfig();
    }
}

QString Settings::getSystemLanguage() const {
    return QLocale::system().name();
}

QStringList Settings::getLanguageDisplayNameList() const {
    QStringList languageDisplayNameList;
    for (const auto &language : Language::languageList) {
        languageDisplayNameList << language.second;
    }
    return languageDisplayNameList;
}

int Settings::getLanguageIndex() const {
    QString languageCode = getLanguage();
    for (int i = 0; i < Language::languageList.size(); i++) {
        if (Language::languageList[i].first == languageCode) {
            return i;
        }
    }
    return 0;
}

QString Settings::getLanguageDisplayName(const QString &lang) const {
    for (const auto &language : Language::languageList) {
        if (language.first == lang) {
            return language.second;
        }
    }
    return "";
}

QString Settings::getLanguageCode(const QString &displayName) const {
    for (const auto &language : Language::languageList) {
        if (language.second == displayName) {
            return language.first;
        }
    }
    return "";
}

/**
 * @brief 强制重新应用方块设置
 * @details 用于在QML中手动强制刷新游戏布局
 */
void Settings::forceUpdateBlockSettings() {
    qDebug() << "强制重新应用方块设置";
    // 发出方块设置变化信号，触发游戏逻辑更新
    emit blockSettingsChanged();
}

/**
 * @brief 获取排行榜排名
 * @details 计算玩家在当前难度排行榜中的排名
 * @param playerName 玩家名称
 * @param score 玩家分数
 * @return 排名描述文本
 */
QString Settings::getRank(const QString &playerName, int score) const {
    if (score <= 0) {
        return tr("未上榜");
    }

    // 检查设置中是否允许加入排行榜
    if (!getJoinLeaderboard()) {
        return tr("未启用排行");
    }

    // 获取当前难度的排行榜，而不是所有难度
    QString currentDifficulty = getDifficulty();
    QVariantList leaderboard = getLeaderboardByDifficulty(currentDifficulty);

    if (leaderboard.isEmpty()) {
        return tr("第1名"); // 如果排行榜为空，玩家将是第一名
    }

    // 计算玩家排名
    int rank = 1;
    bool foundPlayer = false;

    for (const QVariant &entryVar : leaderboard) {
        QVariantMap entry = entryVar.toMap();
        QString name = entry["name"].toString();
        int playerScore = entry["score"].toInt();

        // 如果发现相同名字和相同或更高分数，表示玩家已经在排行榜中
        if (name == playerName && playerScore >= score) {
            foundPlayer = true;
            break;
        }

        // 如果当前分数小于排行榜中的分数，排名加1
        if (score < playerScore) {
            rank++;
        }
    }

    // 如果玩家不在排行榜中，且排名超过100，返回未上榜
    if (!foundPlayer && rank > 100) {
        return tr("未上榜");
    }

    // 返回排名
    return tr("第%1名").arg(rank);
}
