import QtQuick 2.0

Item {
	width: 200
	height: 200

	PauseScreen {
		id: pause
		z: 1
		anchors.fill: parent

		onDisabled: {
			console.log("now can continue");
		}

		onEnterMenu: {
			console.log("enter menu now pleas");
		}
	}
	
	
	Text {
		text: "TEST test TEST"
		anchors.centerIn: parent
	}
	MouseArea {
		anchors.fill: parent
		onClicked: {
			pause.enabled=true;
		}
	}

}
