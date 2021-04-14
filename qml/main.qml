import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import Cutefish.Launcher 1.0
import FishUI 1.0 as FishUI

Item {
    id: root

    width: launcher.screenRect.width
    height: launcher.screenRect.height

    property real horizontalSpacing: root.width * 0.01 * Screen.devicePixelRatio
    property real verticalSpacing: root.height * 0.01 * Screen.devicePixelRatio

    Wallpaper {
        id: backend
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: "file://" + backend.wallpaper
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectCrop
        clip: true
        cache: true
        smooth: false
    }

    FastBlur {
        id: wallpaperBlur
        anchors.fill: parent
        source: wallpaper
        radius: 64
    }

    ColorOverlay {
        anchors.fill: parent
        source: wallpaperBlur
        color: "#000000"
        opacity: 0.6
        visible: true
    }

    LauncherModel {
        id: launcherModel
    }

    Connections {
        target: launcherModel

        function onApplicationLaunched() {
            hideLauncher()
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.leftMargin: launcher.screenAvailableRect ? launcher.screenAvailableRect.x : 0
        anchors.topMargin: launcher.screenAvailableRect ? launcher.screenAvailableRect.y + root.verticalSpacing * 2 * Screen.devicePixelRatio : 0
        anchors.rightMargin: launcher.screenRect.width - (launcher.screenAvailableRect.x + launcher.screenAvailableRect.width)
        anchors.bottomMargin: launcher.screenRect.height - (launcher.screenAvailableRect.y + launcher.screenAvailableRect.height - root.verticalSpacing)

        spacing: root.verticalSpacing * Screen.devicePixelRatio

        Item {
            id: searchItem
            Layout.fillWidth: true
            height: fontMetrics.height + FishUI.Units.largeSpacing

            TextMetrics {
                id: fontMetrics
                text: textField.placeholderText
            }

            TextField {
                id: textField
                anchors.centerIn: parent
                width: searchItem.width * 0.2
                height: parent.height

                leftPadding: FishUI.Units.largeSpacing
                rightPadding: FishUI.Units.largeSpacing

                selectByMouse: true

                placeholderText: qsTr("Search")
                wrapMode: Text.NoWrap

                color: "white"

                Label {
                    id: placeholder
                    x: textField.leftPadding
                    y: textField.topPadding
                    width: textField.width - (textField.leftPadding + textField.rightPadding)
                    height: textField.height - (textField.topPadding + textField.bottomPadding)
                    text: textField.placeholderText
                    font: textField.font
                    color: "white"
                    opacity: 0.5
                    visible: !textField.length && !textField.preeditText && (!textField.activeFocus || textField.horizontalAlignment !== Qt.AlignHCenter)
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: textField.verticalAlignment
                }

                background: Rectangle {
                    opacity: 0.2
                    radius: textField.height * 0.2
                    color: "white"
                    border.width: 0
                }

                onTextChanged: {
                    launcherModel.search(text)
                }

                Keys.onEscapePressed: hideLauncher()
            }
        }

        Item {
            id: gridItem
            Layout.fillHeight: true
            Layout.fillWidth: true

            Keys.enabled: true
            Keys.forwardTo: grid

            LauncherGridView {
                id: grid
                anchors.fill: parent
                anchors.leftMargin: gridItem.width * 0.07
                anchors.rightMargin: gridItem.width * 0.07
                Layout.alignment: Qt.AlignHCenter
                focus: true

                Keys.enabled: true
                Keys.onPressed: {
                    if (event.key === Qt.Key_Escape)
                        hideLauncher()

                    if (event.key === Qt.Key_Left ||
                            event.key === Qt.Key_Right ||
                            event.key === Qt.Key_Up ||
                            event.key === Qt.Key_Down) {
                        return
                    } else {
                        textField.forceActiveFocus()
                    }
                }

                Label {
                    anchors.centerIn: parent
                    text: qsTr("Not found")
                    font.pointSize: 30
                    color: "white"
                    visible: grid.count === 0
                }
            }
        }

        PageIndicator {
            id: pageIndicator
            count: grid.pages
            currentIndex: grid.currentPage
            onCurrentIndexChanged: grid.currentPage = currentIndex
            interactive: true
            spacing: root.horizontalSpacing / 2
            Layout.alignment: Qt.AlignHCenter

            delegate: Rectangle {
                width: 10
                height: width
                radius: width / 2
                color: index === pageIndicator.currentIndex ? "white" : Qt.darker("white")
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1

        onClicked: {
            hideLauncher()
        }
    }

    function hideLauncher() {
        launcher.hide()
    }

    Connections {
        target: launcher

        function onVisibleChanged(visible) {
            if (visible) {
                textField.focus = false
                grid.focus = true
                grid.forceActiveFocus()
            } else {
                textField.text = ""
            }
        }
    }
}
