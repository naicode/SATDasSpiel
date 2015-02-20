.pragma library


function ScoreState(typeSetup) {
    this._score = 0;
    this._levelCount = 1;
    this._scoreMultiplicator = typeSetup.multiplicator;
    this._gametype = typeSetup.type;
}

ScoreState.prototype.getCurrentScore = function() {
    return this._score;
}

ScoreState.prototype.getGametype = function() {
    return this._gametype;
}

ScoreState.prototype.getLevelCount = function() {
    return this._levelCount;
}

ScoreState.prototype.increaseScore = function() {
    this._score += this._scoreMultiplicator * (this._levelCount/2);
}

ScoreState.prototype.increaseLevelCount = function() {
    this._levelCount += 1;
}

ScoreState.prototype.asPOD = function() {
    return {
        score: this._score,
        gametype: this._gametype,
        levelCount: this._levelCount
    }
}
