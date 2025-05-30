import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f0f0f0"    
    signal closed
    signal timeChanged(int seconds)
    signal volumeChanged(double volume)
    signal soundStateChanged(bool enabled)

    // 从GameLogic获取当前设置
    property string currentUsername: gameLogic.getPlayerName()
    property string currentDifficulty: gameLogic.getDifficulty()
    property int currentGameTime: gameLogic.getGameTime()
    property double currentVolume: gameLogic.getVolume()
    property bool isSoundEnabled: true

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "游戏设置"
            font.pixelSize: 36
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Text {
                text: "用户名:"
            }
            TextField {
                id: usernameField
                text: root.currentUsername
                Layout.fillWidth: true
                maximumLength: 20
                onTextChanged: {
                    gameLogic.setPlayerName(text);
                }
            }
        }

        RowLayout {
            Text {
                text: "难度级别:"
            }
            ComboBox {
                id: difficultyCombo
                model: ["简单", "中等", "困难"]
                currentIndex: {
                    if (root.currentDifficulty === "简单")
                        return 0;
                    if (root.currentDifficulty === "困难")
                        return 2;
                    return 1; // 默认中等
                }
                onActivated: {
                    gameLogic.setDifficulty(model[currentIndex]);
                }
            }
        }        RowLayout {
            Text {
                text: "游戏时间:"
            }
            ComboBox {
                id: timeCombo
                model: ["1分钟", "3分钟", "5分钟", "无限"]
                currentIndex: {
                    if (root.currentGameTime <= 60)
                        return 0;
                    if (root.currentGameTime <= 180)
                        return 1;
                    if (root.currentGameTime <= 300)
                        return 2;
                    return 3; // 无限
                }
                onActivated: {
                    var seconds = [60, 180, 300, 9999][currentIndex];
                    timeChanged(seconds);
                }
            }
        }
        
        // 音效开关
        RowLayout {
            Text {
                text: "音效:"
            }
            CheckBox {
                id: soundCheckbox
                checked: root.isSoundEnabled
                onCheckedChanged: {
                    root.isSoundEnabled = checked
                    root.soundStateChanged(checked)
                }
            }
        }
        
        // 音量设置
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Text {
                text: "音效音量:"
            }
            
            Slider {
                id: volumeSlider
                from: 0
                to: 1.0
                value: root.currentVolume
                stepSize: 0.01
                Layout.fillWidth: true
                enabled: soundCheckbox.checked
                
                onValueChanged: {
                    // 将值传递给GameLogic并更新音量
                    gameLogic.setVolume(value);
                    volumeChanged(value);
                }
            }
            
            Text {
                text: Math.round(volumeSlider.value * 100) + "%"
                Layout.preferredWidth: 50
            }
        }

        Button {
            text: "返回"
            Layout.preferredWidth: 200
            onClicked: root.closed()
        }
    }
}
