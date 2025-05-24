#include "gamelogic.h"
#include <QRandomGenerator>

GameLogic::GameLogic(QObject *parent) : QObject{parent} {
    resetGame();
}

void GameLogic::createGrid() {
    grid.resize(ROWS);
    for (int r = 0; r < ROWS; ++r) {
        grid[r].resize(COLS);
        for (int c = 0; c < COLS; ++c) {
            grid[r][c] = QRandomGenerator::global()->bounded(1, 5); // 假设有4种图案
        }
    }
}

void GameLogic::resetGame() {
    createGrid();
}

int GameLogic::getCell(int row, int col) const {
    if (row >= 0 && row < ROWS && col >= 0 && col < COLS) {
        return grid[row][col];
    }
    return 0;
}

bool GameLogic::canLink(int r1, int c1, int r2, int c2) {
    if (grid[r1][c1] == grid[r2][c2] && !(r1 == r2 && c1 == c2)) {
        // 假设可以连接就清除
        grid[r1][c1] = 0;
        grid[r2][c2] = 0;
        return true;
    }
    return false;
}
