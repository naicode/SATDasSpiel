import QtQuick 2.0

Item {
	width: 108*4
	height: 192*4

	TimeLineHeader {
		id: line

		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
		}

		//floor to prevent halve pixels leading to visual "gaps"
		height: Math.floor(parent.height / 25)

		timeDelta: 4000

		onTimeUp: {
			console.log("passed time: "+timeDelta);
		}
	}

	Component.onCompleted: {
		line.start();
	}
}
