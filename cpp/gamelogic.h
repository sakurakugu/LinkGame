#ifndef GAMELOGIC_H
#define GAMELOGIC_H

#include "settings.h"

#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QObject>
#include <QPair>
#include <QPoint>
#include <QQueue>
#include <QRandomGenerator>
#include <QString>
#include <QTextStream>
#include <QTimer>
#include <QVariant>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>
#include <algorithm>
#include <cmath>
#include <fstream>
#include <iostream>
#include <toml.hpp>

class GameLogic : public QObject {
    Q_OBJECT
    Q_PROPERTY(int timeLeft READ timeLeft NOTIFY timeLeftChanged)
    Q_PROPERTY(bool isPaused READ isPaused NOTIFY pauseStateChanged)

  public:
    explicit GameLogic(Settings *settingsManager, QObject *parent = nullptr);
    ~GameLogic();

    //  用于BFS的路径节点结构体
    struct PathNode {
        int x, y;      // 坐标
        int direction; // 当前方向（0:上, 1:右, 2:下, 3:左）
        int turns;     // 转弯次数
    };

    // 提示相关的结构体
    struct HintStep {
        int row1, col1;    // 第一个方块的位置
        int row2, col2;    // 第二个方块的位置
        QVariantList path; // 连接路径
    };

    Q_INVOKABLE int cols() const;                                         // 获取列数
    Q_INVOKABLE int rows() const;                                         // 获取行数
    Q_INVOKABLE int getCell(int row, int col) const;                      // 获取单元格的值
    Q_INVOKABLE bool isOuterCell(int row, int col) const;                 // 判断是否是外圈格子
    Q_INVOKABLE bool canLink(int r1, int c1, int r2, int c2) const;       // 检查两个单元格是否可以连接
    Q_INVOKABLE void removeLink(int r1, int c1, int r2, int c2);          // 移除连接的两个方块
    Q_INVOKABLE QVariantList getLinkPath(int r1, int c1, int r2, int c2); // 获取连接路径，用于绘制路径
    Q_INVOKABLE bool isGameOver() const;                                  // 检查游戏是否结束
    Q_INVOKABLE int getScore() const;                                     // 获取当前分数
    Q_INVOKABLE void setScore(int score);                                 // 设置当前分数
    Q_INVOKABLE QVariantMap getHint();                                    // 获取提示
    Q_INVOKABLE QPair<int, int> getFactorPair(int n) const;               // 获取因子对（行和列）
    Q_INVOKABLE int calculateScore(int pairCount, int turnCount);         // 计算综合评分
    Q_INVOKABLE int getConsecutiveMatches() const;                        // 获取连续消除次数

    // 游戏管理相关
    Q_INVOKABLE void startGame();  // 开始游戏
    Q_INVOKABLE void pauseGame();  // 暂停游戏
    Q_INVOKABLE void resumeGame(); // 恢复游戏
    Q_INVOKABLE void endGame();    // 结束游戏
    Q_INVOKABLE void resetGame();  // 重置游戏

    // 倒计时相关
    Q_INVOKABLE int timeLeft() const;
    Q_INVOKABLE bool isPaused() const;
    Q_INVOKABLE void setPaused(bool paused);

  signals:
    Q_SIGNAL void cellsChanged();                 // 当方块状态改变时发出信号
    Q_SIGNAL void playerNameChanged();            // 当玩家名称改变时发出信号
    Q_SIGNAL void leaderboardChanged();           // 当排行榜改变时发出信号
    Q_SIGNAL void difficultyChanged();            // 当难度改变时发出信号
    Q_SIGNAL void gameTimeChanged();              // 当游戏时间改变时发出信号
    Q_SIGNAL void volumeChanged();                // 当音量改变时发出信号
    Q_SIGNAL void hintAvailable(bool available);  // 提示可用信号
    Q_SIGNAL void gameStarted();                  // 游戏开始信号
    Q_SIGNAL void gamePaused();                   // 游戏暂停信号
    Q_SIGNAL void gameResumed();                  // 游戏恢复信号
    Q_SIGNAL void gameEnded();                    // 游戏结束信号
    Q_SIGNAL void gameCompleted();                // 游戏完成信号（所有方块都被消除）
    Q_SIGNAL void scoreChanged(int score);        // 分数变化信号
    Q_SIGNAL void timeLeftChanged(int time);      // 剩余时间变化信号
    Q_SIGNAL void pauseStateChanged(bool paused); // 暂停状态变化信号

  private:
    int ROWS;                   // 行数（包括隐藏的外圈）
    int COLS;                   // 列数（包括隐藏的外圈）
    QVector<QVector<int>> grid; // 游戏网格

    // 提示相关的成员
    QVector<HintStep> solutionSteps; // 存储解决方案步骤
    int currentStep;                 // 当前步骤索引

    Settings *settings; // 设置管理器

    Config::config config;
    bool m_customLeaderboardEnabled = true;
    bool isGameRunning; // 游戏是否正在运行
    int currentScore;   // 当前分数

    // 综合评分系统相关成员
    int consecutiveMatches;  // 连续消除次数
    QDateTime lastMatchTime; // 上次消除的时间戳

    // 倒计时相关
    QTimer *gameTimer_; // 游戏计时器
    int timeLeft_;      // 剩余时间
    bool isPaused_;     // 是否暂停

    void createGrid();                                                                     // 生成游戏网格
    QVector<QPair<int, int>> getValidPositions() const;                                    // 获取所有有效位置
    bool hasValidMove() const;                                                             // 检查是否有有效移动
    QVector<HintStep> findSolution();                                                      // 寻找解决方案
    void updateTimer();                                                                    // 更新计时器
    void updateRowAndColumn();                                                             // 更新行列数
    bool findPath(int r1, int c1, int r2, int c2, QVector<QVector<QPoint>> &result) const; // 路径查找算法
};

#endif // GAMELOGIC_H
