#ifndef GAMELOGIC_H
#define GAMELOGIC_H

#include <QObject>
#include <QVariant>
#include <QString>
#include <QVector>
#include <QPair>
#include "toml.hpp"

class GameLogic : public QObject
{
    Q_OBJECT
public:
    explicit GameLogic(QObject *parent = nullptr);
    ~GameLogic();

    // 难度相关常量
    static const int EASY_PATTERNS = 4;    // 简单难度：4种图案
    static const int MEDIUM_PATTERNS = 8;  // 中等难度：8种图案
    static const int HARD_PATTERNS = 12;   // 困难难度：12种图案
    static const int TOTAL_PATTERNS = 20;  // 总图案数量

    Q_INVOKABLE int cols() const { return COLS; }
    Q_INVOKABLE int rows() const { return ROWS; }
    Q_INVOKABLE int getCell(int row, int col) const; // 获取单元格的值
    Q_INVOKABLE bool isOuterCell(int row, int col) const; // 判断是否是外圈格子
    Q_INVOKABLE int getPatternCount() const; // 获取当前难度的图案数量
    Q_INVOKABLE int getTotalPatterns() const { return TOTAL_PATTERNS; } // 获取总图案数量

    Q_INVOKABLE void resetGame(); // 重置游戏    
    Q_INVOKABLE bool canLink(int r1, int c1, int r2, int c2); // 检查两个单元格是否可以连接
    Q_INVOKABLE void removeLink(int r1, int c1, int r2, int c2); // 移除连接的两个方块
    Q_INVOKABLE QVariantList getLinkPath(int r1, int c1, int r2, int c2); // 获取连接路径
    Q_INVOKABLE bool isGameOver() const; // 检查游戏是否结束
    
    // 用户名相关
    Q_INVOKABLE QString getPlayerName() const; // 获取玩家名称
    Q_INVOKABLE void setPlayerName(const QString &name); // 设置玩家名称
    
    // 排行榜相关
    Q_INVOKABLE QVariantList getLeaderboard() const; // 获取排行榜
    Q_INVOKABLE void addScoreToLeaderboard(const QString &name, int score); // 添加分数到排行榜
      // 设置相关
    Q_INVOKABLE QString getDifficulty() const; // 获取难度
    Q_INVOKABLE void setDifficulty(const QString &difficulty); // 设置难度
    Q_INVOKABLE int getGameTime() const; // 获取游戏时间
    Q_INVOKABLE void setGameTime(int seconds); // 设置游戏时间
    Q_INVOKABLE double getVolume() const; // 获取音量
    Q_INVOKABLE void setVolume(double volume); // 设置音量

private:
    int ROWS = 8; // 行数
    int COLS = 10; // 列数
    int VISIBLE_ROWS = ROWS-2; // 可见行数
    int VISIBLE_COLS = COLS-2; // 可见列数
    QVector<QVector<int>> grid; // 游戏网格
    
    // 玩家信息
    QString m_playerName; // 玩家名称
    
    // 排行榜信息
    struct LeaderboardEntry {
        QString name;
        int score;
    };
    QVector<LeaderboardEntry> m_leaderboard; // 排行榜
      // 游戏设置
    QString m_difficulty; // 难度
    int m_gameTime; // 游戏时间（秒）
    double m_volume; // 音量（0.0-1.0）
    
    void createGrid(); // 生成游戏网格
    void loadConfig(); // 加载配置
    void saveConfig(); // 保存配置

signals:
    Q_SIGNAL void cellsChanged(); // 当方块状态改变时发出信号
    Q_SIGNAL void playerNameChanged(); // 当玩家名称改变时发出信号
    Q_SIGNAL void leaderboardChanged(); // 当排行榜改变时发出信号
    Q_SIGNAL void difficultyChanged(); // 当难度改变时发出信号
    Q_SIGNAL void gameTimeChanged(); // 当游戏时间改变时发出信号
    Q_SIGNAL void volumeChanged(); // 当音量改变时发出信号
};

#endif // GAMELOGIC_H
