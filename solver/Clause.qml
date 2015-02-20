import QtQuick 2.0
import ".."
import "../config"

//REMEMBER DIMACS

FlatButton {
	id: root

	///////////
	// setup //
	///////////

	property var clause

	label: clause ? clause.asMathString() : "(??)"
    radius: 10

}
