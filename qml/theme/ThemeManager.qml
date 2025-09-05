pragma Singleton
import QtQuick

QtObject {
    // 主题标识符
    readonly property string light_theme: "Light"
    readonly property string dark_theme: "Dark"
    readonly property string pink_theme: "Pink"

    // 当前加载的主题对象
    property QtObject currentTheme: null

    // 初始化函数，根据主题名称加载对应的主题文件
    function loadTheme(themeName) {
        // console.log("加载主题:", themeName);
        var component;
        switch (themeName) {
        case light_theme:
            component = Qt.createComponent("LightTheme.qml");
            break;
        case dark_theme:
            component = Qt.createComponent("DarkTheme.qml");
            break;
        case pink_theme:
            component = Qt.createComponent("PinkTheme.qml");
            break;
        default:
            component = Qt.createComponent("LightTheme.qml");
            break;
        }

        if (component.status === Component.Ready) {
            currentTheme = component.createObject();
            // console.log("成功加载主题:", themeName);
            return currentTheme;
        } else {
            console.error("加载主题失败:", component.errorString(), "，组件状态:", component.status);
            // 尝试加载默认主题
            component = Qt.createComponent("LightTheme.qml");
            if (component.status === Component.Ready) {
                currentTheme = component.createObject();
                return currentTheme;
            }
        }

        return null;
    }
}
