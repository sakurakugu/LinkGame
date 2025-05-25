import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: mainWindow
    width: 640
    height: 480
    visible: true
    title: qsTr("连连看小游戏")
    minimumWidth: 640
    minimumHeight: 480

    // 游戏状态枚举
    property int gameState: 0  // 0=菜单, 1=游戏中, 2=游戏结束
    property int selectedRow: -1
    property int selectedCol: -1
    property int score: 0
    property int timeLeft: 180  // 3分钟游戏时间

    // 定时器
    Timer {
        id: gameTimer
        interval: 1000
        running: gameState === 1
        repeat: true
        onTriggered: {
            timeLeft--
            if (timeLeft <= 0) {
                gameState = 2
                gameStatus.text = "时间到！游戏结束"
            }
        }
    }

    // 开始菜单界面
    Loader {
        id: menuLoader
        anchors.fill: parent
        sourceComponent: menuComponent
        active: gameState === 0
    }

    Component {
        id: menuComponent
        Rectangle {
            color: "#f0f0f0"
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                
                Text {
                    text: "连连看"
                    font.pixelSize: 36
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Button {
                    text: "开始游戏"
                    Layout.preferredWidth: 200
                    onClicked: {
                        gameState = 1
                        gameLogic.resetGame()
                        score = 0
                        timeLeft = 180
                    }
                }
                
                Button {
                    text: "游戏设置"
                    Layout.preferredWidth: 200
                    onClicked: settingsLoader.active = true
                }
                
                Button {
                    text: "游戏帮助"
                    Layout.preferredWidth: 200
                    onClicked: helpLoader.active = true
                }
                
                Button {
                    text: "退出游戏"
                    Layout.preferredWidth: 200
                    onClicked: Qt.quit()
                }
            }
        }
    }

    // 游戏主界面
    Loader {
        id: gameLoader
        anchors.fill: parent
        sourceComponent: gameComponent
        active: gameState === 1
    }

    Component {
        id: gameComponent
        Item {
            // 顶部状态栏
            Rectangle {
                id: statusBar
                width: parent.width
                height: 50
                color: "#e0e0e0"
                
                RowLayout {
                    anchors.fill: parent
                    spacing: 20
                    
                    Text {
                        id: gameStatus
                        text: "游戏进行中"
                        font.pixelSize: 18
                        Layout.leftMargin: 10
                    }
                    
                    Text {
                        text: "分数: " + score
                        font.pixelSize: 18
                    }
                    
                    Text {
                        text: "时间: " + Math.floor(timeLeft/60) + ":" + (timeLeft%60 < 10 ? "0" : "") + timeLeft%60
                        font.pixelSize: 18
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: "返回菜单"
                        onClicked: gameState = 0
                    }
                    
                    Button {
                        text: "提示"
                        onClicked: showHint()
                        Layout.rightMargin: 10
                    }
                }
            }

            // 游戏网格
            Grid {
                id: grid
                columns: gameLogic.cols()
                rows: gameLogic.rows()
                anchors.centerIn: parent
                spacing: 4
                
                Repeater {
                    model: 36
                    delegate: Rectangle {
                        width: 50
                        height: 50
                        color: gameLogic.getCell(Math.floor(index / 6), index % 6) === 0 ? "lightgray" : "skyblue"
                        border.width: (selectedRow === Math.floor(index / 6)) && 
                                     (selectedCol === index % 6) ? 3 : 1
                        border.color: (selectedRow === Math.floor(index / 6) && 
                                      (selectedCol === index % 6)) ? "red" : "black"
                        
                        Behavior on color { ColorAnimation { duration: 200 } }

                        Text {
                            anchors.centerIn: parent
                            text: gameLogic.getCell(Math.floor(index / 6), index % 6)
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: handleCellClick(index)
                        }
                    }
                }
            }
        }
    }

    // 游戏结束界面
    Loader {
        id: endLoader
        anchors.fill: parent
        sourceComponent: endComponent
        active: gameState === 2
    }

    Component {
        id: endComponent
        Rectangle {
            color: "#f0f0f0"
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                
                Text {
                    text: "游戏结束"
                    font.pixelSize: 36
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: "最终得分: " + score
                    font.pixelSize: 24
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Button {
                    text: "再来一局"
                    Layout.preferredWidth: 200
                    onClicked: {
                        gameState = 1
                        gameLogic.resetGame()
                        score = 0
                        timeLeft = 180
                    }
                }
                
                Button {
                    text: "返回菜单"
                    Layout.preferredWidth: 200
                    onClicked: gameState = 0
                }
            }
        }
    }

    // 设置界面
    Loader {
        id: settingsLoader
        anchors.fill: parent
        sourceComponent: settingsComponent
        active: false
    }

    Component {
        id: settingsComponent
        Rectangle {
            color: "#f0f0f0"
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                
                Text {
                    text: "游戏设置"
                    font.pixelSize: 36
                    Layout.alignment: Qt.AlignHCenter
                }
                
                RowLayout {
                    Text { text: "难度级别:" }
                    ComboBox {
                        model: ["简单", "中等", "困难"]
                        currentIndex: 1
                    }
                }
                
                RowLayout {
                    Text { text: "游戏时间:" }
                    ComboBox {
                        model: ["1分钟", "3分钟", "5分钟", "无限"]
                        currentIndex: 1
                        onActivated: {
                            timeLeft = [60, 180, 300, 9999][index]
                        }
                    }
                }
                
                Button {
                    text: "保存设置"
                    Layout.preferredWidth: 200
                    onClicked: settingsLoader.active = false
                }
                
                Button {
                    text: "返回"
                    Layout.preferredWidth: 200
                    onClicked: settingsLoader.active = false
                }
            }
        }
    }

    // 帮助界面
    Loader {
        id: helpLoader
        anchors.fill: parent
        sourceComponent: helpComponent
        active: false
    }

    Component {
        id: helpComponent
        Rectangle {
            color: "#f0f0f0"
            
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
                    onClicked: helpLoader.active = false
                }
            }
        }
    }

    // 游戏逻辑连接
    Connections {
        target: gameLogic
        function onCellsChanged() {
            grid.forceLayout()
            if (gameLogic.isGameOver()) {
                gameState = 2
            }
        }
    }

    // 处理方块点击
    function handleCellClick(index) {
        let r = Math.floor(index / gameLogic.cols())
        let c = index % gameLogic.cols()

        if (selectedRow === -1) {
            selectedRow = r
            selectedCol = c
        } else {
            if (selectedRow === r && selectedCol === c) {
                selectedRow = -1
                selectedCol = -1
            } else if (gameLogic.canLink(selectedRow, selectedCol, r, c)) {
                gameLogic.removeLink(selectedRow, selectedCol, r, c)
                score += 10
                selectedRow = -1
                selectedCol = -1
            }
        }
    }

    // 提示功能
    function showHint() {
        // 这里实现提示逻辑
        // 可以高亮显示一对可连接的方块
    }
}