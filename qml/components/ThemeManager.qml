import QtQuick

QtObject {
    id: themeManager

    // 主题类型
    readonly property string LIGHT_THEME: "light"
    readonly property string DARK_THEME: "dark"

    // 当前主题
    property string currentTheme: settings.getTheme() || LIGHT_THEME

    // 主题颜色
    property var colors: {
        "light": {
            background: "#f0f0f0",
            text: "#000000",
            primary: "#4a90e2",
            secondary: "#f8f8f8",
            accent: "#e74c3c"
        },
        "dark": {
            background: "#1a1a1a",
            text: "#ffffff",
            primary: "#3498db",
            secondary: "#2c2c2c",
            accent: "#e74c3c"
        }
    }

    // 获取当前主题的颜色
    function getColor(colorName) {
        if (!colors[currentTheme] || !colors[currentTheme][colorName]) {
            console.warn("未找到颜色:", colorName, "在主题", currentTheme)
            return "#000000" // 默认返回黑色
        }
        return colors[currentTheme][colorName]
    }

    // 切换主题
    function toggleTheme() {
        currentTheme = currentTheme === LIGHT_THEME ? DARK_THEME : LIGHT_THEME
        settings.setTheme(currentTheme)
    }

    // 监听主题变化
    Connections {
        target: settings
        function onThemeChanged() {
            currentTheme = settings.getTheme()
        }
    }
} 