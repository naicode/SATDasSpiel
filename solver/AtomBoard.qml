import QtQuick 2.0
import ".."
import "../config"
import "../core/ArrayShim.js" as SHIM
import "../core/Fn.js" as Fn

Rectangle {
	id: root

	///////////
	// setup //
	///////////
	
	//:link-out:
    //signal delPressed();
    signal atomSelected(int atom);



    //:link-inout:
	property bool inverted: false
    //:link-in:
    property int atomCount
    property color fontColor
    property color buttonColor
    property real fontSize
    property real buttonWidth
    property real buttonHeight
    property real spacingSize




	/////////////
	// content //
	/////////////

    Item {
        id: keyboard


        implicitWidth: root.buttonWidth * 3 + igrid.spacing * 2;
        implicitHeight: Math.floor((atomCount-1)/3+1) * (igrid.spacing + root.buttonHeight)

        anchors {
            centerIn: parent
        }

        Grid {
            id: igrid
            anchors.fill: parent
            spacing: root.spacingSize
            columns: 3

            Repeater {
                model: atomCount
                FlatButton {
                    width: root.buttonWidth
                    height: root.buttonHeight
                    color: root.buttonColor
                    fontColor: root.fontColor
                    radius: 10
                    font {
                        pixelSize: root.fontSize
                    }
                    label: (inverted?" \u00AC":"  ")+String.fromCharCode(index+65)+" ";
                    onActivated: {
                        var atom = index+1;
                        if (inverted) {
                            atom = -atom;
                        }
                        root.atomSelected(atom);
                    }
                }
            }
        }//END Grid
    }//END Item





}
