#ifndef SETTINGS_H
#define SETTINGS_H

#include "config.h"

#include <QGuiApplication>
#include <QObject>
#include <QPair>
#include <QQuickWindow>
#include <QScreen>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QDebug>
#include <algorithm>

class Settings : public QObject {
    Q_OBJECT

  public:
    explicit Settings(QObject *parent = nullptr);
    ~Settings();

    // 玩家名称相关
    QString getPlayerName() const;           // 获取玩家名称
    void setPlayerName(const QString &name); // 设置玩家名称

    // 排行榜相关
    QVariantList getLeaderboard() const;                        // 获取排行榜
    void addScoreToLeaderboard(const QString &name, int score); // 添加分数到排行榜

    // 难度相关
    QString getDifficulty() const;                 // 获取难度
    void setDifficulty(const QString &difficulty); // 设置难度

    // 游戏时间相关
    int getGameTime() const;       // 获取游戏时间
    void setGameTime(int seconds); // 设置游戏时间

    // 音量相关
    double getVolume() const;      // 获取音量
    void setVolume(double volume); // 设置音量

    // 窗口管理相关
    QString getScreenSize() const;             // 获取当前屏幕大小
    void setScreenSize(int width, int height); // 设置屏幕大小
    bool isFullscreen() const;                 // 获取是否全屏
    void setFullscreen(bool fullscreen);       // 设置全屏
    void resizeWindow(int width, int height);  // 调整窗口大小

    // 配置相关
    void saveConfig(); // 保存配置

  signals:
    void leaderboardChanged(); // 排行榜变化信号
    void gameTimeChanged();    // 游戏时间变化信号
    void volumeChanged();      // 音量变化信号
    void windowSizeChanged();  // 窗口大小变化信号

  private:
    Config::config config; // 配置
    Config configManager;  // 配置管理器
    QQuickWindow *window;  // 主窗口
};

#endif // SETTINGS_H