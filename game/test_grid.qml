import QtQuick 2.0
import "GameObject.js" as Intern

Item {
	width: 400
	height: 800
	
	//FIXME handle GameGrids with greater size then the screen
	GameGrid {
		id: grid

		//note that anchors.fill and simular wont work like expected
		//only anchors witch are "just" positioning are suited for this 
		anchors.centerIn: parent 

		gameWrapper: GameWrapper {
			id: wrapper

			onFormularChanged: {
				grid.callOnFormularChanged();
			}
			onGameStateChanged: {
				grid.callOnGameStateChanged();
			}

			onGameSolved: {
				console.debug("game was: "+ gameObject);
				console.debug("and is now solved");
			}

		}

	}

	Component.onCompleted: {
		var formular = Intern.GameFormular.create([ 1, 2, 0, -1, 3, 0 ]);
		var state = Intern.GameState.create(formular.atomCount);
		//TODO change to "instant win" save version
		var game = Intern.GameObject.createDefault(formular, state, Intern.GameLogic);
		wrapper.setGameInstance(game);
	}

}


