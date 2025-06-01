#include "gamelogic.h"
#include <QRandomGenerator>
#include <QDebug>
#include <algorithm>

GameLogic::GameLogic(QObject *parent) : QObject{parent}, isGameRunning(false), currentScore(0) {
    // 创建设置管理器
    settings = new Settings(this);
    
    // 创建游戏网格
    createGrid();
}

GameLogic::~GameLogic() {
    delete settings;
}

/**
 * @brief 生成游戏网格
 * @details 生成一个ROWS x COLS的网格，并随机填充1到4之间的数字
 */
void GameLogic::createGrid() {
    generateSolution();  // 生成解决方案
    emit cellsChanged(); // 通知 QML 更新
}

/**
 * @brief 判断指定位置是否为外圈格子
 * @param row 行
 * @param col 列
 * @return 如果指定位置为外圈格子返回true，否则返回false
 */
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
        struct Node {
            int x, y, direction, turns; // x, y为坐标，direction为当前方向（0:上, 1:右, 2:下, 3:左），turns为转弯次数
        };
        QQueue<Node> queue;

        // 记录已访问的节点
        QVector<QVector<int>> visited(ROWS, QVector<int>(COLS, INT_MAX));

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
    return settings->getPlayerName();
}

/**
 * @brief 设置玩家名称
 * @param name 玩家名称
 */
void GameLogic::setPlayerName(const QString &name) {
    if (settings->getPlayerName() != name) {
        settings->setPlayerName(name);
        emit playerNameChanged();
    }
}

/**
 * @brief 获取排行榜
 * @return 排行榜列表
 */
QVariantList GameLogic::getLeaderboard() const {
    return settings->getLeaderboard();
}

/**
 * @brief 添加分数到排行榜
 * @param name 玩家名称
 * @param score 分数
 */
void GameLogic::addScoreToLeaderboard(const QString &name, int score) {
    settings->addScoreToLeaderboard(name, score);
    emit leaderboardChanged();
}

/**
 * @brief 获取难度
 * @return 难度
 */
QString GameLogic::getDifficulty() const {
    return settings->getDifficulty();
}

/**
 * @brief 设置难度
 * @param difficulty 难度
 */
void GameLogic::setDifficulty(const QString &difficulty) {
    if (settings->getDifficulty() != difficulty) {
        settings->setDifficulty(difficulty);
        emit difficultyChanged();
    }
}

/**
 * @brief 获取游戏时间
 * @return 游戏时间（秒）
 */
int GameLogic::getGameTime() const {
    return settings->getGameTime();
}

/**
 * @brief 设置游戏时间
 * @param seconds 游戏时间（秒）
 */
void GameLogic::setGameTime(int seconds) {
    if (settings->getGameTime() != seconds) {
        settings->setGameTime(seconds);
        emit gameTimeChanged();
    }
}

/**
 * @brief 获取音量
 * @return 音量（0.0-1.0）
 */
double GameLogic::getVolume() const {
    return settings->getVolume();
}

/**
 * @brief 设置音量
 * @param volume 音量（0.0-1.0）
 */
void GameLogic::setVolume(double volume) {
    if (settings->getVolume() != volume) {
        settings->setVolume(volume);
        emit volumeChanged();
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

/**
 * @brief 获取模式数量
 * @return 模式数量
 */
int GameLogic::getPatternCount() const {
    if (settings->getDifficulty() == "简单") {
        return EASY_PATTERNS;
    } else if (settings->getDifficulty() == "普通") {
        return MEDIUM_PATTERNS;
    } else if (settings->getDifficulty() == "困难") {
        return HARD_PATTERNS;
    }
    return MEDIUM_PATTERNS; // 默认返回普通难度
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

QVariantList GameLogic::getHint() {
    if (currentStep >= solutionSteps.size()) {
        return QVariantList();
    }

    const HintStep &step = solutionSteps[currentStep];
    QVariantList hint;

    // 检查位置是否有效
    if (step.row1 >= 0 && step.row1 < ROWS && step.col1 >= 0 && step.col1 < COLS && step.row2 >= 0 &&
        step.row2 < ROWS && step.col2 >= 0 && step.col2 < COLS) {
        hint.append(step.row1);
        hint.append(step.col1);
        hint.append(step.row2);
        hint.append(step.col2);
        hint.append(step.path);
    }

    currentStep++;
    return hint;
}

QVector<QPoint> GameLogic::findPath(int row1, int col1, int row2, int col2) {
    QVector<QPoint> path;
    
    // 检查是否可以直接连接（直线）
    if (canConnectDirectly(row1, col1, row2, col2)) {
        path.append(QPoint(row1, col1));
        path.append(QPoint(row2, col2));
        return path;
    }
    
    // 检查是否可以通过一个拐点连接
    QPoint corner = findOneCornerPath(row1, col1, row2, col2);
    if (corner.x() != -1) {
        path.append(QPoint(row1, col1));
        path.append(corner);
        path.append(QPoint(row2, col2));
        return path;
    }
    
    // 检查是否可以通过两个拐点连接
    QPair<QPoint, QPoint> corners = findTwoCornerPath(row1, col1, row2, col2);
    if (corners.first.x() != -1) {
        path.append(QPoint(row1, col1));
        path.append(corners.first);
        path.append(corners.second);
        path.append(QPoint(row2, col2));
        return path;
    }
    
    return path;
}

bool GameLogic::canConnectDirectly(int row1, int col1, int row2, int col2) {
    // 检查是否在同一行
    if (row1 == row2) {
        int minCol = qMin(col1, col2);
        int maxCol = qMax(col1, col2);
        for (int col = minCol + 1; col < maxCol; col++) {
            if (grid[row1][col] != 0) return false;
        }
        return true;
    }
    
    // 检查是否在同一列
    if (col1 == col2) {
        int minRow = qMin(row1, row2);
        int maxRow = qMax(row1, row2);
        for (int row = minRow + 1; row < maxRow; row++) {
            if (grid[row][col1] != 0) return false;
        }
        return true;
    }
    
    return false;
}

QPoint GameLogic::findOneCornerPath(int row1, int col1, int row2, int col2) {
    // 尝试水平-垂直连接
    QPoint corner1(col2, row1);
    if (canConnectDirectly(row1, col1, row1, col2) && 
        canConnectDirectly(row1, col2, row2, col2)) {
        return corner1;
    }
    
    // 尝试垂直-水平连接
    QPoint corner2(col1, row2);
    if (canConnectDirectly(row1, col1, row2, col1) && 
        canConnectDirectly(row2, col1, row2, col2)) {
        return corner2;
    }
    
    return QPoint(-1, -1);
}

QPair<QPoint, QPoint> GameLogic::findTwoCornerPath(int row1, int col1, int row2, int col2) {
    // 尝试所有可能的两拐点路径
    QVector<QPair<QPoint, QPoint>> possiblePaths;
    
    // 水平-垂直-水平
    QPoint corner1(col1, row2);
    QPoint corner2(col2, row2);
    if (canConnectDirectly(row1, col1, row1, col1) && 
        canConnectDirectly(row1, col1, row2, col1) && 
        canConnectDirectly(row2, col1, row2, col2)) {
        possiblePaths.append(qMakePair(corner1, corner2));
    }
    
    // 垂直-水平-垂直
    QPoint corner3(col2, row1);
    QPoint corner4(col2, row2);
    if (canConnectDirectly(row1, col1, row1, col2) && 
        canConnectDirectly(row1, col2, row2, col2) && 
        canConnectDirectly(row2, col2, row2, col2)) {
        possiblePaths.append(qMakePair(corner3, corner4));
    }
    
    // 选择最短路径
    if (!possiblePaths.isEmpty()) {
        return possiblePaths.first();
    }
    
    return qMakePair(QPoint(-1, -1), QPoint(-1, -1));
}

/**
 * @brief 生成解决方案
 * @details 生成一个具有有效解的游戏布局
 */
void GameLogic::generateSolution() {
    // 初始化网格
    grid.resize(ROWS);
    for (int i = 0; i < ROWS; ++i) {
        grid[i].resize(COLS);
        for (int j = 0; j < COLS; ++j) {
            grid[i][j] = 0;  // 初始化所有格子为0
        }
    }

    // 获取当前难度下的图案数量
    int patternCount = getPatternCount();
    
    // 计算每种图案需要的对数 (总需要的方块数除以图案种数)
    int totalCells = (ROWS - 2) * (COLS - 2);
    int pairsPerPattern = totalCells / (2 * patternCount);

    // 准备可用位置列表 (只考虑内部格子)
    QVector<QPair<int, int>> positions;
    for (int i = 1; i < ROWS - 1; ++i) {
        for (int j = 1; j < COLS - 1; ++j) {
            positions.append(qMakePair(i, j));
        }
    }

    // 随机打乱位置列表
    std::random_shuffle(positions.begin(), positions.end());
    
    // 分配图案到格子中
    int posIndex = 0;
    for (int pattern = 1; pattern <= patternCount; ++pattern) {
        for (int pair = 0; pair < pairsPerPattern * 2; pair += 2) {
            if (posIndex + 1 < positions.size()) {
                // 为每对格子分配相同的图案
                auto [row1, col1] = positions[posIndex++];
                auto [row2, col2] = positions[posIndex++];
                grid[row1][col1] = pattern;
                grid[row2][col2] = pattern;
            }
        }
    }

    // 处理剩余的位置（如果有的话）
    while (posIndex + 1 < positions.size()) {
        // 为剩余的每对格子分配随机图案
        int pattern = QRandomGenerator::global()->bounded(1, patternCount + 1);
        auto [row1, col1] = positions[posIndex++];
        auto [row2, col2] = positions[posIndex++];
        grid[row1][col1] = pattern;
        grid[row2][col2] = pattern;
    }

    // 生成解决方案步骤
    solutionSteps = findSolution();
    currentStep = 0;

    // 如果没有有效的解决方案，重新生成
    if (solutionSteps.isEmpty()) {
        generateSolution();
    }
}

void GameLogic::startGame() {
    if (!isGameRunning) {
        isGameRunning = true;
        currentScore = 0;
        emit gameStarted();
        emit scoreChanged(currentScore);
    }
}

void GameLogic::pauseGame() {
    if (isGameRunning) {
        isGameRunning = false;
        emit gamePaused();
    }
}

void GameLogic::resumeGame() {
    if (!isGameRunning) {
        isGameRunning = true;
        emit gameResumed();
    }
}

void GameLogic::endGame() {
    if (isGameRunning) {
        isGameRunning = false;
        emit gameEnded();
    }
}

void GameLogic::addScore(const QString &name, int score) {
    currentScore += score;
    emit scoreChanged(currentScore);
    addScoreToLeaderboard(name, currentScore);
}
