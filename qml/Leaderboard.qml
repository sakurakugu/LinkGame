import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f0f0f0"
    
    signal closed()
    
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
                model: gameLogic.getLeaderboard()
                clip: true
                
                header: RowLayout {
                    width: parent.width
                    height: 40
                    spacing: 10
                    
                    Text {
                        text: "排名"
                        font.pixelSize: 18
                        font.bold: true
                        Layout.preferredWidth: 80
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Text {
                        text: "玩家"
                        font.pixelSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: "分数"
                        font.pixelSize: 18
                        font.bold: true
                        Layout.preferredWidth: 100
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
                            font.pixelSize: 16
                            Layout.preferredWidth: 80
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        Text {
                            text: modelData.name
                            font.pixelSize: 16
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: modelData.score
                            font.pixelSize: 16
                            Layout.preferredWidth: 100
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
        
        Button {
            text: "返回"
            Layout.preferredWidth: 200
            Layout.alignment: Qt.AlignHCenter
            onClicked: root.closed()
        }
    }
    
    // 监听排行榜变化
    Connections {
        target: gameLogic
        function onLeaderboardChanged() {
            leaderboardView.model = gameLogic.getLeaderboard()
        }
    }
}