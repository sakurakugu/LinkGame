import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."  // 导入当前目录下的QML文件

Window {
    id: root
    width: 800
    height: 700
    visible: true
    title: qsTr("连连看小游戏")
    minimumWidth: 800
    minimumHeight: 700    // 游戏状态枚举
    readonly property var gameStateEnum: {
        "Menu": 0,       // 菜单
        "Playing": 1,    // 游戏中
        "GameOver": 2,   // 游戏结束
        "Leaderboard": 3,// 排行榜
        "NameInput": 4   // 用户名输入
    }

    // 窗口初始化完成后执行
    Component.onCompleted: {
        // 检查玩家名称，如果已经设置过，点击"开始游戏"时可以直接进入游戏
        if (playerName !== "") {
            hasConfirmedName = true;
        }
    }

    property int gameState: gameStateEnum.Menu  // 使用枚举值
    property int selectedRow: -1
    property int selectedCol: -1
    property int score: 0
    property int timeLeft: gameLogic.getGameTime()  // 从配置获取游戏时间
    property string playerName: gameLogic.getPlayerName()  // 从配置获取玩家名称
    property bool hasConfirmedName: playerName !== "" // 是否已经确认过用户名

    // 定时器
    Timer {        id: gameTimer
        interval: 1000
        running: gameState === gameStateEnum.Playing
        repeat: true
        onTriggered: {
            timeLeft--;
            if (timeLeft <= 0) {
                gameState = gameStateEnum.GameOver;
            }
        }
    }

    // 检查游戏是否结束的计时器
    Timer {
        id: checkGameOverTimer
        interval: 500 // 每0.5秒检查一次
        repeat: true
        running: gameState === gameStateEnum.Playing
        onTriggered: {
            if (gameLogic.isGameOver()) {
                gameTimer.stop();
                gameState = gameStateEnum.GameOver;
            }
        }
    }

    // 监听游戏时间变化
    Connections {
        target: gameLogic
        function onGameTimeChanged() {
            timeLeft = gameLogic.getGameTime();
        }
    }

    // 监听玩家名称变化
    Connections {
        target: gameLogic
        function onPlayerNameChanged() {
            playerName = gameLogic.getPlayerName();
        }
    }    // 开始菜单界面
    Loader {
        id: menuLoader
        anchors.fill: parent
        sourceComponent: menuComponent
        active: gameState === gameStateEnum.Menu

        // 当菜单加载时，如果已经有玩家名称，可以直接点击"开始游戏"按钮进入游戏
        onLoaded: {
            if (playerName !== "") {
                item.directStartEnabled = true;
            }
        }
    }

    // 排行榜界面
    Loader {
        id: leaderboardLoader
        anchors.fill: parent
        source: "Leaderboard.qml"
        active: gameState === gameStateEnum.Leaderboard
        onLoaded: {
            item.closed.connect(function () {
                gameState = 0;  // GameState.Menu
            });
        }
    }

    // 用户名输入界面
    Loader {
        id: playerNameLoader
        anchors.fill: parent
        source: "PlayerNameInput.qml"
        active: gameState === 4  // GameState.NameInput
        onLoaded: {            item.confirmed.connect(function (name) {
                gameLogic.setPlayerName(name);
                playerName = name;
                gameState = gameStateEnum.Playing;
                score = 0;
                timeLeft = gameLogic.getGameTime();
            });
            item.canceled.connect(function () {
                gameState = gameStateEnum.Menu
            });
        }
    }
    Component {
        id: menuComponent
        // 背景
        Rectangle {
            property bool directStartEnabled: false

            color: "#f0f0f0"

            // 标题
            Text {
                id: titleText
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 100
                text: qsTr("连连看小游戏")
                font.pixelSize: 48
                font.bold: true
                color: "#333333"
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20

                Button {
                    text: qsTr("开始游戏")
                    font.pixelSize: 24
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 60
                    background: Rectangle {
                        color: parent.pressed ? "#4a90e2" : "#5ca9fb"
                        radius: 10
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        // 如果已经设置过用户名，直接进入游戏
                        if (directStartEnabled && playerName !== "") {                            console.log("直接进入游戏，玩家：" + playerName);
                            gameState = gameStateEnum.Playing;
                            score = 0;
                            timeLeft = gameLogic.getGameTime();
                        } else {
                            // 显示用户名输入界面
                            console.log("点击-主页面-开始游戏");
                            gameState = gameStateEnum.NameInput; // 切换到用户名输入界面
                        }
                    }
                }

                Button {
                    text: qsTr("排行榜")
                    font.pixelSize: 24
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 60
                    background: Rectangle {
                        color: parent.pressed ? "#4a90e2" : "#5ca9fb"
                        radius: 10
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        // 显示排行榜                        console.log("点击-主页面-排行榜");
                        gameState = gameStateEnum.Leaderboard;
                    }
                }

                Button {
                    text: qsTr("设置")
                    font.pixelSize: 24
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 60
                    background: Rectangle {
                        color: parent.pressed ? "#4a90e2" : "#5ca9fb"
                        radius: 10
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("点击-主页面-设置");
                        settingsLoader.active = true;
                    }
                }

                Button {
                    text: qsTr("游戏帮助")
                    font.pixelSize: 24
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 60
                    background: Rectangle {
                        color: parent.pressed ? "#4a90e2" : "#5ca9fb"
                        radius: 10
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("点击-主页面-游戏帮助");
                        helpLoader.active = true;
                    }
                }

                Button {
                    text: qsTr("退出游戏")
                    font.pixelSize: 24
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 60
                    background: Rectangle {
                        color: parent.pressed ? "#e74c3c" : "#ff6b6b"
                        radius: 10
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("点击-主页面-退出游戏");
                        Qt.quit();
                    }
                }
            }
        }
    }    // 游戏主界面
    Loader {
        id: gameLoader
        anchors.fill: parent
        source: "GameBoard.qml"
        active: gameState === 1  // GameState.Playing
        onLoaded: {
            item.resetRequested.connect(function() {
                gameLogic.resetGame();
                score = 0;
                timeLeft = gameLogic.getGameTime();
            });
            item.menuRequested.connect(function() {
                gameState = 0;  // GameState.Menu
            });
            item.exitGameRequested.connect(function() {
                gameState = 2;  // GameState.GameOver
            });
            item.scoreUpdated.connect(function(newScore) {
                root.score = newScore;
            });
        }
    }
    // 游戏结束界面
    Loader {
        id: endLoader
        anchors.fill: parent
        sourceComponent: GameOver {
            finalScore: score
            onRestartGame: {                gameState = gameStateEnum.Playing;
                score = 0;
                timeLeft = gameLogic.getGameTime();
            }
            onReturnToMenu: {
                gameState = gameStateEnum.Menu
            }
        }
        active: gameState === 2  // GameState.GameOver
    }
    
    // 设置界面    
    Loader {
        id: settingsLoader
        anchors.fill: parent
        source: "Settings.qml"
        active: false
        z: 1000 // 确保设置界面在最上层
        onLoaded: {
            item.closed.connect(function() {
                settingsLoader.active = false
            })
            item.timeChanged.connect(function(seconds) {
                gameLogic.setGameTime(seconds)
                timeLeft = seconds
            })
            item.volumeChanged.connect(function(volume) {
                gameLogic.setVolume(volume)
            })
        }
    }

    // 帮助界面
    Loader {
        id: helpLoader
        anchors.fill: parent
        source: "Help.qml"
        active: false
        z: 999 // 确保帮助界面在设置界面下方
        onLoaded: {
            item.closed.connect(function() {
                helpLoader.active = false
            })
        }
    }    // 游戏逻辑连接
    Connections {
        target: gameLogic
        function onCellsChanged() {
            if (gameLogic.isGameOver()) {
                gameState = GameState.GameOver;
            }
        }
    }
}
