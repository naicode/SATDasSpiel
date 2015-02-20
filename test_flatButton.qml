import QtQuick 2.0

Item {
	width: 200
	height: 200

	
	FlatButton {
		anchors.centerIn: parent
		label: "hallo"
		
		fontColor: "green"
		color: "red"

		onActivated: {
			console.log("ok button activated");
		}

		font {
			pointSize: 20
		}
	}
}
