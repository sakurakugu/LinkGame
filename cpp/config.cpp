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
    config.playerName = DefaultValues::player_name;
    config.difficulty = DefaultValues::difficulty;
    config.gameTime = DefaultValues::game_time;               // 默认游戏时间为3分钟
    config.volume = DefaultValues::volume;                    // 默认音量为80%
    config.soundState = DefaultValues::sound_state;           // 默认声音状态为开启
    config.screenWidth = DefaultValues::screen_width;         // 默认窗口宽度
    config.screenHeight = DefaultValues::screen_height;       // 默认窗口高度
    config.fullscreen = DefaultValues::fullscreen;            // 默认不全屏
    config.borderless = DefaultValues::borderless;            // 默认不无边框
    config.blockCount = DefaultValues::block_count;           // 默认方块数量
    config.blockTypes = DefaultValues::block_types;           // 默认方块种类数
    config.joinLeaderboard = DefaultValues::join_leaderboard; // 默认加入排行榜
    config.theme = DefaultValues::theme;                      // 默认主题为浅色
    config.language = DefaultValues::language;                // 默认语言为中文
    config.leaderboard.clear();                               // 清空排行榜
}

/**
 * @brief 加载配置文件
 * @param config 配置结构体
 */
void Config::loadConfig(config &config) {
    try {
        // 读取配置文件
        const auto data = toml::parse("./config.toml");
        qDebug() << "加载配置文件成功";

        // 读取玩家名称
        if (data.contains("player")) {
            const auto &player = toml::find(data, "player");
            config.playerName = QString::fromStdString(toml::find<std::string>(player, "name"));
        } else {
            config.playerName = DefaultValues::player_name;
        }

        // 读取游戏设置
        if (data.contains("settings")) {
            const auto &settings = toml::find(data, "settings");
            if (settings.contains("difficulty")) {
                config.difficulty = QString::fromStdString(toml::find<std::string>(settings, "difficulty"));
            } else {
                config.difficulty = DefaultValues::difficulty;
            }
            if (settings.contains("game_time")) {
                config.gameTime = toml::find<int>(settings, "game_time");
            } else {
                config.gameTime = DefaultValues::game_time;
            }
            if (settings.contains("volume")) {
                config.volume = toml::find<double>(settings, "volume");
                config.volume = qBound(0.0, config.volume, 1.0); // 确保音量在合法范围内
            } else {
                config.volume = DefaultValues::volume;
            }
            if (settings.contains("sound_state")) {
                config.soundState = toml::find<bool>(settings, "sound_state");
            } else {
                config.soundState = DefaultValues::sound_state;
            }
            if (settings.contains("block_count")) {
                config.blockCount = toml::find<int>(settings, "block_count");
            } else {
                config.blockCount = DefaultValues::block_count;
            }
            if (settings.contains("block_types")) {
                config.blockTypes = toml::find<int>(settings, "block_types");
            } else {
                config.blockTypes = DefaultValues::block_types;
            }
            if (settings.contains("join_leaderboard")) {
                config.joinLeaderboard = toml::find<bool>(settings, "join_leaderboard");
            } else {
                config.joinLeaderboard = DefaultValues::join_leaderboard;
            }
            if (settings.contains("theme")) {
                config.theme = QString::fromStdString(toml::find<std::string>(settings, "theme"));
            } else {
                config.theme = DefaultValues::theme;
            }
            if (settings.contains("language")) {
                config.language = QString::fromStdString(toml::find<std::string>(settings, "language"));
            } else {
                config.language = DefaultValues::language;
            }
        } else {
            config.difficulty = DefaultValues::difficulty;
            config.gameTime = DefaultValues::game_time;
            config.volume = DefaultValues::volume;
            config.blockCount = DefaultValues::block_count;
            config.blockTypes = DefaultValues::block_types;
            config.theme = DefaultValues::theme;
            config.language = DefaultValues::language;
        }

        // 读取排行榜
        config.leaderboard.clear();
        if (data.contains("leaderboard") && toml::find(data, "leaderboard").contains("entries")) {
            const auto &entries = toml::find(data, "leaderboard", "entries").as_array();
            for (const auto &entry : entries) {
                LeaderboardEntry leaderboardEntry;
                leaderboardEntry.name = QString::fromStdString(toml::find<std::string>(entry, "name"));
                leaderboardEntry.score = toml::find<int>(entry, "score");
                config.leaderboard.append(leaderboardEntry);
            }
        }

        // 读取屏幕设置
        if (data.contains("screen")) {
            const auto &screen = toml::find(data, "screen");
            config.screenWidth = toml::find<int>(screen, "width");
            config.screenHeight = toml::find<int>(screen, "height");
            config.fullscreen = toml::find<bool>(screen, "fullscreen");
            config.borderless = toml::find<bool>(screen, "borderless");
        } else {
            config.screenWidth = 800;
            config.screenHeight = 600;
            config.fullscreen = false;
            config.borderless = false;
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
        }
        file << toml::format(data);
        file.close();

    } catch (const std::exception &e) {
        qWarning() << "保存配置文件失败:" << e.what();
    }
}