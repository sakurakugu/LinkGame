import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f0f0f0"
    focus: true // 确保可以接收键盘事件
    
    signal closed()
    
    // 添加键盘事件处理
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            root.closed()
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: parent.width * 0.05 // 使用窗口宽度的5%作为边距
        spacing: parent.height * 0.02 // 使用窗口高度的2%作为间距
        
        Text {
            text: "游戏帮助"
            font.pixelSize: parent.parent.width * 0.05 // 使用窗口宽度的5%作为字体大小
            font.bold: true
            color: "#333333"
            Layout.alignment: Qt.AlignHCenter
        }
        
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.8 // 使用父容器宽度的80%
            Layout.preferredHeight: parent.height * 0.7 // 使用父容器高度的70%
            
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "<h2>游戏规则</h2>" +
                      "<p>1. 点击两个相同的方块</p>" +
                      "<p>2. 如果两个方块可以用不超过三条直线连接，它们就会消失</p>" +
                      "<p>3. 消除所有方块即可获胜</p>" +
                      "<p>4. 游戏有时间限制，请在时间内完成</p>" +
                    //   "<br>" +
                      "<h2>操作说明</h2>" +
                      "<p>- 点击方块选择</p>" +
                      "<p>- 再次点击取消选择</p>" +
                      "<p>- 点击'提示'按钮获取帮助</p>" +
                      "<p>- 游戏结束后可以查看得分</p>" +
                    //   "<br>" +
                      "<h2>快捷键</h2>" +
                      "<p>- ESC：暂停游戏/返回</p>" +
                      "<p>- 方向键：移动选择</p>" +
                      "<p>- 空格键：选择方块</p>" +
                    //   "<br>" +
                      "<h2>作者</h2>" +
                      "<p>- 潘彦玮</p>" +
                      "<p>- 谢智行</p>"
                font.pixelSize: parent.parent.parent.width * 0.02 // 使用窗口宽度的2%作为字体大小
                textFormat: Text.RichText
            }
        }
        
        Button {
            text: "返回"
            Layout.preferredWidth: parent.width * 0.2 // 使用父容器宽度的20%
            Layout.preferredHeight: parent.height * 0.08 // 使用父容器高度的8%
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: parent.parent.width * 0.02 // 使用窗口宽度的2%作为字体大小
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
            onClicked: root.closed()
        }
    }
}
