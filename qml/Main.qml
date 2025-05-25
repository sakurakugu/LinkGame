import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    width: 800
    height: 700
    visible: true
    title: qsTr("连连看小游戏")
    minimumWidth: 800
    minimumHeight: 700

    // 游戏状态枚举
    property int gameState: 0  // 0=菜单, 1=游戏中, 2=游戏结束
    property int selectedRow: -1
    property int selectedCol: -1
    property int score: 0
    property int timeLeft: 180  // 3分钟游戏时间

    // 定时器
    Timer {
        id: gameTimer
        interval: 1000
        running: gameState === 1
        repeat: true
        onTriggered: {
            timeLeft--;
            if (timeLeft <= 0) {
                gameState = 2;
                gameStatus.text = "时间到！游戏结束";
            }
        }
    }

    // 开始菜单界面
    Loader {
        id: menuLoader
        anchors.fill: parent
        sourceComponent: menuComponent
        active: gameState === 0
    }

    Component {
        id: menuComponent
        // 背景
        Rectangle {
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
                        // 创建并显示游戏窗口
                        console.log("点击-主页面-开始游戏");
                        gameState = 1;
                        score = 0;
                        timeLeft = 180;
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
        sourceComponent: GameBoard {
            onResetRequested: {
                gameLogic.resetGame();
                score = 0;
                timeLeft = 180;
            }
            onMenuRequested: {
                gameState = 0;
            }
            score: root.score
            onScoreUpdated: newScore => {
                root.score = newScore;  // 更新主窗口的分数
            }
        }
        active: gameState === 1
    }// 游戏结束界面
    Loader {
        id: endLoader
        anchors.fill: parent
        sourceComponent: GameOver {
            finalScore: score
            onRestartGame: {
                gameState = 1;
                gameLogic.resetGame();
                score = 0;
                timeLeft = 180;
            }
            onReturnToMenu: gameState = 0
        }
        active: gameState === 2
    }// 设置界面
    Loader {
        id: settingsLoader
        anchors.fill: parent
        sourceComponent: Settings {
            onClosed: settingsLoader.active = false
            onTimeChanged: seconds => {
                timeLeft = seconds;
            }
        }
        active: false
    }

    // 帮助界面
    Loader {
        id: helpLoader
        anchors.fill: parent
        sourceComponent: Help {
            onClosed: helpLoader.active = false
        }
        active: false
    }    // 游戏逻辑连接
    Connections {
        target: gameLogic
        function onCellsChanged() {
            if (gameLogic.isGameOver()) {
                gameState = 2;
            }
        }
    }
}
