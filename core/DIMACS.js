.pragma library

"use strict";

/**
 * the library exports folowing elements:
 *
 * DIMACS -> a scope containing functions related to the (simplified) DIMACS-CNF syntax
 * Formular -> a basic Formular class
 * Clause -> a basic Clause class
 */
function atomAsMathString(atom) {
	if (atom === 0) throw new TypeError('"end of clause" is not a valide atom')
	var rawAtom = String.fromCharCode(64+Math.abs(atom))
	if (atom < 0) {
		return "\u00AC" + rawAtom;
	} else {
		return rawAtom;
	}
}

