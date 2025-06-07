import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import "./theme"

Rectangle {
    id: root
    color: currentTheme ? currentTheme.backgroundColor : "#f0f0f0"
    focus: true // 确保可以接收键盘事件

    // 主题管理器
    property ThemeManager themeManager: ThemeManager {
        id: themeManager
    }
    property QtObject currentTheme: null
    property string theme: settings.getTheme()
    property int selectedRow: -1 // 选中的行
    property int selectedCol: -1 // 选中的列
    property var linkPath: [] // 存储连接路径的点
    property bool showingPath: false // 是否正在显示路径
    property int score: 0 // 当前分数
    property bool isPaused: gameLogic.isPaused // 是否暂停

    signal returnToMenu // 返回主菜单信号
    signal closed // 退出游戏信号
    signal scoreUpdated(int newScore) // 分数变化信号
    signal gameHint // 提示信号
    signal resetAllCell // 重置所有方块信号
    signal pauseStateChanged(bool paused) // 暂停状态变化信号
    signal soundStateChanged(bool enabled) // 音效状态变化信号

    // 监听主题变化
    onThemeChanged: {
        // console.log("GameBoard主题变化:", theme);
        currentTheme = themeManager.loadTheme(theme);
    }

    // 游戏加载完成后自动开始游戏
    Component.onCompleted: {
        // console.log("GameBoard初始化，当前主题:", theme);
        currentTheme = themeManager.loadTheme(theme); // 加载当前主题
        root.forceActiveFocus(); // 确保键盘事件处理程序获得焦点
        gameLogic.startGame(); // 开始游戏计时
    }

    // 监听主题变化
    Connections {
        target: settings
        function onThemeChanged() {
            theme = settings.getTheme();
            // console.log("GameBoard主题变化检测到:", theme);
            currentTheme = themeManager.loadTheme(theme);
        }
    }

    Connections {
        target: gameLogic
        // 监听游戏时间变化
        function onTimeLeftChanged(time) {
            if (time <= 0) {
                gameLogic.endGame();
                root.closed();
            }
        }
        // 监听游戏完成信号
        function onGameCompleted() {
            gameLogic.endGame();
            root.closed();
        }
        // 监听暂停状态变化
        function onPauseStateChanged(paused) {
            root.isPaused = paused;
        }
    }

    // 暂停页面
    Rectangle {
        id: pauseOverlay
        anchors.fill: parent
        color: "#80000000" // 半透明黑色背景
        visible: root.isPaused
        z: 100

        MouseArea {
            anchors.fill: parent
            onClicked:
            // 阻止点击事件传递到下层
            {}
        }

        Rectangle {
            width: parent.width * 0.4
            height: parent.height * 0.4
            anchors.centerIn: parent
            color: currentTheme ? currentTheme.secondaryBackgroundColor : "#ffffff"
            opacity: 0.9
            radius: 10

            ColumnLayout {
                anchors.centerIn: parent
                spacing: parent.parent.height * 0.02

                Button {
                    text: qsTr("继续")
                    Layout.preferredWidth: parent.parent.width * 0.6
                    Layout.preferredHeight: parent.parent.height * 0.15
                    font.pixelSize: parent.parent.width * 0.04
                    onClicked: {
                        gameLogic.setPaused(false);
                    }
                }

                Button {
                    text: qsTr("重置游戏")
                    Layout.preferredWidth: parent.parent.width * 0.6
                    Layout.preferredHeight: parent.parent.height * 0.15
                    font.pixelSize: parent.parent.width * 0.04
                    onClicked: {
                        gameLogic.resetGame();
                        root.resetAllCell();
                    }
                }

                Button {
                    text: qsTr("返回主菜单")
                    Layout.preferredWidth: parent.parent.width * 0.6
                    Layout.preferredHeight: parent.parent.height * 0.15
                    font.pixelSize: parent.parent.width * 0.04
                    onClicked: {
                        root.returnToMenu();
                    }
                }

                Button {
                    text: qsTr("设置")
                    Layout.preferredWidth: parent.parent.width * 0.6
                    Layout.preferredHeight: parent.parent.height * 0.15
                    font.pixelSize: parent.parent.width * 0.04
                    onClicked: {
                        settingsLoader.active = true;
                    }
                }

                Button {
                    text: qsTr("退出")
                    Layout.preferredWidth: parent.parent.width * 0.6
                    Layout.preferredHeight: parent.parent.height * 0.15
                    font.pixelSize: parent.parent.width * 0.04
                    onClicked: {
                        gameLogic.setPaused(false);
                        gameLogic.resetGameGrid();
                        root.closed();
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
        z: 1000 // 确保设置界面在暂停页面之上
        onLoaded: {
            item.closed.connect(function () {
                settingsLoader.active = false;
            });
        }
    }

    // 音效组件
    MediaPlayer {
        id: clickSound
        source: "qrc:/qt/qml/LinkGame/music/sound_effect.mp3"
        audioOutput: AudioOutput {
            volume: settings.getVolume()
            muted: !settings.getSoundState() // 如果音效关闭，则静音
        }
    }

    // 监听音量变化
    Connections {
        target: settings
        function onVolumeChanged() {
            // 当音量变化时更新音频输出
            clickSound.audioOutput.volume = settings.getVolume();
        }
        function onSoundStateChanged(enabled) {
            clickSound.audioOutput.muted = !enabled;
        }
    }

    // 连接路径画布
    Canvas {
        id: linkCanvas
        anchors.fill: grid // 填充整个网格
        z: 1 // 确保Canvas在网格上方
        visible: root.showingPath // 只有在显示路径时才可见

        onPaint: {
            if (root.linkPath.length < 2) // 如果路径长度小于2，则不绘制
                return;
            var ctx = getContext("2d"); // 获取2D上下文
            ctx.clearRect(0, 0, width, height); // 清除画布
            ctx.strokeStyle = currentTheme ? currentTheme.connectionLineColor : "#FF0000"; // 设置线条颜色
            ctx.lineWidth = 3; // 设置线条宽度

            ctx.beginPath(); // 开始路径
            ctx.moveTo(root.linkPath[0].x, root.linkPath[0].y); // 移动到第一个点

            for (var i = 1; i < root.linkPath.length; i++) {
                ctx.lineTo(root.linkPath[i].x, root.linkPath[i].y); // 绘制路径
            }

            ctx.stroke(); // 绘制路径
        }
    }

    // 状态栏
    Rectangle {
        id: statusBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height * 0.08
        color: currentTheme ? currentTheme.secondaryBackgroundColor : "#e0e0e0"
        enabled: !root.isPaused

        RowLayout {
            anchors.centerIn: parent
            spacing: parent.parent.width * 0.02
            Text {
                id: gameStatus
                text: root.isPaused ? qsTr("游戏暂停") : qsTr("游戏进行中")
                font.pixelSize: parent.parent.height * 0.4
                color: currentTheme ? currentTheme.textColor : "#333333"
                Layout.alignment: Qt.AlignCenter
            }

            Text {
                id: scoreText
                text: qsTr("分数: ") + root.score
                font.pixelSize: parent.parent.height * 0.4
                color: currentTheme ? currentTheme.textColor : "#333333"
            }

            Text {
                id: timeText
                text: qsTr("时间：") + Math.floor(gameLogic.timeLeft / 60) + ":" + (gameLogic.timeLeft % 60).toString().padStart(2, "0")
                font.pixelSize: parent.parent.height * 0.4
                color: currentTheme ? currentTheme.textColor : "#333333"
                Layout.alignment: Qt.AlignCenter
            }

            Button {
                text: root.isPaused ? qsTr("继续") : qsTr("暂停")
                Layout.preferredWidth: parent.parent.width * 0.1
                Layout.preferredHeight: parent.parent.height * 0.6
                font.pixelSize: parent.parent.height * 0.3
                onClicked: {
                    gameLogic.setPaused(!root.isPaused);
                }
            }

            Button {
                id: hintButton
                text: qsTr("提示")
                Layout.preferredWidth: parent.parent.width * 0.1
                Layout.preferredHeight: parent.parent.height * 0.6
                font.pixelSize: parent.parent.height * 0.3
                onClicked: {
                    // 获取提示
                    var hint = gameLogic.getHint();

                    // 检查提示是否有效
                    if (hint && hint.hasOwnProperty("row1")) {
                        // 播放点击音效
                        clickSound.stop();
                        clickSound.play();

                        // 重置之前的选择
                        if (root.selectedRow >= 0 && root.selectedCol >= 0) {
                            let oldIndex = root.selectedRow * gameLogic.cols() + root.selectedCol;
                            let oldCell = grid.children[oldIndex];
                            if (oldCell) {
                                oldCell.color = currentTheme ? currentTheme.gameBoardBackgroundColor : "skyblue";
                            }
                        }

                        // 高亮显示第一个提示方块
                        let index1 = hint.row1 * gameLogic.cols() + hint.col1;
                        let cell1 = grid.children[index1];
                        if (cell1) {
                            // cell1.color = currentTheme ? currentTheme.selectedBlockBorderColor : "blue";
                            cell1.color = "red";
                        }

                        // 高亮显示第二个提示方块
                        let index2 = hint.row2 * gameLogic.cols() + hint.col2;
                        let cell2 = grid.children[index2];
                        if (cell2) {
                            // cell2.color = currentTheme ? currentTheme.selectedBlockBorderColor : "blue";
                            cell2.color = "red";
                        }

                        // 显示连接路径
                        root.linkPath = hint.path;

                        // 转换路径点坐标到Canvas坐标系统
                        for (var i = 0; i < root.linkPath.length; i++) {
                            // 获取单元格大小和间距
                            let cellSize = Math.min(grid.width / gameLogic.cols(), grid.height / gameLogic.rows());
                            let spacing = grid.spacing * 0.005; // 使用实际的间距
                            let totalSize = cellSize + spacing;

                            // 计算在Canvas上的坐标，要考虑单元格的中心位置
                            // 修正偏移
                            let x = root.linkPath[i].col * totalSize + totalSize / 2;
                            let y = root.linkPath[i].row * totalSize + totalSize / 2;
                            root.linkPath[i] = {
                                x: x,
                                y: y
                            };
                        }

                        // 显示连接路径
                        root.showingPath = true;
                        linkCanvas.requestPaint();

                        // 设置定时器，几秒后隐藏提示
                        hintTimer.row1 = hint.row1;
                        hintTimer.col1 = hint.col1;
                        hintTimer.row2 = hint.row2;
                        hintTimer.col2 = hint.col2;
                        hintTimer.start();
                    }
                }
            }

            Button {
                text: qsTr("退出")
                Layout.preferredWidth: parent.parent.width * 0.1
                Layout.preferredHeight: parent.parent.height * 0.6
                font.pixelSize: parent.parent.height * 0.3
                onClicked: {
                    root.closed();
                }
            }
        }
    }

    // 游戏网格
    Grid {
        id: grid
        columns: gameLogic.cols()
        rows: gameLogic.rows()
        anchors.centerIn: parent
        spacing: parent.width * 0.005 // 使用窗口宽度的0.5%作为间距

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
                width: Math.min(parent.parent.width * 0.08, parent.parent.height * 0.08) // 使用窗口宽度和高度的8%作为方块大小
                height: width // 保持方块为正方形
                // visible: !grid.isOuterCell(index)
                color: grid.getCell(index) === 0 ? "transparent" : (currentTheme ? currentTheme.gameBoardBackgroundColor : "skyblue")
                border.color: grid.getCell(index) === 0 ? "transparent" : (currentTheme ? currentTheme.blockBorderColor : "black")

                property bool highlighted: false // 是否高亮
                property bool pathHighlighted: false // 路径高亮

                // 添加颜色变化的行为
                Behavior on color {
                    ColorAnimation {
                        duration: 100 // 动画持续时间
                    }
                }

                Image {
                    id: image
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    source: {
                        let cellValue = grid.getCell(index);
                        return cellValue === 0 ? "" : "qrc:/qt/qml/LinkGame/image/fruits/" + cellValue + ".svg";
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (grid.getCell(index) === 0) {
                            return;
                        }

                        let r = Math.floor(index / gameLogic.cols());
                        let c = index % gameLogic.cols();
                        clickSound.stop();
                        clickSound.play();

                        if (root.showingPath)
                            return;
                        if (gameLogic.getCell(r, c) !== 0) {
                            console.log("选中: " + index + " -> (" + r + "," + c + ") = " + gameLogic.getCell(r, c));
                            if (root.selectedRow === -1 && root.selectedCol === -1) {
                                root.selectedRow = r;
                                root.selectedCol = c;
                                cell.color = currentTheme ? currentTheme.selectedBlockBorderColor : "blue";
                            } else if (root.selectedRow === r && root.selectedCol === c) {
                                root.selectedRow = -1;
                                root.selectedCol = -1;
                                cell.color = currentTheme ? currentTheme.gameBoardBackgroundColor : "skyblue";
                            } else if (gameLogic.canLink(root.selectedRow, root.selectedCol, r, c)) {
                                cell.color = currentTheme ? currentTheme.selectedBlockBorderColor : "blue";
                                showLinkTimer.firstRow = root.selectedRow;
                                showLinkTimer.firstCol = root.selectedCol;
                                showLinkTimer.secondRow = r;
                                showLinkTimer.secondCol = c;
                                showLinkTimer.start();
                            } else {
                                cell.color = currentTheme ? currentTheme.selectedBlockBorderColor : "blue";
                                resetColorTimer.firstRow = root.selectedRow;
                                resetColorTimer.firstCol = root.selectedCol;
                                resetColorTimer.secondRow = r;
                                resetColorTimer.secondCol = c;
                                resetColorTimer.start();
                            }
                        }
                    }
                }

                Connections {
                    target: root
                    function onResetAllCell() {
                        cell.color = grid.getCell(index) === 0 ? "transparent" : (currentTheme ? currentTheme.gameBoardBackgroundColor : "skyblue");
                        cell.border.color = grid.getCell(index) === 0 ? "transparent" : (currentTheme ? currentTheme.blockBorderColor : "black");
                        image.source = grid.getCell(index) === 0 ? "" : "qrc:/qt/qml/LinkGame/image/fruits/" + grid.getCell(index) + ".svg";
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
        interval: 300 // 300毫秒
        running: false
        repeat: false
        property int firstRow: -1
        property int firstCol: -1
        property int secondRow: -1
        property int secondCol: -1        // 定时器触发时的处理函数
        onTriggered: {
            // 移除连通的方块并隐藏路径
            gameLogic.removeLink(firstRow, firstCol, secondRow, secondCol);            // 更新分数（每消除一对方块加10分）
            root.score += 10; // 增加分数
            gameLogic.setScore(root.score); // 更新 gameLogic 中的分数
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
                // 获取单元格大小和间距
                let cellSize = Math.min(parent.parent.width * 0.08, parent.parent.height * 0.08); // 使用实际的方块大小
                let spacing = parent.width * 0.005; // 使用实际的间距
                let totalSize = cellSize + spacing;

                // 计算在Canvas上的坐标，要考虑单元格的中心位置
                let x = root.linkPath[i].col * totalSize + cellSize / 2;
                let y = root.linkPath[i].row * totalSize + cellSize / 2;

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

    // 提示定时器，用于隐藏提示路径
    Timer {
        id: hintTimer
        interval: 2000 // 2秒后隐藏提示
        running: false
        repeat: false
        property int row1: -1
        property int col1: -1
        property int row2: -1
        property int col2: -1

        // 定时器触发时的处理函数
        onTriggered: {
            // 隐藏路径
            root.showingPath = false;
            linkCanvas.requestPaint();

            // 重置选中状态
            root.selectedRow = -1;
            root.selectedCol = -1;

            // 重置所有颜色
            root.resetAllCell();
        }
    }    
    
    // 键盘事件处理
    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Escape) {
            gameLogic.setPaused(!root.isPaused);
        } else if (!root.isPaused && !root.showingPath) {
            // 方向键和WASD控制
            let newRow = root.selectedRow;
            let newCol = root.selectedCol;

            switch (event.key) {
            case Qt.Key_Left:
            case Qt.Key_A:
                newCol = Math.max(1, root.selectedCol - 1);
                break;
            case Qt.Key_Right:
            case Qt.Key_D:
                newCol = Math.min(gameLogic.cols() - 2, root.selectedCol + 1);
                break;
            case Qt.Key_Up:
            case Qt.Key_W:
                newRow = Math.max(1, root.selectedRow - 1);
                break;
            case Qt.Key_Down:
            case Qt.Key_S:
                newRow = Math.min(gameLogic.rows() - 2, root.selectedRow + 1);
                break;
            case Qt.Key_Space:
            case Qt.Key_Return:// 普通键盘回车键
            case Qt.Key_Enter: // 小键盘回车键
                // 空格键或回车键选择方块
                if (newRow >= 0 && newCol >= 0) {
                    let index = newRow * gameLogic.cols() + newCol;
                    let cell = grid.children[index];
                    // 模拟点击事件
                    if (gameLogic.getCell(newRow, newCol) !== 0) {
                        clickSound.stop();
                        clickSound.play();

                        if (root.selectedRow === -1 && root.selectedCol === -1) {
                            root.selectedRow = newRow;
                            root.selectedCol = newCol;
                            cell.color = currentTheme ? currentTheme.selectedBlockBorderColor : "blue";
                        } else if (root.selectedRow === newRow && root.selectedCol === newCol) {
                            root.selectedRow = -1;
                            root.selectedCol = -1;
                            cell.color = currentTheme ? currentTheme.gameBoardBackgroundColor : "skyblue";
                        } else if (gameLogic.canLink(root.selectedRow, root.selectedCol, newRow, newCol)) {
                            cell.color = currentTheme ? currentTheme.selectedBlockBorderColor : "blue";
                            showLinkTimer.firstRow = root.selectedRow;
                            showLinkTimer.firstCol = root.selectedCol;
                            showLinkTimer.secondRow = newRow;
                            showLinkTimer.secondCol = newCol;
                            showLinkTimer.start();
                        } else {
                            cell.color = currentTheme ? currentTheme.selectedBlockBorderColor : "blue";
                            resetColorTimer.firstRow = root.selectedRow;
                            resetColorTimer.firstCol = root.selectedCol;
                            resetColorTimer.secondRow = newRow;
                            resetColorTimer.secondCol = newCol;
                            resetColorTimer.start();
                        }
                    }
                }
                break;
            }

            // 如果位置有效且不是外圈格子，更新选中位置
            if (newRow >= 1 && newRow < gameLogic.rows() - 1 && newCol >= 1 && newCol < gameLogic.cols() - 1) {
                // 取消之前选中的方块
                if (root.selectedRow >= 0 && root.selectedCol >= 0) {
                    let oldIndex = root.selectedRow * gameLogic.cols() + root.selectedCol;
                    let oldCell = grid.children[oldIndex];
                    if (oldCell) {
                        oldCell.color = currentTheme ? currentTheme.gameBoardBackgroundColor : "skyblue";
                    }
                }

                // 选中新的方块
                root.selectedRow = newRow;
                root.selectedCol = newCol;
                let newIndex = newRow * gameLogic.cols() + newCol;
                let newCell = grid.children[newIndex];
                if (newCell) {
                    newCell.color = currentTheme ? currentTheme.selectedBlockBorderColor : "blue";
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
