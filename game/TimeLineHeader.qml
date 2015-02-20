import QtQuick 2.0

//FIXME insert bug nummer
//fix bug QTBUG-?? 
import "../config"

//use rectangle so that it can have a background color
Rectangle {
	id: root

	///////////
	// setup //
	///////////
	
	signal timeUp(int timeDelta)

	property int timeDelta

	color: Config.style.background

	///////////
	// state //
	///////////

	property bool running: lineRelax.running || lineTense.running || linePanic.running
	property bool paused: lineRelax.paused || lineTense.paused || linePanic.paused

	function start() {
		if (!running) {
			lineRelax.start();
		}
	}

	function cancel() {
		lineRelax.cancel();
		lineTense.cancel();
		linePanic.cancel();
	}

	function pause() {
		if (lineRelax.running) {
			lineRelax.pause();
		} else if (lineTense.running) {
			lineTense.pause();
		} else if (linePanic.running) {
			linePanic.pause();
		} else {
			console.error("cannot pause TimeLine(s) if not running");
			return;
		}
	}

    function resetFill() {
        lineRelax.resetLineFill();
        lineTense.resetLineFill();
        linePanic.resetLineFill();
    }

	function resume() {
		lineRelax.resume();
		lineTense.resume();
		linePanic.resume();
	}

	/////////////
	// content //
	/////////////
	
	MouseArea {
		anchors.fill: parent
		onClicked: {
			if (root.paused) {
				root.resume()
			} else {
				root.pause()
			}
		}
		
	}

	Image {
		id: pauseButton

		anchors {
			top: root.top
			bottom: root.bottom 
			left: root.left
		}
		width: height

		fillMode: Image.PreserveAspectCrop

		//FIXME check if the is VERY imperformant (due too reloading complet images every switch) or intelligent
		source: root.paused ? Config.style.timeLine.continueIcon : Config.style.timeLine.pauseIcon 
	}
	
	Item {
		anchors {
			top: root.top
			bottom: root.bottom
			left: pauseButton.right
			right: root.right
		}

		TimeLine {
			id: lineRelax
			anchors.fill: parent
			z: 1

			timeDelta: root.timeDelta/3
			lineColor: Config.style.timeLine.relaxColor

			onTimeUp: {
				lineTense.start()
			}
		}

		TimeLine {
			id: lineTense
			anchors.fill: parent
			z: 2

			timeDelta: root.timeDelta/3
			lineColor: Config.style.timeLine.tenseColor

			onTimeUp: {
				linePanic.start()
			}
		}

		TimeLine {
			id: linePanic
			anchors.fill: parent
			lineColor: Config.style.timeLine.panicColor

			z: 3

			timeDelta: root.timeDelta/3

			onTimeUp: {
				root.timeUp(root.timeDelta);
			}
		}
	}
}

