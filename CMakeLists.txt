cmake_minimum_required(VERSION 3.16)

project(aerospaceapplication VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.11.0 REQUIRED COMPONENTS Quick Quick3D Network)
qt_standard_project_setup(REQUIRES 6.11.0)

qt_add_executable(aerospace
    main.cpp
    src/space.cpp
    include/space.h
    assets.qrc
)
target_include_directories(aerospace
    PRIVATE
        ${CMAKE_SOURCE_DIR}/include
)

set_source_files_properties(components/Theme.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(aerospace
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
        components/TelemetryData.qml
        components/RocketSegment.qml
        pages/SatelitePage.qml
        pages/LaunchPage.qml
        pages/LogsPage.qml
    SOURCES
        include/space.h
        src/space.cpp
)

qt_add_resources(APP_RESOURCES
    assets.qrc
)

target_sources(aerospace PRIVATE ${APP_RESOURCES})

set_target_properties(aerospace PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

target_link_libraries(aerospace
    PRIVATE Qt6::Quick Qt6::Quick3D Qt6::Network
)

include(GNUInstallDirs)
install(TARGETS aerospace
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)