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
import FishUI 1.0 as FishUI
import Cutefish.Launcher 1.0

PageView {
    id: control

    property int iconSize: 128 + FishUI.Units.largeSpacing * 2

    property int cellWidth: {
        var extraWidth = calcExtraSpacing(iconSize, control.width)
        return iconSize + extraWidth
    }

    property int cellHeight: {
        var extraHeight = calcExtraSpacing(iconSize, control.height)
        return iconSize + extraHeight
    }

    columns: control.width / cellWidth
    rows: control.height / cellHeight

    model: launcherModel

    delegate: Item {
        width: cellWidth
        height: cellHeight

        LauncherGridDelegate {
            id: delegate
            anchors.fill: parent
        }
    }

    function calcExtraSpacing(cellSize, containerSize) {
        var availableColumns = Math.floor(containerSize / cellSize);
        var extraSpacing = 0;
        if (availableColumns > 0) {
            var allColumnSize = availableColumns * cellSize;
            var extraSpace = Math.max(containerSize - allColumnSize, 0);
            extraSpacing = extraSpace / availableColumns;
        }
        return Math.floor(extraSpacing);
    }
}
