#ifndef CONFIG_H
#define CONFIG_H

#include "default_value.h"

#include <QObject>
#include <QString>
#include <toml.hpp>

class Config : public QObject {
    Q_OBJECT

  public:
    // 单例模式
    static Config &GetInstance() {
        static Config instance;
        return instance;
    }

    // 禁用拷贝构造和赋值操作
    Config(const Config &) = delete;
    Config &operator=(const Config &) = delete;

    // 排行榜信息
    struct LeaderboardEntry {
        QString name;       // 玩家名称
        int score;          // 分数
        QString difficulty; // 难度
    };

    // 配置结构体
    struct config {
        QString playerName;                    // 玩家名称
        QVector<LeaderboardEntry> leaderboard; // 排行榜
        QString difficulty;                    // 难度
        int gameTime;                          // 游戏时间
        double volume;                         // 音量
        bool soundState;                       // 声音状态
        int screenWidth;                       // 屏幕宽度
        int screenHeight;                      // 屏幕高度
        bool fullscreen;                       // 是否全屏
        bool borderless;                       // 是否无边框
        int blockCount;                        // 方块数量
        int blockTypes;                        // 方块种类数
        bool joinLeaderboard;                  // 是否加入排行榜
        QString theme;                         // 主题
        QString language;                      // 语言
    };

    void loadConfig(config &config);       // 加载配置
    void saveConfig(const config &config); // 保存配置
    void initConfig(config &config);       // 初始化配置

  private:
    explicit Config(QObject *parent = nullptr);
    ~Config();

    template <typename T>
    QString getTomlString(const T &tomlValue, const std::string &key,
                          const QString &defaultValue); // 获取TOML中的字符串值
    template <typename T>
    int getTomlInt(const T &tomlValue, const std::string &key, int defaultValue); // 获取TOML中的整数值
    template <typename T>
    double getTomlDouble(const T &tomlValue, const std::string &key, double defaultValue); // 获取TOML中的双精度值
    template <typename T>
    bool getTomlBool(const T &tomlValue, const std::string &key, bool defaultValue); // 获取TOML中的布尔值
};

#endif // CONFIG_H