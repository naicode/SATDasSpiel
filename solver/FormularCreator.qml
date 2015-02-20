import QtQuick 2.0
import ".."
import "../config"
import "../core/Formular.js" as FMod
import "../core/Clause.js" as CMod

//FIXME somtimes Formular wants to work with clauseId -1 witch is used to indekate that NO clause is selcted!!
Rectangle {
	id: root

	///////////
	// setup //
	//////////

	color: Config.style.background

    signal requestMenu();
    signal requestSolveing(var formular);

    property real formularFontSizePx: DIP.get(20)
	///////////
	// state //
	///////////

	QtObject {
		id: d
		property bool editMode: false
		property var tmpClause
		property var tmpFormular
		property alias tmpClauseId: formField.highlightClauseId

		Component.onCompleted: {
			d.tmpClause = new CMod.Clause([], 0);
			d.tmpFormular = new FMod.Formular([]);
		}

        function extractForumlar() {
            var res;
            saveEdit(function(d) {
                res = d.formular
                d.formular = new FMod.Formular([]);
                d.clause = new CMod.Clause([],0);
            });
            return res;
        }

		//:fn<:Clause, :Formular> -> ?
		function saveEdit(editCallback) {
			var tmp = {
				clause: d.tmpClause,
				formular:  d.tmpFormular
			};
			editCallback(tmp);
			//it is UI refrsh "save" du to this reassigment
			//so do it even if its still the same clause/formular
			d.tmpClause = tmp.clause;
			d.tmpFormular = tmp.formular;
		}

		function enterEditMode(clauseId) {
			d.tmpClause = d.tmpFormular.clauseAt(clauseId);
			d.editMode = true;
		}

		//the "+" button in !editMode
		function addClauseToFormular() {
		 	if (d.editMode) {
				console.error("the newClause button should not have been aviable");
				return;
			}
			saveEdit(function(d) {
				d.formular.extendWith(d.clause);
				d.clause = new CMod.Clause([],0);
			});
		}

		//the "garbage" button in editMode
		function removeClauseFromFormular() {
			if (!d.editMode) {
				console.error("the delClause button should not have been aviable");
				return;
			}
			saveEdit(function(repr) {
				//rm clause from formular
				repr.formular.reduceAt(d.tmpClauseId);
			});
			//unselct index (would select next clause)
			d.tmpClauseId = -1
			//use new empty creation clause
			d.tmpClause = new CMod.Clause([],0);
			//switch to normal mode
			d.editMode = false;
		} 

		function finishEditingClause() {
			if (!d.editMode) {
				console.error("the finishEdition Button should not have been aviable");
				return;
			}
			//unselect
			d.tmpClauseId = -1
			//new empty creation clause
			d.tmpClause = new CMod.Clause([],0);
			//normal mode
			d.editMode = false
		}

		function delAtomFromClause() {
			//find last visible atom
			var idx = d.tmpClause.atomCount;
			for (; idx > 0; --idx) {
				if (d.tmpClause.hasAtom(idx)) {
					saveEdit(function(d) {
						d.clause.unsetAtom(idx);
					});
					return;
				}
			}
		}
		
		function addAtomToClause(atom) {
			saveEdit(function(d) {
				d.clause.setAtom(atom);
			});
			d.tmpClause = d.tmpClause;
		}
	}

	/////////////
	// content //
	/////////////
	
	//1. put Formular field her
	Formular {
		id: formField
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
		}
		formular: d.tmpFormular

        height: DIP.get(50)
        fontSizePx: formularFontSizePx

		onHighlightClauseIdChanged: {
			d.enterEditMode(formField.highlightClauseId);
		}
	}


	//2. put term view with buttons here
    //2.1 clausel it's flickable
    Item {
        id: clauseSpace
        anchors {
            left: parent.left
            right: parent.right
            top: formField.bottom
            topMargin: DIP.get(10)
        }
        height: clauseView.height+DIP.get(10);
        clip: true

        Flickable {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            height: clauseView.height

            contentWidth: clauseView.width; contentHeight: clauseView.height
            flickableDirection: Flickable.HorizontalFlick

            Clause {
                id: clauseView

                color: Config.style.solver.clauseBgColor
                fontColor: Config.style.solver.clauseFgColor
                font {
                    pixelSize: formularFontSizePx
                }

                border {
                    width: d.editMode? 1 : 0
                    color: Config.style.solver.accent
                }

                clause: d.tmpClause
            }
        }
    }

    Item {
        //TODO mirrot layout
        id: clauseButtons

        property real buttonFontSize: DIP.get(22)

        anchors {
            right: parent.right
            left: parent.left
            top: clauseSpace.bottom
        }
        height: Math.max(backSpace.height, okButton.height, delButton.height, addButton.height)*1.4

        FlatButton {
            id: backSpace
            anchors {
                right: parent.right
                rightMargin: DIP.get(8)
                verticalCenter: parent.verticalCenter
            }

            color: Config.style.solver.atomBoardButtonColor
            fontColor: Config.style.solver.atomBoardFgColor

            font {
                pixelSize: clauseButtons.buttonFontSize
            }

            label: qsTr("←DEL");

            onActivated: d.delAtomFromClause()
        }

        FlatButton {
            id: delButton
            anchors {
                right: backSpace.left
                rightMargin: DIP.get(8)
                verticalCenter: parent.verticalCenter
            }

            color: Config.style.solver.atomBoardButtonColor
            fontColor: Config.style.solver.deny
            font {
                pixelSize: clauseButtons.buttonFontSize
            }

            label: "\u2205"

            enabled: okButton.enabled
            visible: okButton.visible

            onActivated: {
                d.removeClauseFromFormular();
            }
        }

        FlatButton {
            id: okButton
            anchors {
                right: delButton.left
                rightMargin: DIP.get(8)
                verticalCenter: parent.verticalCenter
            }
            font {
                pixelSize: clauseButtons.buttonFontSize
            }

            color: Config.style.solver.atomBoardButtonColor
            fontColor: Config.style.solver.accept

            label: "\u2713"

            visible: d.editMode
            enabled: okButton.visible

            onActivated: {
                d.finishEditingClause();
            }
        }

        FlatButton {
            id: addButton
            anchors {
                right: backSpace.left
                rightMargin: DIP.get(8)
                verticalCenter: parent.verticalCenter
            }
            width: okButton.width+delButton.width+DIP.get(8)

            font {
                bold: true
                pixelSize: clauseButtons.buttonFontSize
            }

            color: Config.style.solver.atomBoardButtonColor
            fontColor: Config.style.solver.atomBoardFgColor

            label: "+"

            visible: !okButton.visible
            enabled: visible

            onActivated: {
                d.addClauseToFormular()
            }
        }

        FlatButton {
            id: inverter
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }

            color: Config.style.solver.atomBoardButtonColor
            fontColor: Config.style.solver.atomBoardFgColor

            font {
                pixelSize: clauseButtons.buttonFontSize
            }

            label: atBoard.inverted?" \u00AC\u0337 ":" \u00AC "
            onActivated: {
                atBoard.inverted = !atBoard.inverted
            }
        }

    }//end buttons



    //3.2 Atom keyboard
	AtomBoard {
		id: atBoard
		anchors {
            top: clauseButtons.bottom
			left: parent.left
			right: parent.right
            bottom: solve.top
            bottomMargin: DIP.get(10);
		}

        atomCount: Config.solver.atomCount
        color: parent.color//Config.style.solver.atomBoardBgColor


        fontColor: Config.style.solver.atomBoardFgColor
        buttonColor: Config.style.solver.atomBoardButtonColor

        fontSize: DIP.get(30)
        buttonWidth: buttonHeight*1.2
        buttonHeight: fontSize*1.4
        spacingSize: (buttonWidth+buttonHeight)/6

		onAtomSelected: {
			d.addAtomToClause(atom);
		}
	}

	//4. put solve Button here
	FlatButton {
		id: solve
		
		anchors {
			right: parent.right
            rightMargin: DIP.get(10)
			bottom: parent.bottom
            bottomMargin: DIP.get(10)
		}
		
		color: Config.style.solver.accent
        radius: DIP.get(10)
		
		font {
            pixelSize: DIP.get(25)
		}

        onActivated: {
            root.requestSolveing(d.extractForumlar());
        }

        label: qsTr("Solve →")
	}

    //5.put back to menu button here
    FlatButton {
        id: back2menu

        anchors {
            left: parent.left
            leftMargin: DIP.get(10)
            bottom: parent.bottom
            bottomMargin: DIP.get(10)
        }

        color: Config.style.solver.atomBoardButtonColor
        radius: DIP.get(10)

        font {
            pixelSize: DIP.get(25)
        }

        label: qsTr("← Back")

        onActivated: root.requestMenu();
    }
}
