.pragma library
//NOTE THIS shim was COPYED form one of my other
//(private) projects. It has a bunch of unit tests
//witch neverless cannot be integrated (easily) with
//this enviroment and where therefor not moved here!
//TODO remove unused parts
/*
 * Copyright 2014 Philipp Korber.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
//define([], function() {
   /**
     * presents a Array created by ziping 2 arrays with the
     * same length together
     *
     * FIXME: what happens if one of the source arrays changes langth
     * in between??
     */
    function ZippedArray(array1, array2) {
        if (array1.length !== array2.length) {
            throw new TypeError("can only zip arrays with same size");
        }
        this._array1 = array1;
        this._array2 = array2;
        this.length = array1.length;
    }

    /**
     * creates a array containing at each index
     * a array containing both the elements from
     * the origin arrays
     */
    ZippedArray.prototype.toArray = function() {
        var res = [];
        this.forEach(function(value1, value2) {
            res.push([value1, value2]);
        });
        return res;
    };

    /**
     * iterates ofer this array.
     * You can pass this as second argument.
     * The first argument is a callback with folowing signatur:
     * callback(valueOfArray1, valueOfArray2, index)
     */
    ZippedArray.prototype.forEach = function(clb, that) {
        var len = this.length;
        for (var idx = 0; idx < len; ++idx) {
            clb.call(that, this._array1[idx], this._array2[idx], idx);
        }
    };

    /**
     * calls the callback on all pairs unti it return a falsely value
     * or all elements are iterated ofer. Returns true if all iterationsteps
     * returned a truely value, else false.
     *
     * callback(value1, value2, index),
     */
    ZippedArray.prototype.forAll = function(clb, that) {
        var len = this.length;
        for (var idx = 0; idx < len; ++idx) {
            if (!clb.call(that, this._array1[idx], this._array2[idx], idx)) {
                return false;
            }
        }
        return true;
    };

    /**
     * calls the callback in each pair untile it returns a truely value
     * or all elements are iterated over. Returns true if atlast one
     * claaback returned a truly value else false
     *
     * callback(value1, value2, index)
     */
    ZippedArray.prototype.forAny = function(clb, that) {
        var len = this.length;
        for (var idx = 0; idx < len; ++idx) {
            if(clb.call(that, this._array1[idx], this._array2[idx], idx)) {
                return true;
            }
        }
        return false;
    };

    /**
     * calls a callback on all elements until the callback
     * returns a falsely value or the iteration ended.
     * Returns true if all callbacks returned true, else false
     */
    if (Array.prototype.forAll === void 0) {
        Object.defineProperty(Array.prototype, "forAll", {
            value: function(callback, that) {
                var len = this.length;
                for (var idx = 0; idx < len; ++idx) {
                    if (!callback.call(that, this[idx], idx)) {
                        return false;
                    }
                }
                return true;
            }
        });
    }

    /**
     * calls a callback on all elements until the callback
     * returns a truely value or the iteration ended.
     * Returns true if any callback returned true, else false
     */
    if (Array.prototype.forAny === void 0) {
        Object.defineProperty(Array.prototype, "forAny", {
            value: function(callback, that) {
                var len = this.length;
                for (var idx = 0; idx < len; ++idx) {
                    if (callback.call(that, this[idx], idx)) {
                        return true;
                    }
                }
                return false;
            }
        });
    }

    /**
     * creates a salow clone of this array by
     * using slice(0, this.length)
     */
    if (Array.prototype.clone === void 0) {
        Object.defineProperty(Array.prototype, "clone", {
            value: function() {
                return this.slice(0, this.length);
            }
        });
    }

    /**
     * creates a deep copy of the array under a fiew restrictions
     * 1. objects witch are not POD have to have a deepClone methode.
     *    If not the clone MIGHT YIELD UNEXPECTED RESULTS
     * 2. for this reason cloning functions is not supported!
     * 3. the data is not allowed to have circular references,
     *    If the calling this function will end in a INFINITE LOOP until
     *    the stack overflows...
     */
    if (Array.prototype.deepClone === void 0) {
        var deepClone = function(obj) {
            if (obj === null) {
                return null;
            }
            var type = typeof obj;
            if (type === "string" || type === "number" || type === "undefined") {
                return obj;
            }
            if (type === "object") {
                if (typeof obj.deepClone === 'function') {
                    return obj.deepClone();
                }
                //FIXME detect if it is NOT a simple object and throw ...
                var neu = {};
                for (var key in obj) {
                    neu[key] = obj[key];
                }
                return neu;
            }
            throw new Expection("only cloning most simple datatypes is supported");
        };
        Object.defineProperty(Array.prototype, "deepClone", {
            value: function() {
                var flatClone = this.clone();
                flatClone.map(function(val) {
                    deepClone(val);
                });
                return flatClone;
            }
        });
    }

    /**
     * creates a ZippedArray from this Array and the given parameter.
     * Not that this function will throw if both array do not have the
     * same length
     */
    if (Array.prototype.zip === void 0) {
        Object.defineProperty(Array.prototype, "zip", {
            value: function(p1) {
                if (p1 == null) {
                    throw new TypeError("cannot zip Array with undefined/null Array");
                }
                return new ZippedArray(this, p1);
            }
        });
    }

    /**
     * Creates a array with a given len
     * with values returned by calling
     * the callback with the given index
     *
     * use `asFunction(x)` if you want to fill
     * it with a lot of x (e.g. false)
     *
     * callback(index) -> fillValueAtIndex
     */
    if (Array.fill === void 0) {
        Object.defineProperty(Array, "fill", {
            value: function(len, clb) {
                var res = [];
                for (var idx = 0; idx < len; ++idx) {
                    res.push(clb(idx));
                }
                return res;
            }
        });
    }

    /** shuffels all values in a given array */
    if(Array.prototype.shuffle === void 0) {
       //http://stackoverflow.com/questions/2450954/how-to-randomize-shuffle-a-javascript-array
       Array.prototype.shuffle = function() {
            var currentIndex = this.length, temporaryValue, randomIndex ;

            // While there remain elements to shuffle...
            while (0 !== currentIndex) {

                // Pick a remaining element...
                randomIndex = Math.floor(Math.random() * currentIndex);
                currentIndex -= 1;

                // And swap it with the current element.
                temporaryValue = this[currentIndex];
                this[currentIndex] = this[randomIndex];
                this[randomIndex] = temporaryValue;
            }
        };
    }

//    return {
//      ZippedArray: ZippedArray,
//    };
//});
