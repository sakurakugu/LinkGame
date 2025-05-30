import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Rectangle {
    id: root
    color: "#f0f0f0"
    focus: true // 确保可以接收键盘事件

    property int selectedRow: -1 // 选中的行
    property int selectedCol: -1 // 选中的列
    property var linkPath: [] // 存储连接路径的点
    property bool showingPath: false // 是否正在显示路径
    property int score: 0 // 当前分数
    property bool isPaused: false // 是否暂停
    property bool isSoundEnabled: true // 是否开启音效

    signal resetRequested // 重置游戏信号
    signal menuRequested // 返回主菜单信号
    signal scoreUpdated(int newScore) // 分数变化信号
    signal hintRequested // 提示信号
    signal resetAllCell
    signal exitGameRequested // 退出游戏信号
    signal pauseStateChanged(bool paused)
    signal soundStateChanged(bool enabled)
    
    // 暂停页面
    Rectangle {
        id: pauseOverlay
        anchors.fill: parent
        color: "#80000000" // 半透明黑色背景
        visible: root.isPaused
        z: 100

        Rectangle {
            width: parent.width
            height: 100
            anchors.centerIn: parent
            color: "#ffffff"
            opacity: 0.9

            RowLayout {
                anchors.centerIn: parent
                spacing: 20

                Button {
                    text: "继续"
                    onClicked: {
                        root.isPaused = false
                        root.pauseStateChanged(false)
                    }
                }

                Button {
                    text: "设置"
                    onClicked: {
                        settingsLoader.active = true
                    }
                }

                Button {
                    text: "退出"
                    onClicked: {
                        root.exitGameRequested()
                    }
                }
            }
        }
    }

    // 设置界面加载器
    Loader {
        id: settingsLoader
        anchors.fill: parent
        source: "Settings.qml"
        active: false
        onLoaded: {
            item.closed.connect(function() {
                settingsLoader.active = false
            })
            item.soundStateChanged.connect(function(enabled) {
                root.isSoundEnabled = enabled
            })
        }
    }

    // 音效组件
    MediaPlayer {
        id: clickSound
        source: "qrc:/qt/qml/LinkGame/music/sound_effect.mp3"
        audioOutput: AudioOutput {
            volume: root.isSoundEnabled ? gameLogic.getVolume() : 0
            muted: !root.isSoundEnabled
        }
    }
    
    // 监听音量变化
    Connections {
        target: gameLogic
        function onVolumeChanged() {
            // 当音量变化时更新音频输出
            clickSound.audioOutput.volume = gameLogic.getVolume();
        }
    }

    // 连接路径画布
    Canvas {
        id: linkCanvas
        anchors.fill: grid // 填充整个网格
        z: 1 // 确保Canvas在网格上方
        visible: root.showingPath

        onPaint: {
            if (root.linkPath.length < 2)
                return;

            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.strokeStyle = "red";
            ctx.lineWidth = 3;

            ctx.beginPath();
            ctx.moveTo(root.linkPath[0].x, root.linkPath[0].y);

            for (var i = 1; i < root.linkPath.length; i++) {
                ctx.lineTo(root.linkPath[i].x, root.linkPath[i].y);
            }

            ctx.stroke();
        }
    }

    // 状态栏
    Rectangle {
        id: statusBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: "#e0e0e0"

        RowLayout {
            anchors.centerIn: parent
            spacing: 20

            Text {
                id: gameStatus
                text: root.isPaused ? "游戏暂停" : "游戏进行中"
                font.pixelSize: 18
                Layout.alignment: Qt.AlignCenter
            }

            Text {
                id: scoreText
                text: "分数: " + root.score
                font.pixelSize: 18
            }

            Text {
                id: timeText
                text: "时间：" + Math.floor(timeLeft / 60) + ":" + (timeLeft % 60).toString().padStart(2, "0")
                font.pixelSize: 18
                Layout.alignment: Qt.AlignCenter
            }

            Button {
                text: root.isPaused ? "继续" : "暂停"
                onClicked: {
                    root.isPaused = !root.isPaused
                    root.pauseStateChanged(root.isPaused)
                }
            }

            Button {
                text: "重置游戏"
                onClicked: {
                    root.resetRequested()
                    root.resetAllCell() // 发射信号，重置所有单元格
                }
            }

            Button {
                text: "提示"
                onClicked: root.hintRequested() 
            }

            Button {
                text: "退出游戏"
                onClicked: {
                    // 发射信号，告知Main.qml退出到结算界面
                    root.resetRequested()
                    root.resetAllCell()
                    root.exitGameRequested()
                }
            }

            Button {
                text: "返回主菜单"
                onClicked: root.menuRequested()
            }
        }
    }

    // 游戏网格
    Grid {
        id: grid
        columns: gameLogic.cols()
        rows: gameLogic.rows()
        anchors.centerIn: parent
        spacing: 4

        function getCell(i) {
            return gameLogic.getCell(Math.floor(i / gameLogic.cols()), i % gameLogic.cols());
        }

        function isOuterCell(i) {
            return gameLogic.isOuterCell(Math.floor(i / gameLogic.cols()), i % gameLogic.cols());
        }

        Repeater {
            model: gameLogic.rows() * gameLogic.cols()

            delegate: Rectangle {
                id: cell

                // 每个方块
                width: 50
                height: 50
                // visible: !grid.isOuterCell(index) // 外圈方块不可见
                color: grid.getCell(index) === 0 ? "transparent" : "skyblue" // 根据游戏逻辑设置颜色
                border.color: grid.getCell(index) === 0 ? "transparent" : "black" // 根据方块内容设置边框颜色

                // 添加颜色变化的行为
                Behavior on color {
                    ColorAnimation {
                        duration: 100 // 渐变持续时间 100 毫秒
                    }
                }

                Image {
                    id: image
                    // 显示方块内容
                    anchors.centerIn: parent // 图片居中
                    width: parent.width // 设置图片宽度为方块宽度的80%
                    height: parent.height // 设置图片高度为方块高度的80%
                    source: {
                        // 获取单元格中的值
                        let cellValue = grid.getCell(index);
                        // 如果值为0，返回空字符串，否则返回对应的图片路径
                        return cellValue === 0 ? "" : "qrc:/qt/qml/LinkGame/image/fruits/" + cellValue + ".svg";
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // 如果方块已隐藏（值为0），不处理点击
                        if (grid.getCell(index) === 0) {
                            return;
                        }
                        
                        // 计算行列
                        let r = Math.floor(index / gameLogic.cols());
                        let c = index % gameLogic.cols();
                        // 播放点击音效
                        clickSound.stop();  // 先停止可能正在播放的音效
                        clickSound.play();  // 播放点击音效

                        // 如果当前正在显示路径，不处理点击
                        if (root.showingPath)
                            return;
                        if (gameLogic.getCell(r, c) !== 0) {
                            console.log("选中: " + index + " -> (" + r + "," + c + ") = " + gameLogic.getCell(r, c));
                            if (root.selectedRow === -1 && root.selectedCol === -1) {
                                // 如果之前没有选中任何方块，记录选中的方块
                                root.selectedRow = r;
                                root.selectedCol = c;
                                cell.color = "blue";
                            } else if (root.selectedRow === r && root.selectedCol === c) {
                                // 如果点击的是同一个方块，取消之前的选中
                                root.selectedRow = -1;
                                root.selectedCol = -1;
                                cell.color = "skyblue";
                            } else if (gameLogic.canLink(root.selectedRow, root.selectedCol, r, c)) {
                                // 如果可以连接两个方块
                                cell.color = "blue"; // 先将第二个方块变为蓝色
                                // 准备连接信息
                                showLinkTimer.firstRow = root.selectedRow;
                                showLinkTimer.firstCol = root.selectedCol;
                                showLinkTimer.secondRow = r;
                                showLinkTimer.secondCol = c;
                                showLinkTimer.start();
                            } else {
                                // 不能连通
                                cell.color = "blue"; // 先将第二个方块变为蓝色
                                // 设置不能连通时的定时器
                                resetColorTimer.firstRow = root.selectedRow;
                                resetColorTimer.firstCol = root.selectedCol;
                                resetColorTimer.secondRow = r;
                                resetColorTimer.secondCol = c;
                                resetColorTimer.start();
                            }
                        }
                    }
                }                // 连接重置信号
                Connections {
                    target: root
                    function onResetAllCell() {
                        cell.color = grid.getCell(index) === 0 ? "transparent" : "skyblue"; // 根据游戏逻辑设置颜色
                        cell.border.color = grid.getCell(index) === 0 ? "transparent" : "black"; // 根据方块内容设置边框颜色
                        image.source = grid.getCell(index) === 0 ? "" : "qrc:/qt/qml/LinkGame/image/fruits/" + grid.getCell(index) + ".svg"; // 设置图片路径
                    }
                }
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
            root.selectedRow = -1;
            root.selectedCol = -1;
            // 重置所有颜色
            root.resetAllCell();
        }
    }

    // 连通后隐藏路径的定时器
    Timer {
        id: pathTimer
        interval: 300 // 500毫秒
        running: false
        repeat: false
        property int firstRow: -1
        property int firstCol: -1
        property int secondRow: -1
        property int secondCol: -1        // 定时器触发时的处理函数
        onTriggered: {
            // 移除连通的方块并隐藏路径
            gameLogic.removeLink(firstRow, firstCol, secondRow, secondCol);
            // 更新分数（每消除一对方块加10分）
            root.score += 10; // 增加分数
            root.scoreUpdated(root.score);  // 发送信号
            // 更改方块颜色
            root.resetAllCell(); // 重置
            root.showingPath = false;
            linkCanvas.requestPaint(); // 请求重绘画布
            root.selectedRow = -1;
            root.selectedCol = -1;
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
            root.linkPath = gameLogic.getLinkPath(firstRow, firstCol, secondRow, secondCol);

            // 转换路径点坐标到Canvas坐标系统
            for (var i = 0; i < root.linkPath.length; i++) {
                let cellSize = 50 + 4; // 单元格尺寸 + 间距
                let x = root.linkPath[i].col * cellSize + cellSize / 2;
                let y = root.linkPath[i].row * cellSize + cellSize / 2;
                root.linkPath[i] = {
                    x: x,
                    y: y
                };
            }

            // 显示连接路径
            root.showingPath = true;
            linkCanvas.requestPaint();

            // 设置隐藏方块的定时器
            pathTimer.firstRow = firstRow;
            pathTimer.firstCol = firstCol;
            pathTimer.secondRow = secondRow;
            pathTimer.secondCol = secondCol;
            pathTimer.start();
        }
    }

    // 键盘事件处理
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            root.isPaused = !root.isPaused
            root.pauseStateChanged(root.isPaused)
        } else if (!root.isPaused && !root.showingPath) {
            // 方向键控制
            let newRow = root.selectedRow
            let newCol = root.selectedCol
            
            switch (event.key) {
                case Qt.Key_Left:
                    newCol = Math.max(1, root.selectedCol - 1)
                    break
                case Qt.Key_Right:
                    newCol = Math.min(gameLogic.cols() - 2, root.selectedCol + 1)
                    break
                case Qt.Key_Up:
                    newRow = Math.max(1, root.selectedRow - 1)
                    break
                case Qt.Key_Down:
                    newRow = Math.min(gameLogic.rows() - 2, root.selectedRow + 1)
                    break
                case Qt.Key_Space:
                    // 空格键选择方块
                    if (newRow >= 0 && newCol >= 0) {
                        let index = newRow * gameLogic.cols() + newCol
                        let cell = grid.children[index]
                        if (cell && cell.MouseArea) {
                            cell.MouseArea.clicked()
                        }
                    }
                    break
            }
            
            // 如果位置有效且不是外圈格子，更新选中位置
            if (newRow >= 1 && newRow < gameLogic.rows() - 1 &&
                newCol >= 1 && newCol < gameLogic.cols() - 1) {
                // 取消之前选中的方块
                if (root.selectedRow >= 0 && root.selectedCol >= 0) {
                    let oldIndex = root.selectedRow * gameLogic.cols() + root.selectedCol
                    let oldCell = grid.children[oldIndex]
                    if (oldCell) {
                        oldCell.color = "skyblue"
                    }
                }
                
                // 选中新的方块
                root.selectedRow = newRow
                root.selectedCol = newCol
                let newIndex = newRow * gameLogic.cols() + newCol
                let newCell = grid.children[newIndex]
                if (newCell) {
                    newCell.color = "blue"
                }
            }
        }
    }

    Connections {
        target: gameLogic
        function onCellsChanged() {
            grid.forceLayout(); // 强制刷新网格
        }
    }
}
