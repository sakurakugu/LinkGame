cmake_minimum_required(VERSION 3.16)

project(LinkGame VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(QT_QML_GENERATE_QMLLS_INI ON)
set(CMAKE_AUTORCC ON) # 自动处理资源文件

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

# 添加外部库 toml11
include(FetchContent)
FetchContent_Declare(
  toml11
  GIT_REPOSITORY https://github.com/ToruNiina/toml11.git
  GIT_TAG        v4.4.0
)
FetchContent_MakeAvailable(toml11)

set(PROJECT_SOURCE
    main.cpp
    "./image/icon.rc" # 添加图标资源
)

set(MYQML_FILES
    qml/Main.qml
    qml/Help.qml
    qml/Settings.qml
    qml/GameOver.qml
    qml/GameBoard.qml
)

set(MYPRIVATE
    Qt6::Quick
    toml11::toml11
)

set(RESOURCES
    # 添加资源文件
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
)

# 将文件添加到Qt_Creator的列表中
qt_add_executable(appLinkGame
    ${PROJECT_SOURCE}
)

qt_add_qml_module(appLinkGame
    URI LinkGame
    VERSION 1.0
    QML_FILES
        SOURCES gamelogic.h gamelogic.cpp
        QML_FILES ${MYQML_FILES}
    RESOURCES
        ${RESOURCES}
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
