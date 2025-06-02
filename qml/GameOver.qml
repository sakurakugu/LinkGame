import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f0f0f0"

    property int finalScore: gameLogic.getScore()
    property string playerName: gameLogic.getPlayerName()
    property string rank: finalScore > 0 ? gameLogic.getRank(playerName, finalScore) : "未上榜"

    signal restartGame
    signal returnToMenu

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20 // 间距

        Text {
            text: "游戏结束"
            font.pixelSize: 36
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "玩家: " + playerName
            font.pixelSize: 20
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
            font.pixelSize: 18
            Layout.alignment: Qt.AlignHCenter
            visible: finalScore > 0
        }

        Button {
            text: "再来一局"
            Layout.preferredWidth: 200
            onClicked: {
                root.restartGame();
            }
        }

        Button {
            text: "返回菜单"
            Layout.preferredWidth: 200
            onClicked: {
                root.returnToMenu();
            }
        }
    }
}
