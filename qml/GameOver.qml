import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./theme"

Rectangle {
    id: root
    color: currentTheme ? currentTheme.backgroundColor : "#f0f0f0"

    // 主题管理器
    property ThemeManager themeManager: ThemeManager {
        id: themeManager
    }
    property QtObject currentTheme: null
    property string theme: settings.getTheme()

    // 监听主题变化
    onThemeChanged: {
        console.log("GameOver主题变化:", theme);
        currentTheme = themeManager.loadTheme(theme);
    }

    Component.onCompleted: {
        console.log("GameOver初始化，当前主题:", theme);
        currentTheme = themeManager.loadTheme(theme); // 加载当前主题
        root.forceActiveFocus();
    }

    // 添加主题变化监听
    Connections {
        target: settings
        function onThemeChanged() {
            theme = settings.getTheme();
            console.log("GameOver主题变化检测到:", theme);
            currentTheme = themeManager.loadTheme(theme);
        }
    }

    property int finalScore: gameLogic.getScore()
    property string playerName: settings.getPlayerName()
    property string rank: finalScore > 0 ? gameLogic.getRank(playerName, finalScore) : "未上榜"

    signal restartGame
    signal returnToMenu

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20 // 间距        
        Text {
            text: qsTr("游戏结束")
            font.pixelSize: 48
            color: currentTheme ? currentTheme.textColor : "#333333"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: qsTr("玩家: ") + playerName
            font.pixelSize: 24
            color: currentTheme ? currentTheme.textColor : "#333333"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: qsTr("最终得分: ") + finalScore
            font.pixelSize: 24
            color: currentTheme ? currentTheme.textColor : "#333333"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            id: rankText
            text: qsTr("当前排名: ") + rank
            font.pixelSize: 24
            color: currentTheme ? currentTheme.textColor : "#333333"
            Layout.alignment: Qt.AlignHCenter
            visible: finalScore > 0
        }

        MyButton {
            text: qsTr("再来一局")
            onClicked: {
                settings.addScoreToLeaderboard(playerName, finalScore);
                root.restartGame();
            }
        }

        MyButton {
            text: qsTr("返回菜单")
            onClicked: {
                settings.addScoreToLeaderboard(playerName, finalScore);
                root.returnToMenu();
            }
        }
    }
}
