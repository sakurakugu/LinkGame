cmake_minimum_required(VERSION 3.16)

project(LinkGame 
    VERSION 1.0.0
    DESCRIPTION "连连看小游戏"
    HOMEPAGE_URL "https://github.com/sakurakugu/LinkGame"
    LANGUAGES CXX)

# 设置C++标准和其他编译选项
set(CMAKE_CXX_STANDARD 23)                 # 使用 C++23 标准
set(CMAKE_CXX_STANDARD_REQUIRED ON)        # 强制要求 C++23
set(CMAKE_CXX_EXTENSIONS OFF)              # 禁用编译器扩展，确保可移植性
set(QT_QML_GENERATE_QMLLS_INI ON)          # 生成 qmlls.ini 文件

# Qt 自动化工具
set(CMAKE_AUTORCC ON)                      # 自动处理资源文件
set(CMAKE_AUTOMOC ON)                      # 自动处理 MOC
set(CMAKE_AUTOUIC ON)                      # 自动处理 UIC

# 设置待包含的 Qt 组件
set(QT_COMPONENTS 
    Core
    Gui
    Quick
    Qml
    LinguistTools
)

# 设置项目的源文件
set(PROJECT_SOURCES
    cpp/gamelogic.cpp
    cpp/gamelogic.h
    cpp/config.cpp
    cpp/config.h
    cpp/settings.cpp
    cpp/settings.h
    cpp/language.cpp
    cpp/language.h
    cpp/logger.cpp
    cpp/logger.h
)

# 设置 QML 文件的路径
set(MYQML_COMPONENTS
    qml/components/Cell.qml
    qml/components/MyButton.qml
)

# 设置主题相关的 QML 文件
set(MYQML_THEME
    qml/theme/ThemeManager.qml
    qml/theme/LightTheme.qml
    qml/theme/DarkTheme.qml
    qml/theme/PinkTheme.qml
)

# 设置 QML 文件的路径
set(MYQML_FILES
    qml/Main.qml
    qml/Help.qml
    qml/Settings.qml
    qml/GameOver.qml
    qml/GameBoard.qml
    qml/Leaderboard.qml
    ${MYQML_COMPONENTS}
    ${MYQML_THEME}
)

# 设置国际化翻译文件的路径
set(MYI18N_FILES
    i18n/qml_en.ts
    i18n/qml_zh_CN.ts
    i18n/qml_ja.ts
)

# 设置私有库变量 PRIVATE_LIBRARIES, 储存需要链接的库
set(PRIVATE_LIBRARIES
    Qt6::Quick
    toml11::toml11
)

# 设置资源文件的路径
set(RESOURCES
    # 添加资源文件
    # 图标
    image/fruits/1.svg
    image/fruits/2.svg
    image/fruits/3.svg
    image/fruits/4.svg
    image/fruits/5.svg
    image/fruits/6.svg
    image/fruits/7.svg
    image/fruits/8.svg
    image/fruits/9.svg
    image/fruits/10.svg
    image/fruits/11.svg
    image/fruits/12.svg
    image/fruits/13.svg
    image/fruits/14.svg
    image/fruits/15.svg
    image/fruits/16.svg
    image/fruits/17.svg
    image/fruits/18.svg
    image/fruits/19.svg
    image/fruits/20.svg
    # 音乐
    music/sound_effect.mp3
)

# 安装路径配置
if (WIN32)
set(CMAKE_INSTALL_PREFIX "C:/Software/Apps/LinkGame" CACHE PATH "安装路径前缀" FORCE)
endif()

# 查找所有需要的Qt组件
find_package(Qt6 REQUIRED ${QT_COMPONENTS})

qt_standard_project_setup(REQUIRES 6.9)

# 添加外部库 toml11
include(FetchContent)
FetchContent_Declare(
    toml11
    GIT_REPOSITORY https://github.com/ToruNiina/toml11.git
    GIT_TAG        v4.4.0
)
FetchContent_MakeAvailable(toml11)

# 将文件添加到Qt_Creator的列表中
qt_add_executable(appLinkGame
    main.cpp
    ${PROJECT_SOURCES}
    "./image/icon.rc" # 添加图标资源
)

# 添加 QML 文件到项目中
qt_add_qml_module(appLinkGame
    URI LinkGame                    # QML 模块 URI
    VERSION 1.0                     # 模块版本
    QML_FILES ${MYQML_FILES}        # QML 文件列表
    SOURCES ${PROJECT_SOURCES}      # C++ 源文件
    RESOURCES ${RESOURCES}          # 资源文件  
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/LinkGame  # 输出目录
)

# 国际化翻译
qt_add_translations(appLinkGame
    # 最终路径：qrc:/qt/qml/Translated/i18n/qml_*.qm
    RESOURCE_PREFIX /qt/qml/Translated/i18n
    TS_FILES ${MYI18N_FILES}
)

# 设置目标属性
set_target_properties(appLinkGame PROPERTIES
    OUTPUT_NAME "LinkGame"            # 输出文件名
    DEBUG_POSTFIX "_debug"              # Debug 版本后缀
)

# 平台特定配置
# Windows 调试配置：在 VSCode + Ninja + Debug 模式下显示控制台
if(WIN32 AND "${CMAKE_GENERATOR}" MATCHES "Ninja" AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(WIN32_EXEC_FLAG FALSE)          # 显示控制台窗口，便于调试
else()
    set(WIN32_EXEC_FLAG TRUE)           # 隐藏控制台窗口
endif()
# Qt 在 iOS 上会自动设置 MACOSX_BUNDLE_GUI_IDENTIFIER
# 如果你正在为 iOS 或 macOS 开发，你应该考虑手动设置一个明确的、固定的 bundle 标识符。
set_target_properties(appLinkGame PROPERTIES
    # macOS Bundle 配置
    MACOSX_BUNDLE_GUI_IDENTIFIER com.sakurakugu.linkgame
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE

    # Windows 可执行文件配置
    WIN32_EXECUTABLE ${WIN32_EXEC_FLAG}

    # 通用属性
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

# 设置编译选项
target_link_libraries(appLinkGame
    PRIVATE ${PRIVATE_LIBRARIES}
)

# 安装配置
include(GNUInstallDirs)
install(TARGETS appLinkGame
    BUNDLE DESTINATION .                                    # macOS Bundle 安装位置
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}             # 可执行文件安装位置
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}             # 库文件安装位置
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}             # 静态库安装位置
)

# 构建信息输出
message(STATUS "====== LinkGame 构建配置 =====")
message(STATUS "项目版本: ${PROJECT_VERSION}")
message(STATUS "构建类型: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ 标准: ${CMAKE_CXX_STANDARD}")
message(STATUS "Qt6 版本: ${Qt6_VERSION}")
message(STATUS "安装前缀: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "=============================")
