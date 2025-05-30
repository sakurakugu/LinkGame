#include "gamelogic.h"
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QPair>
#include <QPoint>
#include <QQueue>
#include <QRandomGenerator>
#include <QTextStream>
#include <QVariantList>
#include <QVariantMap>
#include <algorithm>
#include <fstream>
#include <iostream>
#include <toml.hpp>

GameLogic::GameLogic(QObject *parent) : QObject{parent} {
    // 设置默认值
    m_playerName = "未命名";
    m_difficulty = "中等";
    m_gameTime = 180;
    m_volume = 0.8; // 默认音量设置为80%

    // 加载配置
    loadConfig();

    // 创建游戏网格
    createGrid();
}

GameLogic::~GameLogic() {
    // 保存配置
    saveConfig();
}

/**
 * @brief 生成游戏网格
 * @details 生成一个ROWS x COLS的网格，并随机填充1到4之间的数字
 */
void GameLogic::createGrid() {
    generateSolution(); // 生成解决方案
    emit cellsChanged(); // 通知 QML 更新
}

bool GameLogic::isOuterCell(int row, int col) const {
    return row == 0 || row == ROWS - 1 || col == 0 || col == COLS - 1;
}

/**
 * @brief 重置游戏
 * @details 重新生成游戏网格，并通知QML更新
 */
void GameLogic::resetGame() {
    createGrid();
    emit cellsChanged(); // 通知 QML 更新
}

/**
 * @brief 获取指定位置的方块
 * @param row 行
 * @param col 列
 * @return 指定位置的方块
 */
int GameLogic::getCell(int row, int col) const {
    if (row >= 0 && row < ROWS && col >= 0 && col < COLS) {
        return grid[row][col];
    }
    return 0;
}

/**
 * @brief 判断两个方块是否可以连接
 * @param r1 第一个方块的行
 * @param c1 第一个方块的列
 * @param r2 第二个方块的行
 * @param c2 第二个方块的列
 * @return 如果可以连接返回true，否则返回false
 */
bool GameLogic::canLink(int r1, int c1, int r2, int c2) const {
    // 检查两个方块是否相同且不为0
    if (grid[r1][c1] == grid[r2][c2] && grid[r1][c1] != 0 && grid[r2][c2] != 0) {
        // 方向数组：上、右、下、左
        const int dr[] = {-1, 0, 1, 0};
        const int dc[] = {0, 1, 0, -1};

        // BFS需要的队列
        // QQueue<QPoint> queue;
        struct Node {
            int x, y, direction, turns; // x, y为坐标，direction为当前方向（0:上, 1:右, 2:下, 3:左），turns为转弯次数
        };
        QQueue<Node> queue;

        // 记录已访问的节点
        // QVector<QVector<bool>> visited(ROWS, QVector<bool>(COLS, false));
        QVector<QVector<int>> visited(ROWS, QVector<int>(COLS, INT_MAX));

        // 将起点加入队列
        // queue.enqueue(QPoint(r1, c1));
        // visited[r1][c1] = true;

        // 将起点加入队列
        for (int i = 0; i < 4; ++i) {
            int nr = r1 + dr[i];
            int nc = c1 + dc[i];
            if (nr >= 0 && nr < ROWS && nc >= 0 && nc < COLS && (grid[nr][nc] == 0 || (nr == r2 && nc == c2))) {
                queue.enqueue({nr, nc, i, 0});
                visited[nr][nc] = 0;
            }
        }

        // BFS寻路
        while (!queue.isEmpty()) {
            Node current = queue.dequeue();

            // 如果到达目标点，返回true
            if (current.x == r2 && current.y == c2) {
                return true;
            }

            // 检查四个方向
            for (int i = 0; i < 4; ++i) {
                int nr = current.x + dr[i];
                int nc = current.y + dc[i];
                int newTurns = current.turns + (i != current.direction ? 1 : 0); // 计算转弯次数

                // 检查新坐标是否有效
                if (nr >= 0 && nr < ROWS && nc >= 0 && nc < COLS && newTurns <= 2 && visited[nr][nc] > newTurns &&
                    (grid[nr][nc] == 0 || (nr == r2 && nc == c2))) {
                    visited[nr][nc] = newTurns;
                    queue.enqueue({nr, nc, i, newTurns});
                }
            }
        }
    }

    return false;
}

/**
 * @brief 移除连接的两个方块
 * @param r1 第一个方块的行
 * @param c1 第一个方块的列
 * @param r2 第二个方块的行
 * @param c2 第二个方块的列
 */
void GameLogic::removeLink(int r1, int c1, int r2, int c2) {
    if (grid[r1][c1] != 0 && grid[r2][c2] != 0) {
        // 清除两个方块
        grid[r1][c1] = 0;
        grid[r2][c2] = 0;
        // 发送信号，通知UI更新
        emit cellsChanged();
    }
}

/**
 * @brief 获取玩家名称
 * @return 玩家名称
 */
QString GameLogic::getPlayerName() const {
    return m_playerName;
}

/**
 * @brief 设置玩家名称
 * @param name 玩家名称
 */
void GameLogic::setPlayerName(const QString &name) {
    if (m_playerName != name) {
        m_playerName = name;
        emit playerNameChanged();
        saveConfig();
    }
}

/**
 * @brief 获取排行榜
 * @return 排行榜列表
 */
QVariantList GameLogic::getLeaderboard() const {
    QVariantList result;
    for (const auto &entry : m_leaderboard) {
        QVariantMap item;
        item["name"] = entry.name;
        item["score"] = entry.score;
        result.append(item);
    }
    return result;
}

/**
 * @brief 添加分数到排行榜
 * @param name 玩家名称
 * @param score 分数
 */
void GameLogic::addScoreToLeaderboard(const QString &name, int score) {
    auto it = std::find_if(m_leaderboard.begin(), m_leaderboard.end(),
                           [&name](const LeaderboardEntry &entry) { return entry.name == name; });

    if (it != m_leaderboard.end()) {
        // 如果找到相同用户名，更新分数
        it->score = std::max(it->score, score); // 保留更高分数
    } else {
        // 如果没有相同用户名，添加新的分数
        LeaderboardEntry newEntry;
        newEntry.name = name;
        newEntry.score = score;
        m_leaderboard.append(newEntry);
    }

    // 按分数降序排序
    std::sort(m_leaderboard.begin(), m_leaderboard.end(),
              [](const LeaderboardEntry &a, const LeaderboardEntry &b) { return a.score > b.score; });

    // // 只保留前10名
    // if (m_leaderboard.size() > 10) {
    //     m_leaderboard.resize(10);
    // }

    emit leaderboardChanged();
    saveConfig();
}

/**
 * @brief 获取难度
 * @return 难度
 */
QString GameLogic::getDifficulty() const {
    return m_difficulty;
}

/**
 * @brief 设置难度
 * @param difficulty 难度
 */
void GameLogic::setDifficulty(const QString &difficulty) {
    if (m_difficulty != difficulty) {
        m_difficulty = difficulty;
        emit difficultyChanged();
        saveConfig();
    }
}

/**
 * @brief 获取游戏时间
 * @return 游戏时间（秒）
 */
int GameLogic::getGameTime() const {
    return m_gameTime;
}

/**
 * @brief 设置游戏时间
 * @param seconds 游戏时间（秒）
 */
void GameLogic::setGameTime(int seconds) {
    if (m_gameTime != seconds) {
        m_gameTime = seconds;
        emit gameTimeChanged();
        saveConfig();
    }
}

/**
 * @brief 获取音量
 * @return 音量（0.0-1.0）
 */
double GameLogic::getVolume() const {
    return m_volume;
}

/**
 * @brief 设置音量
 * @param volume 音量（0.0-1.0）
 */
void GameLogic::setVolume(double volume) {
    // 确保音量在合法范围内
    double newVolume = qBound(0.0, volume, 1.0);
    if (m_volume != newVolume) {
        m_volume = newVolume;
        emit volumeChanged();
        saveConfig();
    }
}

/**
 * @brief 加载配置
 */
void GameLogic::loadConfig() {
    try {
        // 使用toml11库解析配置文件
        const auto data = toml::parse("config.toml");

        // 解析玩家名称
        if (data.contains("player") && toml::find(data, "player").contains("name")) {
            m_playerName = QString::fromStdString(toml::find<std::string>(data, "player", "name"));
        }        // 解析游戏设置
        if (data.contains("settings")) {
            const auto &settings = toml::find(data, "settings");

            if (settings.contains("difficulty")) {
                m_difficulty = QString::fromStdString(toml::find<std::string>(settings, "difficulty"));
            }

            if (settings.contains("game_time")) {
                m_gameTime = toml::find<int>(settings, "game_time");
            }
            
            if (settings.contains("volume")) {
                m_volume = toml::find<double>(settings, "volume");
                // 确保音量在合法范围内
                m_volume = qBound(0.0, m_volume, 1.0);
            }
        }

        // 解析排行榜
        m_leaderboard.clear();
        if (data.contains("leaderboard") && toml::find(data, "leaderboard").contains("entries")) {
            const auto &entries = toml::find(data, "leaderboard", "entries").as_array();
            for (const auto &entry : entries) {
                LeaderboardEntry leaderboardEntry;
                leaderboardEntry.name = QString::fromStdString(toml::find<std::string>(entry, "name"));
                leaderboardEntry.score = toml::find<int>(entry, "score");
                m_leaderboard.append(leaderboardEntry);
            }
        }
    } catch (const std::exception &e) {
        qDebug() << "解析配置文件出错:" << e.what() << "，使用默认配置";
    }
}

/**
 * @brief 保存配置
 */
void GameLogic::saveConfig() {
    try {
        // 创建toml数据结构
        toml::value data;

        // 写入玩家信息
        data["player"].comments().push_back(" 玩家信息");
        data["player"]["name"] = m_playerName.toStdString();

        // 写入游戏设置
        data["settings"].comments().push_back(" 游戏设置");
        data["settings"]["difficulty"] = m_difficulty.toStdString();
        data["settings"]["game_time"] = m_gameTime;

        // 写入排行榜
        data["leaderboard"].comments().push_back(" 玩家排行榜");
        std::vector<toml::value> entriesArray;
        for (const auto &entry : std::as_const(m_leaderboard)) {
            toml::value entryData;
            entryData["name"] = entry.name.toStdString();
            entryData["score"] = entry.score;
            entriesArray.push_back(entryData);
        }
        data["leaderboard"]["entries"] = entriesArray;

        // 添加注释
        data.comments().push_back(" 连连看游戏配置文件");
        data.comments().push_back(" \u4f5c\u8005: \u6f58\u5f66\u73ae\u3001\u8c22\u667a\u884c");

        // 写入文件
        std::ofstream file("config.toml");
        if (!file) {
            qDebug() << "无法保存配置文件";
            return;
        }

        file << toml::format(data);
        file.close();
    } catch (const std::exception &e) {
        qDebug() << "保存配置文件出错:" << e.what();
    }
}

/**
 * @brief 检查游戏是否结束
 * @return 如果游戏结束返回true，否则返回false
 */
bool GameLogic::isGameOver() const {
    // 检查是否还有非空方块
    for (int r = 1; r < ROWS - 1; ++r) {
        for (int c = 1; c < COLS - 1; ++c) {
            if (grid[r][c] != 0) {
                return false; // 还有方块，游戏未结束
            }
        }
    }
    return true; // 所有方块都已消除，游戏结束
}

/**
 * @brief 获取连接路径
 * @param r1 第一个方块的行
 * @param c1 第一个方块的列
 * @param r2 第二个方块的行
 * @param c2 第二个方块的列
 * @return 路径列表，包含连接两个方块的所有点
 */
QVariantList GameLogic::getLinkPath(int r1, int c1, int r2, int c2) {
    // 方向数组：上、右、下、左
    const int dr[] = {-1, 0, 1, 0};
    const int dc[] = {0, 1, 0, -1};

    // 结果路径
    QVariantList path;

    // BFS需要的队列
    QQueue<QPoint> queue;

    // 记录已访问的节点
    QVector<QVector<bool>> visited(ROWS, QVector<bool>(COLS, false));

    // 记录每个点的前驱节点，用于还原路径
    QVector<QVector<QPoint>> parent(ROWS, QVector<QPoint>(COLS, QPoint(-1, -1)));

    // 将起点加入队列
    queue.enqueue(QPoint(r1, c1));
    visited[r1][c1] = true;

    // 标记是否找到路径
    bool found = false;

    // BFS寻路
    while (!queue.isEmpty() && !found) {
        QPoint current = queue.dequeue();

        // 检查四个方向
        for (int i = 0; i < 4; ++i) {
            int nr = current.x() + dr[i];
            int nc = current.y() + dc[i];

            // 检查新坐标是否有效
            if (nr >= 0 && nr < ROWS && nc >= 0 && nc < COLS && !visited[nr][nc]) {
                // 如果是空格子、外圈格子或者是目标点，则可以移动
                if (grid[nr][nc] == 0 || isOuterCell(nr, nc) || (nr == r2 && nc == c2)) {
                    visited[nr][nc] = true;
                    parent[nr][nc] = current;
                    queue.enqueue(QPoint(nr, nc));

                    // 如果找到目标点
                    if (nr == r2 && nc == c2) {
                        found = true;
                        break;
                    }
                }
            }
        }
    }

    // 如果找到路径，则还原路径
    if (found) {
        QPoint current(r2, c2);

        // 从目标点开始，一直回溯到起点
        while (!(current.x() == r1 && current.y() == c1)) {
            QVariantMap point;
            point["row"] = current.x();
            point["col"] = current.y();
            path.prepend(point); // 从终点向起点倒序添加

            current = parent[current.x()][current.y()];
        }

        // 添加起点
        QVariantMap startPoint;
        startPoint["row"] = r1;
        startPoint["col"] = c1;
        path.prepend(startPoint);
    }

    return path;
}

int GameLogic::getPatternCount() const {
    if (m_difficulty == "简单") {
        return EASY_PATTERNS;
    } else if (m_difficulty == "中等") {
        return MEDIUM_PATTERNS;
    } else if (m_difficulty == "困难") {
        return HARD_PATTERNS;
    }
    return MEDIUM_PATTERNS; // 默认返回中等难度
}

/**
 * @brief 检查指定位置是否有效
 * @param row 行
 * @param col 列
 * @return 如果位置有效返回true，否则返回false
 */
bool GameLogic::isValidPosition(int row, int col) const {
    return row >= 1 && row < ROWS - 1 && col >= 1 && col < COLS - 1;
}

/**
 * @brief 获取所有有效位置
 * @return 所有有效位置的列表
 */
QVector<QPair<int, int>> GameLogic::getValidPositions() const {
    QVector<QPair<int, int>> positions;
    for (int r = 1; r < ROWS - 1; ++r) {
        for (int c = 1; c < COLS - 1; ++c) {
            if (grid[r][c] != 0) {
                positions.append(qMakePair(r, c));
            }
        }
    }
    return positions;
}

bool GameLogic::hasValidMove() const {
    auto positions = getValidPositions();
    for (int i = 0; i < positions.size(); ++i) {
        for (int j = i + 1; j < positions.size(); ++j) {
            int r1 = positions[i].first;
            int c1 = positions[i].second;
            int r2 = positions[j].first;
            int c2 = positions[j].second;
            
            if (grid[r1][c1] == grid[r2][c2] && canLink(r1, c1, r2, c2)) {
                return true;
            }
        }
    }
    return false;
}

QVector<GameLogic::HintStep> GameLogic::findSolution() {
    QVector<HintStep> solution;
    QVector<QVector<int>> tempGrid = grid; // 创建临时网格
    
    while (hasValidMove()) {
        auto positions = getValidPositions();
        bool found = false;
        
        for (int i = 0; i < positions.size() && !found; ++i) {
            for (int j = i + 1; j < positions.size() && !found; ++j) {
                int r1 = positions[i].first;
                int c1 = positions[i].second;
                int r2 = positions[j].first;
                int c2 = positions[j].second;
                
                if (grid[r1][c1] == grid[r2][c2] && canLink(r1, c1, r2, c2)) {
                    HintStep step;
                    step.row1 = r1;
                    step.col1 = c1;
                    step.row2 = r2;
                    step.col2 = c2;
                    step.path = getLinkPath(r1, c1, r2, c2);
                    solution.append(step);
                    
                    // 移除这对方块
                    grid[r1][c1] = 0;
                    grid[r2][c2] = 0;
                    found = true;
                }
            }
        }
    }
    
    grid = tempGrid; // 恢复原始网格
    return solution;
}

void GameLogic::generateSolution() {
    // 初始化网格大小
    grid.resize(ROWS);
    for (int r = 0; r < ROWS; ++r) {
        grid[r].resize(COLS);
        for (int c = 0; c < COLS; ++c) {
            grid[r][c] = 0;
        }
    }
    
    // 生成成对的图案
    QVector<int> patterns;
    int totalCells = (ROWS - 2) * (COLS - 2); // 内部格子数量
    int pairs = totalCells / 2; // 需要生成的图案对数
    
    // 确保图案数量是偶数
    if (pairs * 2 != totalCells) {
        pairs--;
    }
    
    // 生成成对的图案
    for (int i = 0; i < pairs; ++i) {
        int pattern = QRandomGenerator::global()->bounded(1, TOTAL_PATTERNS + 1);
        patterns.append(pattern);
        patterns.append(pattern);
    }
    
    // 随机打乱图案
    std::random_shuffle(patterns.begin(), patterns.end());
    
    // 填充网格
    int index = 0;
    for (int r = 1; r < ROWS - 1; ++r) {
        for (int c = 1; c < COLS - 1; ++c) {
            if (index < patterns.size()) {
                grid[r][c] = patterns[index++];
            }
        }
    }
    
    // 生成解决方案
    solutionSteps = findSolution();
    currentStep = 0;
}

QVariantList GameLogic::getHint() {
    if (currentStep >= solutionSteps.size()) {
        return QVariantList();
    }
    
    const HintStep& step = solutionSteps[currentStep];
    QVariantList hint;
    
    // 检查位置是否有效
    if (step.row1 >= 0 && step.row1 < ROWS && step.col1 >= 0 && step.col1 < COLS &&
        step.row2 >= 0 && step.row2 < ROWS && step.col2 >= 0 && step.col2 < COLS) {
        hint.append(step.row1);
        hint.append(step.col1);
        hint.append(step.row2);
        hint.append(step.col2);
        hint.append(step.path);
    }
    
    currentStep++;
    return hint;
}
