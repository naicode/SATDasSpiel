import QtQuick 2.0
import ".."
import "../core/Clause.js" as ClauseMod

Item {
	width: 200; height: 200
	
	Clause {
		anchors.centerIn: parent
		
		color: "gray"
		fontColor: "#00FF00"

		clause: new ClauseMod.Clause([-1, 4, -8], 8);
	}
}
