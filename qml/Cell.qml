import QtQuick 2.15

Item {
    id: root
    width: 40
    height: 40

    property int pattern: 0
    property bool selected: false
    property bool highlighted: false
    property bool pathHighlighted: false

    Rectangle {
        id: cellRect
        anchors.fill: parent
        color: {
            if (highlighted) {
                return "#FFD700" // 金色高亮
            } else if (pathHighlighted) {
                return "#90EE90" // 浅绿色路径高亮
            } else if (selected) {
                return "#ADD8E6" // 浅蓝色选中
            } else {
                return "#FFFFFF" // 白色背景
            }
        }
        border.color: "#000000"
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: pattern > 0 ? pattern.toString() : ""
            font.pixelSize: 20
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (pattern > 0) {
                root.selected = !root.selected
            }
        }
    }
} 