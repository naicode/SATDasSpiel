.pragma library
.import "Clause.js" as ClauseModule 
.import "ArrayShim.js" as SHIM

"use strict";

var Clause = ClauseModule.Clause;

/**
 * creates a Formular based on a array containing a DIMACS like CNF 
 * e.g.  [ 1 -3 0 2 0 -1 2 0 ] 
 * and converts it into a internal Structur (a list of Clause's)
 */
function Formular(formularGrid) {
	Object.defineProperties(this, {
		clauseCount: {get:function() {
			return this._grid.length;
		}},

		atomCount: {get:function() {
			//not clause.atomCout is independedn from the actual count of atoms in the clause
			//assume creation was correct -> atomcount on each clause is same
			if (this.clauseCount === 0) return 0;
			return this._grid[0].atomCount;
		}},
		_grid: { value: formularGrid, configurable: true }
	});
}
Formular.create = function create(formularDIMACS) {
	return new Formular(formularDIMACS);
};

Formular.createFromDIMACSArray2D = function(array2d) {
    if (array2d.length === 0) return new Formular([]);
    //FIXME assums that array2d is well formed!!
    var max = array2d[0].length;
    var res = [];
    return  new Formular(array2d.map(function(clause) {
        return new Clause(clause, max);
    }));
}

Formular.createDIMACS = function(formularDIMACS) {
	if (!(formularDIMACS instanceof Array)) throw new TypeError("expected formular to be an array|");
	//FIXME split up in helper functions

	//converts the formular in DIMACS Formt to a format with subarrays for each klausel
	//:> [ 1 -3 0 2 0 -1 2 0 ] => [ [ 1 -3 ] [ 2 ] [ -1 2 ] ]
	//FIMXE make the later one optional
	//it also collects meta infos to check if ther is no usused Atom e.g. [ 1 4 0 1 3 0 ] is not valide, 2 is missing
	var grid = [];
	var partialClause = [];
	var max = 0;
	var checked = [];
	formularDIMACS.forEach(function(element) {
		if (element === 0) {
			grid.push(partialClause);
			partialClause = [];
		} else {
			var abse = Math.abs(element);
			if (abse > max) {
				max = abse;
			}
			checked[abse-1] = true;
			partialClause.push(element);
		}
	});
	if (partialClause.length) throw new Error("missing tailing 0 to close last clause");

	//do the gap check
	for (var idx = 0; idx < max; ++idx) {
		//fixme just move others "down"
		if (!checked[idx]) throw new Error("each Atom beggining form A/1 to N/X has to exist (for this game!)");
	}
	
	//now convert to Clause's
	grid = grid.map(function(ele) {
		return new Clause(ele, max); 
	});
	
	return new Formular(grid);
}


Formular.prototype.clauseAt = function(clauseIndex) {
	if (clauseIndex >= this.clauseCount || clauseIndex < 0) {
		throw new TypeError("clause Index("+clauseIndex+") out of range [0;"+this.clauseCount+"]");
	}
	return this._grid[clauseIndex];
};

Formular.prototype.extendWith = function(clause) {
	this._grid.push(clause);
}

Formular.prototype.reduceAt = function(idx) {
	var len = this._grid.length
	for(; idx < len-1; ++idx) {
		this._grid[idx] = this._grid[idx+1]
	}
	//se ECMAScript 5 standart why to mess with length to truncat
	this._grid.length -= 1
}

/**
 * this function normalizes a formular with clauses with different
 * atomCount values (Note atomCount !== number of atoms VISIBLE in Clause)
 */
Formular.prototype.normalize = function() {
    var max = 0;
    this._grid.forEach(function(clause) {
        var hatom = clause.findHighestAtom();
        if (hatom > max) max = hatom;
    });
    this._grid.forEach(function(clause) {
        clause.normalizeTo(max);
    });
};

Formular.prototype.toString = function() {
	var idx, len = this._grid.length,
		res = "Formular(";

	for (idx = 0; idx < len; ++idx) {
		if (idx != 0) {
			res += ", ";
		}
		res += this._grid[idx].toString()
	}
	return res + ")";
}

Formular.prototype.asMathString = function() {
    var res = "";
    this._grid.forEach(function(clause, idx) {
        if (idx !== 0) {
            res += " \u2227 ";
        }
        res += clause.asMathString();
    });
    return res;
}

Formular.prototype.getContainingAtoms = function() {
    var atoms = {};
    this._grid.forEach(function(clause) {
        //FIXME bad style
        clause._atoms.forEach(function(atom) {
            if (atom && atom != 0) {
                if (atom > 0) atoms[atom] = true
                else atoms[-atom] = true
            }
        });
    });
    return Object.keys(atoms);
}
