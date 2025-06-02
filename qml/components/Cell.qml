import QtQuick 2.15

Item {
    id: root // 组件的根元素
    width: 40 // 组件的宽度
    height: 40 // 组件的高度

    property int pattern: 0 // 方块的图案
    property bool selected: false // 是否选中
    property bool highlighted: false // 是否高亮
    property bool pathHighlighted: false // 是否路径高亮

    Rectangle {
        id: cellRect // 方块的矩形元素
        anchors.fill: parent // 填充父元素
        color: {
            if (highlighted) {
                // 如果高亮
                return "#FFD700"; // 金色高亮
            } else if (pathHighlighted) {
                // 如果路径高亮
                return "#90EE90"; // 浅绿色路径高亮
            } else if (selected) {
                // 如果选中
                return "#ADD8E6"; // 浅蓝色选中
            } else {
                // 否则
                return "#FFFFFF"; // 白色背景
            }
        }
        border.color: "#000000" // 边框颜色
        border.width: 1 // 边框宽度

        Text {
            anchors.centerIn: parent // 居中显示
            text: pattern > 0 ? pattern.toString() : "" // 如果图案大于0，显示图案，否则显示空字符串
            font.pixelSize: 20 // 字体大小
        }
    }

    MouseArea {
        anchors.fill: parent // 填充父元素
        onClicked: {
            if (pattern > 0) {
                // 如果图案大于0
                root.selected = !root.selected; // 切换选中状态
            }
        }
    }
}
