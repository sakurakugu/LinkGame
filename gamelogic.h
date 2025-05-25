#ifndef GAMELOGIC_H
#define GAMELOGIC_H

#include <QObject>
#include <QVariant>

class GameLogic : public QObject
{
    Q_OBJECT
public:
    explicit GameLogic(QObject *parent = nullptr);

    Q_INVOKABLE int cols() const { return COLS; }
    Q_INVOKABLE int rows() const { return ROWS; }
    Q_INVOKABLE int getCell(int row, int col) const; // 获取单元格的值

    Q_INVOKABLE void resetGame(); // 重置游戏    
    Q_INVOKABLE bool canLink(int r1, int c1, int r2, int c2); // 检查两个单元格是否可以连接
    Q_INVOKABLE void removeLink(int r1, int c1, int r2, int c2); // 移除连接的两个方块
    Q_INVOKABLE QVariantList getLinkPath(int r1, int c1, int r2, int c2); // 获取连接路径

private:
    int ROWS = 6; // 行数
    int COLS = 8; // 列数
    QVector<QVector<int>> grid; // 游戏网格

    void createGrid(); // 生成游戏网格

signals:
    void cellsChanged(); // 当方块状态改变时发出信号
};

#endif // GAMELOGIC_H
