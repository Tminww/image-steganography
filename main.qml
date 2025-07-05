import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3
import ImageEditor 1.0

ApplicationWindow {
    id: window
    width: 1200
    height: 800
    title: qsTr("Редактор бинарных изображений")
    visible: true
    color: "#f4f6f9"

    ImageEditor {
        id: imageEditor
        selectedRow: rowTextField.acceptableInput ? parseInt(rowTextField.text) : 0
        binaryPattern: patternTextField.text

        onOriginalImagePathChanged: {
            modifiedImagePath = ""
            modifiedPreview.source = ""
        }

        onModifiedImagePathChanged: {
            if (modifiedImagePath !== "") {
                modifiedPreview.source = ""
                modifiedPreview.source = "file:///" + modifiedImagePath + "?t=" + Date.now()
            }
        }
    }

    FileDialog {
        id: openDialog
        title: qsTr("Открыть изображение")
        nameFilters: ["Файлы изображений (*.png *.jpg *.jpeg *.bmp *.gif)"]
        onAccepted: {
            var path = fileUrl.toString()
            if (imageEditor.loadImage(path)) {
                console.log("Изображение успешно загружено")
                rowTextField.text = imageEditor.imageHeight > 0 ? Math.floor(imageEditor.imageHeight / 2) : "0"
                originalPreview.source = ""
                originalPreview.source = "file:///" + imageEditor.originalImagePath + "?t=" + Date.now()
            }
        }
    }

    FileDialog {
        id: saveDialog
        title: qsTr("Сохранить измененное изображение")
        nameFilters: ["Файлы PNG (*.png)"]
        selectExisting: false
        onAccepted: {
            var path = fileUrl.toString()
            if (imageEditor.saveModifiedImage(path)) {
                console.log("Изображение успешно сохранено")
            }
        }
    }

    // Полноэкранный просмотр изображения
    Rectangle {
        id: fullScreenDialog
        visible: false
        anchors.fill: parent
        color: "#1a1a1a"
        opacity: 0.95
        z: 1000

        property string imageSource: ""
        property bool isOriginal: true

        function open() {
            visible = true
        }

        function close() {
            visible = false
        }

        MouseArea {
            anchors.fill: parent
            onClicked: fullScreenDialog.close()
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 12

            // Заголовок
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                Label {
                    text: fullScreenDialog.isOriginal ? qsTr("Исходное изображение") : qsTr("Измененное изображение")
                    font.bold: true
                    font.pixelSize: 18
                    font.family: "Arial"
                    color: "#ffffff"
                    Layout.fillWidth: true
                    Layout.maximumWidth: parent.width - 50
                    wrapMode: Text.Wrap
                }
                
                Button {
                    text: "✕"
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    font.pixelSize: 16
                    background: Rectangle {
                        color: "#e63946"
                        radius: 20
                        border.color: "#ffffff"
                        border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: fullScreenDialog.close()
                    hoverEnabled: true
                    states: [
                        State {
                            name: "hovered"
                            when: parent.hovered
                            PropertyChanges { target: parent.background; color: "#f76c6c" }
                        }
                    ]
                }
            }

            // Изображение
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Image {
                    id: sourceImage
                    source: fullScreenDialog.imageSource
                    fillMode: Image.PreserveAspectFit
                    width: Math.min(parent.width, implicitWidth)
                    height: Math.min(parent.height, implicitHeight)
                    anchors.centerIn: parent
                    cache: false
                }

                Rectangle {
                    visible: imageEditor.hasImage && sourceImage.status === Image.Ready
                    x: sourceImage.x
                    y: sourceImage.y + (imageEditor.imageHeight > 0 ? (imageEditor.selectedRow * sourceImage.height / imageEditor.imageHeight) : 0)
                    width: sourceImage.width
                    height: Math.max(1, sourceImage.height / imageEditor.imageHeight)
                    color: fullScreenDialog.isOriginal ? "#e63946" : "#52b788"
                    opacity: 0.6
                    border.color: "#ffffff"
                    border.width: 1
                }
            }

            // Инструкция
            Label {
                text: qsTr("Щелкните в любом месте, чтобы закрыть")
                color: "#d3d3d3"
                font.pixelSize: 14
                font.family: "Arial"
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.Wrap
                Layout.maximumWidth: parent.width
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 15
        clip: true

        Item {
            width: window.width - 30
            height: childrenRect.height

            ColumnLayout {
                width: parent.width
                spacing: 20

                // Control Panel
                GroupBox {
                    title: qsTr("Управление")
                    Layout.fillWidth: true
                    background: Rectangle {
                        color: "#ffffff"
                        border.color: "#dfe6e9"
                        radius: 8
                    }
                    label: Label {
                        x: 15
                        text: parent.title
                        font.bold: true
                        font.pixelSize: 16
                        font.family: "Arial"
                        color: "#2d3436"
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 15

                        RowLayout {
                            spacing: 12

                            Button {
                                text: qsTr("Загрузить изображение")
                                font.pixelSize: 14
                                font.family: "Arial"
                                background: Rectangle {
                                    color: "#0984e3"
                                    radius: 6
                                    border.color: "#74b9ff"
                                    border.width: 1
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: openDialog.open()
                                hoverEnabled: true
                                states: [
                                    State {
                                        name: "hovered"
                                        when: parent.hovered
                                        PropertyChanges { target: parent.background; color: "#74b9ff" }
                                    }
                                ]
                            }

                            Button {
                                text: qsTr("Сохранить измененное изображение")
                                enabled: imageEditor.hasImage && imageEditor.modifiedImagePath !== ""
                                font.pixelSize: 14
                                font.family: "Arial"
                                background: Rectangle {
                                    color: enabled ? "#52b788" : "#b2bec3"
                                    radius: 6
                                    border.color: enabled ? "#95d5b2" : "#dfe6e9"
                                    border.width: 1
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: saveDialog.open()
                                hoverEnabled: true
                                states: [
                                    State {
                                        name: "hovered"
                                        when: parent.hovered && parent.enabled
                                        PropertyChanges { target: parent.background; color: "#95d5b2" }
                                    }
                                ]
                            }
                        }

                        RowLayout {
                            spacing: 12

                            Label {
                                text: qsTr("Строка для изменения:")
                                font.pixelSize: 14
                                font.family: "Arial"
                                color: "#2d3436"
                            }

                            TextField {
                                id: rowTextField
                                Layout.preferredWidth: 100
                                placeholderText: qsTr("Введите номер строки")
                                text: imageEditor.imageHeight > 0 ? Math.floor(imageEditor.imageHeight / 2) : "0"
                                font.pixelSize: 14
                                font.family: "Arial"
                                validator: IntValidator {
                                    bottom: 0
                                    top: imageEditor.imageHeight > 0 ? imageEditor.imageHeight - 1 : 0
                                }
                                enabled: imageEditor.hasImage
                                background: Rectangle {
                                    color: "#ffffff"
                                    border.color: rowTextField.acceptableInput ? "#dfe6e9" : "#e63946"
                                    border.width: 1
                                    radius: 4
                                }
                                color: "#2d3436"
                                onTextChanged: {
                                    if (acceptableInput) {
                                        imageEditor.setSelectedRow(parseInt(text))
                                    }
                                }
                            }

                            Label {
                                text: qsTr("/ %1").arg(imageEditor.imageHeight > 0 ? imageEditor.imageHeight - 1 : 0)
                                font.pixelSize: 14
                                font.family: "Arial"
                                color: "#636e72"
                            }
                        }

                        RowLayout {
                            spacing: 12

                            Label {
                                text: qsTr("Бинарный шаблон:")
                                font.pixelSize: 14
                                font.family: "Arial"
                                color: "#2d3436"
                            }

                            TextField {
                                id: patternTextField
                                Layout.fillWidth: true
                                placeholderText: qsTr("Введите бинарный шаблон (только 0 и 1)")
                                text: "01010101"
                                font.pixelSize: 14
                                font.family: "Arial"
                                validator: RegExpValidator { regExp: /^[01]+$/ }
                                background: Rectangle {
                                    color: "#ffffff"
                                    border.color: patternTextField.acceptableInput ? "#dfe6e9" : "#e63946"
                                    border.width: 1
                                    radius: 4
                                }
                                color: "#2d3436"
                            }
                        }

                        Button {
                            text: qsTr("Обработать изображение")
                            enabled: imageEditor.hasImage && patternTextField.text.length > 0 && rowTextField.acceptableInput
                            font.pixelSize: 14
                            font.family: "Arial"
                            background: Rectangle {
                                color: enabled ? "#0984e3" : "#b2bec3"
                                radius: 6
                                border.color: enabled ? "#74b9ff" : "#dfe6e9"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: imageEditor.processImage()
                            hoverEnabled: true
                            states: [
                                State {
                                    name: "hovered"
                                    when: parent.hovered && parent.enabled
                                    PropertyChanges { target: parent.background; color: "#74b9ff" }
                                }
                            ]
                        }
                    }
                }

                // Image Info
                GroupBox {
                    title: qsTr("Информация об изображении")
                    Layout.fillWidth: true
                    visible: imageEditor.hasImage
                    background: Rectangle {
                        color: "#ffffff"
                        border.color: "#dfe6e9"
                        radius: 8
                    }
                    label: Label {
                        x: 15
                        text: parent.title
                        font.bold: true
                        font.pixelSize: 16
                        font.family: "Arial"
                        color: "#2d3436"
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10

                        Label {
                            text: qsTr("Размеры: %1 x %2").arg(imageEditor.imageWidth).arg(imageEditor.imageHeight)
                            font.pixelSize: 14
                            font.family: "Arial"
                            color: "#2d3436"
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            Layout.maximumWidth: parent.width - 40
                        }

                        Label {
                            text: qsTr("Исходное: %1").arg(imageEditor.originalImagePath)
                            wrapMode: Text.Wrap
                            font.pixelSize: 14
                            font.family: "Arial"
                            color: "#2d3436"
                            Layout.fillWidth: true
                            Layout.maximumWidth: parent.width - 40
                        }

                        Label {
                            text: qsTr("Измененное: %1").arg(imageEditor.modifiedImagePath)
                            wrapMode: Text.Wrap
                            font.pixelSize: 14
                            font.family: "Arial"
                            color: "#2d3436"
                            Layout.fillWidth: true
                            visible: imageEditor.modifiedImagePath !== ""
                            Layout.maximumWidth: parent.width - 40
                        }
                    }
                }

                // Images Display
                RowLayout {
                    Layout.fillWidth: true
                    Layout.maximumWidth: window.width - 40
                    Layout.preferredHeight: imageEditor.hasImage ? 250 : 0
                    Layout.minimumHeight: imageEditor.hasImage ? 250 : 0
                    spacing: 20
                    visible: imageEditor.hasImage

                    // Original Image Preview
                    GroupBox {
                        title: qsTr("Исходное изображение")
                        Layout.fillWidth: true
                        Layout.maximumWidth: (window.width - 80) / 2
                        Layout.fillHeight: true
                        visible: imageEditor.hasImage
                        background: Rectangle {
                            color: "#ffffff"
                            border.color: "#dfe6e9"
                            radius: 8
                        }
                        label: Label {
                            x: 15
                            text: parent.title
                            font.bold: true
                            font.pixelSize: 16
                            font.family: "Arial"
                            color: "#2d3436"
                        }

                        Rectangle {
                            width: Math.min(300, parent.width - 30)
                            height: 200
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#f0f0f0"
                            border.color: "#dfe6e9"
                            border.width: 1
                            radius: 4

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    fullScreenDialog.imageSource = "file:///" + imageEditor.originalImagePath + "?t=" + Date.now()
                                    fullScreenDialog.isOriginal = true
                                    fullScreenDialog.open()
                                }
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                states: [
                                    State {
                                        name: "hovered"
                                        when: parent.hovered
                                        PropertyChanges { target: parent; border.color: "#74b9ff" }
                                    }
                                ]
                            }

                            Image {
                                id: originalPreview
                                source: imageEditor.originalImagePath !== "" ? "file:///" + imageEditor.originalImagePath : ""
                                fillMode: Image.PreserveAspectFit
                                anchors.fill: parent
                                anchors.margins: 10
                                cache: false

                                onStatusChanged: {
                                    if (status == Image.Error) {
                                        console.log("Ошибка загрузки исходного изображения:", source)
                                    }
                                }
                            }

                            Rectangle {
                                visible: imageEditor.hasImage && originalPreview.status === Image.Ready
                                x: 10
                                y: imageEditor.imageHeight > 0 ? 10 + (imageEditor.selectedRow * (parent.height - 20) / imageEditor.imageHeight) : 10
                                width: parent.width - 20
                                height: Math.max(1, (parent.height - 20) / imageEditor.imageHeight)
                                color: "#e63946"
                                opacity: 0.6
                                border.color: "#ffffff"
                                border.width: 1
                            }

                            Rectangle {
                                width: 30
                                height: 30
                                color: "#2d3436"
                                opacity: 0.8
                                radius: 15
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: 10

                                Text {
                                    text: "🔍"
                                    color: "#ffffff"
                                    anchors.centerIn: parent
                                    font.pixelSize: 16
                                }
                            }

                            Text {
                                text: qsTr("Щелкните для просмотра в полном размере")
                                color: "#636e72"
                                font.pixelSize: 12
                                font.family: "Arial"
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: 10
                                wrapMode: Text.Wrap
                                width: parent.width - 20
                            }
                        }
                    }

                    // Modified Image Preview
                    GroupBox {
                        title: qsTr("Измененное изображение")
                        Layout.fillWidth: true
                        Layout.maximumWidth: (window.width - 80) / 2
                        Layout.fillHeight: true
                        visible: imageEditor.modifiedImagePath !== ""
                        background: Rectangle {
                            color: "#ffffff"
                            border.color: "#dfe6e9"
                            radius: 8
                        }
                        label: Label {
                            x: 15
                            text: parent.title
                            font.bold: true
                            font.pixelSize: 16
                            font.family: "Arial"
                            color: "#2d3436"
                        }

                        Rectangle {
                            width: Math.min(300, parent.width - 30)
                            height: 200
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#f0f0f0"
                            border.color: "#dfe6e9"
                            border.width: 1
                            radius: 4

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    fullScreenDialog.imageSource = "file:///" + imageEditor.modifiedImagePath + "?t=" + Date.now()
                                    fullScreenDialog.isOriginal = false
                                    fullScreenDialog.open()
                                }
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                states: [
                                    State {
                                        name: "hovered"
                                        when: parent.hovered
                                        PropertyChanges { target: parent; border.color: "#74b9ff" }
                                    }
                                ]
                            }

                            Image {
                                id: modifiedPreview
                                source: imageEditor.modifiedImagePath !== "" ? "file:///" + imageEditor.modifiedImagePath : ""
                                fillMode: Image.PreserveAspectFit
                                anchors.fill: parent
                                anchors.margins: 10
                                cache: false

                                onStatusChanged: {
                                    if (status == Image.Error) {
                                        console.log("Ошибка загрузки измененного изображения:", source)
                                    } else if (status == Image.Ready) {
                                        console.log("Измененное изображение успешно загружено")
                                    }
                                }
                            }

                            Rectangle {
                                visible: imageEditor.hasImage && modifiedPreview.status === Image.Ready
                                x: 10
                                y: imageEditor.imageHeight > 0 ? 10 + (imageEditor.selectedRow * (parent.height - 20) / imageEditor.imageHeight) : 10
                                width: parent.width - 20
                                height: Math.max(1, (parent.height - 20) / imageEditor.imageHeight)
                                color: "#52b788"
                                opacity: 0.6
                                border.color: "#ffffff"
                                border.width: 1
                            }

                            Rectangle {
                                width: 30
                                height: 30
                                color: "#2d3436"
                                opacity: 0.8
                                radius: 15
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: 10

                                Text {
                                    text: "🔍"
                                    color: "#ffffff"
                                    anchors.centerIn: parent
                                    font.pixelSize: 16
                                }
                            }

                            Text {
                                text: qsTr("Щелкните для просмотра в полном размере")
                                color: "#636e72"
                                font.pixelSize: 12
                                font.family: "Arial"
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: 10
                                wrapMode: Text.Wrap
                                width: parent.width - 20
                            }
                        }
                    }
                }
            }
        }
    }
}