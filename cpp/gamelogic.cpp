#include "gamelogic.h"

GameLogic::GameLogic(Settings *settingsManager, QObject *parent)
    : QObject{parent}, isGameRunning(false), currentScore(0), timeLeft_(0), isPaused_(false), consecutiveMatches(0) {
    // 使用外部提供的设置管理器
    settings = settingsManager;

    // 创建游戏计时器
    gameTimer_ = new QTimer(this);
    connect(gameTimer_, &QTimer::timeout, this, &GameLogic::updateTimer);

    // 根据设置更新行列数
    updateRowAndColumn();

    // 创建游戏网格，不在这里创建，GUI中不会显示
    createGrid();

    // 初始化上次匹配时间
    lastMatchTime = QDateTime::currentDateTime();

    // 监听方块设置变化，更新行列数（使用直接连接模式以确保立即执行）
    connect(settings, &Settings::blockSettingsChanged, this, [this]() {
        updateRowAndColumn();
        resetGame(); // 重置游戏以应用新的行列数
    });
}

GameLogic::~GameLogic() {
    delete gameTimer_;
}

/**
 * @brief 开始游戏
 * @details 如果游戏未开始，则开始游戏并初始化游戏计时器
 */
void GameLogic::startGame() {
    if (!isGameRunning) {
        isGameRunning = true;
        currentScore = 0;
        consecutiveMatches = 0;  // 重置连续消除次数
        lastMatchTime = QDateTime::currentDateTime(); // 重置匹配时间
        timeLeft_ = settings->getGameTime();
        isPaused_ = false;
        gameTimer_->start(1000); // 每秒更新一次

        // 发出相关信号
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
        createGrid();  // 重新生成游戏网格
        emit timeLeftChanged(timeLeft_);
        emit gameEnded();
    }
}

/**
 * @brief 重置游戏
 * @details 重置游戏状态，重新生成网格和解决方案
 */
void GameLogic::resetGame() {
    // 重置游戏状态
    isGameRunning = true;
    currentScore = 0;
    timeLeft_ = settings->getGameTime();
    isPaused_ = false;
    consecutiveMatches = 0;  // 重置连续消除次数
    lastMatchTime = QDateTime::currentDateTime(); // 重置上次匹配时间
    gameTimer_->start(1000); // 再重启计时器
    createGrid();            // 重新生成游戏网格
    emit gameStarted();
    emit scoreChanged(currentScore);
    emit timeLeftChanged(timeLeft_);
    emit pauseStateChanged(isPaused_);
}

/**
 * @brief 根据方块数量更新行列数
 * @details 根据设置中的方块数量计算合适的行列数
 */
void GameLogic::updateRowAndColumn() {
    // 获取方块数量
    const int blockCount = settings->getRealBlockCount();

    // 计算合适的行列数
    auto [r, c] = getFactorPair(blockCount);

    // 更新行列数（加2是为了外圈边框）
    ROWS = r + 2;
    COLS = c + 2;
}

/**
 * @brief 生成游戏网格
 * @details 生成一个ROWS x COLS的网格，并随机填充1到20之间的图案，还有生成一个具有有效解的游戏布局
 */
void GameLogic::createGrid() {
    // 初始化网格为 ROWS x COLS，所有格子值为 0
    grid = QVector<QVector<int>>(ROWS, QVector<int>(COLS, 0));

    // 获取当前难度下的图案数量
    int blockTypes = settings->getBlockTypes();

    // 计算每种图案需要的几对 (总需要的方块数除以图案种数)
    int pairsPerPattern = settings->getRealBlockCount() / (2 * blockTypes);

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

    // 寻找是否最少有一个解
    solutionSteps = findSolution();
    currentStep = 0; // 当前步骤索引

    // 如果没有有效的解决方案，重新生成
    if (solutionSteps.isEmpty()) {
        qDebug() << "没有有效的解决方案，重新生成网格";
        createGrid();
    }
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
 * @brief 获取指定位置的方块的值
 * @param row 行
 * @param col 列
 * @return 指定位置的方块的值
 */
int GameLogic::getCell(int row, int col) const {
    if (isOuterCell(row, col)) {
        return 0; // 外圈格子返回0
    }
    return grid[row][col];
}

/**
 * @brief 执行路径查找算法
 * @param r1 第一个方块的行
 * @param c1 第一个方块的列
 * @param r2 第二个方块的行
 * @param c2 第二个方块的列
 * @param result 存储结果数组，用于重构路径
 * @return 是否找到路径
 */
bool GameLogic::findPath(int r1, int c1, int r2, int c2, QVector<QVector<QPoint>> &result) const {
    // 方向数组：上、右、下、左
    const int dr[] = {-1, 0, 1, 0};
    const int dc[] = {0, 1, 0, -1};

    // BFS需要的队列
    QQueue<PathNode> queue;

    // 记录已访问的节点及其转弯次数（记录最小转弯次数）
    QVector<QVector<int>> visited(ROWS, QVector<int>(COLS, INT_MAX));

    // 初始化result数组
    result.resize(ROWS);
    for (int i = 0; i < ROWS; i++) {
        result[i].resize(COLS, QPoint(-1, -1));
    }

    // 将起点的四个方向加入队列
    for (int i = 0; i < 4; ++i) {
        int nr = r1 + dr[i];
        int nc = c1 + dc[i];
        if (nr >= 0 && nr < ROWS && nc >= 0 && nc < COLS && (grid[nr][nc] == 0 || (nr == r2 && nc == c2))) {
            queue.enqueue({nr, nc, i, 0});
            visited[nr][nc] = 0;
            result[nr][nc] = QPoint(r1, c1);
        }
    }

    // 标记是否找到路径
    bool found = false;

    // BFS寻路
    while (!queue.isEmpty() && !found) {
        PathNode current = queue.dequeue();

        // 如果到达目标点，标记为找到
        if (current.x == r2 && current.y == c2) {
            found = true;
            break;
        }

        // 检查四个方向
        for (int i = 0; i < 4; ++i) {
            int nr = current.x + dr[i];                                      // new row
            int nc = current.y + dc[i];                                      // new column
            int newTurns = current.turns + (i != current.direction ? 1 : 0); // 计算转弯次数

            // 检查新坐标是否有效，且转弯次数不超过2次
            /* 如果新坐标在网格内，且转弯次数不超过2次，并且未被访问过或转弯次数更少
               且新坐标是空格或外圈格子（值为0），或者是目标点 */
            if (nr >= 0 && nr < ROWS && nc >= 0 && nc < COLS && newTurns <= 2 && visited[nr][nc] > newTurns &&
                (getCell(nr, nc) == 0 || (nr == r2 && nc == c2))) {
                visited[nr][nc] = newTurns;                    // 更新访问记录
                result[nr][nc] = QPoint(current.x, current.y); // 记录结果节点
                queue.enqueue({nr, nc, i, newTurns});          // 将新节点加入队列

                // 如果找到目标点
                if (nr == r2 && nc == c2) {
                    found = true;
                    break;
                }
            }
        }
    }

    return found;
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
        QVector<QVector<QPoint>> result;
        return findPath(r1, c1, r2, c2, result);
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
        // 检查最近一次消除时间，更新连击计数
        QDateTime currentTime = QDateTime::currentDateTime();
        int secSinceLastMatch = lastMatchTime.secsTo(currentTime);
        
        // 如果在3秒内完成下一次消除，增加连击
        if (secSinceLastMatch <= 3) {
            consecutiveMatches++;
        } else {
            // 超过3秒，重置连击
            consecutiveMatches = 0;
        }
        
        // 更新上次消除时间
        lastMatchTime = currentTime;
        
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
    QVector<QVector<QPoint>> result;
    QVariantList path;

    // 是否找到路径
    bool found = findPath(r1, c1, r2, c2, result);

    // 如果找到路径，则构建路径
    if (found) {
        QPoint current(r2, c2);

        // 从目标点开始，一直回溯到起点
        while (!(current.x() == r1 && current.y() == c1)) {
            QVariantMap point;
            point["row"] = current.x();
            point["col"] = current.y();
            path.prepend(point); // 从终点向起点倒序添加

            current = result[current.x()][current.y()];
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
                positions.append({r, c});
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

    // 使用提前退出策略，一旦找到可移动的方块就返回
    for (int i = 0; i < positions.size(); ++i) {
        for (int j = i + 1; j < positions.size(); ++j) {
            int r1 = positions[i].first;
            int c1 = positions[i].second;
            int r2 = positions[j].first;
            int c2 = positions[j].second;

            // 只有相同的方块图案才可能连接
            if (grid[r1][c1] == grid[r2][c2]) {
                if (canLink(r1, c1, r2, c2)) {
                    return true;
                }
            }
        }
    }
    return false;
}

/**
 * @brief 生成解决方案步骤列表
 * @return 解决方案步骤列表
 */
QVector<GameLogic::HintStep> GameLogic::findSolution() {
    QVector<HintStep> solution;            // 解决方案步骤列表
    QVector<QVector<int>> tempGrid = grid; // 创建临时网格

    // 通过模拟消除找出一个完整的解决方案
    while (true) {
        auto positions = getValidPositions(); // 获取所有有效位置
        bool foundPair = false;               // 是否找到可消除的一对

        for (int i = 0; i < positions.size() && !foundPair; ++i) {
            for (int j = i + 1; j < positions.size() && !foundPair; ++j) {
                int r1 = positions[i].first;
                int c1 = positions[i].second;
                int r2 = positions[j].first;
                int c2 = positions[j].second;

                if (grid[r1][c1] == grid[r2][c2] && canLink(r1, c1, r2, c2)) {
                    // 创建解决方案步骤
                    HintStep step;
                    step.row1 = r1;
                    step.col1 = c1;
                    step.row2 = r2;
                    step.col2 = c2;
                    step.path = getLinkPath(r1, c1, r2, c2); // 获取连接路径
                    solution.append(step);                   // 添加步骤到解决方案列表

                    // 模拟消除这对方块
                    grid[r1][c1] = 0;
                    grid[r2][c2] = 0;
                    foundPair = true;
                }
            }
        }

        // 如果没有找到可消除的一对，结束循环
        if (!foundPair) {
            break;
        }
    }

    grid = tempGrid; // 恢复原始网格
    return solution;
}

/**
 * @brief 更新游戏计时器
 * @details 每秒更新一次游戏计时器
 */
void GameLogic::updateTimer() {
    if (timeLeft_ > 0) {
        --timeLeft_;
        emit timeLeftChanged(timeLeft_);

        // 时间结束时结束游戏
        if (timeLeft_ <= 0) {
            endGame();
        }
    }
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

    // 从平方根向下搜索，找到最接近的因子对
    for (int i = sqrtN; i >= 1; --i) {
        if (n % i == 0) {
            int j = n / i;
            return {i, j}; // 返回尽可能接近的两个因子
        }
    }
    return {1, n};
}

/**
 * @brief 计算综合评分
 * @details 基于多种因素计算分数，包括转折点数量、剩余时间、难度和连击
 * @param pairCount 消除方块对数（默认为1）
 * @param turnCount 连接路径转折点数
 * @return 计算得出的分数
 */
int GameLogic::calculateScore(int pairCount, int turnCount) {
    // 基础分值
    int baseScore = 10;
    
    // 转折点奖励 (0-2个转折点，转折越少奖励越高)
    int turnBonus = 0;
    if (turnCount <= 2) {
        turnBonus = (2 - turnCount) * 5;
    }
    
    // 速度奖励 (根据剩余时间百分比，最多加15分)
    double timePercent = static_cast<double>(timeLeft_) / settings->getGameTime();
    int timeBonus = static_cast<int>(timePercent * 15);
    
    // 难度系数 (1.0-2.0)
    double difficultyFactor = 1.0;
    QString difficulty = settings->getDifficulty();
    if (difficulty == "普通") difficultyFactor = 1.5;
    else if (difficulty == "困难") difficultyFactor = 2.0;
    
    // 连续消除奖励 (每连击增加10%，最多叠加到200%)
    int comboFactor = std::min(consecutiveMatches, 10); // 最多10连击
    double comboMultiplier = 1.0 + comboFactor * 0.1;
    
    // 计算最终分数
    int totalScore = static_cast<int>((baseScore + turnBonus + timeBonus) * difficultyFactor * comboMultiplier);
    
    // 确保至少有基本分
    if (totalScore < baseScore) {
        totalScore = baseScore;
    }
    
    // 返回计算得出的分数 * 消除对数
    return totalScore * pairCount;
}

/**
 * @brief 获取连续消除次数
 * @details 获取当前玩家的连续消除次数
 * @return 连续消除次数
 */
int GameLogic::getConsecutiveMatches() const {
    return consecutiveMatches;
}
