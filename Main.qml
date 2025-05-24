import QtQuick
import QtQuick.Controls // 导入Button

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("连连看小游戏")

        property int selectedRow: -1
    property int selectedCol: -1

    Grid {
        id: grid
        columns: gameLogic.cols()
        rows: gameLogic.rows()
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: 36
            delegate: Rectangle {
                width: 50
                height: 50
                color: gameLogic.getCell(Math.floor(index / 6), index % 6) === 0 ? "lightgray" : "skyblue"
                border.color: "black"

                Text {
                    anchors.centerIn: parent
                    text: gameLogic.getCell(Math.floor(index / 6), index % 6)
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        let r = Math.floor(index / 6)
                        let c = index % 6

                        if (selectedRow === -1) {
                            selectedRow = r
                            selectedCol = c
                        } else {
                            if (gameLogic.canLink(selectedRow, selectedCol, r, c)) {
                                grid.forceLayout()
                            }
                            selectedRow = -1
                            selectedCol = -1
                        }
                    }
                }
            }
        }
    }

    Button {
        text: "重置游戏"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        onClicked: {
            gameLogic.resetGame()
            grid.forceLayout()
        }
    }
}
