import QtQuick 2.0

Item {
	id: root
	width: 400
	height: 400

	ListModel {
		id: lmodel
	}
	Component.onCompleted: {
		lmodel.append({
			0: 'affen',
			1: 'raffen'
		});
		lmodel.append({
			0: 'cobalt',
			1: 'sobalt'
		});
	}

	CustomTable {
		anchors.centerIn: parent
		model: lmodel
		cellWidth: 50
		cellHeight: 50
		horizontalSpacing: 0
		verticalSpacing: 30
		columnCount: 2
		delegate: Rectangle {
			property var cellData: parent.cellData
			color: "green"
			border {
				width: 1
				color: "red"
			}
			Text {
				anchors.centerIn: parent
				text: cellData
			}
		}
	}
}
