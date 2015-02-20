.pragma library
.import "DIMACS.js" as DIMACS

//does it support use struct??
"use strict";

/**
 * atoms contains all the atoms in DIMACS like Form e.g. [ 1 -4 5 ]
 * expectedCount contains the number of Atoms e.g. 5
 * with will result in filling gaps => [ 1 0 0 -4 5 ]
 * This is needed for the game Part
 */
function Clause(atoms, expectedCount) {
    var idx, len, ele, _atoms;

    //no "gaps" to fill
    if (atoms.length === expectedCount) {
        _atoms = atoms.slice(0);
    } else {
        //make sure 0 is written in gaps
        //make sure all atoms are at the correct position

        //create a "empty" atom array
        _atoms = [];
        for (idx = 0; idx < expectedCount; ++idx) {
            _atoms.push(0);
        }

        //insert all known atoms
        for (idx = 0, len = atoms.length; idx < len; ++idx) {
            ele = atoms[idx];
            _atoms[Math.abs(ele)-1] = ele;
        }
    }

	Object.defineProperties(this, {
		_atoms: {value: _atoms, configurable: true },
		atomCount: {get: function() {
			return this._atoms.length;
		}}
	});
}

Clause.prototype.toString = function() {
	return "Clause("+this._atoms+")"
};

/**
 * atomIdx := [0;len[
 * returns true if the atom with the index atomIdx
 * appears in this clause
 */
Clause.prototype.hasAtomAt = function(atomIdx) {
    //console.error("use of deprecated atomIdx access: hasAtomAt");
	return this.atomAt(atomIdx) !== 0
};
//FIXME above replace with this
Clause.prototype.hasAtom = function(atom) {
	return this.atomStateOf(atom) !== 0;
};

/**
 * atomIdx := [0;len[
 *
 * access a atom by index starting with A=1, B=2
 * returns 0   if it is not in the clause
 *         x>0 if it is in clause and not negated
 *         x<0 if it is in clause and negated
 *         where x === index
 */
Clause.prototype.atomAt = function(atomIdx) {
	var res = this._atoms[atomIdx];
	if (res === undefined) return 0;
	return res;
};
Clause.prototype.atomStateOf = function(atom) {
    return this.atomAt(Math.abs(atom)-1);
};


/**
 * set the atom Math.abs(atom) to atom
 */
Clause.prototype.setAtom = function(atom) {
	this._atoms[Math.abs(atom)-1] = atom;
}

/**
 * unsets/removes the atom Math.abs(atom)
 */
Clause.prototype.unsetAtom = function(atom) {
	//TODO range set / shrink?
	this._atoms[Math.abs(atom)-1] = 0;
}

/**
 * returns a representation containing only Atoms contained 
 * in the Clause and uses unicode math logic symbols for NOT and OR
 */
Clause.prototype.asMathString = function() {
	var idx, len = this.atomCount,
		ele, first = true,
		res = "( ";

	for (idx = 1; idx <= len; ++idx) {
		ele = this.atomStateOf(idx);
		if (ele === 0) continue;

		if (!first) {
			res += " \u2228 ";
		} else {
			first = false;
		}

		res += DIMACS.atomAsMathString(ele);
	}
	return res + " )"
}

//this is used by normalisation for the solver
Clause.prototype.findHighestAtom = function() {
    var max = 0,
        idx, len = this._atoms.length,
        atom;

    for (idx = 0; idx < len; ++idx) {
        atom = this._atoms[idx];
        if (atom > max) {
            max = atom;
        } else if (atom < -max) {
            max = -atom;
        }
    }
    return max;
}

Clause.prototype.normalizeTo = function(maxAtom) {
    //maxAtom will be === this._atoms.length after normalisation
    //see ECMAScript 5 standart if you are iritated
    //(will add undefineds, but this is ok with this class)
    this._atoms.length = maxAtom;
}



