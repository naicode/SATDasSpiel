import QtQuick 2.3

Item {
	width: 320
	height: 480

	MainMenu {
		id: mm
		anchors.fill: parent

		onRequestNewGame: {
			console.log("new game");
			mm.gameInBg = true
		}

		onRequestResumeGame: {
			console.log("resume")
			mm.gameInBg = false
		}

		onRequestViewHeighscores: {
			console.log("heighscores");
		}

		onRequestViewSolver: {
			console.log("solver");
		}
	}
}

