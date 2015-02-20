import QtQuick 2.0
import "../config"

Rectangle {
	id: root
    
	///////////
	// setup //
	///////////

	//called when the game wants to "leave" and enter the menu
	//this does not mean the game ends it is just paused
	signal menuRequested(var gameObject)

	//called when the game ends (is solved)
	signal gameSolved(var gameObject)

	//called when the game ende (fails)
	signal gameFailed(var gameObject)

	color: Config.style.background

	//it is QML coding convention to put inner states 
	//in a object identified by `d`, like used below.
	//Nevertheless sometimes a prefix `_` (like in python) is
	//used too
	QtObject {
		id: d
		property alias timeDelta: timeLine.timeDelta
		property alias game: grid.gameWrapper

		function callGameSolved() {
			root.cleanup();
            d.game.gameObject.scoreState.increaseScore();
			root.gameSolved(d.game.gameObject);
		}

		function callGameFailed() {
			root.cleanup();
			root.gameFailed(d.game.gameObject);
		}
		
		function callMenuRequested() {
			root.menuRequested(d.game.gameObject);
		}
	}

	///////////
	// state //
	///////////

    function startNewGame(gameObject, timeDelta) {
		d.game.setGameInstance(gameObject);
        d.timeDelta = timeDelta;
		//pauseScreen.enabled = false;
		timeLine.start()
	}

	function cleanup() {
		//to be sure it is stoped not
		//just paused
		timeLine.cancel()
        timeLine.resetFill()

		//make sure the pause screen is not visible
		//pauseScreen.enabled = false;
	}

	/////////////
	// content //
	/////////////
	
	TimeLineHeader {
		id: timeLine
		
		//floor to prevent "halve" pixels leading to visual "gaps" between components
		height: Math.floor(parent.height / 25)

		onTimeUp: {
			d.callGameFailed()
		}
		
		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
		}

	}
	
	//wrap in item to center rem. relativ to remainging space and not parent
	//also it "wraps" the pause screen
	Item {
		id: gameBody
		
		anchors {
			top: timeLine.bottom
			right: root.right
			left: root.left
			bottom: root.bottom
		}

		PauseScreen {
			id: pauseScreen
			z: 1
			anchors.fill: parent

			enabled: timeLine.paused

			onDisableRequested: {
				timeLine.resume();
			}

			onMenuRequested: {
				d.callMenuRequested();
			}
		}

		GameGrid {
			id: grid
			//just to make the intend clear that it is "behind" the pause screen
			z: 0
			
			enabled: !pauseScreen.enabled
            showAlternateSymbols: pauseScreen.overlayEnabled
            fxFeedBackEnabled: pauseScreen.soundEnabled

            anchors.fill: parent

			gameWrapper: GameWrapper {
				id: wrapper

				onFormularChanged: {
					//connect game logic with visual repr.
					grid.callOnFormularChanged();
				}

				onGameStateChanged: {
					//connect game logic with visual repr.
					grid.callOnGameStateChanged();
				}

				onGameSolved: {
					d.callGameSolved();
				}
			}

		}
	}
}

