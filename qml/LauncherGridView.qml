import QtQuick 2.12
import MeuiKit 1.0 as Meui
import Cutefish.Launcher 1.0

PageView {
    id: gridView

    property int iconSize: gridView.width * 0.1 + Meui.Units.largeSpacing * 2

    property int cellWidth: {
        var extraWidth = calcExtraSpacing(iconSize, gridView.width)
        return iconSize + extraWidth
    }

    property int cellHeight: {
        var extraHeight = calcExtraSpacing(iconSize, gridView.height);
        return iconSize + extraHeight;
    }

    columns: gridView.width / cellWidth
    rows: gridView.height / cellHeight

    model: launcherModel

    delegate: Item {
        width: cellWidth
        height: cellHeight

        LauncherGridDelegate {
            id: delegate
            anchors.fill: parent
            anchors.margins: Meui.Units.smallSpacing
        }
    }

    onWidthChanged: {
        // gridView.adaptGrid()
    }

    onHeightChanged: {
        // gridView.adaptGrid()
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

    function adaptGrid() {
        var fullWidth = gridView.width
        var fullHeight = gridView.height

        var cellSize = Math.max(144, gridView.height * 0.18)

        gridView.cellWidth = cellSize + calcExtraSpacing(cellSize, fullWidth)
        gridView.cellHeight = cellSize + calcExtraSpacing(cellSize, fullHeight)
    }
}
