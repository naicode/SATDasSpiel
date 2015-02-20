import QtQuick 2.0
import "../core/Formular.js" as FormularMod

Item {
	width: 200
	height: 200

	Formular {
		anchors.left: parent.left;
		anchors.right: parent.right;
		formular: FormularMod.Formular.createDIMACS([-1, 2, 0, 4, -5, 0, 2, -3, 0, -2, 4, 0 ])
		
		height: 40
		

		onHighlightClauseIdChanged: {
			console.log("now", highlightClauseId)
		}
	}
}
