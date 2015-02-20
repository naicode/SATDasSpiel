import QtQuick 2.0
import "."
//TODO add opacity gray overaly if diabled
Rectangle {
	id: root

	///////////
	// setup //
	///////////
	
	signal activated();

	//bg color is root.color -> OK
	property alias fontColor: ilabel.color
	property alias label: ilabel.text
	property alias enabled: mouse.enabled

	property alias font: ilabel.font
	
    property int horizontalPadding: DIP.get(20)
    property int verticalPadding: DIP.get(10)

	implicitWidth: ilabel.width +horizontalPadding
	implicitHeight: ilabel.height +verticalPadding
	/////////////
	// content //
	/////////////
	
	Text {
		id: ilabel
		anchors.centerIn: parent
	}

	MouseArea {
		id: mouse
		anchors.fill: parent
		onClicked: {
			root.activated()
		}
	}
	
}
