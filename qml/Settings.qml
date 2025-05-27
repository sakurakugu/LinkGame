import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f0f0f0"
    
    signal closed()
    signal timeChanged(int seconds)
    
    // 从GameLogic获取当前设置
    property string currentDifficulty: gameLogic.getDifficulty()
    property int currentGameTime: gameLogic.getGameTime()
    
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
                id: difficultyCombo
                model: ["简单", "中等", "困难"]
                currentIndex: {
                    if (root.currentDifficulty === "简单") return 0;
                    if (root.currentDifficulty === "困难") return 2;
                    return 1; // 默认中等
                }
                onActivated: {
                    gameLogic.setDifficulty(model[currentIndex]);
                }
            }
        }
        
        RowLayout {
            Text { text: "游戏时间:" }
            ComboBox {
                id: timeCombo
                model: ["1分钟", "3分钟", "5分钟", "无限"]
                currentIndex: {
                    if (root.currentGameTime <= 60) return 0;
                    if (root.currentGameTime <= 180) return 1;
                    if (root.currentGameTime <= 300) return 2;
                    return 3; // 无限
                }
                onActivated: {
                    var seconds = [60, 180, 300, 9999][currentIndex];
                    timeChanged(seconds);
                }
            }
        }
        
        Button {
            text: "保存设置"
            Layout.preferredWidth: 200
            onClicked: {
                // 保存设置
                gameLogic.setDifficulty(difficultyCombo.model[difficultyCombo.currentIndex]);
                var seconds = [60, 180, 300, 9999][timeCombo.currentIndex];
                gameLogic.setGameTime(seconds);
                root.closed();
            }
        }
        
        Button {
            text: "返回"
            Layout.preferredWidth: 200
            onClicked: root.closed()
        }
    }
}
