import QtQuick 2.0
import "../config"

Rectangle {
	id: flipBase

    //color: hightlight? "green" : Config.style.background
    color: Config.style.background

	/////////////////////
	//setup properties //
	/////////////////////
	
	//todo link with front: Image { source: parent.frontIcon }
	property string frontIcon
	property string backIcon

    property string alternateSymbol
    property bool blendAlernateSymbolIn: true
	//////////////////////
	// state properties //
	//////////////////////
	property bool hightlight: false
	property bool hideIcon: true

    property var heighlightSources
    property int heighlightSourceIndex: 0
	
	property bool showGoodSide: true


    //FIXME color highlighting with png images is not very good
    //but for now eneugh
    Image {
        id: bg
        anchors.fill: parent
        z: 0
        visible: flipBase.hightlight
        source: heighlightSources[heighlightSourceIndex];
    }

	Flipable {
		id: flipable
		anchors.fill: parent
        z: 1
		
		visible: !hideIcon

		front: Image {
			anchors.fill: parent
			fillMode: Image.PreserveAspectFit 	
			source: flipBase.frontIcon 
		}

		back: Image { 
			anchors.fill: parent
			fillMode: Image.PreserveAspectFit 	
			source: flipBase.backIcon 
		}


		
		transform: Rotation {
			id: rotation
			origin.x: flipBase.width/2
			origin.y: flipBase.height/2
			axis.x: 1; axis.y: 0; axis.z: 0
			angle: 0
		}

		states: State {
			name: "back"
			PropertyChanges { target: rotation; angle: 180 }
			when: !flipBase.showGoodSide
		}
		transitions: Transition {
			NumberAnimation { target: rotation; property: "angle"; duration: 250 }
		}
	}

    Rectangle {
        id: overlay
        visible: blendAlernateSymbolIn
        anchors.fill: parent
        color: "gray"
        opacity: 0.8
        z: 2
        Text {
            anchors.centerIn: parent
            text: alternateSymbol
            color: "red"
            font {
                pixelSize: parent.height*0.75
            }
        }
        Rectangle {
            height: 1
            color: "darkgray"
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
        }
        Rectangle {
            height: 1
            color: "darkgray"
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
        }
    }


}
