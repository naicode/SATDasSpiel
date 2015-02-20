.pragma library
.import "../core/ArrayShim.js" as SHIM
.import "../core/Fn.js" as Fn

"use strict";

var generateLevel = (function() {
    function _generateSolution(atomCount) {
        return Array.fill(atomCount, Fn.randomBool);
    }

    function _generateEmptyGrid(atomCount, clauseCount) {
        return Array.fill(clauseCount, function() {
            return Array.fill(atomCount,Fn.returning(0));
        });
    }

    function _toAtom(atomIdx) {
        //atomIdx is Math.abs(atomInDIMACS)-1
        return atomIdx+1;
    }

    function _toNegAtom(atomIdx) {
        //atomIdx is Math.abs(atomInDIMACS)-1
        return -(atomIdx+1);
    }


    function _minimalFillGrid(grid, solution, indexes) {
        //shuffle or else every atomCount values would repeat (but not in order)
        indexes.shuffle();

        //iter over the fullIndexes
        //-> means iterate over clauses and the choices done for them
        var idx, atomIdx, len = indexes.length;
        for (idx = 0; idx < len; ++idx) {
            //whitch atom is important for this clause
            atomIdx = indexes[idx];
            //choose atom depending on solution
            grid[idx][atomIdx] = solution[atomIdx] ? _toAtom(atomIdx) : _toNegAtom(atomIdx);
        }
    }

    function _fillGridUp(grid, atomCount, maxFillFactor, indexes) {
        var maxFill = atomCount*maxFillFactor,
            idy, idx, len = grid.length,
            row, fill, atomIdx;

        for (idx = 0; idx < len; ++idx) {
            row = grid[idx];
            fill = maxFill;
            indexes.shuffle();

            idy = 0;
            for(idy = 0; Math.random() * atomCount < fill-- && idy < atomCount; ++idy) {
                atomIdx = indexes[idy];
                if (!row[atomIdx]) {
                    if (Fn.randomBool()) {
                        row[atomIdx] = _toAtom(atomIdx)
                    } else {
                        row[atomIdx] = _toNegAtom(atomIdx)
                    }
                }
            }
        }
    }

    function generateLevel(config) {
        //1. generate a solution
        //2. generate empty gird
        //3. fill one value for each row and collum
        //4. fill some andditional values

        var solution, grid,
            fullIndexes, exactIndexes,
            //FIXME apply assure for below
            atomCount = config.atomCount,
            clauseCount = config.clauseCount,
            maxFillFactor = config.maxFillFactor;


        //step 1.
        solution = _generateSolution(atomCount);

        //step 2.
        grid = _generateEmptyGrid(atomCount, clauseCount)


        //step 3.
        exactIndexes = Array.fill(atomCount, Fn.id);
        fullIndexes = Array.fill(clauseCount, function(idx) {
            if (idx % atomCount === 0) exactIndexes.shuffle();
            return exactIndexes[idx % atomCount];
        });


        _minimalFillGrid(grid, solution, fullIndexes);


        //step 4.  //make sure it dosn't make it to easy
        _fillGridUp(grid, atomCount, maxFillFactor, exactIndexes);

        //TODO implement easy check -> use for start gen
        //e.g. grid._recomenededStartState = ...
        return grid;

    }
    return generateLevel;
})();

