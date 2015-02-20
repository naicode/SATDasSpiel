.pragma library

function id(x) {
    return x;
}

function returning(x) {
    return function() {
        return x;
    }
}

function randomBool() {
    return (Math.random() >= 0.5);
}
