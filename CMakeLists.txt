cmake_minimum_required(VERSION 3.16)

project(AerospaceApplication VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Quick3D Network)
qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(AerospaceApp
    main.cpp
    assets.qrc
)

set_source_files_properties(components/Theme.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)
qt_add_qml_module(AerospaceApp
    URI Aerospace
    VERSION 1.0
    QML_FILES
        Main.qml
        components/Theme.qml
        components/GlassPanel.qml
        components/GlassButton.qml
        components/SidebarButton.qml
        components/StatCard.qml
        components/TitleBar.qml
        components/ControlButton.qml
        components/GaugeBar.qml
        components/LogView.qml
        components/LaunchStep.qml
        pages/SatelitePage.qml
        pages/LaunchPage.qml
        pages/HealthPage.qml
        pages/LogsPage.qml
)

qt_add_resources(APP_RESOURCES
    assets.qrc
)

target_sources(AerospaceApp PRIVATE ${APP_RESOURCES})

set_target_properties(AerospaceApp PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

target_link_libraries(AerospaceApp
    PRIVATE Qt6::Quick Qt6::Quick3D Qt6::Network
)

include(GNUInstallDirs)
install(TARGETS AerospaceApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)