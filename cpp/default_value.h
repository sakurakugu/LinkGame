#ifndef DEFAULT_VALUE_H
#define DEFAULT_VALUE_H

struct DefaultValues {
    static constexpr const char *player_name = "Player";
    static constexpr const char *difficulty = "normal";
    static constexpr int game_time = 180;      // 默认游戏时间为3分钟
    static constexpr double volume = 0.8;      // 默认音量为80%
    static constexpr int screen_width = 800;   // 默认窗口宽度
    static constexpr int screen_height = 600;  // 默认窗口高度
    static constexpr bool fullscreen = false;  // 默认不全屏
};

#endif // DEFAULT_VALUE_H
