import QtQuick 2.0
import QtMultimedia 5.0
import ".."
import "../config"
import "../core/DIMACS.js" as DIMACS

//TODO allow mutiple types of bg hightlighting -> just port bg images form HTML ther is no time for opengl sheader effekts...
//TODO win annimation

Item {
	id: root
    clip: true



	///////////
	// setup //
	///////////
	


	property GameWrapper gameWrapper	

	//if it set to false, the grid cannot be changed (by user input)
	property bool enabled: false
    property bool showAlternateSymbols: false
    property bool fxFeedBackEnabled: false

    ///////////
	// state //
	///////////
	
	function callOnFormularChanged() {
		iterateCells(function() {
            updateCellTypesCallback.apply(this, arguments)
			updateCellsCallback.apply(this, arguments)
		});
	}
	
	function callOnGameStateChanged() {
		iterateCells(
			updateCellsCallback
		);
        //this will trigger some update, its a hack but a good one
        root.bindDummy = root.bindDummy;
	}

	//:fn<:index :Term :Item :GameState>> -> ?
	function iterateCells(callback0) {
		var colIdx, colIdxDiff = 0,
			rowIdx, colLen, rowLen,
			column, item, clause, state;

		colLen = columnList.children.length;
		for (colIdx = 0; colIdx < colLen; ++colIdx) {
			column = columnList.children[colIdx];
			//FIXME test how Repeater behaves
			if (column.objectName == "repeater") {
				colIdxDiff += 1;
				continue;
			}


			rowLen = column.children.length;
			for (rowIdx = 0; rowIdx < rowLen; ++rowIdx) {
				item = column.children[rowIdx];
				if (item.objectName === "repeater") continue;
				
				//dive into Item -> GameCell
				//FIXME this is bad use objectName === "GameCell" test
				item = item.children[1];


				
                clause = gameWrapper.getClause(rowIdx);
				
				callback0(colIdx-colIdxDiff, clause, item, gameWrapper.gameObject);
				
			}
		}
	}

	function updateCellTypesCallback(atomIdx, clause, item, game) {
        item.hideIcon = !clause.hasAtomAt(atomIdx);
        if (item.hideIcon) {
            item.alternateSymbol = "";
        } else {
            item.alternateSymbol = DIMACS.atomAsMathString(clause.atomAt(atomIdx));
        }

        //FIXME if only one colum exists... (low,low realy unimportant)
        if (atomIdx === 0) {
            item.heighlightSourceIndex = 1;
        } else if (atomIdx === gameWrapper.columnCount-1) {
            item.heighlightSourceIndex = 2;
        }


	}

	function updateCellsCallback(atomIdx, clause, item, game) {
		var logic = game.logic,
			state = game.state;

		item.hightlight = logic.isClauseSolved(clause, state);
		
		//formular does not change only update id it hasAtom -> not hides it's icon
		if (!item.hideIcon) {
            var res = logic.isCellSolved(atomIdx, clause, state);
			item.showGoodSide = res;
		}
	}

	/////////////
	// content //
	/////////////
	
/*FIXME using gird or GridLayour might be bether but I have no time for this now
	Grid {
		id: grid
		columns: gameWrapper.columnCount
		rows: gameWrapper.rowCount
		anchors.fill: parent

		Repeater {
			objectName: "repeater"
			model: grid.columns*grid.rows
			GameCell {
				width: 100; height: 100
				frontIcon: gameWrapper.frontIcon
				backIcon: gameWrapper.backIcon
				border {width: 1; color: "red"}
			}
		}
	}
	*/				
	
    property var bindDummy: QtObject {
        function getAssigment(index) {
            return DIMACS.atomAsMathString(index+1)+"=\n"+
                    (gameWrapper.gameObject.state.getAtomValue(index)?qsTr("true"):qsTr("false"));
        }
    }

    SoundEffect {
        id: rolloverFx
        source: "qrc:/rollover3.wav"
    }

    Flickable {
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        width: Math.min(root.width, _contentWidth)

        //flickableDirection: Flickable.HorizontalAndVerticalFlick
        boundsBehavior: Flickable.StopAtBounds

        //the added 50dp are to be able to flick it a little bit further
        property real _contentWidth: (DIP.get(Config.style.cell.width) + DIP.get(Config.style.cell.borderSize)) * gameWrapper.columnCount + DIP.get(50)
        //Note: the Flickables width and contentWidth are somhow internaly bound together so
        //binding the width (+root.width?) to the contentWidth (in this circumstates) results in a binding loop (but works!?)
        //to prevent this error binding contentWidth and width to a third value (_contentWidth) is used
        contentWidth: _contentWidth
        contentHeight: (DIP.get(Config.style.cell.height) + DIP.get(Config.style.cell.borderSize)) * (gameWrapper.rowCount+1) + DIP.get(50)


        Row {
            id: atomList
            Repeater {
                id: atomListRep
                model: gameWrapper.columnCount
                Item {
                    visible: root.showAlternateSymbols
                    width: DIP.get(Config.style.cell.width)
                    height: DIP.get(Config.style.cell.height)
                    Text {
                        text: bindDummy.getAssigment(index);

                        color: "red"
                        font {
                            pixelSize: parent.height/3
                        }
                    }
                }
            }
        }

        //TODO add state cells
        Row {
            id: columnList
            y: DIP.get(Config.style.cell.height)
            Repeater {
                objectName: "repeater"
                id: singleRepeater
                model: gameWrapper.columnCount

                Column {
                    property int colIdx: index
                    //TODO add mouse area
                    Repeater {
                        objectName: "repeater"
                        model: gameWrapper.rowCount
                        Item {
                            width: DIP.get(Config.style.cell.width)
                            height: DIP.get(Config.style.cell.height)

                            MouseArea {
                                anchors.fill: parent
                                enabled: root.enabled
                                onClicked: {
                                    if (root.fxFeedBackEnabled) rolloverFx.play()
                                    gameWrapper.toggleAtomValue(colIdx);
                                }
                            }
                            GameCell {
                                anchors.fill: parent
                                objectName: "GameCell"
                                frontIcon: Config.style.cell.frontIcon
                                backIcon: Config.style.cell.backIcon
                                heighlightSources: ["cellBgCenter.png","cellBgLeft.png","cellBgRight.png"]
                                border {
                                    width: Config.style.cell.borderSize
                                    color: Config.style.cell.borderColor
                                }
                                blendAlernateSymbolIn: root.showAlternateSymbols

                            }
                        }
                    }

                }
            }
        }
    }
}
