import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f0f0f0"

    property int finalScore: settings.getScore()
    property string playerName: settings.getPlayerName()
    property string rank: finalScore > 0 ? settings.getRank(playerName, finalScore) : "未上榜"

    signal restartGame
    signal returnToMenu

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20 // 间距

        Text {
            text: "游戏结束"
            font.pixelSize: 48
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "玩家: " + playerName
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "最终得分: " + finalScore
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            id: rankText
            text: "当前排名: " + rank
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
            visible: finalScore > 0
        }

        MyButton {
            text: "再来一局"
            onClicked: {
                settings.addScoreToLeaderboard(playerName, finalScore);
                root.restartGame();
            }
        }

        MyButton {
            text: "返回菜单"
            onClicked: {
                settings.addScoreToLeaderboard(playerName, finalScore);
                root.returnToMenu();
            }
        }
    }
}
