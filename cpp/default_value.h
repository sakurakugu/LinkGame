#ifndef DEFAULT_VALUE_H
#define DEFAULT_VALUE_H

#include <QList>
#include <QPair>
#include <QString>

namespace DefaultValues {

constexpr const char *appName = "LinkGame"; // 应用程序名称
constexpr const char *player_name = "Player";
constexpr const char *difficulty = "普通";
constexpr int game_time = 180;            // 默认游戏时间为3分钟
constexpr double volume = 0.8;            // 默认音量为80%
constexpr bool sound_state = true;        // 默认声音状态为开启
constexpr int screen_width = 800;         // 默认窗口宽度
constexpr int screen_height = 600;        // 默认窗口高度
constexpr bool fullscreen = false;        // 默认非全屏
constexpr bool borderless = false;        // 默认非无边框
constexpr int block_count = 48;           // 默认方块数量
constexpr int block_types = 8;            // 默认方块种类数
constexpr bool join_leaderboard = true;   // 默认加入排行榜
constexpr const char *theme = "Light";    // 默认主题为浅色
constexpr const char *language = "zh_CN"; // 默认语言为中文

constexpr int block_types_easy = 4;   // 简单难度：4种图案
constexpr int block_types_medium = 8; // 普通难度：8种图案
constexpr int block_types_hard = 12;  // 困难难度：12种图案
constexpr int block_types_total = 20; // 总图案数量

constexpr int block_count_easy = 24;   // 简单难度：24个方块
constexpr int block_count_medium = 48; // 普通难度：48个方块
constexpr int block_count_hard = 72;   // 困难难度：72个方块

constexpr int game_time_easy = 120;   // 简单难度：120秒
constexpr int game_time_medium = 180; // 普通难度：180秒
constexpr int game_time_hard = 240;   // 困难难度：240秒

constexpr bool join_leaderboard_easy = true;   // 简单难度：加入排行榜
constexpr bool join_leaderboard_medium = true; // 普通难度：加入排行榜
constexpr bool join_leaderboard_hard = true;   // 困难难度：加入排行榜

// 预设分辨率列表
const QList<QPair<int, int>> presetResolutions = {
    {4096, 2160}, // 4K UHD
    {3840, 2160}, // 4K UHD
    {2560, 1440}, // 2K QHD
    {1920, 1200}, // WUXGA
    {1920, 1080}, // Full HD
    {1680, 1050}, // WSXGA+
    {1600, 900},  // HD+
    {1440, 900},  // WXGA+
    {1366, 768},  // HD
    {1280, 1024}, // SXGA
    {1280, 800},  // WXGA
    {1280, 720},  // HD
    {1024, 768},  // XGA
    {800, 600}    // SVGA
};

// 支持的语言列表
const QList<QPair<QString, QString>> languageList = {{"zh_CN", "简体中文"}, {"en", "English"}, {"ja", "日本語"}};

constexpr std::string_view logFileName{"LinkGame"}; // 日志文件名

}; // namespace DefaultValues

#endif // DEFAULT_VALUE_H
