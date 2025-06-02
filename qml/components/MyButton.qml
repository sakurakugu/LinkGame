// MyButton.qml
import QtQuick

Rectangle {
    id: root

    // 可自定义的属性
    property string text: "按钮"
    property color normalColor: "#5ca9fb" // 正常状态颜色
    property color hoverColor: "#b0d3f8" // 悬停状态颜色
    property color pressedColor: "#4a90e2" // 按下状态颜色
    property int fontSize: 16 // 默认字体大小
    property int buttonWidth: 200 // 默认宽度
    property int buttonHeight: 40 // 默认高度

    signal clicked

    radius: 10
    implicitWidth: buttonWidth  // 默认宽度
    implicitHeight: buttonHeight  // 默认高度

    // 添加颜色渐变动画
    Behavior on color {
        ColorAnimation {
            duration: 250  // 0.25秒的渐变时间
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: root.fontSize
        color: "white"
    }

    color: normalColor

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        // 根据鼠标状态改变颜色
        onEntered: root.color = root.hoverColor // 悬停状态颜色
        onExited: root.color = root.normalColor // 正常状态颜色
        onPressed: root.color = root.pressedColor // 按下状态颜色
        onReleased: root.color = mouseArea.containsMouse ? root.hoverColor : root.normalColor // 根据鼠标状态改变颜色
    }
}
