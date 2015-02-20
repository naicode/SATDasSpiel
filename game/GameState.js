.pragma library


//contains the "state"
"use strict"

function GameState(atomCount) {
	
	var states = [];
	for (var idx = 0; idx < atomCount; ++idx) {
		states.push(false);
	}
	Object.defineProperties(this, {
		_states: {value: states},
		atomCount: {value: atomCount}
	});
}

GameState.prototype.compatibleWith = function(other) {
	return other && this.atomCount == other.atomCount;
};

GameState.prototype._atomBoundsCheck = function(atomIdx) {
	if (atomIdx < 0 || atomIdx > this._states.length) 
		throw new TypeError("atomIdx out of bounds");
};

GameState.prototype.toggleAtomValue = function(atomIdx) {
	this._atomBoundsCheck(atomIdx);
	this._states[atomIdx] = !this._states[atomIdx];
	//FIXME put isSolved check here or have it indirectly in the "update" queue
	//- former one is slower but cleaner
	//	- use this one, it also can be speed up by row result caching!!
	//	- but the "state" has no access to the structure ...
	//		-> either give it access -> component coupling 
	//		-> or     call the check on a upper level -> bas style
	//	<-- or "unite" GameState&GameGird on JS level insted of QML-Wrappe level <- !! do this
	//
	//- laterone is fast (but not mutch)
};

//sets states form a binary bool array clamping to
//atomCount length, (needed for save function)
GameState.prototype.setAsBin = function(bin) {
    //TODO throw if atomCount > 30
    var idx, len = this.atomCount;
    for (idx = 0; idx < len; ++idx) {
        this._states[idx] = !!( bin & (1 << idx) );
    }
}

//gets as binary array (needed for save/load function
GameState.prototype.getAsBin = function() {
    //TODO throw if atomCount > 30
    var idx, len = this.atomCount,
        res = 0;
    for (idx = 0; idx < len; ++idx) {
        if (this._states[idx]) {
            res |= (1<<idx);
        }
    }
    return res;
}

GameState.prototype.getAtomValue = function(atomIdx) {
	this._atomBoundsCheck(atomIdx);
	return this._states[atomIdx];
};


function create(atomCount) {
	return new GameState(atomCount);
};
