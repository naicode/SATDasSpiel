import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3

import '../config/'
import '..'

/**
 * creates a screen with is 
 * completly transparent (optical + mouse) if
 * disabled and contains a resume and a 
 * "go to menu" button
 */

Rectangle {
	id: root

	///////////
	// setup //
	//////////
	
	signal disableRequested()
	signal menuRequested()

    property alias overlayEnabled: overlayEnabler.checked
    property alias soundEnabled: fxEnabler.checked
	property bool enabled: true

	state: enabled? "ENABLED" : "DISABLED"

	/////////////
	// content //
	/////////////
	
	opacity: 0

	color: Config.style.pause.background;

    //TODO put formular at top

	Item {
		width: Math.max(contButton.width, child2.width)
		height: contButton.height+child2.height + child2.dynGap
		
		anchors.centerIn: parent
		
		//FIXME Replace with ImageButton
		Rectangle {
			id: contButton

			//the color is a "artifact" from testing with
			//ended up producing a nice blendin/out efect 
			//so it stayed
			color: "green"

			width: Math.floor(Math.min(root.width/4, root.height/4))
			height: contButton.width

			anchors {
				horizontalCenter: parent.horizontalCenter
				top: parent.top
			}

			Image {
				anchors.fill: parent
				fillMode: Image.PreserveAspectFit
				source: "continue.svg"

			}
			MouseArea {
				anchors.fill: parent
				enabled: root.enabled
				onClicked: {
					root.disableRequested();
				}
			}
		}

		//FIXME Replace with FlatButton
		Rectangle {
			id: child2

			property int dynGap: Math.floor(contButton.height/5)

			color: Config.style.pause.buttonColor

			anchors {
				horizontalCenter: contButton.horizontalCenter
				top: contButton.bottom
				topMargin: dynGap
			}

			width: menuButton.width*1.1
			height: menuButton.height*1.2

			Text {
				id: menuButton
				anchors.centerIn: parent
                text: "↓ "+qsTr("Menu")+" ↓"
                font.pixelSize: DIP.get(20)
				color: Config.style.pause.fontColor
			}

			MouseArea {
				anchors.fill: parent
				enabled: root.enabled
				onClicked: {
					root.menuRequested()
				}
			}
		}
	}

    CheckBox {
        id: fxEnabler
        anchors {
            bottom: overlayEnabler.top
            bottomMargin: DIP.get(10)
            left: parent.left
            leftMargin: DIP.get(10)
        }
        text: qsTr("Sound")
        style: CheckBoxStyle {
            label: Text {
                text: control.text
                font {
                    pixelSize: DIP.get(16)
                }
                color: "white"
            }
        }
    }

    CheckBox {
        id: overlayEnabler
        anchors {
            bottom: parent.bottom
            bottomMargin: DIP.get(10)
            left: parent.left
            leftMargin: DIP.get(10)
        }
        text: qsTr("Formular Overlay")
        style: CheckBoxStyle {
            label: Text {
                text: control.text
                font {
                    pixelSize: DIP.get(16)
                }
                color: "white"
            }
        }
    }

    //TODO put overlay switch here

	/////////////
	// states ///
	/////////////
	
	states: [
		State {
			name: "DISABLED"
			PropertyChanges {target: root; opacity: 0 }
		},
		State {
			name: "ENABLED"
			PropertyChanges {target: root; opacity: 1}
		}
	]

	transitions: Transition {
		to: "ENABLED"; reversible: true
		NumberAnimation {
			property: "opacity"
			duration: 500
		}
	}
}
