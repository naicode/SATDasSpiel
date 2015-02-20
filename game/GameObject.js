.pragma library

"use strict"

function GameObject(formular, state, logic, scoreState) {
	Object.defineProperties(this, {
		formular: {value: formular, configurable: true },
		state: {value: state, configurable: true },
		logic: {value: logic, configurable: true },
        scoreState: {value: scoreState},
		//forward to internals _formular
		clauseCount: {get: function() {
			return this.formular.clauseCount;
		}},
		
		atomCount: {get: function() {
			return this.formular.atomCount;
		}}
	});
}


GameObject.createDefault = function(formular, state, logic, scoreState) {
    return new GameObject(formular, state, logic, scoreState);
};
//publish
var createDefault = GameObject.createDefault;

//changes state so that it is not to easy e.g. already solved
GameObject.createWithSaveStartValues = function(formular, state, logic, scoreState) {
    var obj = this.createDefault(formular, state, logic, scoreState);
	obj._shuffleStatesForGameStart();
	return obj;
};

//publish
var createWithSaveStartValues = GameObject.createWithSaveStartValues;

//shuffle the stati befor the game begins
//so that they are not happen to be the solution
GameObject.prototype._shuffleStatesForGameStart = function() {

    //trys until start solution is not solved
    if (this.state.atomCount < 31) {
        var state = this.state;
        var combi, len = 1 << this.state.atomCount;
        for (combi = 0; combi < len; ++combi) {
            state.setAsBin(combi);
            if (!this.logic.isFormularSolved(this.formular, state)) {
                break;
            }
        }
    } else {
        //more then 30 Atoms is realy not needed...
        console.error("due to shift limition usefull shuffelling for more than 30 Atoms is not implemented")
    }
};

GameObject.prototype.getClause = function(clauseIdx) {
	return this.formular.clauseAt(clauseIdx);
};

GameObject.prototype.toggleAtomValue = function(atomIdx) {
	this.state.toggleAtomValue(atomIdx);
	return this.logic.isFormularSolved(this.formular, this.state);
};
