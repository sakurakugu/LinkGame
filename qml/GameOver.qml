import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f0f0f0"
    
    property int finalScore: 0
    property string playerName: gameLogic.getPlayerName()
    
    signal restartGame()
    signal returnToMenu()
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20
        
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
            text: "排名计算中..."
            font.pixelSize: 18
            Layout.alignment: Qt.AlignHCenter
            visible: finalScore > 0
        }
        
        Button {
            text: "再来一局"
            Layout.preferredWidth: 200
            onClicked: {
                if (finalScore > 0) {
                    gameLogic.addScoreToLeaderboard(playerName, finalScore);
                }
                root.restartGame()
            }
        }
        
        Button {
            text: "返回菜单"
            Layout.preferredWidth: 200
            onClicked: {
                // 添加分数到排行榜
                if (finalScore > 0) {
                    gameLogic.addScoreToLeaderboard(playerName, finalScore);
                }
                root.returnToMenu();
            }
        }
    }
}
