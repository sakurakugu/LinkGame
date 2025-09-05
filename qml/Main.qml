import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "."  // 导入当前目录下的QML文件
import "./theme" // 导入主题目录

Window {
    /* 窗口与页面相关 */
    id: root
    // 使用默认尺寸，避免访问settings方法时报错
    width: 800
    height: 600
    visible: true
    title: qsTr("连连看小游戏")
    minimumWidth: 800
    minimumHeight: 600
    flags: isFullScreen ? (Qt.Window | Qt.FramelessWindowHint) : Qt.Window
    color: currentTheme ? currentTheme.backgroundColor : "#f0f0f0" // 应用主题背景色
    property bool isFullScreen: false
    property bool exitDialogVisible: false // 控制退出确认对话框的可见性
    property QtObject currentTheme: null
    property string currentThemeName: "light" // 默认主题名称，稍后会从settings更新
    
    // 设置一个全局的主题对象，可供各个页面访问
    property alias globalTheme: root.currentTheme

    // 窗口初始化完成后执行
    Component.onCompleted: {
        // 初始化主窗口
        settings.initWindow();

        // 设置窗口属性，延迟一下保证settings已正确初始化
        Qt.callLater(function () {
            width = settings.getWindowWidth();
            height = settings.getWindowHeight();
            isFullScreen = settings.isFullscreen();

            // 从settings获取当前主题并加载
            currentThemeName = settings.getTheme();
            console.log("Main窗口初始化，加载主题:", currentThemeName);
            currentTheme = ThemeManager.loadTheme(currentThemeName);
        });
        // root.forceActiveFocus(); // 确保键盘事件处理程序获得焦点
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
    
    // 主题变化监听
    Connections {
        target: settings
        function onThemeChanged() {
            currentThemeName = settings.getTheme();
            console.log("Main - 主题变化检测到:", currentThemeName);
            // 更新当前主题
            currentTheme = ThemeManager.loadTheme(currentThemeName);
        }
    }

    FocusScope {
        anchors.fill: parent
        focus: true

        // 键盘事件处理
        Keys.onPressed: function (event) {
            // 检测ESC键
            if (event.key === Qt.Key_Escape) {
                if (!exitDialogVisible) {
                    exitDialogVisible = true;  // 显示退出确认对话框
                    event.accepted = true;     // 标记事件已处理
                } else {
                    exitDialogVisible = false; // 如果对话框已显示，则关闭对话框
                    event.accepted = true;
                }
            } else
            // 检测回车键，当退出对话框显示时
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (exitDialogVisible) {
                    Qt.quit();                 // 确认退出游戏
                    event.accepted = true;
                }
            }
        }
    }

    // StackView用于页面管理
    property alias stackView: stackView

    // StackView用于页面导航
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: menuPage
    }

    // 主菜单页面
    Component {
        id: menuPage
        Page {
            // 背景
            Rectangle {
                anchors.fill: parent
                color: root.currentTheme ? root.currentTheme.backgroundColor : "#f0f0f0"
                
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
                    color: root.currentTheme ? root.currentTheme.textColor : "#333333"
                }

                // 按钮布局
                ColumnLayout {
                    anchors.centerIn: parent
                    anchors.topMargin: parent.height * 0.2 // 与标题保持一定距离
                    spacing: parent.height * 0.03 // 使用窗口高度的3%作为按钮间距

                    MyButton {
                        text: qsTr("开始游戏")
                        fontSize: parent.parent.width * 0.03
                        buttonWidth: parent.parent.width * 0.25
                        buttonHeight: parent.parent.height * 0.08

                        onClicked: {
                            console.log("点击-主页面-开始游戏");
                            stackView.push(gameComponent);
                        }
                    }

                    MyButton {
                        text: qsTr("排行榜")
                        fontSize: parent.parent.width * 0.03
                        buttonWidth: parent.parent.width * 0.25
                        buttonHeight: parent.parent.height * 0.08

                        onClicked: {
                            console.log("点击-主页面-排行榜");
                            stackView.push(leaderboardComponent);
                        }
                    }

                    MyButton {
                        text: qsTr("设置")
                        fontSize: parent.parent.width * 0.03
                        buttonWidth: parent.parent.width * 0.25
                        buttonHeight: parent.parent.height * 0.08

                        onClicked: {
                            console.log("点击-主页面-设置");
                            stackView.push(settingsComponent);
                        }
                    }

                    MyButton {
                        text: qsTr("游戏帮助")
                        fontSize: parent.parent.width * 0.03
                        buttonWidth: parent.parent.width * 0.25
                        buttonHeight: parent.parent.height * 0.08

                        onClicked: {
                            console.log("点击-主页面-游戏帮助");
                            stackView.push(helpComponent);
                        }
                    }

                    MyButton {
                        text: qsTr("退出游戏")
                        fontSize: parent.parent.width * 0.03
                        buttonWidth: parent.parent.width * 0.25
                        buttonHeight: parent.parent.height * 0.08
                        normalColor: "#f35c4b"
                        hoverColor: "#fda0a0"
                        pressedColor: "#ec3030"

                        onClicked: {
                            console.log("点击-主页面-退出游戏");
                            Qt.quit();
                         }
                     }
                 }
             }
         }
    }

    // 游戏页面组件
    Component {
        id: gameComponent
        Page {
            GameBoard {
                anchors.fill: parent
                onReturnToMenu: {
                    stackView.pop();
                }
                onClosed: {
                    stackView.push(gameOverComponent);
                }
            }
        }
    }

    // 游戏结束页面组件
    Component {
        id: gameOverComponent
        Page {
            GameOver {
                anchors.fill: parent
                onRestartGame: {
                    stackView.pop();
                    stackView.pop();
                    stackView.push(gameComponent);
                }
                onReturnToMenu: {
                    stackView.popToIndex(0);
                }
            }
        }
    }

    // 排行榜页面组件
    Component {
        id: leaderboardComponent
        Page {
            Leaderboard {
                anchors.fill: parent
                onClosed: {
                    stackView.pop();
                }
            }
        }
    }

    // 设置页面组件
    Component {
        id: settingsComponent
        Page {
            Settings {
                anchors.fill: parent
                onClosed: {
                    stackView.pop();
                }
            }
        }
    }

    // 帮助页面组件
    Component {
        id: helpComponent
        Page {
            Help {
                anchors.fill: parent
                onClosed: {
                    stackView.pop();
                }
            }
        }
    }

    // 退出确认对话框
    Dialog {
        id: exitConfirmDialog
        anchors.centerIn: parent
        width: parent.width * 0.4
        height: parent.height * 0.25
        modal: true
        visible: exitDialogVisible
        closePolicy: Dialog.NoAutoClose
        focus: true

        background: Rectangle {
            color: "#ffffff"
            border.color: "#cccccc"
            border.width: 1
            radius: 8
        }

        header: Rectangle {
            color: "#f0f0f0"
            height: 40
            width: parent.width
            radius: 8

            Text {
                anchors.centerIn: parent
                text: qsTr("确认退出")
                font.pixelSize: 16
                font.bold: true
            }
        }

        contentItem: FocusScope {
            id: contentItem
            anchors.fill: parent
            focus: true

            Keys.onPressed: function (event) {
                console.log("Dialog Key pressed:", event.key); // 可调试输出
                if (event.key === Qt.Key_Escape) {
                    exitDialogVisible = false;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    Qt.quit();
                    event.accepted = true;
                }
            }

            Text {
                anchors.centerIn: parent
                width: parent.width * 0.8
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: qsTr("确定要退出游戏吗？")
                font.pixelSize: 14
            }
        }

        footer: Rectangle {
            color: "transparent"
            height: 60
            width: parent.width

            RowLayout {
                anchors.centerIn: parent
                spacing: 20

                Button {
                    text: qsTr("退出 (Enter)")
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 30

                    onClicked: {
                        Qt.quit();
                    }

                    background: Rectangle {
                        color: parent.down ? "#ec3030" : (parent.hovered ? "#fda0a0" : "#f35c4b")
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    text: qsTr("取消 (Esc)")
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 30

                    onClicked: {
                        exitDialogVisible = false;
                    }

                    background: Rectangle {
                        color: parent.down ? "#d0d0d0" : (parent.hovered ? "#e0e0e0" : "#f0f0f0")
                        border.color: "#cccccc"
                        radius: 4
                    }

                    contentItem: Text {
                        text: parent.text                        
                        color: root.currentTheme ? root.currentTheme.textColor : "#333333"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        // 当对话框关闭时重置焦点
        onClosed: {
            root.forceActiveFocus();
        }

        onVisibleChanged: {
            if (visible) {
                dialogContent.forceActiveFocus();
            }
        }
    }
}
