import QtQuick 2.4

Item {
	width: 320
	height: 480

	EnterOneLineDialog {
		id: dialog
		title: "DO It"
		text: "Please Enter Your Name:"
		placeHolder: "HERE"

		onLineEntered: {
			console.log("entered what?",line);
			Qt.quit(0)
		}


	}

	Component.onCompleted: {
		dialog.open()
	}
	}
