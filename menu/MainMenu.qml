import QtQuick 2.3
import QtQuick.Dialogs 1.2
import ".."
import "../config"

FlatMenu {
    id: root

    ///////////
    // setup //
    //////////

    seperatorColor: Config.style.menu.seperatorColor
    fillColor: Config.style.menu.buttonColor

    //:link-in:
    property int buttonPadding: DIP.get(50)

    property bool gameInBg: false

    //:link-out:
    signal requestNewGame()
    signal requestResumeGame()
    signal requestViewHeighscores()
    signal requestViewSolver()
    //signal requestViewAbaut()

    /////////////
    // content //
    /////////////


    FlatButton {
        id: newgame
        verticalPadding: buttonPadding
        fontColor: Config.style.menu.fontColor
        color: Config.style.menu.buttonColor

        font {
            pixelSize: DIP.get(20)
        }

        label: qsTr("New Game")
        onActivated: {
            if (gameInBg) {
                gameOverwriteDialog.open()
            } else {
                requestNewGame()
            }
        }

    }

    FlatButton {
        id: resume
        verticalPadding: buttonPadding
        fontColor: Config.style.menu.fontColor
        color: Config.style.menu.buttonColor
        font {
            pixelSize: DIP.get(20)
        }

        label: qsTr("Resume Game")
        onActivated: {
            if (!gameInBg) {
                console.error("called resume, but no game to resume!!");
                return;
            }
            requestResumeGame()
        }

        height: gameInBg? resume.implicitHeight : 0
        visible: gameInBg

    }

    FlatButton {
        id: highscore
        verticalPadding: buttonPadding
        fontColor: Config.style.menu.fontColor
        color: Config.style.menu.buttonColor
        font {
            pixelSize: DIP.get(20)
        }

        label: qsTr("Heighscores")
        onActivated: requestViewHeighscores()

    }

    FlatButton {
        id: solver
        verticalPadding: buttonPadding
        color: Config.style.menu.buttonColor
        font {
            pixelSize: DIP.get(20)
        }

        label: qsTr("Solve SAT")
        onActivated: requestViewSolver()
        enabled: !gameInBg
        fontColor: enabled? Config.style.menu.fontColor : Config.style.menu.disabledFontColor

    }

    FlatButton {
        id: abaut
        verticalPadding: buttonPadding
        fontColor: Config.style.menu.fontColor
        color: Config.style.menu.buttonColor
        font {
            pixelSize: DIP.get(20)
        }

        label: qsTr("Abaut")
        onActivated: abautDialog.open()

    }

    MessageDialog {
        id: gameOverwriteDialog
        title: qsTr("Oh realy?")
        text: "Ther is still a game Running!\nDo you want to discard the game?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            console.log("accepted");
            root.requestNewGame();
        }
    }

    MessageDialog {
        id: abautDialog
        title: qsTr("Abaut")
        text: qsTr("SAT Das Spiel, written by Philipp Korber")
        standardButtons: StandardButton.Ok
    }
}

