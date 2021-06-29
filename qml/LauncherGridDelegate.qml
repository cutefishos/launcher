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
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Window 2.12
import FishUI 1.0 as FishUI
import Cutefish.Launcher 1.0

Item {
    id: control

    property bool dragStarted: false
    property var dragItemIndex: index

    Drag.active: iconMouseArea.drag.active
    Drag.dragType: Drag.Automatic
    Drag.supportedActions: Qt.MoveAction
    Drag.hotSpot.x: icon.width / 2
    Drag.hotSpot.y: icon.height / 2

    Drag.onDragStarted:  {
        dragStarted = true
    }

    Drag.onDragFinished: {
        dragStarted = false
    }

    DropArea {
        anchors.fill: icon
        enabled: true

        onContainsDragChanged: {
            if (drag.source)
                launcherModel.move(drag.source.dragItemIndex, control.dragItemIndex)
        }
    }

    IconItem {
        id: icon

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: label.top
        anchors.margins: FishUI.Units.largeSpacing * 2

        width: height
        height: width

        source: model.iconName
        visible: !dragStarted

        ColorOverlay {
            id: colorOverlay
            anchors.fill: icon
            source: icon
            color: "#000000"
            opacity: 0.5
            visible: iconMouseArea.pressed
        }
    }

    FishUI.DesktopMenu {
        id: _itemMenu

        MenuItem {
            text: qsTr("Open")
            onTriggered: launcherModel.launch(model.appId)
        }

        MenuItem {
            text: qsTr("Uninstall")
            onTriggered: {}
        }
    }

    MouseArea {
        id: iconMouseArea
        anchors.fill: icon
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        drag.axis: Drag.XAndYAxis

        onClicked: {
            if (mouse.button == Qt.LeftButton)
                launcherModel.launch(model.appId)
            else if (mouse.button == Qt.RightButton)
                _itemMenu.popup()
        }

        onPositionChanged: {
            if (pressed) {
                if (mouse.source !== Qt.MouseEventSynthesizedByQt) {
                    drag.target = icon
                    icon.grabToImage(function(result) {
                        control.Drag.imageSource = result.url
                    })
                } else {
                    drag.target = null
                }
            }
        }

        onReleased: {
            drag.target = null
        }
    }

    TextMetrics {
        id: fontMetrics
        font.family: label.font.family
        text: label.text
    }

    Label {
        id: label

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            margins: FishUI.Units.smallSpacing
        }

        visible: !dragStarted

        text: model.name
        elide: Text.ElideRight
        textFormat: Text.PlainText
        maximumLineCount: 2
        wrapMode: "WordWrap"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        width: parent.width - 2 * FishUI.Units.smallSpacing
        height: fontMetrics.height * 2
        color: "white"
    }
}
