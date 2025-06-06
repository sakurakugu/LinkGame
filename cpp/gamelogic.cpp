#include "gamelogic.h"

GameLogic::GameLogic(Settings *settingsManager, QObject *parent)
    : QObject{parent}, isGameRunning(false), currentScore(0), timeLeft_(0), isPaused_(false) {
    // 使用外部提供的设置管理器
    settings = settingsManager;

    // 创建游戏计时器
    gameTimer_ = new QTimer(this);
    connect(gameTimer_, &QTimer::timeout, this, &GameLogic::updateTimer);
    
    // 根据设置更新行列数
    updateDimensions();
    
    // 创建游戏网格
    createGrid();
    
    // 监听方块设置变化，更新行列数（使用直接连接模式以确保立即执行）
    connect(settings, &Settings::blockSettingsChanged, this, [this]() {
        updateDimensions();
        resetGame();  // 重置游戏以应用新的行列数
    });
}

/**
 * @brief 根据方块数量更新行列数
 * @details 根据设置中的方块数量计算合适的行列数
 */
void GameLogic::updateDimensions() {
    // 获取方块数量
    int blockCount = settings->getBlockCount();
    
    // 计算合适的行列数
    auto [r, c] = getFactorPair(blockCount);
    
    // 更新行列数（加2是为了外圈边框）
    ROWS = r + 2;
    COLS = c + 2;
    VISIBLE_ROWS = r;
    VISIBLE_COLS = c;
    
    qDebug() << "更新网格尺寸：" << ROWS << "x" << COLS << "，有效格子：" << VISIBLE_ROWS << "x" << VISIBLE_COLS;
}

GameLogic::~GameLogic() {
    delete gameTimer_;
}

/**
 * @brief 生成游戏网格
 * @details 生成一个ROWS x COLS的网格，并随机填充1到20之间的图案
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

        // 检查游戏是否结束
        if (isGameOver()) {
            isGameRunning = false;
            emit gameCompleted();
        }
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
 * @brief 获取连接路径，用于绘制路径
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

    // BFS需要的队列，存储节点及其方向和转弯次数
    struct Node {
        int x, y, direction, turns; // x, y为坐标，direction为当前方向（0:上, 1:右, 2:下, 3:左），turns为转弯次数
    };
    QQueue<Node> queue;

    // 记录已访问的节点及其转弯次数（记录最小转弯次数）
    QVector<QVector<int>> visited(ROWS, QVector<int>(COLS, INT_MAX));

    // 记录每个点的前驱节点，用于还原路径
    QVector<QVector<QPoint>> parent(ROWS, QVector<QPoint>(COLS, QPoint(-1, -1)));

    // 将起点的四个方向加入队列
    for (int i = 0; i < 4; ++i) {
        int nr = r1 + dr[i];
        int nc = c1 + dc[i];
        if (nr >= 0 && nr < ROWS && nc >= 0 && nc < COLS && (grid[nr][nc] == 0 || (nr == r2 && nc == c2))) {
            queue.enqueue({nr, nc, i, 0});
            visited[nr][nc] = 0;
            parent[nr][nc] = QPoint(r1, c1);
        }
    }

    // 标记是否找到路径
    bool found = false;

    // BFS寻路
    while (!queue.isEmpty() && !found) {
        Node current = queue.dequeue();

        // 如果到达目标点，标记为找到
        if (current.x == r2 && current.y == c2) {
            found = true;
            break;
        }

        // 检查四个方向
        for (int i = 0; i < 4; ++i) {
            int nr = current.x + dr[i];
            int nc = current.y + dc[i];
            int newTurns = current.turns + (i != current.direction ? 1 : 0); // 计算转弯次数

            // 检查新坐标是否有效，且转弯次数不超过2次
            if (nr >= 0 && nr < ROWS && nc >= 0 && nc < COLS && newTurns <= 2 && visited[nr][nc] > newTurns &&
                (grid[nr][nc] == 0 || isOuterCell(nr, nc) || (nr == r2 && nc == c2))) {
                visited[nr][nc] = newTurns;
                parent[nr][nc] = QPoint(current.x, current.y);
                queue.enqueue({nr, nc, i, newTurns});

                // 如果找到目标点
                if (nr == r2 && nc == c2) {
                    found = true;
                    break;
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

/**
 * @brief 检查是否还有有效的移动，用于生成解决方案
 * @return 如果还有有效的移动返回true，否则返回false
 */
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

/**
 * @brief 生成解决方案
 * @return 解决方案步骤列表
 */
QVector<GameLogic::HintStep> GameLogic::findSolution() {
    QVector<HintStep> solution;            // 解决方案步骤列表
    QVector<QVector<int>> tempGrid = grid; // 创建临时网格

    while (hasValidMove()) {
        auto positions = getValidPositions(); // 获取所有有效位置
        bool found = false;                   // 是否找到解决方案

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
                    step.path = getLinkPath(r1, c1, r2, c2); // 获取连接路径
                    solution.append(step);                   // 添加步骤到解决方案列表

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
            grid[i][j] = 0; // 初始化所有格子为0
        }
    }

    // 获取当前难度下的图案数量
    int blockTypes = settings->getBlockTypes();

    // 计算每种图案需要的对数 (总需要的方块数除以图案种数)
    int totalCells = VISIBLE_ROWS * VISIBLE_COLS;
    int pairsPerPattern = totalCells / (2 * blockTypes);

    // 准备可用位置列表 (只考虑内部格子)
    QVector<QPair<int, int>> positions;
    for (int i = 1; i < ROWS - 1; ++i) {
        for (int j = 1; j < COLS - 1; ++j) {
            positions.append(qMakePair(i, j));
        }
    }

    // 随机打乱位置列表，使用C++11的梅森旋转算法（std::mt19937），random_device{}()生成随机种子
    auto seed = std::random_device{}();
    std::shuffle(positions.begin(), positions.end(), std::mt19937(seed));
    qDebug() << "种子：" << seed;

    // std::shuffle(positions.begin(), positions.end(), std::mt19937{std::random_device{}()});

    // 分配图案到格子中
    int posIndex = 0;
    for (int pattern = 1; pattern <= blockTypes; ++pattern) {
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
        int pattern = QRandomGenerator::global()->bounded(1, blockTypes + 1);
        auto [row1, col1] = positions[posIndex++];
        auto [row2, col2] = positions[posIndex++];
        grid[row1][col1] = pattern;
        grid[row2][col2] = pattern;
    }

    // 生成解决方案步骤
    solutionSteps = findSolution();
    currentStep = 0; // 当前步骤索引

    // 如果没有有效的解决方案，重新生成
    if (solutionSteps.isEmpty()) {
        generateSolution();
    }
}

/**
 * @brief 开始游戏
 * @details 如果游戏未开始，则开始游戏并初始化游戏计时器
 */
void GameLogic::startGame() {
    if (!isGameRunning) {
        isGameRunning = true;
        currentScore = 0;
        timeLeft_ = settings->getGameTime();
        isPaused_ = false;
        gameTimer_->start(1000); // 每秒更新一次
        emit gameStarted();
        emit scoreChanged(currentScore);
        emit timeLeftChanged(timeLeft_);
        emit pauseStateChanged(isPaused_);
    }
}

/**
 * @brief 暂停游戏
 * @details 如果游戏正在运行，则暂停游戏并停止计时
 */
void GameLogic::pauseGame() {
    if (isGameRunning) {
        isGameRunning = false;
        gameTimer_->stop();
        emit gamePaused();
    }
}

/**
 * @brief 恢复游戏
 * @details 如果游戏处于暂停状态，则恢复游戏并重新开始计时
 */
void GameLogic::resumeGame() {
    if (!isGameRunning) {
        isGameRunning = true;
        gameTimer_->start();
        emit gameResumed();
    }
}

/**
 * @brief 结束游戏
 * @details 如果游戏正在运行，则结束游戏并停止计时
 */
void GameLogic::endGame() {
    if (isGameRunning) {
        isGameRunning = false;
        gameTimer_->stop();
        timeLeft_ = 0; // 确保时间归零
        createGrid(); // 重新生成游戏网格
        emit timeLeftChanged(timeLeft_);
        emit gameEnded();
    }
}

/**
 * @brief 重置游戏
 * @details 重置游戏状态，重新生成网格和解决方案
 */
void GameLogic::resetGame() {
    isGameRunning = true;
    currentScore = 0;
    timeLeft_ = settings->getGameTime();
    isPaused_ = false;
    gameTimer_->start(1000); // 再重启计时器
    createGrid(); // 重新生成游戏网格
    emit gameStarted();
    emit scoreChanged(currentScore);
    emit timeLeftChanged(timeLeft_);
    emit pauseStateChanged(isPaused_);
}

/**
 * @brief 更新游戏计时器
 * @details 每秒更新一次游戏计时器
 */
void GameLogic::updateTimer() {
    if (timeLeft_ > 0) {
        timeLeft_--;
        emit timeLeftChanged(timeLeft_);

        if (timeLeft_ <= 0) {
            endGame();
        }
    }
}

/**
 * @brief 获取排行榜
 * @details 从 settings 中获取排行榜
 */
QString GameLogic::getRank(const QString &playerName, int score) const {
    // 从 settings 中获取排行榜
    QVariantList leaderboard = settings->getLeaderboard();

    // 如果分数为0或者排行榜为空，直接返回未上榜
    if (score <= 0 || leaderboard.isEmpty()) {
        return "未上榜";
    }

    // 检查玩家是否在排行榜中
    int rank = 1;
    bool foundPlayer = false;

    for (const QVariant &entryVar : leaderboard) {
        QVariantMap entry = entryVar.toMap();
        QString name = entry["name"].toString();
        int playerScore = entry["score"].toInt();

        // 如果发现相同名字和相同或更高分数，表示玩家已经在排行榜中
        if (name == playerName && playerScore >= score) {
            foundPlayer = true;
            break;
        }

        // 如果当前分数小于排行榜中的分数，排名加1
        if (score < playerScore) {
            rank++;
        }
    }

    // 检查设置中是否允许加入排行榜
    if (!settings->getJoinLeaderboard()) {
        return "未启用排行";
    }

    // 如果玩家不在排行榜中，且排名超过100，返回未上榜
    if (!foundPlayer && rank > 100) {
        return "未上榜";
    }

    // 返回排名
    return "第" + QString::number(rank) + "名";
}

/**
 * @brief 获取游戏计时器剩余时间
 * @details 获取游戏计时器剩余时间
 */
int GameLogic::timeLeft() const {
    return timeLeft_;
}

/**
 * @brief 获取游戏是否暂停
 * @details 获取游戏是否暂停
 */
bool GameLogic::isPaused() const {
    return isPaused_;
}

/**
 * @brief 设置游戏是否暂停
 * @details 设置游戏是否暂停
 */
void GameLogic::setPaused(bool paused) {
    if (isPaused_ != paused) {
        isPaused_ = paused;
        if (paused) {
            gameTimer_->stop();
        } else {
            gameTimer_->start();
        }
        emit pauseStateChanged(isPaused_);
    }
}

/**
 * @brief 获取当前得分
 * @details 获取当前得分
 */
int GameLogic::getScore() const {
    return currentScore;
}

/**
 * @brief 设置当前得分
 * @details 设置当前得分
 */
void GameLogic::setScore(int score) {
    currentScore = score;
}

/**
 * @brief 获取列数
 * @details 获取列数
 */
int GameLogic::cols() const {
    return COLS;
}

/**
 * @brief 获取行数
 * @details 获取行数
 */
int GameLogic::rows() const {
    return ROWS;
}

/**
 * @brief 获取提示
 * @details 获取一对可连接的方块和它们的连接路径
 * @return 包含可连接方块信息的QVariantMap
 */
QVariantMap GameLogic::getHint() {
    QVariantMap result;

    // 如果游戏暂停或者没有有效移动，返回空提示
    if (isPaused_ || !hasValidMove()) {
        return result;
    }

    // 找到当前网格状态下的一个可行解
    QVector<HintStep> currentSolution = findSolution();

    // 如果没有找到解决方案，返回空提示
    if (currentSolution.isEmpty()) {
        return result;
    }

    // 获取第一个提示步骤
    HintStep step = currentSolution.first();

    // 填充提示信息
    result["row1"] = step.row1;
    result["col1"] = step.col1;
    result["row2"] = step.row2;
    result["col2"] = step.col2;
    result["path"] = step.path;

    return result;
}

/**
 * @brief 获取因子对（行和列）
 * @details 获取一个偶数的因子对（行和列），两者的差尽量小
 * @param number 要分解的偶数
 * @return 包含因子对的QPair<int, int>
 */
QPair<int, int> GameLogic::getFactorPair(int n) const {
    int sqrtN = static_cast<int>(std::sqrt(n)); // 取平方根(显式转换为int)
    for (int i = sqrtN; i >= 1; --i) {
        if (n % i == 0) {
            int j = n / i;
            return {i, j}; // 返回尽可能接近的两个因子
        }
    }

    // 理论上不会到这里
    return {1, n};
}
