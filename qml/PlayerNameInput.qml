import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f0f0f0"
    
    signal confirmed(string playerName)
    signal canceled()
    
    property string currentName: gameLogic.getPlayerName()
    
    Rectangle {
        anchors.centerIn: parent
        width: 400
        height: 250
        color: "white"
        radius: 10
        border.color: "#cccccc"
        border.width: 1
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20
            
            Text {
                text: "请输入您的名字"
                font.pixelSize: 24
                Layout.alignment: Qt.AlignHCenter
            }
            
            TextField {
                id: nameInput
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                placeholderText: "请输入名字"
                text: root.currentName
                font.pixelSize: 16
                selectByMouse: true
                maximumLength: 20
                
                background: Rectangle {
                    border.color: nameInput.activeFocus ? "#5ca9fb" : "#cccccc"
                    border.width: 1
                    radius: 5
                }
            }
            
            Item { Layout.fillHeight: true }
            
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20
                
                Button {
                    text: "确定"
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    
                    background: Rectangle {
                        color: parent.pressed ? "#4a90e2" : "#5ca9fb"
                        radius: 5
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 16
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        if (nameInput.text.trim() !== "") {
                            root.confirmed(nameInput.text.trim())
                        }
                    }
                }
                
                Button {
                    text: "取消"
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    
                    background: Rectangle {
                        color: parent.pressed ? "#e0e0e0" : "#f0f0f0"
                        border.color: "#cccccc"
                        border.width: 1
                        radius: 5
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 16
                        color: "#333333"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: root.canceled()
                }
            }
        }
    }
}