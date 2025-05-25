import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#f0f0f0"
    
    signal closed()
    signal timeChanged(int seconds)
    
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
                    timeChanged([60, 180, 300, 9999][index])
                }
            }
        }
        
        Button {
            text: "保存设置"
            Layout.preferredWidth: 200
            onClicked: root.closed()
        }
        
        Button {
            text: "返回"
            Layout.preferredWidth: 200
            onClicked: root.closed()
        }
    }
}
