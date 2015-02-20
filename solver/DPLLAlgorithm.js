//.pragma library

/**
 * implements a DPLL SAT Solver Algorithm
 *
 * NOT through this implementations has some optimasations it
 * has a fairly naive point of view. High optimasation can be don
 * if some of the seperated methodes are merged into each other AND
 * if it is given permission to elimenate mutiple atoms at onece and not
 * one by the time.
 *
 * NO CORRECTION, THIS IMPLEMENTATION IS BAD! But it works...
 * Why?
 *  resusing _partial is ok (strongly decreases stack usage) but resusing _clause is bad. If not resused it could be created mutch faster.
 *  it only takes on elimenation at time even if it already detected more than one!
 *  it uses {} as Set... (sets are introduced in ECMAScript 6 but this must run on 5!)
 *  bad style
 *  ...
 *
 * Note to make clear that _partial and _clause are reused objects they WILL NOT BE RETURNED anywhere,
 * I hope this brings atlast the poitn across how dangerus sutch reuse techniks are!
 */

var dpll = (function() {
    "use strict";

    //FIXME commentout after testing
    function objToStr(obj) {
        var res = "{ ";
        for (var x in obj) {
            res+=x+": "+obj[x]+", "
        }
        return res + "}"
    }

    var SetProperties = {
        "copy":{
            enumerable: false,
            value: function() {
                var x,next = {};
                Object.defineProperties(next, SetProperties);
                for (x in this) {
                    next[x] = this[x];
                }
                //console.log("cpy:", objToStr(next));
                return next;
            }
        },

        "with": {
            enumerable: false,
            value: function(choice) {
                var next = this.copy();
                if (choice < 0) {
                    next[-choice] = false;
                } else if (choice > 0) {
                    next[choice] = true;
                } else {
                    throw new TypeError("choice ["+choice+"] is not a legal choice int 0<x or 0>x")
                }
                //console.log("now with:", objToStr(next));
                return next;
            }
        }
    }

    function newDPLLEnv() {
        //reuse same scope local object to keep stack smal
        var _partial = {
            like_new_with: function(formular, res) {
                this._res = res;
                this.first_unappied = null;
                var valid,idx, len, idy, leny, clause, atom;
                this._remClauses = [];
                len = formular.length;
                for (idx = 0; idx < len; ++idx) {
                    clause = formular[idx];
                    valid = false;
                    for(atom in clause) {
                        if (atom in res) {
                            //has atom
                            if(res[atom] === clause[atom]) {
                                //console.log("atom ",atom," solved with ",res[atom]);
                                //and solved
                                valid = true;
                                if (this.first_unapplied) break;
                            }
                            //console.log("atom ",atom," unsolved with ",res[atom]);
                        } else {
                            //atome not her so its open if solved/unsolved
                            valid = true;
                            if (!this.first_unapplied) {
                                this.first_unapplied = res[atom] ? atom : -atom;
                            }

                            this._remClauses.push(clause);
                            break;
                        }
                    }
                    //all where set and false!
                    if (!valid) {
                        this.isUnsolveable = true;
                        this.isSolved = false;
                        this.clauseRemaining =0;
                        return;
                    }
                }

                this.clauseRemaining = this._remClauses.length;
                this.isSolved = (this.clauseRemaining === 0)
                this.isUnsolveable = false;

            },

            isSolved: false,
            isUnsolveable: false,
            clauseRemaining: 0,

            clauseAt: function(idx) {
                return _clause.like_new_with(this._remClauses[idx],this._res);
            }
        }

        //reuse same scope local object to keep stack small
        //FIXME dont reuse but recreate it stack overhead is smal compeared to _partial
        var _clause = {
            like_new_with: function(iclause, res) {
                this._remAtoms = [];
                var atom, idx, len = iclause.length;
                for (atom in iclause) {
                    if (atom in res) continue;
                    this._remAtoms.push(iclause[atom]?atom:-atom);

                }
                this.atomsRemaining = this._remAtoms.length;
            },

            //the idx is relativ to the REMAINING atoms!!
            atomAt: function(idx) {
                return this._remAtoms[idx];
            },

            atomsRemaining: 0
        }

        function partial_apply(formular, res) {
            //console.log("partial apply");
            _partial.like_new_with(formular, res);
        }

        //scan for singles e.g. (NOT A) --> NOT A
        //and all same e.g. (A OR B) AND (A OR C) --> A
        function scan_formular_on_partial() {
            //console.log("scan formular")
            var apperence = [],
                clause, idy, leny,
                idx, len = _partial.clauseRemaining;

            for (idx=0; idx < len; ++idx) {
                _partial.clauseAt(idx);
                leny = _clause.atomsRemaining;

                if (leny === 1) {
                    return _clause.atomAt(0);
                }

                for (idy = 0; idy < leny; ++idy) {
                    //console.log(_clause.atomAt(idy),"appered")
                    apperence[_clause.atomAt(idy)] = true;
                }
            }

            for (var x in apperence) {
                if (!(-x in apperence)) {
                    //FIXME theroreticly we could collect all same and single atome at once
                    //but for now just take one
                    //console.log("found what? "+x);
                    return x;
                }
            }
            return 0;
        }

        function _dpll(res, formular) {
            //console.log("enter inner _dpll")
            partial_apply(formular, res);

            if (_partial.isSolved) {
                //console.log("ret:", objToStr(res), res);
                return res;
            } else if (_partial.isUnsolveable) {
                //console.log("retfalse");
                return false;
            }

            var choice = scan_formular_on_partial();
            if (choice) {
                //console.log("rt-choice:",choice)
                return _dpll(res.with(choice), formular);
            } else {
                choice = _partial.first_unapplied;
                //console.log("rt-fup:",choice)
                return _dpll(res.with(choice), formular) ||
                       _dpll(res.with(-choice), formular);
            }
        }

        return function(formular) {
            //TODO make sure formular is normalized IMPORTANT!! It must have a valide AtomCount
            var res = {};
            Object.defineProperties(res, SetProperties);
            return _dpll(res, formular);
        };
    }

    function dpll(formular) {
        return newDPLLEnv()(formular);
    }

    return dpll;
})();

