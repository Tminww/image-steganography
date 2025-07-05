cmake_minimum_required(VERSION 3.16)
project(ImageBinaryEditor)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find Qt5 components
find_package(Qt5 REQUIRED COMPONENTS Core Widgets Qml Quick)

# Set up Qt5 automatically
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Source files
set(SOURCES
    main.cpp
    imageeditor.cpp
)

set(HEADERS
    imageeditor.h
)

# QML and resource files
set(QML_FILES
    main.qml
)

# Create resource file
qt5_add_resources(RESOURCES resources.qrc)

# Create executable
add_executable(${PROJECT_NAME}
    ${SOURCES}
    ${HEADERS}
    ${RESOURCES}
)

# Link Qt5 libraries
target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Widgets
    Qt5::Qml
    Qt5::Quick
)

# Copy QML files to build directory for development
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/main.qml ${CMAKE_CURRENT_BINARY_DIR}/main.qml COPYONLY)
