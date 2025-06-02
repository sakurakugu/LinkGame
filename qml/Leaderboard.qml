import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./components"

Rectangle {
    id: root
    color: "#f0f0f0"
    focus: true // 确保可以接收键盘事件

    signal closed

    // 添加键盘事件处理
    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Escape) {
            root.closed();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Text {
            text: "排行榜"
            font.pixelSize: 36
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "white"
            border.color: "#cccccc"
            border.width: 1
            radius: 5

            ListView {
                id: leaderboardView
                anchors.fill: parent
                anchors.margins: 10
                model: settings.getLeaderboard()
                clip: true

                header: RowLayout {
                    width: parent.width
                    height: 40
                    spacing: 10

                    Text {
                        text: "排名"
                        font.pixelSize: parent.parent.width * 0.03
                        font.bold: true
                        Layout.preferredWidth: parent.width * 0.2
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: "玩家"
                        font.pixelSize: parent.parent.width * 0.03
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "分数"
                        font.pixelSize: parent.parent.width * 0.03
                        font.bold: true
                        Layout.preferredWidth: parent.width * 0.2
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                delegate: Rectangle {
                    width: parent.width
                    height: 50
                    color: index % 2 === 0 ? "#f9f9f9" : "white"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        Text {
                            text: (index + 1) + "."
                            font.pixelSize: parent.parent.width * 0.03
                            Layout.preferredWidth: parent.width * 0.2
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            text: modelData.name
                            font.pixelSize: parent.parent.width * 0.03
                            Layout.fillWidth: true
                        }

                        Text {
                            text: modelData.score
                            font.pixelSize: parent.parent.width * 0.03
                            Layout.preferredWidth: parent.width * 0.2
                            horizontalAlignment: Text.AlignHCenter
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
            text: "返回"
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
            leaderboardView.model = settings.getLeaderboard();
        }
    }
}
