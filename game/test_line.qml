import QtQuick 2.0

Item {
	width: 300; height: 300

	TimeLine {
		id: tl
		anchors.fill: parent

		timeDelta: 3000
		lineColor: "red"

		onTimeUp: {
			console.log("timeUp after: "+timeDelta);
			tl.reset();
			tl.start();
		}
	}

	MouseArea {
		anchors.fill: parent
		onClicked: {
			if (tl.paused || tl.running) {
				tl.cancel();
			} else {
				tl.start();
			}
			/*if (tl.paused) {
				tl.start();
			} else {
				tl.pause();
			}*/
		}
	}

	Component.onCompleted: {
		tl.start()
	}

}
