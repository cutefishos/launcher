import QtQuick 2.12
import QtQuick.Window 2.12
import FishUI 1.0 as FishUI
import Cutefish.Launcher 1.0

PageView {
    id: gridView

    property int iconSize: gridView.width > gridView.height ? gridView.width * 0.1 + root.horizontalSpacing
                                                            : gridView.height * 0.1 + root.verticalSpacing

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
            anchors.leftMargin: root.horizontalSpacing
            anchors.rightMargin: root.horizontalSpacing
            anchors.topMargin: root.verticalSpacing
            anchors.bottomMargin: root.verticalSpacing
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
