import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import "."
import "./menu"
import "./game"
import "./solver"
import "./config"

//TODO Move ScorState back to /game/
import "./core/ScoreState.js" as ScoreState
import "./core/Formular.js" as FMod
import "./game/GameState.js" as GameState
import "./game/GameObject.js" as GameObject
import "./game/GameLogic.js" as GameLogic
import "./game/LevelGenerator.js" as LevelGenerator

ApplicationWindow {
    id: root

    property GameBase gameViewSlot;

    title: qsTr("SAT Das Spiel")
    visible: true
    height: 480; width: 320

    QtObject {
        id: d

        //state flow
        //initial:    gamegrid|menu
        //
        //:gamegrid
        //  -> win/lose screen
        //  -> menu
        //
        //:win/lose screen
        //  -> game
        //  -> heighscore
        //
        //:heighscore
        //  -> menu
        //
        //:menu
        //  -> heighscore
        //  <- game[1,2]
        //  -> solver
        //
        //:solver
        //  -> menu


        ////////////////////
        function goToMenu() {
            //is menu in stack?
            var menuItem = viewStack.find(function(item) { return item.objectName === "menu" });
            if (menuItem) {
                //yes -> go back to menu
                viewStack.pop(menuItem);
            } else {
                if (viewStack.depth > 1) {
                    //no and not current == game -> replace menu with current
                    viewStack.push({item: menu, replace: true});
                } else {
                    //no and current == game -> add menu on stack
                    viewStack.push(menu);
                }
            }
        }

        function goToNewGame() {
            root.gameViewSlot.cleanup();
            setupNewGame(arguments[0]);
        }
        function goToResumeGame() {
            goToGame();
        }
        function goToGame() {
            viewStack.pop(root.gameViewSlot);
        }

        function setupNewGame() {
            //optional some if won next level else undefined
            var continueWithScoreState = arguments[0];

            //TODO replace this defaulting with difficulty selection dialog
            if (!continueWithScoreState) {
                difficultyChoice.open();
            } else {
                continueWithScoreState.increaseLevelCount();
                _setupNewGame_part2(continueWithScoreState);
            }


        }
        function _setupNewGame_part2(continueWithScoreState) {
            var config = Config.level[continueWithScoreState.getGametype()];
            var rawLevel = LevelGenerator.generateLevel(config);
            var formular = FMod.Formular.createFromDIMACSArray2D(rawLevel);

            var state =  GameState.create(formular.atomCount);
            var game = GameObject.createWithSaveStartValues(formular, state, GameLogic, continueWithScoreState);
            root.gameViewSlot.startNewGame(game, config.time);
            goToGame();
        }
    }

    Dialog {
        id: difficultyChoice

        standardButtons: StandardButton.Ok

        Item {
            anchors {
                left: parent.left
                horizontalCenter: parent.horizontalCenter
            }
            width: Math.max(msg.width, parent.width)
            height: msg.height + combochoice.height + combochoice.anchors.topMargin

            Text {
                id: msg
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                text: qsTr("Chose game difficulty:");
            }

            ComboBox {
                id: combochoice
                anchors {
                    top: msg.bottom
                    topMargin: DIP.get(10)
                    left:  parent.left
                    right: parent.right
                }

                property var rawModel: Object.keys(Config.level)
                currentIndex: rawModel.indexOf("middle");
                //TODO add tr for model in config
                model: rawModel.map(function(x){ return Config.level[x].label; });
                function getDifficulty() {
                    return rawModel[currentIndex];
                }
            }
        }



        onAccepted: {
            var difi = combochoice.getDifficulty()
            var scoreState = new ScoreState.ScoreState({
                multiplicator: Config.level[difi].scoreMultiplicator,
                type: difi
            });
            d._setupNewGame_part2(scoreState);
        }
    }

    //TODO replace StackView with custom SateMaschinView, i noticed to late
    //that StackView is mutch less suited for the needed task then I thought!!
    //now I don't have time to replace it
    StackView {
        id: viewStack
        initialItem: game

        Component.onCompleted: {
            //TODO push menu! -> neeeded so that game can stay in bg
            root.gameViewSlot = viewStack.currentItem;
            viewStack.push(menu);
        }
    }

    Component {
        id: game

        GameBase {
            onMenuRequested: {
                viewStack.push(menu);
                var menuItem = viewStack.currentItem
                menuItem.gameInBg = true;
            }
            onGameFailed: {
                 enterWinLoseScreen(false, gameObject);
            }
            onGameSolved: {
                enterWinLoseScreen(true, gameObject);
            }
            function enterWinLoseScreen(won, gameObject) {
                //TODO disable game?
                viewStack.push(winlosescreen);
                var wlItem = viewStack.currentItem
                wlItem.won = won;
                wlItem.scoreState = gameObject.scoreState;
            }
        }
    }

    Component {
        id: menu
        //:menu
        //  -> heighscore
        //  <- game[1,2]
        //  -> solver
        MainMenu {
            objectName:  "menu";

            onRequestNewGame: {
                d.goToNewGame();
            }
            onRequestResumeGame: {
                d.goToResumeGame();
            }

            onRequestViewHeighscores: {
                viewStack.push(heighscores)
            }
            onRequestViewSolver: {
                viewStack.push(solver)
            }
        }
    }

    Component {
        id: winlosescreen
        //:win/lose screen
        //  -> game
        //  -> heighscore
        WinloseScreen {
            onContinueAfter: {
                //TODO get score here somhow
                var scoreState = this.scoreState;
                //FIXME remove savty check later?
                if (!scoreState) {
                    throw new TypeError("scoreState is not set");
                }

                if (won) {
                    d.goToNewGame(scoreState);
                } else {
                    viewStack.push({item: heighscores, replace:true});
                    var hitem = viewStack.currentItem;
                    hitem.optionalNewHeighscore(scoreState.asPOD());
                }
            }
        }
    }


    Component {
        id: heighscores
        //:heighscore
        //  -> menu

        Highscores  {
            onRequestedLeaveHighscoreView: d.goToMenu();
        }
    }
    Component {
        id: solver
        FormularCreator {
            onRequestMenu: d.goToMenu();
            onRequestSolveing: {
                viewStack.push(solvingView)
                var solving = viewStack.currentItem;
                solving.toSolve = formular;
            }
        }
    }

    Component {
        id: solvingView
        DPLLSolver {
            onRequestBack: viewStack.pop();
        }
    }

    Component.onCompleted: {
        //SETUP DIP
        //TODO
        DIP.upperBoundZoomSpace = 4000;
        //SETUP DIP BINDINGS
        //binding is needed because the density might change if the
        //app is moved to a different screen
        DIP.pixelWrapedDensity = Qt.binding(function() {
            //see DIP for doc
            return Screen.pixelDensity*25.4/160;
        });
        DIP.screenWidth = Qt.binding(function() {
            //see DIP for doc
            return width//Screen.width
        });
        DIP.screenHeight = Qt.binding(function() {
            //see DIP for doc
            return height//Screen.height;
        });
    }
}
