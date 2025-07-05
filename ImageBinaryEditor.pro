QT += core widgets qml quick

CONFIG += c++17

TARGET = ImageBinaryEditor
TEMPLATE = app

SOURCES += \
    main.cpp \
    imageeditor.cpp

HEADERS += \
    imageeditor.h

RESOURCES += \
    resources.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =
