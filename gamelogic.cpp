#include "gamelogic.h"
#include <QRandomGenerator>
#include <QVariantList>
#include <QVariantMap>
#include <QQueue>
#include <QPoint>
#include <QPair>

GameLogic::GameLogic(QObject *parent) : QObject{parent} {
    createGrid();
}


/**
 * @brief 生成游戏网格
 * @details 生成一个ROWS x COLS的网格，并随机填充1到4之间的数字
 */
void GameLogic::createGrid() {
    grid.resize(ROWS);
    for (int r = 0; r < ROWS; ++r) {
        grid[r].resize(COLS);
        for (int c = 0; c < COLS; ++c) {
            // 外圈格子设为0（空格子）
            if (isOuterCell(r, c)) {
                grid[r][c] = 0;
            } else {
                grid[r][c] = QRandomGenerator::global()->bounded(1, 5); // 假设有4种图案
            }
        }
    }
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
bool GameLogic::canLink(int r1, int c1, int r2, int c2) {
    // 检查两个方块是否相同且不为0
    if (grid[r1][c1] == grid[r2][c2] && grid[r1][c1] != 0 && grid[r2][c2] != 0) {
        // 方向数组：上、右、下、左
        const int dr[] = {-1, 0, 1, 0};
        const int dc[] = {0, 1, 0, -1};
        
        // BFS需要的队列
        QQueue<QPoint> queue;
        
        // 记录已访问的节点
        QVector<QVector<bool>> visited(ROWS, QVector<bool>(COLS, false));
        
        // 将起点加入队列
        queue.enqueue(QPoint(r1, c1));
        visited[r1][c1] = true;
        
        // BFS寻路
        while (!queue.isEmpty()) {
            QPoint current = queue.dequeue();
            
            // 检查四个方向
            for (int i = 0; i < 4; ++i) {
                int nr = current.x() + dr[i];
                int nc = current.y() + dc[i];
                
                // 检查新坐标是否有效
                if (nr >= 0 && nr < ROWS && nc >= 0 && nc < COLS && !visited[nr][nc]) {
                    // 如果是空格子或者是外圈格子，则可以继续搜索
                    if (grid[nr][nc] == 0 || isOuterCell(nr, nc)) {
                        visited[nr][nc] = true;
                        queue.enqueue(QPoint(nr, nc));
                    } 
                    // 如果是目标点，说明找到路径
                    else if (nr == r2 && nc == c2) {
                        return true;
                    }
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
