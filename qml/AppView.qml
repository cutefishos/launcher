import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import MeuiKit 1.0 as Meui

ListView {
    id: control

    focus: true
    snapMode: ListView.SnapToItem
    maximumFlickVelocity: 9000
    highlightMoveDuration: 100

    preferredHighlightBegin: 0
    preferredHighlightEnd: 0
    highlightRangeMode: ListView.StrictlyEnforceRange
    highlightFollowsCurrentItem: true
    cacheBuffer: control.width * control.count
    clip: true

    displaced: Transition {
        SpringAnimation {
            property: "y"
            spring: 3
            damping: 0.1
            epsilon: 0.25
            duration: 1000
        }
    }

    Component {
        id: listDelegate

        Flow {
            id: launcherGrid
            width: control.width
            height: control.height

            move: Transition {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                    properties: "x,y"
                }
            }

            Repeater {
                id: repeaterHandle

                delegate: DropArea {
                    id: delegate
                    width: control.width / 6
                    height: control.height / 4
                    opacity: 1
                }
            }
        }
    }
}
