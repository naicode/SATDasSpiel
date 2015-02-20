import QtQuick 2.0

/**
 * this component presents a "line" witch 
 * will be filled over time.
 */

//wrap into a Item so that the outer size is constant
//and it plays well with e.g. using anchors on it
Item {
	id: root
	
	property int timeDelta
	property string lineColor

	//cannot use alias, animation paused/running are not read-only
	property bool paused: animation.paused
	property bool running: animation.running

	signal timeUp()

    function resetLineFill() {
        line.width = 0;
    }

	/*starts or resumes the timer*/
	function start() {
		if (!animation.running) {
            //console.debug("time line stated");
			line.width = root.width;
			animation.start();
		}
	}

	/*pauses the timer*/
	function pause() {
        //console.debug("time line paused");
		animation.pause();
	}

	/*resume the animation */
	function resume() {
        //console.debug("time line resume");
		animation.resume();
	}

	/*reset resets the timers value to 0*/
	function cancel() {
        //console.debug("time line cancel");
		//prevent timeUp signal from beeing called
		if (animation.paused || animation.running) {
			root.state = "CANCELED"
			animation.stop();
		} 
	}

	states: [
		State {
			name: "CANCELED"
		}
	]
	
	Rectangle {
		id: line

		color: root.lineColor

		anchors {
			left: root.left
			top: root.top
			bottom: root.bottom
		}
		width: 0

		NumberAnimation {
			id: animation
			target: line
			property: "width"
			from: 0
			to: root.width
			duration: timeDelta

			onStopped: {
				if (root.state === "CANCELED") {
					root.state = "";
				} else {
					//will be called when animation ended but not when paused!
					timeUp(timeDelta);
				}
			}
		}

	}

}
