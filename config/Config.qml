pragma Singleton
import QtQuick 2.0

/**
 * this Qtobject singelton contains all style settings and default
 * configuration. To change some of them you can e,g, exchange the
 * style object with a different on at load time
 */
QtObject {
	property SolverConf solver: SolverConf {
        atomCount: 12
	}

    property StorageConf storage: StorageConf {
        dbMame: "SATHeighscoreStorage"
        dbVersion: "1.0"
        dbDescription: "storage for heighscores"
        estimatedSize: 4096
    }

	property GameStyle style: GameStyle {
		background: "black"

		cell {
            //her not DIP.get! it will automaticly be used
            width: 50; height: 50

            borderSize: 0
			borderColor: "red"

			frontIcon: "front.svg"
			backIcon: "back.svg"
		}

		timeLine {
			id: tl
			pauseIcon: "pause.svg"
			continueIcon: "continue.svg"
			relaxColor: "green"
			tenseColor: "orange"
			panicColor: "red"
		}

		pause {
			//TODO other gray
			background: "#2B292E"
			buttonColor: "orange"
			fontColor: "black"
			continueIcon: tl.continueIcon
		}

		solver {
			clauseBgColor: "#213E42"
			clauseFgColor: "white"
			formularBgColor:  "#2B292E"//"#657374"
			
			atomBoardFgColor: "white"
			atomBoardBgColor: "#2B292E"
			atomBoardButtonColor: "#213E42"
			
			accent: "orange"
			accept: "green"
			deny: "red"
		}

        menu {
            seperatorColor: "#2B292E"
            buttonColor: "#213E42"
            disabledFontColor: "gray"
            fontColor: "white"
        }

	}

    property var level: jsObject({
        middle: {
          time: 20000,
          atomCount: 10,
          clauseCount: 30,
          scoreMultiplicator: 2,
          maxFillFactor: 0.75,
          label: qsTr("middle")
        },

        easy: {
            time:10000,
            atomCount: 8,
            clauseCount: 10,
            scoreMultiplicator: 0.01,
            maxFillFactor: 0.75,
            label: qsTr("easy")
        },

        hard: {
            time:20000,
            atomCount: 13,
            clauseCount: 50,
            scoreMultiplicator: 4,
            maxFillFactor: 0.75,
            label: qsTr("hard")
        },

        timerush: {
            time: 11110,
            atomCount: 10,
            clauseCount: 30,
            scoreMultiplicator: 6,
            maxFillFactor: 0.75,
            label: qsTr("timerush")
        },

        splitsecond: {
            time: 2700,
            atomCount: 8,
            clauseCount: 8,
            scoreMultiplicator: 10,
            maxFillFactor: 0.75,
            label: qsTr("splitsecond")
        }
    });

    function jsObject(x) { return x }

}

