#ifndef GAMELOGIC_H
#define GAMELOGIC_H

#include <QObject>

class GameLogic : public QObject
{
    Q_OBJECT
public:
    explicit GameLogic(QObject *parent = nullptr);

    Q_INVOKABLE int getCell(int row, int col) const; // 获取单元格的值
    Q_INVOKABLE void resetGame(); // 重置游戏
    Q_INVOKABLE bool canLink(int r1, int c1, int r2, int c2); // 检查两个单元格是否可以连接

private:
    static const int ROWS = 6; // 行数
    static const int COLS = 6; // 列数
    QVector<QVector<int>> grid; // 游戏网格

    void createGrid(); // 生成游戏网格

signals:
};

#endif // GAMELOGIC_H
