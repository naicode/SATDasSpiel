.pragma library

"use strict"

//cell is a Atom with may or may not be negated (aka. `A`  or  `NOT A` ) 
/* returns true if the given Atom (inklusiv prefix) is solved with the given truth value */
function isCellSolved(index, clause, state) {
	var atomCell = clause.atomAt(index),
		isTrue = state.getAtomValue(index);
	
	return (atomCell > 0 && isTrue ) || (atomCell < 0 && !isTrue);
}

/* returns true if a given  `clause` is solved with the given `state`, else false */
function isClauseSolved(clause, state) {
	if (!state.compatibleWith(clause)) throw new TypeError("given clause and state are incompatible");
	
	var idx, len = clause.atomCount;
	for (idx = 0; idx < len; ++idx) {
		if (this.isCellSolved(idx,	clause, state)) {
			return true;
		}
	}

	return false;
}

/* returns true if the formular is solved with the specific state */
function isFormularSolved(formular, state) {
	if (!state.compatibleWith(formular)) throw new TypeError("given formular and state are incompatible");
	var idx, len = formular.clauseCount;

	for (var idx = 0; idx < len; ++idx) {
		var clause = formular.clauseAt(idx);
		if (! this.isClauseSolved(clause, state)) {
			return false;
		}
	}
	return true;

}



