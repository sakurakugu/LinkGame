#ifndef DEFAULT_VALUE_H
#define DEFAULT_VALUE_H

struct DefaultValues {
    static constexpr const char *player_name = "Player";
    static constexpr const char *difficulty = "普通";
    static constexpr int game_time = 180;      // 默认游戏时间为3分钟
    static constexpr double volume = 0.8;      // 默认音量为80%
    static constexpr int screen_width = 800;   // 默认窗口宽度
    static constexpr int screen_height = 600;  // 默认窗口高度
    static constexpr bool fullscreen = false;  // 默认非全屏
    static constexpr bool borderless = false;  // 默认非无边框
    static constexpr int block_count = 48;     // 默认方块数量
    static constexpr int block_types = 8;     // 默认方块种类数
};

#endif // DEFAULT_VALUE_H
