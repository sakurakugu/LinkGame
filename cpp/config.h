#ifndef CONFIG_H
#define CONFIG_H

#include "default_value.h"

#include <QDir>
#include <QFile>
#include <QObject>
#include <QStandardPaths>
#include <QString>
#include <QTextStream>
#include <QVector>
#include <toml.hpp>

class Config : public QObject {
    Q_OBJECT

  public:
    explicit Config(QObject *parent = nullptr);
    ~Config();

    // 排行榜信息
    struct LeaderboardEntry {
        QString name;
        int score;
    };

    // 配置结构体
    struct config {
        QString playerName;                    // 玩家名称
        QString difficulty;                    // 游戏难度
        int gameTime;                          // 游戏时间（秒）
        double volume;                         // 音量（0.0 - 1.0）
        QVector<LeaderboardEntry> leaderboard; // 排行榜，存储玩家名称和分数
        int screenWidth;                       // 窗口宽度
        int screenHeight;                      // 窗口高度
        bool fullscreen;                       // 是否全屏
        int blockCount;                        // 方块数量
        int blockTypes;                        // 方块种类数
    };

    void loadConfig(config &config);       // 加载配置
    void saveConfig(const config &config); // 保存配置
    void initConfig(config &config);       // 初始化配置

  private:
};

#endif // SETTINGS_H