import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "."  // 导入当前目录下的QML文件

Window {
    /* 窗口与页面相关 */
    id: root
    width: settings.getWindowWidth()
    height: settings.getWindowHeight()
    visible: true
    title: qsTr("连连看小游戏")
    minimumWidth: 800
    minimumHeight: 600
    flags: isFullScreen ? (Qt.Window | Qt.FramelessWindowHint) : Qt.Window

    property bool isFullScreen: settings.isFullscreen()

    // 窗口初始化完成后执行
    Component.onCompleted: {
        // 初始化设置窗口
        settings.initWindow();
    }

    // 窗口大小变化处理
    onWidthChanged: {
        if (!isFullScreen) {
            settings.updateWindowSize();
        }
    }
    onHeightChanged: {
        if (!isFullScreen) {
            settings.updateWindowSize();
        }
    }

    // 游戏状态枚举
    readonly property var page: {
        "Menu": 0,       // 主菜单
        "Playing": 1,    // 游戏中
        "GameOver": 2,   // 游戏结束
        "Leaderboard": 3,// 排行榜
        "Settings": 4,   // 设置
        "Help": 5        // 帮助
    }

    property int pageState: page.Menu  // 页面状态

    // 主页面
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
                anchors.topMargin: parent.height * 0.10  // 使用窗口高度的10%作为上边距
                anchors.bottomMargin: parent.height * 0.10

                text: qsTr("连连看小游戏")
                font.pixelSize: parent.width * 0.06 // 使用窗口宽度的6%作为字体大小
                font.bold: true
                color: "#333333"
            }

            // 按钮布局
            ColumnLayout {
                anchors.centerIn: parent
                anchors.topMargin: parent.height * 0.2 // 与标题保持一定距离
                spacing: parent.height * 0.03 // 使用窗口高度的3%作为按钮间距

                Button {
                    text: qsTr("开始游戏")
                    font.pixelSize: parent.parent.width * 0.03
                    Layout.preferredWidth: parent.parent.width * 0.25
                    Layout.preferredHeight: parent.parent.height * 0.08
                    background: Rectangle {
                        color: parent.hovered ? "#4a90e2" : "#5ca9fb"
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
                        console.log("点击-主页面-开始游戏");
                        pageState = page.Playing;
                    }
                }

                Button {
                    text: qsTr("排行榜")
                    font.pixelSize: parent.parent.width * 0.03
                    Layout.preferredWidth: parent.parent.width * 0.25
                    Layout.preferredHeight: parent.parent.height * 0.08
                    background: Rectangle {
                        color: parent.hovered ? "#4a90e2" : "#5ca9fb"
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
                        console.log("点击-主页面-排行榜");
                        pageState = page.Leaderboard;
                    }
                }

                Button {
                    text: qsTr("设置")
                    font.pixelSize: parent.parent.width * 0.03
                    Layout.preferredWidth: parent.parent.width * 0.25
                    Layout.preferredHeight: parent.parent.height * 0.08
                    background: Rectangle {
                        color: parent.hovered ? "#4a90e2" : "#5ca9fb"
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
                        pageState = page.Settings;
                    }
                }

                Button {
                    text: qsTr("游戏帮助")
                    font.pixelSize: parent.parent.width * 0.03
                    Layout.preferredWidth: parent.parent.width * 0.25
                    Layout.preferredHeight: parent.parent.height * 0.08
                    background: Rectangle {
                        color: parent.hovered ? "#4a90e2" : "#5ca9fb"
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
                        pageState = page.Help;
                    }
                }

                Button {
                    text: qsTr("退出游戏")
                    font.pixelSize: parent.parent.width * 0.03
                    Layout.preferredWidth: parent.parent.width * 0.25
                    Layout.preferredHeight: parent.parent.height * 0.08
                    background: Rectangle {
                        color: parent.hovered ? "#e74c3c" : "#ff6b6b"
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
    }

    // 游戏主界面
    Loader {
        id: gameLoader
        anchors.fill: parent
        source: "GameBoard.qml"
        active: pageState === 1  // GameState.Playing
        onLoaded: {
            item.resetRequested.connect(function () {
                gameLogic.resetGame();
                score = 0;
                timeLeft = gameLogic.getGameTime();
            });
            item.menuRequested.connect(function () {
                pageState = 0;  // GameState.Menu
                // 不重置时间，只是暂停游戏
            });
            item.exitGameRequested.connect(function () {
                pageState = 2;  // GameState.GameOver
            });
            item.scoreUpdated.connect(function (newScore) {
                root.score = newScore;
            });
            item.pauseStateChanged.connect(function (paused) {
                if (paused) {
                    gameTimer.stop();
                } else {
                    gameTimer.start();
                }
            });
        }
    }

    // 开始菜单界面
    Loader {
        id: menuLoader
        anchors.fill: parent
        active: pageState === page.Menu
        sourceComponent: menuComponent
    }

    // 游戏结束界面
    Loader {
        id: endLoader
        anchors.fill: parent
        source: "GameOver.qml"
        active: pageState === page.GameOver
    }

    // 排行榜界面
    Loader {
        id: leaderboardLoader
        anchors.fill: parent
        source: "Leaderboard.qml"
        active: pageState === page.Leaderboard
        onLoaded: {
            item.closed.connect(function () {
                pageState = page.Menu;
            });
        }
    }

    // 设置界面
    Loader {
        id: settingsLoader
        anchors.fill: parent
        source: "Settings.qml"
        active: pageState === page.Settings
        onLoaded: {
            item.closed.connect(function () {
                pageState = page.Menu;
            });
        }
    }

    // 帮助界面
    Loader {
        id: helpLoader
        anchors.fill: parent
        source: "Help.qml"
        active: pageState === page.Help
        onLoaded: {
            item.closed.connect(function () {
                pageState = page.Menu;
            });
        }
    }
}
