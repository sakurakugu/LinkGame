#ifndef GAMELOGIC_H
#define GAMELOGIC_H

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
#include <QVariant>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>
#include <algorithm>
#include <fstream>
#include <iostream>
#include <toml.hpp>
#include "settings.h"

class GameLogic : public QObject {
    Q_OBJECT
  public:
    explicit GameLogic(QObject *parent = nullptr);
    ~GameLogic();

    // 提示相关的结构体
    struct HintStep {
        int row1, col1;    // 第一个方块的位置
        int row2, col2;    // 第二个方块的位置
        QVariantList path; // 连接路径
    };

    Q_INVOKABLE int cols() const {
        return COLS;
    }
    Q_INVOKABLE int rows() const {
        return ROWS;
    }
    Q_INVOKABLE int getCell(int row, int col) const;      // 获取单元格的值
    Q_INVOKABLE bool isOuterCell(int row, int col) const; // 判断是否是外圈格子
    Q_INVOKABLE void resetGame();                                         // 重置游戏
    Q_INVOKABLE bool canLink(int r1, int c1, int r2, int c2) const;       // 检查两个单元格是否可以连接
    Q_INVOKABLE void removeLink(int r1, int c1, int r2, int c2);          // 移除连接的两个方块
    Q_INVOKABLE QVariantList getLinkPath(int r1, int c1, int r2, int c2); // 获取连接路径
    Q_INVOKABLE bool isGameOver() const;                                  // 检查游戏是否结束
    Q_INVOKABLE QVariantList getHint();                                   // 获取提示
    Q_INVOKABLE QVector<QPoint> findPath(int row1, int col1, int row2, int col2); // 寻找最少弯折的路径

    // 游戏管理相关
    void startGame();  // 开始游戏
    void pauseGame();  // 暂停游戏
    void resumeGame(); // 恢复游戏
    void endGame();    // 结束游戏

  signals:
    Q_SIGNAL void cellsChanged();                // 当方块状态改变时发出信号
    Q_SIGNAL void playerNameChanged();           // 当玩家名称改变时发出信号
    Q_SIGNAL void leaderboardChanged();          // 当排行榜改变时发出信号
    Q_SIGNAL void difficultyChanged();           // 当难度改变时发出信号
    Q_SIGNAL void gameTimeChanged();             // 当游戏时间改变时发出信号
    Q_SIGNAL void volumeChanged();               // 当音量改变时发出信号
    Q_SIGNAL void hintAvailable(bool available); // 提示可用信号
    Q_SIGNAL void gameStarted();           // 游戏开始信号
    Q_SIGNAL void gamePaused();            // 游戏暂停信号
    Q_SIGNAL void gameResumed();           // 游戏恢复信号
    Q_SIGNAL void gameEnded();             // 游戏结束信号
    Q_SIGNAL void scoreChanged(int score); // 分数变化信号

  private:
    int ROWS = 8;                // 行数
    int COLS = 10;               // 列数
    int VISIBLE_ROWS = ROWS - 2; // 可见行数
    int VISIBLE_COLS = COLS - 2; // 可见列数
    QVector<QVector<int>> grid;  // 游戏网格

    // 提示相关的成员
    QVector<HintStep> solutionSteps; // 存储解决方案步骤
    int currentStep;                 // 当前步骤索引

    Settings* settings; // 设置管理器

    Config::config config;
    bool m_customLeaderboardEnabled = true;
    bool isGameRunning; // 游戏是否正在运行
    int currentScore;   // 当前分数

    void createGrid();                                  // 生成游戏网格
    void loadConfig();                                  // 加载配置
    void saveConfig();                                  // 保存配置
    void generateSolution();                            // 生成解决方案
    bool isValidPosition(int row, int col) const;       // 检查位置是否有效
    QVector<QPair<int, int>> getValidPositions() const; // 获取所有有效位置
    bool hasValidMove() const;                          // 检查是否有有效移动
    QVector<HintStep> findSolution();                   // 寻找解决方案
    bool canConnectDirectly(int row1, int col1, int row2, int col2);
    QPoint findOneCornerPath(int row1, int col1, int row2, int col2);
    QPair<QPoint, QPoint> findTwoCornerPath(int row1, int col1, int row2, int col2);
    void setCustomBlocks(int count);
    void setCustomLeaderboardEnabled(bool enabled);
};

#endif // GAMELOGIC_H
