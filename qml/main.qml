/*
 * Copyright (C) 2021 CutefishOS.
 *
 * Author:     revenmartin <revenmartin@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

import Cutefish.Launcher 1.0
import FishUI 1.0 as FishUI

Item {
    id: root

    width: launcher.screenRect.width
    height: launcher.screenRect.height

    property real horizontalSpacing: launcher.screenRect.width * 0.01
    property real verticalSpacing: launcher.screenRect.height * 0.01
    property real maxSpacing: horizontalSpacing > verticalSpacing ? horizontalSpacing : verticalSpacing
    property bool launcherVisible: launcher.visible

    Wallpaper {
        id: backend
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: "file://" + backend.wallpaper
        sourceSize: Qt.size(launcher.screenRect.width,
                            launcher.screenRect.height)
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: false
        smooth: false
    }

    FastBlur {
        id: wallpaperBlur
        anchors.fill: parent
        source: wallpaper
        cached: true
        radius: root.launcherVisible ? 72 : 0
        visible: true

        Behavior on radius {
            NumberAnimation {
                duration: 300
            }
        }
    }

    ColorOverlay {
        anchors.fill: parent
        source: wallpaperBlur
        color: "#000000"
        visible: true
        opacity: launcherVisible ? 0.4 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }
        }
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
        anchors.topMargin: launcher.screenAvailableRect ? launcher.screenAvailableRect.y + root.maxSpacing * 2 : 0
        anchors.rightMargin: launcher.screenRect.width - (launcher.screenAvailableRect.x + launcher.screenAvailableRect.width)
        anchors.bottomMargin: launcher.screenRect.height - (launcher.screenAvailableRect.y + launcher.screenAvailableRect.height - root.verticalSpacing)

        // spacing: root.verticalSpacing
        spacing: 0

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
                    opacity: 0.65
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

                Timer {
                    id: searchTimer
                    interval: 500
                    repeat: false
                    onTriggered: launcherModel.search(textField.text)
                }

                onTextChanged: {
                    if (textField.text === "") {
                        // Switch directly to normal mode
                        launcherModel.search("")
                    } else {
                        searchTimer.start()
                    }
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

                scale: root.launcherVisible ? 1.0 : 1.05
                Behavior on scale {
                    NumberAnimation {
                        duration: 250
                    }
                }

                opacity: root.launcherVisible ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 100
                    }
                }

                Keys.enabled: true
                Keys.onPressed: {
                    if (event.key === Qt.Key_Escape)
                        hideLauncher()

                    if (event.key === Qt.Key_Left ||
                            event.key === Qt.Key_Right ||
                            event.key === Qt.Key_Up ||
                            event.key === Qt.Key_Down) {
                        return
                    }

                    // First input text
                    if ((event.key >= Qt.Key_A && event.key <= Qt.Key_Z) ||
                            event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                        textField.forceActiveFocus()
                        textField.text = event.text
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
            spacing: FishUI.Units.largeSpacing
            Layout.alignment: Qt.AlignHCenter

            delegate: Rectangle {
                width: 10
                height: width
                radius: width / 2
                color: index === pageIndicator.currentIndex ? "white" : Qt.darker("white", 1.8)
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
