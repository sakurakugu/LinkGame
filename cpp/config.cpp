#include "config.h"

Config::Config(QObject *parent) : QObject(parent) {
}

Config::~Config() {
}

/**
 * @brief 初始化配置
 * @param config 配置结构体
 */
void Config::initConfig(config &config) {
    // 设置默认配置
    config.playerName      = DefaultValues::player_name;
    config.difficulty      = DefaultValues::difficulty;
    config.gameTime        = DefaultValues::game_time;
    config.volume          = DefaultValues::volume;
    config.soundState      = DefaultValues::sound_state;
    config.screenWidth     = DefaultValues::screen_width;
    config.screenHeight    = DefaultValues::screen_height;
    config.fullscreen      = DefaultValues::fullscreen;
    config.borderless      = DefaultValues::borderless;
    config.blockCount      = DefaultValues::block_count;
    config.blockTypes      = DefaultValues::block_types;
    config.joinLeaderboard = DefaultValues::join_leaderboard;
    config.theme           = DefaultValues::theme;
    config.language        = DefaultValues::language;
    config.leaderboard.clear();
}

/**
 * @brief 加载配置文件
 * @param config 配置结构体
 */
void Config::loadConfig(config &config) {
    // 输出配置文件的绝对路径
    qDebug() << "配置文件路径:" << QDir::currentPath() + "/config.toml";

    try {
        // 读取配置文件
        const auto data = toml::parse("./config.toml");
        qDebug() << "加载配置文件成功";

        // 初始化默认配置
        initConfig(config);

        // 读取玩家名称
        if (data.contains("player")) {
            const auto &player = toml::find(data, "player");
            config.playerName = getTomlString(player, "name", DefaultValues::player_name);
        }

        // 读取游戏设置
        if (data.contains("settings")) {
            const auto &settings = toml::find(data, "settings");

            // 使用辅助函数读取各项配置
            config.difficulty = getTomlString(settings, "difficulty", DefaultValues::difficulty);
            config.gameTime = getTomlInt(settings, "game_time", DefaultValues::game_time);

            // 音量需要额外处理确保在合法范围内
            config.volume = getTomlDouble(settings, "volume", DefaultValues::volume);
            config.volume = qBound(0.0, config.volume, 1.0);

            config.soundState = getTomlBool(settings, "sound_state", DefaultValues::sound_state);
            config.blockCount = getTomlInt(settings, "block_count", DefaultValues::block_count);
            config.blockTypes = getTomlInt(settings, "block_types", DefaultValues::block_types);
            config.joinLeaderboard = getTomlBool(settings, "join_leaderboard", DefaultValues::join_leaderboard);
            config.theme = getTomlString(settings, "theme", DefaultValues::theme);
            config.language = getTomlString(settings, "language", DefaultValues::language);
        }

        // 读取排行榜
        config.leaderboard.clear();
        if (data.contains("leaderboard") && toml::find(data, "leaderboard").contains("entries")) {
            const auto &entries = toml::find(data, "leaderboard", "entries").as_array();
            for (const auto &entry : entries) {
                LeaderboardEntry leaderboardEntry;
                leaderboardEntry.name = getTomlString(entry, "name", "未知玩家");
                leaderboardEntry.score = getTomlInt(entry, "score", 0);
                leaderboardEntry.difficulty = getTomlString(entry, "difficulty", "普通");

                config.leaderboard.append(leaderboardEntry);
            }
        }

        // 读取屏幕设置
        if (data.contains("screen")) {
            const auto &screen = toml::find(data, "screen");
            config.screenWidth = getTomlInt(screen, "width", DefaultValues::screen_width);
            config.screenHeight = getTomlInt(screen, "height", DefaultValues::screen_height);
            config.fullscreen = getTomlBool(screen, "fullscreen", DefaultValues::fullscreen);
            config.borderless = getTomlBool(screen, "borderless", DefaultValues::borderless);
        }
    } catch (const std::exception &e) {
        qWarning() << "加载配置文件失败:" << e.what() << "，使用默认配置";
        initConfig(config);
    }
}

/**
 * @brief 保存配置文件
 * @param config 配置结构体
 */
void Config::saveConfig(const config &config) {
    try {
        toml::value data;

        // 保存玩家信息
        data["player"].comments().push_back(" 玩家信息");
        data["player"]["name"] = config.playerName.toStdString();

        // 保存游戏设置
        data["settings"].comments().push_back(" 游戏设置");
        data["settings"]["difficulty"] = config.difficulty.toStdString();
        data["settings"]["game_time"] = config.gameTime;
        data["settings"]["volume"] = config.volume;
        data["settings"]["sound_state"] = config.soundState;
        data["settings"]["block_count"] = config.blockCount;
        data["settings"]["block_types"] = config.blockTypes;
        data["settings"]["join_leaderboard"] = config.joinLeaderboard;
        data["settings"]["theme"] = config.theme.toStdString();
        data["settings"]["language"] = config.language.toStdString();

        // 保存排行榜
        data["leaderboard"].comments().push_back(" 玩家排行榜");
        std::vector<toml::value> leaderboard;
        for (const auto &entry : std::as_const(config.leaderboard)) {
            toml::value entryData;
            entryData["name"] = entry.name.toStdString();
            entryData["score"] = entry.score;
            entryData["difficulty"] = entry.difficulty.toStdString();
            leaderboard.push_back(entryData);
        }
        data["leaderboard"]["entries"] = leaderboard;

        // 保存屏幕设置
        data["screen"].comments().push_back(" 屏幕设置");
        data["screen"]["width"] = config.screenWidth;
        data["screen"]["height"] = config.screenHeight;
        data["screen"]["fullscreen"] = config.fullscreen;
        data["screen"]["borderless"] = config.borderless;

        // 添加注释
        data.comments().push_back(" 连连看游戏配置文件");
        data.comments().push_back(" \u4f5c\u8005: \u6f58\u5f66\u73ae\u3001\u8c22\u667a\u884c");

        // 写入文件
        std::ofstream file("config.toml");
        if (!file) {
            qWarning() << "无法保存配置文件";
            return;
        }
        file << toml::format(data);
        file.close();
        qDebug() << "配置文件保存成功";

    } catch (const std::exception &e) {
        qWarning() << "保存配置文件失败:" << e.what();
    }
}

/**
 * @brief 从TOML配置中读取字符串值
 * @param tomlValue TOML值
 * @param key 键名
 * @param defaultValue 默认值
 * @return 读取的字符串值
 */
template <typename T>
QString Config::getTomlString(const T &tomlValue, const std::string &key, const QString &defaultValue) {
    if (tomlValue.contains(key)) {
        return QString::fromStdString(toml::find<std::string>(tomlValue, key));
    }
    return defaultValue;
}

/**
 * @brief 从TOML配置中读取整数值
 * @param tomlValue TOML值
 * @param key 键名
 * @param defaultValue 默认值
 * @return 读取的整数值
 */
template <typename T> int Config::getTomlInt(const T &tomlValue, const std::string &key, int defaultValue) {
    if (tomlValue.contains(key)) {
        return toml::find<int>(tomlValue, key);
    }
    return defaultValue;
}

/**
 * @brief 从TOML配置中读取浮点值
 * @param tomlValue TOML值
 * @param key 键名
 * @param defaultValue 默认值
 * @return 读取的浮点值
 */
template <typename T> double Config::getTomlDouble(const T &tomlValue, const std::string &key, double defaultValue) {
    if (tomlValue.contains(key)) {
        return toml::find<double>(tomlValue, key);
    }
    return defaultValue;
}

/**
 * @brief 从TOML配置中读取布尔值
 * @param tomlValue TOML值
 * @param key 键名
 * @param defaultValue 默认值
 * @return 读取的布尔值
 */
template <typename T> bool Config::getTomlBool(const T &tomlValue, const std::string &key, bool defaultValue) {
    if (tomlValue.contains(key)) {
        return toml::find<bool>(tomlValue, key);
    }
    return defaultValue;
}