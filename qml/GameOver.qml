import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f0f0f0"
    
    property int finalScore: 0
    
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
            text: "最终得分: " + finalScore
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }
        
        Button {
            text: "再来一局"
            Layout.preferredWidth: 200
            onClicked: root.restartGame()
        }
        
        Button {
            text: "返回菜单"
            Layout.preferredWidth: 200
            onClicked: root.returnToMenu()
        }
    }
}
