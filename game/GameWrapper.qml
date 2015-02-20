import QtQuick 2.0

QtObject {
	id: self

	//////////////////////
	// setup properties //
	//////////////////////

	//removed style is now aviable over Config.style
	//property GameStyle style

	//////////////////////
	// state properties //
	//////////////////////

	//more or less transparent game object
	//might be js and/or c++/native based
	property var gameObject

	property int rowCount
	property int columnCount

	signal formularChanged();
	signal gameStateChanged();

	//this signal might link to places fare outside of
	//the GameGrid so pass the gameObject on
	signal gameSolved(var gameObject);

	function setGameInstance(gameObject) {
		/* todo safty checks */
		self.gameObject = gameObject;

		//assign row/columnCount for property bindings
		self.rowCount = gameObject.clauseCount;
		self.columnCount = gameObject.atomCount;

		//signal change of the "game"
		formularChanged();
	}

	function getClause(clauseIdx) {
		return self.gameObject.getClause(clauseIdx);
	}

	function toggleAtomValue(atomIdx) {
		var solved = self.gameObject.toggleAtomValue(atomIdx);
		gameStateChanged();
		if (solved) {
			gameSolved(self.gameObject);	
		}
	}
	
	//FIXME used?
	function getState() {
		var res =  self.gameObject.getState();
		return res;
	}
}

