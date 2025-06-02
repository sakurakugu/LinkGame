import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f0f0f0"
    focus: true // 确保可以接收键盘事件

    // 定义信号
    signal closed
    signal timeChanged(int seconds)
    signal soundStateChanged(bool enabled)

    // 从GameLogic获取当前设置
    property string username: settings.getPlayerName()
    property string difficulty: settings.getDifficulty()
    property int gameTime: settings.getGameTime()
    property double volume: settings.getVolume()
    property int blockCount: settings.getBlockCount()
    property int blockTypes: settings.getBlockTypes()
    property bool isSoundEnabled: true

    // 添加键盘事件处理
    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Escape) {
            root.closed();
        }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded // 垂直滚动条根据需要显示
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff // 水平滚动条始终不显示

        Item {
            width: scrollView.width
            height: Math.max(scrollView.height, contentLayout.height)

            ColumnLayout {
                id: contentLayout
                anchors.centerIn: parent
                width: parent.width * 0.8 // 使用父容器宽度的80%
                spacing: parent.parent.height * 0.05 // 使用窗口高度的3%作为间距

                Text {
                    text: "游戏设置"
                    font.pixelSize: parent.parent.width * 0.04 // 使用窗口宽度的4%作为字体大小
                    Layout.alignment: Qt.AlignHCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: parent.parent.width * 0.02 // 使用父容器宽度的2%作为间距

                    Text {
                        text: "用户名:"
                        font.pixelSize: parent.parent.parent.width * 0.02 // 使用窗口宽度的2%作为字体大小
                    }
                    TextField {
                        id: usernameField
                        text: root.username
                        Layout.fillWidth: true
                        maximumLength: 20
                        font.pixelSize: parent.parent.parent.width * 0.02 // 使用窗口宽度的2%作为字体大小
                        onTextChanged: {
                            settings.setPlayerName(text);
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: parent.parent.width * 0.02

                    Text {
                        text: "难度级别:"
                        font.pixelSize: parent.parent.parent.width * 0.02
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: parent.parent.parent.width * 0.02

                        RadioButton {
                            id: easyRadio
                            text: "简单"
                            checked: root.difficulty === "简单"
                            font.pixelSize: parent.parent.parent.parent.width * 0.02
                            onCheckedChanged: if (checked)
                                settings.setDifficulty("简单")
                        }
                        RadioButton {
                            id: mediumRadio
                            text: "普通"
                            checked: root.difficulty === "普通"
                            font.pixelSize: parent.parent.parent.parent.width * 0.02
                            onCheckedChanged: if (checked)
                                settings.setDifficulty("普通")
                        }
                        RadioButton {
                            id: hardRadio
                            text: "困难"
                            checked: root.difficulty === "困难"
                            font.pixelSize: parent.parent.parent.parent.width * 0.02
                            onCheckedChanged: if (checked)
                                settings.setDifficulty("困难")
                        }
                        RadioButton {
                            id: customRadio
                            text: "自定义"
                            checked: root.difficulty === "自定义"
                            font.pixelSize: parent.parent.parent.parent.width * 0.02
                            onCheckedChanged: if (checked)
                                settings.setDifficulty("自定义")
                        }
                    }
                }

                // 自定义设置面板
                Rectangle {
                    visible: customRadio.checked
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.parent.height * 0.4
                    color: "#f8f8f8"
                    radius: 5

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: parent.parent.parent.width * 0.02
                        spacing: parent.parent.parent.height * 0.01

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "游戏时间(秒):"
                                font.pixelSize: parent.parent.parent.parent.width * 0.02
                            }
                            TextField {
                                id: customTimeField
                                text: root.gameTime
                                Layout.fillWidth: true
                                font.pixelSize: parent.parent.parent.parent.width * 0.02
                                validator: IntValidator {
                                    bottom: 30
                                    top: 3600
                                }
                                onTextChanged: {
                                    if (text !== "") {
                                        settings.setGameTime(parseInt(text));
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "方块数量:"
                                font.pixelSize: parent.parent.parent.parent.width * 0.02
                            }
                            TextField {
                                id: blockCountField
                                text: root.blockCount
                                Layout.fillWidth: true
                                font.pixelSize: parent.parent.parent.parent.width * 0.02
                                validator: IntValidator {
                                    bottom: 16
                                    top: 100
                                }
                                onTextChanged: {
                                    if (text !== "") {
                                        settings.setBlockCount(parseInt(text));
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "方块种类:"
                                font.pixelSize: parent.parent.parent.parent.width * 0.02
                            }
                            TextField {
                                id: blockTypesField
                                text: root.blockTypes
                                Layout.fillWidth: true
                                font.pixelSize: parent.parent.parent.parent.width * 0.02
                                validator: IntValidator {
                                    bottom: 8
                                    top: 36
                                }
                                onTextChanged: {
                                    if (text !== "") {
                                        settings.setBlockTypes(parseInt(text));
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "参加排行榜"
                                font.pixelSize: parent.parent.parent.parent.width * 0.02
                            }
                            CheckBox {
                                id: customLeaderboardCheck
                                checked: true
                                font.pixelSize: parent.parent.parent.parent.width * 0.02
                                onCheckedChanged: {
                                    settings.setCustomLeaderboardEnabled(checked);
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: parent.parent.width * 0.02

                    Text {
                        text: "游戏时间:"
                        font.pixelSize: parent.parent.parent.width * 0.02
                    }
                    ComboBox {
                        id: timeCombo
                        model: ["1分钟", "3分钟", "5分钟", "无限"]
                        Layout.fillWidth: true
                        font.pixelSize: parent.parent.parent.width * 0.02
                        currentIndex: {
                            if (root.gameTime <= 60)
                                return 0;
                            if (root.gameTime <= 180)
                                return 1;
                            if (root.gameTime <= 300)
                                return 2;
                            return 3; // 无限
                        }
                        onActivated: {
                            var seconds = [60, 180, 300, 9999][currentIndex];
                            settings.setGameTime(seconds);
                        }
                    }
                }

                // 音效开关和音量设置
                RowLayout {
                    Layout.fillWidth: true
                    spacing: parent.parent.width * 0.02

                    Text {
                        text: "音量:"
                        font.pixelSize: parent.parent.parent.width * 0.02
                    }
                    CheckBox {
                        id: soundCheckbox
                        checked: root.isSoundEnabled
                        font.pixelSize: parent.parent.parent.width * 0.02
                        onCheckedChanged: {
                            root.isSoundEnabled = checked;
                            root.soundStateChanged(checked);
                        }
                    }

                    Slider {
                        id: volumeSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 1
                        value: root.volume
                        enabled: soundCheckbox.checked
                        onValueChanged: {
                            settings.setVolume(value);
                        }
                    }
                    Text {
                        text: Math.round(volumeSlider.value * 100) + "%"
                        font.pixelSize: parent.parent.parent.width * 0.02
                        Layout.preferredWidth: parent.parent.parent.width * 0.1
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: parent.parent.width * 0.02

                    Text {
                        text: "窗口大小:"
                        font.pixelSize: parent.parent.parent.width * 0.02
                    }
                    ComboBox {
                        id: windowSizeCombo
                        model: settings.getWindowSizeModel() // 从C++端获取窗口大小模型
                        Layout.fillWidth: true
                        font.pixelSize: parent.parent.parent.width * 0.02
                        currentIndex: {
                            let currentSize = settings.getScreenSize(); // 获取当前屏幕大小
                            if (currentSize.startsWith("全屏")) // 如果当前屏幕大小以"全屏"开头
                                return 0;
                            if (currentSize.startsWith("无边框")) // 如果当前屏幕大小以"无边框"开头
                                return 1;
                            return model.indexOf(currentSize); // 返回当前屏幕大小在模型中的索引
                        }
                        onActivated: {
                            if (currentIndex === 0) {
                                // 如果当前索引为0
                                settings.setFullscreen(true); // 设置全屏
                            } else if (currentIndex === 1) {
                                // 如果当前索引为1
                                settings.setBorderless(true); // 设置无边框
                            } else {
                                let size = model[currentIndex].split("x"); // 将当前屏幕大小按"x"分割成数组
                                settings.setFullscreen(false); // 设置非全屏
                                settings.setBorderless(false); // 设置非无边框
                                settings.resizeWindow(parseInt(size[0]), parseInt(size[1])); // 调整窗口大小
                            }
                        }
                    }
                }

                // 添加窗口大小变化监听
                Connections {
                    target: root.Window.window
                    function onWidthChanged() {
                        settings.updateWindowSize();
                    }
                    function onHeightChanged() {
                        settings.updateWindowSize();
                    }
                }

                Button {
                    text: "确定"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: parent.parent.width * 0.2 // 使用窗口宽度的20%作为按钮宽度
                    Layout.preferredHeight: parent.parent.height * 0.08 // 使用窗口高度的8%作为按钮高度
                    font.pixelSize: parent.parent.width * 0.02 // 使用窗口宽度的2%作为字体大小
                    onClicked: {
                        root.closed();
                    }
                }
            }
        }
    }
}
