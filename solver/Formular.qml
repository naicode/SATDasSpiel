import QtQuick 2.0
import "../config"

/**
 * To diplay a formular just addign it to this components
 * `formular` porperty. Not that setting a width/height is
 * required or it will display in unexpected ways
 *
 * Requirement for `Formular` instance:
 * 	.clauseCount -> return the number of clauses
 * 	.clauseAt(idx) -> return the clause of type `Clause` with index idx ( [0;len[ )
 *  
 * Requirement for `Clause` instances:
 *  .asMathString() -> returns a correct (unicode) string representaition of the clause 
 *  				   using unicode symbols for `or` and `not` (and `and` etc. witch should
 *  				   not apear there). The clause is expected to be wrapped into braces
 */

Rectangle {
	id: root

	///////////
	// setup //
	///////////

	//:link-out:

	//:link-inout:
	property var formular
    property real fontSizePx
	//use onHighlightClauseIdChanged to detect the selction of a clause for e.g. editing
	property int highlightClauseId: -1

	//:config:
	color: Config.style.solver.formularBgColor

	QtObject {
		id: d

		/**
		 * expectes folowing:
		 * clauseId match {
		 *     undefined => reparse all
		 *     _ >= 0 && _ < [len] => element changed
		 *     _ === [len] => new element added
		 * }
		 */
		function formularChanged(clauseId) {
			if (!root.formular) {
				formularModel.clear();
				return;
			}
			if (clauseId === undefined) {
				formularModel.clear();
				var idx, len = root.formular.clauseCount;
				for (idx = 0; idx < len; ++idx) {
					formularChanged(idx);
				}
			} else if (clauseId === formularModel.count) {
				formularModel.append({
					clauseId: clauseId
				});
			} else if (clauseId < formularModel.count && clauseId >= 0) {
				formularModel.get(clauseId).clause = root.formular.clauseAt(clauseId);
			} else {
				console.error("cannot add/update clause, clauseId ("+clauseId+") out of range [0;"+formularModel.count+"]");
			}
		}

		property var callback: d.formularChanged.bind(root)
		
		function setupFormular() {
			//FIMXE nothing like the next line is (and will be) part of core/Formular
			//formular.setOnChangeCallback(d.callback);
			d.callback()	
		}

	}

	///////////
	// state //
	///////////

	onFormularChanged: {
		d.setupFormular();
	}

	Component.onCompleted: {
		d.setupFormular();
	}


	/////////////
	// content //
	/////////////
	
	ListModel {
		id: formularModel
		//TODO setup
	}

	ListView {
        id: clauseView

        model: formularModel
        anchors.fill: parent
		delegate: Item {
            implicitWidth: sep.width+preclause.width
			//no implicit heigh

			Text {
				id: sep
				anchors {
					left: parent.left
					verticalCenter: preclause.verticalCenter
				}
                font {
                    pixelSize: fontSizePx
                }

				color: Config.style.solver.clauseFgColor

				text: model.index == 0? "" : " \u2227 "
			}

			Clause {
				id: preclause

				//position>
                anchors {
                    left: sep.right
				}
                y: ((root.height - height) >> 1)

				//color>
				color: Config.style.solver.clauseBgColor
				fontColor: Config.style.solver.clauseFgColor
                font {
                    pixelSize: fontSizePx
                }

				border {
					width:  root.highlightClauseId === clauseId? 1 : 0
					color: Config.style.solver.accent
				}
				//data>
				clause: root.formular.clauseAt(model.clauseId)
				property int clauseId: model.clauseId

				//state>
				onActivated: {
					root.highlightClauseId = clauseId
				}
			}
		}

		orientation: ListView.Horizontal
		snapMode: ListView.NoSnap
		focus: true

	}
}
