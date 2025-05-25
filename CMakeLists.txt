cmake_minimum_required(VERSION 3.16)

project(LinkGame VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(QT_QML_GENERATE_QMLLS_INI ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)


qt_add_executable(appLinkGame
    main.cpp
    "./image/icon.rc"   # 添加图标资源
)

qt_add_qml_module(appLinkGame
    URI LinkGame
    VERSION 1.0
    QML_FILES
        SOURCES gamelogic.h gamelogic.cpp
        QML_FILES qml/MainMenu.qml qml/GameWindow.qml
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
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appLinkGame
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
