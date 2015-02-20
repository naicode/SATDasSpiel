import QtQuick 2.0
import "../config"
import "../core/Formular.js" as FMod
import "GameState.js" as GameState
import "GameLogic.js" as GameLogic
import "GameObject.js" as GameObject

Item {
	width: 400
	height: 800

	GameBase {
		id: gameBase
		anchors.fill: parent
		
		onMenuRequested: {
			console.log("game paused");
		}

		onGameSolved: {
			console.log("game solved");
		}

		onGameFailed: {
			console.log("game failed");
		}

		Component.onCompleted: {
			var formular = FMod.Formular.createDIMACS([ 1, 2, 0, -1, 3, 0 ]);
			var state =  GameState.create(formular.atomCount);
			var game = GameObject.createDefault(formular, state, GameLogic);
			gameBase.startNewGame(game);
		}
	}
}
