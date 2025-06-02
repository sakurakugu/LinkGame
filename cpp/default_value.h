#ifndef DEFAULT_VALUE_H
#define DEFAULT_VALUE_H

struct DefaultValues {
    static constexpr const char *player_name = "Player";
    static constexpr const char *difficulty = "普通";
    static constexpr int game_time = 180;     // 默认游戏时间为3分钟
    static constexpr double volume = 0.8;     // 默认音量为80%
    static constexpr bool sound_state = true; // 默认声音状态为开启
    static constexpr int screen_width = 800;  // 默认窗口宽度
    static constexpr int screen_height = 600; // 默认窗口高度
    static constexpr bool fullscreen = false; // 默认非全屏
    static constexpr bool borderless = false; // 默认非无边框
    static constexpr int block_count = 48;    // 默认方块数量
    static constexpr int block_types = 8;     // 默认方块种类数
    static constexpr const char *theme = "light"; // 默认主题为浅色

    static constexpr int block_types_easy = 4;   // 简单难度：4种图案
    static constexpr int block_types_medium = 8; // 普通难度：8种图案
    static constexpr int block_types_hard = 12;  // 困难难度：12种图案
    static constexpr int block_types_total = 20; // 总图案数量
};

#endif // DEFAULT_VALUE_H
