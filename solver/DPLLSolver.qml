import QtQuick 2.0
import "../config"
import "../core/DIMACS.js" as DIMACS
import "./DPLLAlgorithm.js" as DPLL
import ".."


Rectangle {
    id: root

    ///////////
    // setup //
    ///////////

    color: Config.style.solver.atomBoardBgColor

    property var toSolve
    signal requestBack();

    QtObject {
        id: d
        property bool solving: false
    }

    ///////////
    // state //
    ///////////

    onToSolveChanged: {
        if (d.solving) {
            console.error("still working");
        } else {
            if (root.toSolve) {
                var cformular = convertFormular(toSolve);
                solver.sendMessage({
                    formular: cformular,
                    dpll: DPLL.dpll
                });
                d.solving = true;
            }
        }
    }

    //orginally I wanted/used the formular
    //structure from /core/Formular /core/Cluase.
    //Neverless this is not trivialy possible to
    //to the Fakt that webworkers cannot use .import
    //witch I noticed only later so I transform it
    //to a different Format here!
    //Btw. if I would reimplement all, I lighly
    //would use belows format as internal format!
    function convertFormular(formular) {
        formular.normalize();
        var atom, clause, nclause, nformular = [];
        var idy, leny, idx, len = formular.clauseCount;
        for (idx = 0; idx < len; ++idx) {
            clause = formular.clauseAt(idx);
            nclause = {};
            leny = clause.atomCount;
            for (idy = 0; idy < leny; ++idy) {
                atom = clause.atomAt(idy);
                if (atom > 0) {
                    nclause[atom] = true;
                } else if(atom < 0) {
                    nclause[-atom] = false;
                }
            }
            nformular.push(nclause)
        }
        return nformular;
    }

    /////////////
    // content //
    /////////////

    WorkerScript {
        id: solver
        source: "DPLLWorker.js"
        onMessage: {
            d.solving = false;
            var sol = messageObject.solution;
            var resTxt = qsTr("done:\n");
            var entry = [];
            if (sol === false) {
                resTxt += qsTr("Not Solvable");
            } else {
                resultModel1.clear();
                resultModel2.clear();

                var atoms = toSolve.getContainingAtoms();
                var res1 = [], res2=[], toggle=true;
                atoms.forEach(function(atom) {
                    var value;
                    if (atom in sol) {
                        if (sol[atom] === true) {
                            value  = "1" //qsTr("true");
                        } else if (sol[atom] === false) {
                            value = "0" //qsTr("false");
                        } else {
                            value = "??";
                            console.error("undefined state for atom:",atom)
                        }
                    } else {
                        value = "*";
                    }

                    (toggle?res1:res2).push({
                        "0": DIMACS.atomAsMathString(atom),
                        "1": value
                    });
                    toggle = !toggle;

                });
                resultModel1.append(res1);
                resultModel2.append(res2);
            }
            doingText.text = resTxt;
            //TODO display here
        }
    }

    ListModel {
        id: resultModel1
    }
    ListModel {
        id: resultModel2
    }


    Item {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: backButton.top
            bottomMargin: DIP.get(10)
        }

        //implicitHeight: whatText.height + DIP.get(20) + formField.height+ doingText.height + resultTables.height + resultTables.anchors.topMargin

        Text {
            id: whatText
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            font {
                pixelSize: DIP.get(40)
            }

            color: Config.style.solver.atomBoardFgColor
            wrapMode: Text.WordWrap;
            text: qsTr("Solving:")
        }


        Formular {
            id: formField
            anchors {
                top: whatText.bottom
                topMargin: DIP.get(8)
                left: parent.left
                right: parent.right
            }
            height: fontSizePx*2.2
            color: "black"

            fontSizePx: DIP.get(25)

            formular: toSolve
        }


        Text {
            id: doingText
            anchors {
                top: formField.bottom
                topMargin: DIP.get(20)
                horizontalCenter: whatText.horizontalCenter
            }
            font {
                pixelSize: DIP.get(25)
            }

            color: Config.style.solver.atomBoardFgColor

            text: qsTr("working...")
        }

        Flickable {
            id: resultTables
            anchors {
                top: doingText.bottom
                topMargin: DIP.get(10)
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            clip: true

            flickableDirection: Flickable.VerticalFlick

            width: innerTables.width
            contentWidth:  innerTables.width
            contentHeight: innerTables.height+DIP.get(5)


            Item {
                id: innerTables
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                width: resultTabel1.width + resultTabel2.width + DIP.get(30)
                height: Math.max(resultTabel1.height+resultTabel1.anchors.topMargin,
                                 resultTabel2.height+resultTabel2.anchors.topMargin)

                CustomTable {
                    id: resultTabel1
                    anchors {
                        top: parent.top
                        topMargin: DIP.get(5)
                        left: parent.left
                    }

                    property real fontSize: DIP.get(20)
                    horizontalSpacing: DIP.get(3)
                    verticalSpacing:  DIP.get(20)
                    cellWidth: DIP.get(40)
                    cellHeight: fontSize*1.4
                    columnCount: 2

                    model: resultModel1
                    delegate: Rectangle {
                        radius: 5
                        color: Config.style.solver.atomBoardButtonColor
                        Text {
                            anchors.centerIn: parent
                            text: parent.parent.cellData
                            font {
                                pixelSize: DIP.get(20)
                            }
                            color: Config.style.solver.atomBoardFgColor
                        }
                    }

                }
                CustomTable {
                    id: resultTabel2
                    anchors {
                        top: parent.top
                        topMargin: DIP.get(5)
                        right: parent.right
                    }

                    property real fontSize: DIP.get(20)
                    horizontalSpacing: DIP.get(3)
                    verticalSpacing:  DIP.get(20)
                    cellWidth: DIP.get(40)
                    cellHeight: fontSize*1.4
                    columnCount: 2

                    model: resultModel2
                    delegate: Rectangle {
                        radius: 5
                        color: Config.style.solver.atomBoardButtonColor
                        Text {
                            anchors.centerIn: parent
                            text: parent.parent.cellData
                            font {
                                pixelSize: DIP.get(20)
                            }
                            color: Config.style.solver.atomBoardFgColor
                        }
                    }

                }//END Custom Table
            }
        }
        Rectangle {
            id: sep1
            z:1
            y: resultTables.y
            x: resultTables.x
            width: resultTables.width
            height: DIP.get(1)
            color: "gray"
        }
        Rectangle {
            id: sep2
            z:1
            y: resultTables.y+resultTables.height-height
            x: resultTables.x
            width: resultTables.width
            height: DIP.get(1)
            color: "gray"
        }

    }
    FlatButton {
        id: backButton
        anchors {
            left: parent.left
            leftMargin: DIP.get(10)
            bottom: parent.bottom
            bottomMargin: DIP.get(10)
        }
        radius: DIP.get(10)

        label: qsTr("← Back")
        fontColor: Config.style.solver.atomBoardFgColor
        font {
            pixelSize: DIP.get(25);
        }
        color: Config.style.solver.atomBoardButtonColor

        onActivated: root.requestBack()
    }

}
