import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./components"
import "./theme"

Rectangle {
    id: root
    color: currentTheme ? currentTheme.backgroundColor : "#f0f0f0"
    focus: true // 确保可以接收键盘事件

    // 主题管理器
    property ThemeManager themeManager: ThemeManager {
        id: themeManager
    }
    property QtObject currentTheme: null
    property string theme: settings.getTheme()

    // 监听主题变化
    onThemeChanged: {
        console.log("Help主题变化:", theme);
        currentTheme = themeManager.loadTheme(theme);
    }

    signal closed

    Component.onCompleted: {
        console.log("Help初始化，当前主题:", theme);
        currentTheme = themeManager.loadTheme(theme); // 加载当前主题
        root.forceActiveFocus(); // 确保键盘事件处理程序获得焦点
    }
    
    // 添加主题变化监听
    Connections {
        target: settings
        function onThemeChanged() {
            theme = settings.getTheme();
            console.log("Help主题变化检测到:", theme);
            currentTheme = themeManager.loadTheme(theme);
        }
    }

    // 添加键盘事件处理
    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Escape) {
            root.closed();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: parent.width * 0.05 // 使用窗口宽度的5%作为边距
        spacing: parent.height * 0.02 // 使用窗口高度的2%作为间距        
        Text {
            text: qsTr("游戏帮助")
            font.pixelSize: parent.parent.width * 0.05 // 使用窗口宽度的5%作为字体大小
            font.bold: true
            color: currentTheme ? currentTheme.textColor : "#333333"
            Layout.alignment: Qt.AlignHCenter
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.8 // 使用父容器宽度的80%
            Layout.preferredHeight: parent.height * 0.7 // 使用父容器高度的70%
            Layout.alignment: Qt.AlignHCenter // 水平居中

            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: qsTr(
                    "<h2>游戏规则</h2>" +
                    "<p>1. 点击两个相同的方块</p>" +
                    "<p>2. 如果两个方块可以用不超过三条直线连接，它们就会消失</p>" +
                    "<p>3. 消除所有方块即可获胜</p>" +
                    "<p>4. 游戏有时间限制，请在时间内完成</p>" +
                    "<h2>操作说明</h2>" +
                    "<p>- 点击方块选择</p>" +
                    "<p>- 再次点击取消选择</p>" +
                    "<p>- 点击'提示'按钮获取帮助</p>" +
                    "<p>- 游戏结束后可以查看得分</p>" +
                    "<h2>快捷键</h2>" +
                    "<p>- ESC：暂停游戏/返回</p>" +
                    "<p>- 方向键：移动选择</p>" +
                    "<p>- 空格键：选择方块</p>" +
                    "<h2>作者</h2>" +
                    "<p>- 潘彦玮</p>" +
                    "<p>- 谢智行</p>"
                    )
                font.pixelSize: parent.parent.parent.width * 0.02
                textFormat: Text.RichText
            }
        }

        MyButton {
            text: qsTr("返回")
            Layout.alignment: Qt.AlignHCenter
            buttonWidth: parent.width * 0.15
            buttonHeight: parent.height * 0.08
            fontSize: width * 0.2
            onClicked: root.closed()
        }
    }
}
