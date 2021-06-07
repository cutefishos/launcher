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
import Cutefish.Launcher 1.0

Item {
    id: pagedGrid

    property var model

    property int rows
    property int columns

    property Component delegate

    readonly property var count: model.count

    readonly property int pageCount: rows * columns
    readonly property alias pages: pageView.count
    property alias currentPage: pageView.currentIndex

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true

        onWheel: {
            if (wheel.angleDelta.y > 0)
                pageView.decrementCurrentIndex();
            else
                pageView.incrementCurrentIndex();
        }
    }

    ListView {
        id: pageView
        anchors.fill: parent

        orientation: Qt.Horizontal
        snapMode: ListView.SnapOneItem
        highlightFollowsCurrentItem: true
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: 500
        currentIndex: 0

        maximumFlickVelocity: 9000

        preferredHighlightBegin: 0
        preferredHighlightEnd: 0

        cacheBuffer: pageView.width * pageView.count
        boundsBehavior: Flickable.DragOverBounds
        clip: true

//        // Blank area
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: launcher.hideWindow()
        }

        model: Math.ceil(pagedGrid.count / pageCount)
        delegate: pageDelegate
    }

    Component {
        id: pageDelegate

        Flow {
            id: _page
            width: pagedGrid.width
            height: pagedGrid.height
            // columns: pagedGrid.columns

            readonly property int pageIndex: index

//            move: Transition {
//                NumberAnimation {
//                    duration: 300
//                    easing.type: Easing.InOutQuad
//                    properties: "x,y"
//                }
//            }

            Repeater {
                model: PageModel {
                    id: _pageModel
                    sourceModel: pagedGrid.model
                    startIndex: pageCount * pageIndex
                    limitCount: pageCount
                }

                delegate: pagedGrid.delegate
            }
        }
    }
}
