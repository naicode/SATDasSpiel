import QtQuick 2.0
import ".."
import "../config"

Rectangle {
    id: root
    color: Config.style.solver.atomBoardBgColor

    property var scoreState
    property bool won: false

    signal continueAfter(bool won, var scoreState)

    Item {
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
        }

        implicitHeight: text.height + continueButton.height + DIP.get(20)

        Text {
            id: text

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }

            text: root.won?qsTr("You have Won"):qsTr("You lose...");
            font {
                pixelSize: DIP.get(20)
            }

            //TODO add own color slot
            color: Config.style.solver.atomBoardFgColor
        }

        FlatButton {
            id: continueButton
            anchors {
                top: text.bottom
                topMargin: DIP.get(20)
                horizontalCenter: text.horizontalCenter
            }

            label: qsTr("Continue")
            onActivated: continueAfter(root.won, root.scoreState);

            fontColor: Config.style.solver.atomBoardFgColor
            color: Config.style.solver.atomBoardButtonColor
        }
    }
}

