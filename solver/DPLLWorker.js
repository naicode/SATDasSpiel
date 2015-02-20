Qt.include("DPLLAlgorithm.js")

WorkerScript.onMessage = function(message) {
    var formular = message.formular;
    //formular.forEach(function(clause) {
    //    console.log("clause here");
    //    for (var atom in clause) {
    //        console.log("with atom",atom);
    //    }
    //});
    var solution = dpll(formular);


    //console.log("res:",solution);


    WorkerScript.sendMessage({solution: solution});
}
