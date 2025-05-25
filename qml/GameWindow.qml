import QtQuick
import QtQuick.Controls

pragma ComponentBehavior: Bound

Window {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("连连看小游戏")
    minimumWidth: 640
    minimumHeight: 480

    // // 需要在这里声明 gameLogic 属性
    // required property var gameLogic

    property int selectedRow: -1 // 选中的行
    property int selectedCol: -1 // 选中的列
    property var linkPath: [] // 存储连接路径的点
    property bool showingPath: false // 是否正在显示路径

    signal resetAllColors // 重置所有颜色信号
    signal closed // 窗口关闭信号

    // 当窗口关闭时发出信号
    onClosing: {
        closed()
    }

    // 连接路径画布
    Canvas {
        id: linkCanvas
        anchors.fill: grid // 填充整个网格
        z: 1 // 确保Canvas在Grid上方
        visible: root.showingPath

        onPaint: {
            if (root.linkPath.length < 2)
                return; // 如果路径长度小于2，不绘制

            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.strokeStyle = "red";
            ctx.lineWidth = 3;

            ctx.beginPath();
            // 从第一个点开始
            ctx.moveTo(root.linkPath[0].x, root.linkPath[0].y);

            // 绘制路径上的所有点
            for (var i = 1; i < root.linkPath.length; i++) {
                ctx.lineTo(root.linkPath[i].x, root.linkPath[i].y);
            }

            ctx.stroke();
        }
    }

    // 网格布局
    Grid {
        id: grid
        columns: gameLogic.cols() // 获取列数
        rows: gameLogic.rows() // 获取行数
        anchors.centerIn: parent // 水平和垂直居中
        spacing: 4 // 网格间距

        function getCell(i) {
            return gameLogic.getCell(Math.floor(i / gameLogic.cols()), 
                   i % gameLogic.cols()); // 获取方块内容
        }

        function isOuterCell(i) {
            return gameLogic.isOuterCell(Math.floor(i / gameLogic.cols()), 
                   i % gameLogic.cols()); // 获取外圈方块
        }

        Repeater {
            model: gameLogic.rows() * gameLogic.cols()
            
            delegate: Rectangle {
                id: cell
                required property int index
                
                // 每个方块
                width: 50
                height: 50
                visible: !grid.isOuterCell(cell.index) // 外圈方块不可见
                color: grid.getCell(cell.index) === 0 ? "transparent" : "skyblue" // 根据游戏逻辑设置颜色
                border.color: grid.getCell(cell.index) === 0 ? "transparent" : "black" // 根据方块内容设置边框颜色

                // 添加颜色变化的行为
                Behavior on color {
                    ColorAnimation {
                        duration: 100 // 渐变持续时间 300 毫秒
                    }
                }

                Text {
                    // 显示方块内容
                    anchors.centerIn: parent // 文本居中
                    text: grid.getCell(cell.index)
                    color: grid.getCell(cell.index) === 0 ? "transparent" : "black" // 根据方块内容设置文字颜色
                }

                MouseArea {
                    anchors.fill: parent // 鼠标区域填充整个矩形
                    onClicked: {
                        // 计算行列
                        let r = Math.floor(cell.index / gameLogic.cols())
                        let c = cell.index % gameLogic.cols()

                        // 如果当前正在显示路径，不处理点击
                        if (root.showingPath)
                            return

                        if (gameLogic.getCell(r, c) !== 0) {
                            console.log("选中方块: " + r + ", " + c);
                            if (root.selectedRow === -1 && root.selectedCol === -1) {
                                // 如果之前没有选中任何方块，记录选中的方块
                                root.selectedRow = r
                                root.selectedCol = c
                                cell.color = "blue"
                            } else if (root.selectedRow === r && root.selectedCol === c) {
                                // 如果点击的是同一个方块，取消之前的选中
                                root.selectedRow = -1
                                root.selectedCol = -1
                                cell.color = "skyblue"
                            } else if (gameLogic.canLink(root.selectedRow, root.selectedCol, r, c)) {
                                // 如果可以连接两个方块
                                cell.color = "blue" // 先将第二个方块变为蓝色

                                // 准备连接信息
                                showLinkTimer.firstRow = root.selectedRow
                                showLinkTimer.firstCol = root.selectedCol
                                showLinkTimer.secondRow = r
                                showLinkTimer.secondCol = c
                                showLinkTimer.start()
                            } else {
                                // 不能连通
                                cell.color = "blue" // 先将第二个方块变为蓝色

                                // 设置不能连通时的定时器
                                resetColorTimer.firstRow = root.selectedRow
                                resetColorTimer.firstCol = root.selectedCol
                                resetColorTimer.secondRow = r
                                resetColorTimer.secondCol = c
                                resetColorTimer.start()
                            }
                        }
                    }
                }

                // 连接重置颜色信号
                Connections {
                    target: root
                    function onResetAllColors() {
                        cell.color = grid.getCell(cell.index) === 0 ? "transparent" : "skyblue";
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

    // 顶部工具栏
    Row {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
        spacing: 20

        Button {
            text: "重置游戏"
            onClicked: {
                gameLogic.resetGame()
                grid.forceLayout() // 强制布局更新
            }
        }

        Button {
            text: "返回主菜单"
            onClicked: {
                root.close()
            }
        }
    }

    // 不能连通时重置颜色的定时器
    Timer {
        id: resetColorTimer
        interval: 200 // 200毫秒后重置颜色
        running: false
        repeat: false
        property int firstRow: -1
        property int firstCol: -1
        property int secondRow: -1
        property int secondCol: -1

        // 定时器触发时的处理函数
        onTriggered: {
            // 重置选中状态
            root.selectedRow = -1
            root.selectedCol = -1
            // 重置所有颜色
            root.resetAllColors()
        }
    }
    
    Timer {
        id: pathTimer
        interval: 300 // 500毫秒
        running: false
        repeat: false
        property int firstRow: -1
        property int firstCol: -1
        property int secondRow: -1
        property int secondCol: -1

        // 定时器触发时的处理函数
        onTriggered: {
            // 移除连通的方块并隐藏路径
            gameLogic.removeLink(firstRow, firstCol, secondRow, secondCol)
            // 更改方块颜色
            root.resetAllColors() // 重置所有颜色
            root.showingPath = false
            linkCanvas.requestPaint() // 请求重绘画布
            root.selectedRow = -1
            root.selectedCol = -1
        }
    }

    // 显示连线的定时器，在改变第二个方块颜色后延迟一段时间再显示连线
    Timer {
        id: showLinkTimer
        interval: 150 // 150毫秒
        running: false
        repeat: false
        property int firstRow: -1
        property int firstCol: -1
        property int secondRow: -1
        property int secondCol: -1

        // 定时器触发时的处理函数
        onTriggered: {
            // 获取连接路径
            root.linkPath = gameLogic.getLinkPath(firstRow, firstCol, secondRow, secondCol)

            // 转换路径点坐标到Canvas坐标系统
            for (var i = 0; i < root.linkPath.length; i++) {
                let cellSize = 50 + 4 // 单元格尺寸 + 间距
                let x = root.linkPath[i].col * cellSize + cellSize / 2
                let y = root.linkPath[i].row * cellSize + cellSize / 2
                root.linkPath[i] = { x: x, y: y }
            }

            // 显示连接路径
            root.showingPath = true
            linkCanvas.requestPaint()

            // 设置隐藏方块的定时器
            pathTimer.firstRow = firstRow
            pathTimer.firstCol = firstCol
            pathTimer.secondRow = secondRow
            pathTimer.secondCol = secondCol
            pathTimer.start()
        }
    }
} 