import QtQuick 2.0

Item {
	width: 250; height: 250

	AtomBoard {
		anchors.fill: parent

		onDelPressed: {
			console.log("dell pressed")
		}
		onAtomSelected: {
			console.log("add atom: ", atom);
		}
	}
}
