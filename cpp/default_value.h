#ifndef DEFAULT_VALUE_H
#define DEFAULT_VALUE_H

struct DefaultValues {
    static constexpr const char *player_name = "Player";
    static constexpr const char *difficulty = "普通";
    static constexpr int game_time = 180;            // 默认游戏时间为3分钟
    static constexpr double volume = 0.8;            // 默认音量为80%
    static constexpr bool sound_state = true;        // 默认声音状态为开启
    static constexpr int screen_width = 800;         // 默认窗口宽度
    static constexpr int screen_height = 600;        // 默认窗口高度
    static constexpr bool fullscreen = false;        // 默认非全屏
    static constexpr bool borderless = false;        // 默认非无边框
    static constexpr int block_count = 48;           // 默认方块数量
    static constexpr int block_types = 8;            // 默认方块种类数
    static constexpr bool join_leaderboard = true;   // 默认加入排行榜
    static constexpr const char *theme = "light";    // 默认主题为浅色
    static constexpr const char *language = "zh_CN"; // 默认语言为中文

    static constexpr int block_types_easy = 4;   // 简单难度：4种图案
    static constexpr int block_types_medium = 8; // 普通难度：8种图案
    static constexpr int block_types_hard = 12;  // 困难难度：12种图案
    static constexpr int block_types_total = 20; // 总图案数量

    static constexpr int block_count_easy = 24;   // 简单难度：24个方块
    static constexpr int block_count_medium = 48; // 普通难度：48个方块
    static constexpr int block_count_hard = 72;   // 困难难度：72个方块

    static constexpr int game_time_easy = 120;   // 简单难度：120秒
    static constexpr int game_time_medium = 180; // 普通难度：180秒
    static constexpr int game_time_hard = 240;   // 困难难度：240秒

    static constexpr bool join_leaderboard_easy = true;   // 简单难度：加入排行榜
    static constexpr bool join_leaderboard_medium = true; // 普通难度：加入排行榜
    static constexpr bool join_leaderboard_hard = true;   // 困难难度：加入排行榜
};

#endif // DEFAULT_VALUE_H
