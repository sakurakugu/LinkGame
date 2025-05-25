import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f0f0f0"
    
    signal closed()
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        
        Text {
            text: "游戏帮助"
            font.pixelSize: 36
            Layout.alignment: Qt.AlignHCenter
        }
        
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "连连看游戏规则:\n\n" +
                      "1. 点击两个相同的方块\n" +
                      "2. 如果两个方块可以用不超过三条直线连接，它们就会消失\n" +
                      "3. 消除所有方块即可获胜\n" +
                      "4. 游戏有时间限制，请在时间内完成\n\n" +
                      "操作说明:\n" +
                      "- 点击方块选择\n" +
                      "- 再次点击取消选择\n" +
                      "- 点击'提示'按钮获取帮助\n" +
                      "- 游戏结束后可以查看得分"
                font.pixelSize: 16
            }
        }
        
        Button {
            text: "返回"
            Layout.preferredWidth: 200
            Layout.alignment: Qt.AlignHCenter
            onClicked: root.closed()
        }
    }
}
