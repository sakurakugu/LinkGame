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
    property string currentDifficulty: "" // 添加当前难度属性，默认为空表示显示所有难度

    // 监听主题变化
    onThemeChanged: {
        console.log("Leaderboard主题变化:", theme);
        currentTheme = themeManager.loadTheme(theme);
    }

    signal closed

    Component.onCompleted: {
        console.log("Leaderboard初始化，当前主题:", theme);
        currentTheme = themeManager.loadTheme(theme); // 加载当前主题
        root.forceActiveFocus(); // 确保键盘事件处理程序获得焦点
        updateLeaderboard(); // 更新排行榜显示
    }

    // 添加主题变化监听
    Connections {
        target: settings
        function onThemeChanged() {
            theme = settings.getTheme();
            console.log("Leaderboard主题变化检测到:", theme);
            currentTheme = themeManager.loadTheme(theme);
        }
    }

    // 添加键盘事件处理
    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Escape) {
            root.closed();
        }
    }

    // 更新排行榜数据
    function updateLeaderboard() {
        if (currentDifficulty === "") {
            leaderboardView.model = settings.getLeaderboard();
        } else {
            leaderboardView.model = settings.getLeaderboardByDifficulty(currentDifficulty);
        }
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Text {
            text: currentDifficulty === "" ? qsTr("排行榜") : qsTr("排行榜 - ") + currentDifficulty
            font.pixelSize: 36
            color: currentTheme ? currentTheme.textColor : "#333333"
            Layout.alignment: Qt.AlignHCenter
        }
        RowLayout {
            id: difficultySelector
            spacing: 10
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignHCenter

            Text {
                text: qsTr("难度:")
                font.pixelSize: parent.parent.width * 0.03
                color: currentTheme ? currentTheme.textColor : "#333333"
                verticalAlignment: Text.AlignVCenter
            }
            ComboBox {
                id: difficultyComboBox
                model: [qsTr("全部"), qsTr("简单"), qsTr("普通"), qsTr("困难")]
                currentIndex: 0
                Layout.preferredWidth: 120
                implicitHeight: 40
                font.pixelSize: parent.parent.width * 0.03
                // 监听当前索引变化
                onCurrentIndexChanged: {
                    currentDifficulty = currentIndex === 0 ? "" : model[currentIndex];
                    updateLeaderboard();
                }

                // 背景颜色适应主题
                background: Rectangle {
                    color: currentTheme ? currentTheme.secondaryBackgroundColor : "white"
                    border.color: currentTheme ? currentTheme.borderColor : "#cccccc"
                    border.width: 1
                    radius: 5
                }// 样式
                delegate: Item {
                    implicitWidth: 100
                    implicitHeight: 40

                    Rectangle {
                        id: comboBoxItem
                        width: parent.width
                        height: parent.height
                        color: index === difficultyComboBox.currentIndex ? "#0078d4" : "transparent"
                        border.color: currentTheme ? currentTheme.borderColor : "#cccccc"
                        border.width: 1
                        radius: 5

                        Text {
                            text: modelData
                            font.pixelSize: difficultyComboBox.font.pixelSize
                            color: index === difficultyComboBox.currentIndex ? "white" : currentTheme ? currentTheme.textColor : "#333333"
                            anchors.centerIn: parent
                        }
                    }
                    MouseArea {
                        id: comboBoxMouseArea
                        anchors.fill: parent
                        onClicked: {
                            difficultyComboBox.currentIndex = index;
                            currentDifficulty = index === 0 ? "" : model[index];
                            updateLeaderboard();
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: currentTheme ? currentTheme.secondaryBackgroundColor : "white"
            border.color: currentTheme ? currentTheme.borderColor : "#cccccc"
            border.width: 1
            radius: 5

            ListView {
                id: leaderboardView
                anchors.fill: parent
                anchors.margins: 10
                model: settings.getLeaderboard()
                clip: true

                header: Rectangle {
                    width: parent.width
                    height: 40
                    color: "transparent"
                    property real headerFontSize: width * 0.03

                    RowLayout {
                        anchors.fill: parent
                        spacing: 10
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        Text {
                            text: qsTr("排名")
                            font.pixelSize: parent.parent.headerFontSize
                            font.bold: true
                            Layout.preferredWidth: parent.width * 0.15
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            text: qsTr("玩家")
                            font.pixelSize: parent.parent.headerFontSize
                            font.bold: true
                            Layout.preferredWidth: parent.width * 0.45
                            horizontalAlignment: Text.AlignLeft
                        }

                        // 当显示所有难度时，显示难度列
                        Text {
                            text: qsTr("难度")
                            font.pixelSize: parent.parent.headerFontSize
                            font.bold: true
                            visible: root.currentDifficulty === ""
                            Layout.preferredWidth: parent.width * 0.2
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            text: qsTr("分数")
                            font.pixelSize: parent.parent.headerFontSize
                            font.bold: true
                            Layout.preferredWidth: parent.width * 0.15
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                delegate: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: 50
                    color: index % 2 === 0 ? "#f9f9f9" : "white"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10
                        // 使用Layout.preferredWidth属性来设置固定宽度比例

                        Text {
                            text: (index + 1) + "."
                            font.pixelSize: parent.parent.width * 0.03
                            Layout.preferredWidth: parent.width * 0.15
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: modelData.name
                            font.pixelSize: parent.parent.width * 0.03
                            Layout.preferredWidth: parent.width * 0.45 // 名字占更多空间
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            elide: Text.ElideRight // 如果文字太长则显示省略号
                            wrapMode: Text.NoWrap
                        }

                        // 当显示所有难度时，显示难度列
                        Text {
                            text: modelData.difficulty || qsTr("普通")
                            font.pixelSize: parent.parent.width * 0.03
                            visible: currentDifficulty === ""
                            Layout.preferredWidth: parent.width * 0.2
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: modelData.score
                            font.pixelSize: parent.parent.width * 0.03
                            Layout.preferredWidth: parent.width * 0.15
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onHoveredChanged: {
                            if (mouseArea.containsMouse) {
                                parent.color = "#e0e0e0";
                            } else {
                                parent.color = index % 2 === 0 ? "#f9f9f9" : "white";
                            }
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }
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

    // 监听排行榜变化
    Connections {
        target: settings
        function onLeaderboardChanged() {
            updateLeaderboard(); // 使用更新函数保持当前难度的筛选
        }
    }
}
