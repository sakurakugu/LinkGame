import QtQuick
import QtQuick.Controls // 导入Button

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("连连看小游戏")
    minimumWidth: 640

    property int selectedRow: -1 // 选中的行
    property int selectedCol: -1 // 选中的列

    Grid { // 网格布局
        id: grid
        columns: gameLogic.cols() // 获取列数
        rows: gameLogic.rows() // 获取行数
        anchors.centerIn: parent // 水平和垂直居中
        spacing: 4 // 网格间距

        Repeater {
            model: 36
            delegate: Rectangle {
                // 每个方块
                width: 50
                height: 50
                color: gameLogic.getCell(Math.floor(index / 6), index % 6) === 0 ? "lightgray" : "skyblue" // 根据游戏逻辑设置颜色
                border.color: "black"

                Text {
                    // 显示方块内容
                    anchors.centerIn: parent // 文本居中
                    text: gameLogic.getCell(Math.floor(index / 6), index % 6) // 获取方块内容
                }

                MouseArea {
                    anchors.fill: parent // 鼠标区域填充整个矩形
                    onClicked: {
                        let r = Math.floor(index / gameLogic.cols());
                        let c = index % gameLogic.cols();

                        if (selectedRow === -1) {
                            // 如果没有选中任何方块
                            selectedRow = r; // 记录选中行
                            selectedCol = c; // 记录选中列
                        } else {
                            console.log("已选择: " + selectedRow + ", " + selectedCol + " 和 " + r + ", " + c);
                            if (selectedRow === r && selectedCol === c) {
                                // 如果点击的是同一个方块
                                selectedRow = -1; // 重置选中行
                                selectedCol = -1; // 重置选中列
                            } else if (gameLogic.canLink(selectedRow, selectedCol, r, c)) {
                                // 检查是否可以连通
                                gameLogic.removeLink(selectedRow, selectedCol, r, c); // 移除连通的方块
                            }
                            selectedRow = -1; // 重置选中行
                            selectedCol = -1; // 重置选中列
                        }
                    }
                }
            }
        }
    }
    Connections {
        // 连接到游戏逻辑对象
        target: gameLogic
        function onCellsChanged() {
            grid.forceLayout(); // 当方块状态改变时强制布局更新
        }
    }

    Button {
        text: "重置游戏"
        anchors.bottom: parent.bottom // 设置按钮在底部
        anchors.horizontalCenter: parent.horizontalCenter // 水平居中
        anchors.bottomMargin: 10 // 底部边距
        onClicked: {
            gameLogic.resetGame();
            grid.forceLayout(); // 强制布局更新
        }
    }
}
