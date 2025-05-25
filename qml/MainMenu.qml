import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

pragma ComponentBehavior: Bound

Window {
    id: root
    width: 800
    height: 600
    visible: true
    title: qsTr("连连看小游戏")
    minimumWidth: 800
    minimumHeight: 600

    // 背景
    Rectangle {
        anchors.fill: parent
        color: "#f0f0f0"
    }

    // 标题
    Text {
        id: titleText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 100
        text: qsTr("连连看小游戏")
        font.pixelSize: 48
        font.bold: true
        color: "#333333"
    }

    // 按钮容器
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        // 开始游戏按钮
        Button {
            text: qsTr("开始游戏")
            font.pixelSize: 24
            Layout.preferredWidth: 200
            Layout.preferredHeight: 60
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
            onClicked: {
                // 创建并显示游戏窗口
                console.log("点击-主页面-开始游戏")
                var gameWindow = gameWindowComponent.createObject(root, {
                    "gameLogic": root.gameLogic
                })
                if (gameWindow) {
                    gameWindow.show()
                    // 隐藏主菜单窗口
                    root.hide()
                } else {
                    console.error("创建游戏窗口失败")
                }
            }
        }

        // 设置按钮
        Button {
            text: qsTr("设置")
            font.pixelSize: 24
            Layout.preferredWidth: 200
            Layout.preferredHeight: 60
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
            onClicked: {
                console.log("点击-主页面-设置")
                // TODO: 打开设置窗口
            }
        }

        // 退出游戏按钮
        Button {
            text: qsTr("退出游戏")
            font.pixelSize: 24
            Layout.preferredWidth: 200
            Layout.preferredHeight: 60
            background: Rectangle {
                color: parent.pressed ? "#e74c3c" : "#ff6b6b"
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
                console.log("点击-主页面-退出游戏")
                Qt.quit()
            }
        }
    }

    // 游戏窗口组件
    Component {
        id: gameWindowComponent
        GameWindow {
            onClosed: {
                root.show() // 当游戏窗口关闭时显示主菜单
            }
        }
    }
} 