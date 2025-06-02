cmake_minimum_required(VERSION 3.16)

project(LinkGame VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(QT_QML_GENERATE_QMLLS_INI ON)
set(CMAKE_AUTORCC ON) # 自动处理资源文件

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml LinguistTools) # 添加 国际化翻译 组件

qt_standard_project_setup(REQUIRES 6.8)

# 添加外部库 toml11
include(FetchContent)
FetchContent_Declare(
  toml11
  GIT_REPOSITORY https://github.com/ToruNiina/toml11.git
  GIT_TAG        v4.4.0
)
FetchContent_MakeAvailable(toml11)

set(PROJECT_SOURCES
    cpp/gamelogic.cpp
    cpp/gamelogic.h
    cpp/config.cpp
    cpp/config.h
    cpp/settings.cpp
    cpp/settings.h
    cpp/language.cpp
    cpp/language.h
)

set(MYQML_COMPONENTS
    qml/components/Cell.qml
    qml/components/MyButton.qml
)

set(MYQML_FILES
    qml/Main.qml
    qml/Help.qml
    qml/Settings.qml
    qml/GameOver.qml
    qml/GameBoard.qml
    qml/Leaderboard.qml
    ${MYQML_COMPONENTS}
)



set(MYPRIVATE
    Qt6::Quick
    toml11::toml11
)

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

# 将文件添加到Qt_Creator的列表中
qt_add_executable(appLinkGame
    main.cpp
    ${PROJECT_SOURCES}
    "./image/icon.rc" # 添加图标资源
)

qt_add_qml_module(appLinkGame
    URI LinkGame
    VERSION 1.0
    QML_FILES
        SOURCES ${PROJECT_SOURCES}
        QML_FILES ${MYQML_FILES}
    RESOURCES
        ${RESOURCES}
)

# 国际化翻译
qt_add_translations(appLinkGame
    # 最终路径：qrc:/qt/qml/Translated/i18n/qml_*.qm
    RESOURCE_PREFIX /qt/qml/Translated/i18n
    TS_FILE_BASE qml
    TS_FILE_DIR i18n
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appLinkGame PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appLinkGame
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appLinkGame
    PRIVATE ${MYPRIVATE}
)

include(GNUInstallDirs)
install(TARGETS appLinkGame
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
