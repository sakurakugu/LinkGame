import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./components"
import "./theme"

Rectangle {
    id: root
    color: currentTheme ? currentTheme.backgroundColor : "#f0f0f0"
    focus: true // 确保可以接收键盘事件

    // 定义信号
    signal closed    
    
    Component.onCompleted: {
        // console.log("Settings初始化，当前主题: " + theme);
        // console.log("加载主题...");
        currentTheme = themeManager.loadTheme(theme); // 加载当前主题
        // console.log("是否成功加载主题: " + (currentTheme !== null));
        root.forceActiveFocus(); // 确保键盘事件处理程序获得焦点
    }

    // 从GameLogic获取当前设置
    property string username: settings.getPlayerName()
    property string difficulty: settings.getDifficulty()
    property int gameTime: settings.getGameTime()
    property double volume: settings.getVolume()
    property int blockCount: settings.getBlockCount()
    property int blockTypes: settings.getBlockTypes()
    property bool joinLeaderboard: settings.getJoinLeaderboard()
    property bool isSoundEnabled: settings.getSoundState()
    property string theme: settings.getTheme()    // 主题管理器
    property ThemeManager themeManager: ThemeManager {
        id: themeManager
    }
    property QtObject currentTheme: null    // 当主题变化时更新预览
    onThemeChanged: {
        console.log("Settings主题变化:", theme);
        currentTheme = themeManager.loadTheme(theme);
        updateThemeUI();
    }
    
    // 更新主题相关的UI元素
    function updateThemeUI() {
        // 确保下拉框选中正确的主题
        themeCombo.currentIndex = settings.getThemeIndex();
        
        // 强制重新应用主题颜色到所有UI元素
        // 这里不需要明确设置，因为绑定会自动更新
        console.log("重新应用主题到UI元素");
    }

    // 添加键盘事件处理
    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Escape) {
            root.closed();
        }
    }
    
    // 添加语言变化监听并重新应用文本
    Connections {
        target: settings
        function onLanguageChanged() {
            console.log("Settings检测到语言变化，更新UI文本");
            
            // 由于Loader会重新加载组件，这里只需要确保正确更新ComboBox等组件
            // 更新语言下拉框
            languageCombo.model = settings.getLanguageDisplayNameList();
            languageCombo.currentIndex = settings.getLanguageIndex();
            
            // 可以在这里添加其他需要手动更新的组件
        }
    }    
    Flickable {
        id: flickable
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: bottomButton.top
        anchors.bottomMargin: 20 // 与按钮底部的 margin 保持一致
        contentWidth: width
        contentHeight: contentLayout.implicitHeight + 40  // 增加一些额外空间
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: true // 确保可以交互滚动
        
        // 添加滚动指示器
        ScrollBar.vertical: ScrollBar {
            active: flickable.interactive
            policy: ScrollBar.AsNeeded
            
            // 应用主题颜色
            contentItem: Rectangle {
                implicitWidth: 6
                implicitHeight: 100
                radius: width / 2
                color: parent.pressed ? 
                       (currentTheme ? Qt.darker(currentTheme.accentColor, 1.1) : "#005a9e") : 
                       (currentTheme ? currentTheme.accentColor : "#0078d7")
                opacity: parent.active ? 0.8 : 0.5
            }
            
            background: Rectangle {
                implicitWidth: 6
                implicitHeight: 100
                color: currentTheme ? Qt.alpha(currentTheme.borderColor, 0.1) : "#1a000000"
                radius: width / 2
                opacity: 0.5
            }
        }

        // 设置鼠标滚轮滚动行为
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton // 不接收任何鼠标按钮事件
            onWheel: function (wheel) {
                // 根据滚轮方向调整内容位置
                if (wheel.angleDelta.y > 0)
                    flickable.flick(0, 500);
                else
                    // 向上滚动
                    flickable.flick(0, -500); // 向下滚动
            }
        }

        ColumnLayout {
            id: contentLayout
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.8 // 使用父容器宽度的80%
            anchors.top: parent.top
            anchors.topMargin: 20
            spacing: root.height * 0.05 // 使用窗口高度的5%作为间距
            Text {
                text: qsTr("游戏设置")
                font.pixelSize: parent.parent.width * 0.04 // 使用窗口宽度的4%作为字体大小
                color: currentTheme ? currentTheme.textColor : "#333333"
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: parent.parent.width * 0.02 // 使用父容器宽度的2%作为间距

                Text {
                    text: qsTr("用户名:")
                    font.pixelSize: parent.parent.parent.width * 0.02 // 使用窗口宽度的2%作为字体大小
                }                
                TextField {
                    id: usernameField
                    text: root.username
                    Layout.fillWidth: true
                    maximumLength: 20
                    font.pixelSize: parent.parent.parent.width * 0.02 // 使用窗口宽度的2%作为字体大小
                    // validator: RegularExpressionValidator {
                    //     regularExpression: /^[a-zA-Z0-9_\u4e00-\u9fa5]{1,20}$/
                    // }
                    onTextChanged: {
                        if (acceptableInput) {
                            settings.setPlayerName(text);
                        }
                    }
                    
                    // 应用主题颜色
                    color: acceptableInput ? (currentTheme ? currentTheme.textColor : "#333333") : "red"
                    
                    background: Rectangle {
                        implicitWidth: 200
                        implicitHeight: 40
                        color: currentTheme ? currentTheme.secondaryBackgroundColor : "#ffffff"
                        border.color: usernameField.acceptableInput ? 
                                     (currentTheme ? currentTheme.borderColor : "#cccccc") : 
                                     "red"
                        border.width: 1
                        radius: 2
                    }
                    
                    // 添加提示文本
                    ToolTip {
                        visible: !usernameField.acceptableInput && usernameField.text.length > 0
                        // text: qsTr("用户名只能包含字母、数字、下划线和汉字，长度1-20")
                        text: qsTr("用户名长度要为1-20个字符")
                        delay: 500
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: parent.parent.width * 0.02

                Text {
                    text: qsTr("难度级别:")
                    font.pixelSize: parent.parent.parent.width * 0.02
                }                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: parent.parent.parent.width * 0.02
                    
                    RadioButton {
                        id: easyRadio
                        text: qsTr("简单")
                        checked: root.difficulty === "简单"
                        font.pixelSize: parent.parent.parent.parent.width * 0.02
                        onCheckedChanged: if (checked) {
                            settings.setDifficulty("简单");
                            customTimeField.text = settings.getGameTime();
                            blockCountField.text = settings.getBlockCount();
                            blockTypesField.text = settings.getBlockTypes();
                        }
                        
                        // 应用主题颜色
                        contentItem: Text {
                            text: easyRadio.text
                            font: easyRadio.font
                            opacity: enabled ? 1.0 : 0.3
                            color: currentTheme ? currentTheme.textColor : "#333333"
                            leftPadding: easyRadio.indicator.width + easyRadio.spacing
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        indicator: Rectangle {
                            implicitWidth: 18
                            implicitHeight: 18
                            x: easyRadio.leftPadding
                            y: parent.height / 2 - height / 2
                            radius: 9
                            border.color: currentTheme ? currentTheme.borderColor : "#999999"
                            border.width: 1
                            
                            Rectangle {
                                width: 10
                                height: 10
                                x: 4
                                y: 4
                                radius: 5
                                color: currentTheme ? currentTheme.accentColor : "#0078d7"
                                visible: easyRadio.checked
                            }
                        }
                    }                    
                    RadioButton {
                        id: mediumRadio
                        text: qsTr("普通")
                        checked: root.difficulty === "普通"
                        font.pixelSize: parent.parent.parent.parent.width * 0.02
                        onCheckedChanged: if (checked) {
                            settings.setDifficulty("普通");
                            customTimeField.text = settings.getGameTime();
                            blockCountField.text = settings.getBlockCount();
                            blockTypesField.text = settings.getBlockTypes();
                            joinLeaderboardCheck.checked = settings.getJoinLeaderboard();
                        }
                        
                        // 应用主题颜色
                        contentItem: Text {
                            text: mediumRadio.text
                            font: mediumRadio.font
                            opacity: enabled ? 1.0 : 0.3
                            color: currentTheme ? currentTheme.textColor : "#333333"
                            leftPadding: mediumRadio.indicator.width + mediumRadio.spacing
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        indicator: Rectangle {
                            implicitWidth: 18
                            implicitHeight: 18
                            x: mediumRadio.leftPadding
                            y: parent.height / 2 - height / 2
                            radius: 9
                            border.color: currentTheme ? currentTheme.borderColor : "#999999"
                            border.width: 1
                            
                            Rectangle {
                                width: 10
                                height: 10
                                x: 4
                                y: 4
                                radius: 5
                                color: currentTheme ? currentTheme.accentColor : "#0078d7"
                                visible: mediumRadio.checked
                            }
                        }
                    }                    
                    RadioButton {
                        id: hardRadio
                        text: qsTr("困难")
                        checked: root.difficulty === "困难"
                        font.pixelSize: parent.parent.parent.parent.width * 0.02
                        onCheckedChanged: if (checked) {
                            settings.setDifficulty("困难");
                            customTimeField.text = settings.getGameTime();
                            blockCountField.text = settings.getBlockCount();
                            blockTypesField.text = settings.getBlockTypes();
                            joinLeaderboardCheck.checked = settings.getJoinLeaderboard();
                        }
                        
                        // 应用主题颜色
                        contentItem: Text {
                            text: hardRadio.text
                            font: hardRadio.font
                            opacity: enabled ? 1.0 : 0.3
                            color: currentTheme ? currentTheme.textColor : "#333333"
                            leftPadding: hardRadio.indicator.width + hardRadio.spacing
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        indicator: Rectangle {
                            implicitWidth: 18
                            implicitHeight: 18
                            x: hardRadio.leftPadding
                            y: parent.height / 2 - height / 2
                            radius: 9
                            border.color: currentTheme ? currentTheme.borderColor : "#999999"
                            border.width: 1
                            
                            Rectangle {
                                width: 10
                                height: 10
                                x: 4
                                y: 4
                                radius: 5
                                color: currentTheme ? currentTheme.accentColor : "#0078d7"
                                visible: hardRadio.checked
                            }
                        }
                    }                    
                    RadioButton {
                        id: customRadio
                        text: qsTr("自定义")
                        checked: root.difficulty === "自定义"
                        font.pixelSize: parent.parent.parent.parent.width * 0.02
                        onCheckedChanged: if (checked) {
                            settings.setDifficulty("自定义");
                            customTimeField.text = settings.getGameTime();
                            blockCountField.text = settings.getBlockCount();
                            blockTypesField.text = settings.getBlockTypes();
                            joinLeaderboardCheck.checked = settings.getJoinLeaderboard();
                        }
                        
                        // 应用主题颜色
                        contentItem: Text {
                            text: customRadio.text
                            font: customRadio.font
                            opacity: enabled ? 1.0 : 0.3
                            color: currentTheme ? currentTheme.textColor : "#333333"
                            leftPadding: customRadio.indicator.width + customRadio.spacing
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        indicator: Rectangle {
                            implicitWidth: 18
                            implicitHeight: 18
                            x: customRadio.leftPadding
                            y: parent.height / 2 - height / 2
                            radius: 9
                            border.color: currentTheme ? currentTheme.borderColor : "#999999"
                            border.width: 1
                            
                            Rectangle {
                                width: 10
                                height: 10
                                x: 4
                                y: 4
                                radius: 5
                                color: currentTheme ? currentTheme.accentColor : "#0078d7"
                                visible: customRadio.checked
                            }
                        }
                    }
                }
            }

            // 自定义设置面板
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.parent.height * 0.3 // 使用窗口高度的40%作为高度
                color: currentTheme ? currentTheme.secondaryBackgroundColor : "#f8f8f8"
                border.color: currentTheme ? currentTheme.borderColor : "#dddddd"
                border.width: 1
                radius: 5

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: parent.parent.parent.width * 0.02 // 使用窗口宽度的2%作为间距
                    spacing: parent.parent.parent.height * 0.01 // 使用窗口高度的1%作为间距

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: qsTr("游戏时间(秒):")
                            font.pixelSize: parent.parent.parent.parent.width * 0.02
                        }                        
                        TextField {
                            id: customTimeField
                            text: root.gameTime
                            Layout.fillWidth: true
                            font.pixelSize: parent.parent.parent.parent.width * 0.02
                            enabled: customRadio.checked
                            validator: IntValidator {
                                bottom: 30
                                top: 3600
                            }
                            onTextChanged: {
                                if (acceptableInput && text !== "" && customRadio.checked) {
                                    var value = parseInt(text);
                                    if (value < 30) value = 30;
                                    if (value > 3600) value = 3600;
                                    if (value !== parseInt(text)) {
                                        text = value.toString();
                                    }
                                    settings.setGameTime(value);
                                }
                            }
                            
                            // 应用主题颜色
                            color: acceptableInput || text === "" ? 
                                  (currentTheme ? (enabled ? currentTheme.textColor : currentTheme.secondaryTextColor) : (enabled ? "#333333" : "#999999")) : 
                                  "red"
                            
                            background: Rectangle {
                                implicitWidth: 200
                                implicitHeight: 40
                                color: customTimeField.enabled ? 
                                       (currentTheme ? currentTheme.secondaryBackgroundColor : "#ffffff") : 
                                       (currentTheme ? Qt.darker(currentTheme.secondaryBackgroundColor, 1.05) : "#f0f0f0")
                                border.color: customTimeField.acceptableInput || customTimeField.text === "" ? 
                                             (currentTheme ? currentTheme.borderColor : "#cccccc") : 
                                             "red"
                                border.width: 1
                                radius: 2
                            }
                            
                            // 添加提示文本
                            ToolTip {
                                visible: !customTimeField.acceptableInput && customTimeField.text.length > 0
                                text: qsTr("游戏时间必须是30-3600之间的整数")
                                delay: 500
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: qsTr("方块数量:")
                            font.pixelSize: parent.parent.parent.parent.width * 0.02
                        }                        
                        TextField {
                            id: blockCountField
                            text: root.blockCount
                            Layout.fillWidth: true
                            font.pixelSize: parent.parent.parent.parent.width * 0.02
                            enabled: customRadio.checked
                            validator: IntValidator {
                                bottom: 16
                                top: 100
                            }
                            onTextChanged: {
                                if (acceptableInput && text !== "" && customRadio.checked) {
                                    var value = parseInt(text);
                                    // 确保方块数量是偶数
                                    if (value % 2 !== 0) {
                                        value = value - 1;
                                        text = value.toString();
                                    }
                                    if (value < 16) value = 16;
                                    if (value > 100) value = 100;                                    
                                    if (value !== parseInt(text)) {
                                        text = value.toString();
                                    }
                                    settings.setBlockCount(value);
                                    
                                    // 立即强制更新，确保不需要重启就能应用新设置
                                    settings.forceUpdateBlockSettings();
                                }
                            }
                            
                            // 应用主题颜色
                            color: acceptableInput || text === "" ? 
                                  (currentTheme ? (enabled ? currentTheme.textColor : currentTheme.secondaryTextColor) : (enabled ? "#333333" : "#999999")) : 
                                  "red"
                            
                            background: Rectangle {
                                implicitWidth: 200
                                implicitHeight: 40
                                color: blockCountField.enabled ? 
                                       (currentTheme ? currentTheme.secondaryBackgroundColor : "#ffffff") : 
                                       (currentTheme ? Qt.darker(currentTheme.secondaryBackgroundColor, 1.05) : "#f0f0f0")
                                border.color: blockCountField.acceptableInput || blockCountField.text === "" ? 
                                             (currentTheme ? currentTheme.borderColor : "#cccccc") : 
                                             "red"
                                border.width: 1
                                radius: 2
                            }
                            
                            // 添加提示文本
                            ToolTip {
                                visible: !blockCountField.acceptableInput && blockCountField.text.length > 0
                                text: qsTr("方块数量必须是16-100之间的偶数")
                                delay: 500
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: qsTr("方块种类:")
                            font.pixelSize: parent.parent.parent.parent.width * 0.02
                        }                        
                        TextField {
                            id: blockTypesField
                            text: root.blockTypes
                            Layout.fillWidth: true
                            font.pixelSize: parent.parent.parent.parent.width * 0.02
                            enabled: customRadio.checked
                            validator: IntValidator {
                                bottom: 1
                                top: 20
                            }
                            onTextChanged: {
                                if (acceptableInput && text !== "" && customRadio.checked) {
                                    var value = parseInt(text);
                                    if (value < 1) value = 1;
                                    if (value > 20) value = 20;
                                    
                                    // 确保方块种类数量不超过总方块数量的一半
                                    var maxTypes = Math.floor(parseInt(blockCountField.text) / 2);
                                    if (value > maxTypes) {
                                        value = maxTypes;
                                        text = value.toString();
                                    }
                                    
                                    settings.setBlockTypes(value);
                                }
                            }
                            
                            // 应用主题颜色
                            color: acceptableInput || text === "" ? 
                                  (currentTheme ? (enabled ? currentTheme.textColor : currentTheme.secondaryTextColor) : (enabled ? "#333333" : "#999999")) : 
                                  "red"
                            
                            background: Rectangle {
                                implicitWidth: 200
                                implicitHeight: 40
                                color: blockTypesField.enabled ? 
                                       (currentTheme ? currentTheme.secondaryBackgroundColor : "#ffffff") : 
                                       (currentTheme ? Qt.darker(currentTheme.secondaryBackgroundColor, 1.05) : "#f0f0f0")
                                border.color: blockTypesField.acceptableInput || blockTypesField.text === "" ? 
                                             (currentTheme ? currentTheme.borderColor : "#cccccc") : 
                                             "red"
                                border.width: 1
                                radius: 2
                            }
                            
                            // 添加提示文本
                            ToolTip {
                                visible: !blockTypesField.acceptableInput && blockTypesField.text.length > 0
                                text: qsTr("方块种类数必须是1-20之间的整数，且不能超过方块数量的一半")
                                delay: 500
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            id: leaderboardText
                            text: qsTr("参加排行榜")
                            font.pixelSize: parent.parent.parent.parent.width * 0.02
                            color: customRadio.checked ? (currentTheme ? currentTheme.secondaryTextColor : "#999999") : (currentTheme ? currentTheme.textColor : "#333333")
                        }                        
                        CheckBox {
                            id: joinLeaderboardCheck
                            checked: settings.getJoinLeaderboard()
                            enabled: !customRadio.checked
                            opacity: customRadio.checked ? 0.5 : 1.0
                            font.pixelSize: parent.parent.parent.parent.width * 0.02
                            onCheckedChanged: {
                                if (!customRadio.checked) {
                                    settings.setJoinLeaderboard(checked);
                                }
                            }
                            
                            // 应用主题颜色
                            contentItem: Text {
                                leftPadding: joinLeaderboardCheck.indicator.width + joinLeaderboardCheck.spacing
                                text: ""
                                font: joinLeaderboardCheck.font
                                opacity: enabled ? 1.0 : 0.3
                                color: currentTheme ? currentTheme.textColor : "#333333"
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            indicator: Rectangle {
                                implicitWidth: 20
                                implicitHeight: 20
                                x: joinLeaderboardCheck.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 3
                                border.color: currentTheme ? 
                                    (joinLeaderboardCheck.enabled ? currentTheme.borderColor : Qt.lighter(currentTheme.borderColor, 1.2)) : 
                                    (joinLeaderboardCheck.enabled ? "#999999" : "#cccccc")
                                border.width: 1
                                color: joinLeaderboardCheck.checked ? 
                                    (currentTheme ? currentTheme.accentColor : "#0078d7") : 
                                    (currentTheme ? "transparent" : "transparent")
                                
                                Text {
                                    text: "✓"
                                    color: "white"
                                    anchors.centerIn: parent
                                    font.pixelSize: 14
                                    visible: joinLeaderboardCheck.checked
                                }
                            }
                        }
                    }
                    
                    // 自定义模式下的排行榜说明
                    Text {
                        id: customModeLeaderboardNote
                        text: qsTr("*自定义模式不能参加排行榜")
                        font.pixelSize: parent.parent.parent.parent.width * 0.015
                        font.italic: true
                        color: currentTheme ? currentTheme.secondaryTextColor : "#999999"
                        visible: customRadio.checked
                        Layout.topMargin: -parent.parent.parent.parent.width * 0.01
                    }
                }
            }

            // 音效开关和音量设置
            RowLayout {
                Layout.fillWidth: true
                spacing: parent.parent.width * 0.02

                Text {
                    text: qsTr("音量:")
                    font.pixelSize: parent.parent.parent.width * 0.02
                }                
                CheckBox {
                    id: soundCheckbox
                    checked: root.isSoundEnabled
                    font.pixelSize: parent.parent.parent.width * 0.02
                    onCheckedChanged: {
                        settings.setSoundState(checked);
                    }
                    
                    // 应用主题颜色
                    contentItem: Text {
                        leftPadding: soundCheckbox.indicator.width + soundCheckbox.spacing
                        text: ""
                        font: soundCheckbox.font
                        opacity: enabled ? 1.0 : 0.3
                        color: currentTheme ? currentTheme.textColor : "#333333"
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    indicator: Rectangle {
                        implicitWidth: 20
                        implicitHeight: 20
                        x: soundCheckbox.leftPadding
                        y: parent.height / 2 - height / 2
                        radius: 3
                        border.color: currentTheme ? currentTheme.borderColor : "#999999"
                        border.width: 1
                        color: soundCheckbox.checked ? 
                            (currentTheme ? currentTheme.accentColor : "#0078d7") : 
                            (currentTheme ? "transparent" : "transparent")
                        
                        Text {
                            text: "✓"
                            color: "white"
                            anchors.centerIn: parent
                            font.pixelSize: 14
                            visible: soundCheckbox.checked
                        }
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
                    
                    // 应用主题颜色
                    background: Rectangle {
                        x: volumeSlider.leftPadding
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 4
                        width: volumeSlider.availableWidth
                        height: implicitHeight
                        radius: 2
                        color: currentTheme ? 
                               (volumeSlider.enabled ? currentTheme.borderColor : Qt.lighter(currentTheme.borderColor, 1.2)) : 
                               (volumeSlider.enabled ? "#bdbebf" : "#e6e6e6")

                        Rectangle {
                            width: volumeSlider.visualPosition * parent.width
                            height: parent.height
                            color: currentTheme ? 
                                   (volumeSlider.enabled ? currentTheme.accentColor : Qt.lighter(currentTheme.accentColor, 1.2)) : 
                                   (volumeSlider.enabled ? "#0078d7" : "#9ebce0")
                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x: volumeSlider.leftPadding + volumeSlider.visualPosition * volumeSlider.availableWidth - width / 2
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        implicitWidth: 14
                        implicitHeight: 14
                        radius: 7
                        color: volumeSlider.pressed ? 
                               (currentTheme ? Qt.darker(currentTheme.accentColor, 1.1) : "#005a9e") : 
                               (currentTheme ? currentTheme.accentColor : "#0078d7")
                        border.color: volumeSlider.pressed ? 
                                     (currentTheme ? Qt.darker(currentTheme.accentColor, 1.1) : "#005a9e") : 
                                     (currentTheme ? currentTheme.accentColor : "#0078d7")
                        opacity: volumeSlider.enabled ? 1 : 0.3
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
                    text: qsTr("窗口大小:")
                    font.pixelSize: parent.parent.parent.width * 0.02
                }                
                ComboBox {
                    id: windowSizeCombo
                    model: settings.getWindowSizeModel() // 从C++端获取窗口大小模型
                    Layout.fillWidth: true
                    font.pixelSize: parent.parent.parent.width * 0.02
                    currentIndex: {
                        // 首先获取当前屏幕大小文本
                        let currentSize = settings.getScreenSize();

                        // 获取模型中的第一个和第二个选项用于比较
                        let fullscreenOption = model[0];
                        let borderlessFullscreenOption = model[1];

                        // 比较当前屏幕大小与模型中的选项
                        if (currentSize === fullscreenOption)
                            return 0;
                        if (currentSize === borderlessFullscreenOption)
                            return 1;

                        return model.indexOf(currentSize); // 返回当前屏幕大小在模型中的索引
                    }
                    onActivated: {
                        if (currentIndex === 0) {
                            // 如果当前索引为0
                            settings.setFullscreen(true); // 设置全屏
                            settings.setBorderless(false); // 设置非无边框
                        } else if (currentIndex === 1) {
                            // 如果当前索引为1
                            settings.setBorderless(true); // 设置无边框
                            settings.setFullscreen(true); // 设置非全屏
                        } else {
                            let size = model[currentIndex].split("x"); // 将当前屏幕大小按"x"分割成数组
                            settings.setFullscreen(false); // 设置非全屏
                            settings.setBorderless(false); // 设置非无边框
                            settings.resizeWindow(parseInt(size[0]), parseInt(size[1])); // 调整窗口大小
                        }
                    }
                    // 自定义显示文本
                    displayText: settings.getScreenSize()
                    // 确保model中的每个项目都是字符串
                    textRole: ""
                    
                    // 应用主题颜色
                    contentItem: Text {
                        text: windowSizeCombo.displayText
                        font: windowSizeCombo.font
                        color: currentTheme ? currentTheme.textColor : "#333333"
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        leftPadding: 5
                    }
                    
                    background: Rectangle {
                        implicitWidth: 120
                        implicitHeight: 40
                        color: currentTheme ? currentTheme.secondaryBackgroundColor : "#f8f8f8"
                        border.color: currentTheme ? currentTheme.borderColor : "#cccccc"
                        border.width: 1
                        radius: 2
                    }
                }
            }

            // 添加主题切换选项
            RowLayout {
                Layout.fillWidth: true
                spacing: parent.parent.width * 0.02

                Text {
                    text: qsTr("主题:")
                    font.pixelSize: parent.parent.parent.width * 0.02
                }                
                ComboBox {
                    id: themeCombo
                    model: settings.getThemeList()
                    currentIndex: settings.getThemeIndex()
                    Layout.fillWidth: true
                    font.pixelSize: parent.parent.parent.width * 0.02
                    onCurrentIndexChanged: {
                        let themeName = model[currentIndex];
                        settings.setTheme(themeName);
                    }
                    
                    // 应用主题颜色
                    contentItem: Text {
                        text: themeCombo.displayText
                        font: themeCombo.font
                        color: currentTheme ? currentTheme.textColor : "#333333"
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        leftPadding: 5
                    }
                    
                    background: Rectangle {
                        implicitWidth: 120
                        implicitHeight: 40
                        color: currentTheme ? currentTheme.secondaryBackgroundColor : "#f8f8f8"
                        border.color: currentTheme ? currentTheme.borderColor : "#cccccc"
                        border.width: 1
                        radius: 2
                    }
                }
            }

            // 添加语言切换选项
            RowLayout {
                Layout.fillWidth: true
                spacing: parent.parent.width * 0.02

                Text {
                    text: qsTr("语言:")
                    font.pixelSize: parent.parent.parent.width * 0.02
                }                
                ComboBox {
                    id: languageCombo
                    model: settings.getLanguageDisplayNameList()
                    currentIndex: settings.getLanguageIndex()
                    Layout.fillWidth: true
                    font.pixelSize: parent.parent.parent.width * 0.02
                    onCurrentIndexChanged: {
                        let displayName = model[currentIndex];
                        let langCode = settings.getLanguageCode(displayName);
                        settings.setLanguage(langCode);
                    }
                    
                    // 应用主题颜色
                    contentItem: Text {
                        text: languageCombo.displayText
                        font: languageCombo.font
                        color: currentTheme ? currentTheme.textColor : "#333333"
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        leftPadding: 5
                    }
                    
                    background: Rectangle {
                        implicitWidth: 120
                        implicitHeight: 40
                        color: currentTheme ? currentTheme.secondaryBackgroundColor : "#f8f8f8"
                        border.color: currentTheme ? currentTheme.borderColor : "#cccccc"
                        border.width: 1
                        radius: 2
                    }
                }
            }

            // 添加窗口大小变化监听
            Connections {
                target: settings
                function onWindowSizeChanged() {
                    // 更新下拉列表的选项
                    windowSizeCombo.model = settings.getWindowSizeModel();
                    // 更新显示文本
                    windowSizeCombo.displayText = settings.getScreenSize();
                    // 更新当前选中的选项
                    let currentSize = settings.getScreenSize();

                    // 获取模型中的第一个和第二个选项用于比较
                    let fullscreenOption = windowSizeCombo.model[0];
                    let borderlessFullscreenOption = windowSizeCombo.model[1];

                    if (currentSize === fullscreenOption) {
                        windowSizeCombo.currentIndex = 0;
                    } else if (currentSize === borderlessFullscreenOption) {
                        windowSizeCombo.currentIndex = 1;
                    } else {
                        windowSizeCombo.currentIndex = windowSizeCombo.model.indexOf(currentSize);
                    }
                }
            }
        }
    }    // 将按钮放在 Flickable 外部，使其始终固定在底部中间
    MyButton {
        id: bottomButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        text: qsTr("确定")
        buttonWidth: contentLayout.width * 0.15
        buttonHeight: root.height * 0.08
        fontSize: width * 0.2
        normalColor: currentTheme ? currentTheme.accentColor : "#5ca9fb"
        hoverColor: currentTheme ? Qt.lighter(currentTheme.accentColor, 1.2) : "#b0d3f8"
        pressedColor: currentTheme ? Qt.darker(currentTheme.accentColor, 1.1) : "#4a90e2"
        onClicked: root.closed()
    }
}
