#ifndef SETTINGS_H
#define SETTINGS_H

#include "config.h"

#include <QDebug>
#include <QGuiApplication>
#include <QObject>
#include <QPair>
#include <QQuickWindow>
#include <QScreen>
#include <QString>
#include <QStringList>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>
#include <algorithm>

class Settings : public QObject {
    Q_OBJECT

  public:
    explicit Settings(QObject *parent = nullptr);
    ~Settings();

    // 初始化窗口
    Q_INVOKABLE void initWindow();

    // 玩家名称相关
    Q_INVOKABLE QString getPlayerName() const;           // 获取玩家名称
    Q_INVOKABLE void setPlayerName(const QString &name); // 设置玩家名称

    // 排行榜相关
    Q_INVOKABLE QVariantList getLeaderboard() const;                        // 获取排行榜
    Q_INVOKABLE void addScoreToLeaderboard(const QString &name, int score); // 添加分数到排行榜

    // 难度相关
    Q_INVOKABLE QString getDifficulty() const;                 // 获取难度
    Q_INVOKABLE void setDifficulty(const QString &difficulty); // 设置难度

    // 游戏时间相关
    Q_INVOKABLE int getGameTime() const;       // 获取游戏时间
    Q_INVOKABLE void setGameTime(int seconds); // 设置游戏时间

    // 声音相关
    Q_INVOKABLE double getVolume() const;       // 获取音量
    Q_INVOKABLE void setVolume(double volume);  // 设置音量
    Q_INVOKABLE bool getSoundState() const;     // 获取声音状态
    Q_INVOKABLE void setSoundState(bool state); // 设置声音状态

    // 方块相关
    Q_INVOKABLE int getBlockCount() const;     // 获取方块数量
    Q_INVOKABLE void setBlockCount(int count); // 设置方块数量
    Q_INVOKABLE int getBlockTypes() const;     // 获取方块种类数
    Q_INVOKABLE void setBlockTypes(int types); // 设置方块种类数

    // 窗口管理相关
    Q_INVOKABLE QString getScreenSize() const;             // 获取当前屏幕大小
    Q_INVOKABLE void setScreenSize(int width, int height); // 设置屏幕大小
    Q_INVOKABLE bool isFullscreen() const;                 // 获取是否全屏
    Q_INVOKABLE void setFullscreen(bool fullscreen);       // 设置全屏
    Q_INVOKABLE bool isBorderless() const;                 // 获取是否无边框
    Q_INVOKABLE void setBorderless(bool borderless);       // 设置无边框
    Q_INVOKABLE void resizeWindow(int width, int height);  // 调整窗口大小
    Q_INVOKABLE void updateWindowSize();                   // 更新窗口大小
    Q_INVOKABLE int getWindowWidth() const;                // 获取窗口宽度
    Q_INVOKABLE int getWindowHeight() const;               // 获取窗口高度

    // 物理屏幕大小相关
    Q_INVOKABLE QPair<int, int> getPhysicalScreenSize() const;      // 获取物理屏幕大小
    Q_INVOKABLE QStringList getWindowSizeModel() const;             // 获取窗口大小模型
    Q_INVOKABLE QPair<int, int> getAvailableScreenSize() const;     // 获取可用屏幕大小（不包括任务栏等系统区域）
    QPair<int, int> logicalToPhysical(int width, int height) const; // 逻辑像素转物理像素(× 缩放倍数 dpr)
    int logicalToPhysical(int number) const;                        // 逻辑像素转物理像素(× 缩放倍数 dpr)

    // 配置相关
    Q_INVOKABLE void saveConfig(); // 保存配置

  signals:
    Q_SIGNAL void leaderboardChanged();            // 排行榜变化信号
    Q_SIGNAL void gameTimeChanged();               // 游戏时间变化信号
    Q_SIGNAL void volumeChanged();                 // 音量变化信号
    Q_SIGNAL void soundStateChanged(bool enabled); // 音效状态变化信号
    Q_SIGNAL void windowSizeChanged();             // 窗口大小变化信号
    Q_SIGNAL void blockSettingsChanged();          // 方块设置变化信号
    Q_SIGNAL void windowStateChanged();            // 窗口状态变化信号

  private:
    Config::config config; // 配置
    Config configManager;  // 配置管理器
    QQuickWindow *window;  // 主窗口
};

#endif // SETTINGS_H