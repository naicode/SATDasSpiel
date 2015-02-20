import QtQuick.LocalStorage 2.0
import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Dialogs 1.2
import ".."
import "../config"

//TODO implement
Rectangle {
    id: root

    ///////////
    // setup //
    ///////////

    //TODO get own color slot
    color: Config.style.solver.atomBoardBgColor

    //:link-out:
    signal requestedLeaveHighscoreView()

    ///////////
    // state //
    ///////////

    QtObject {
        id: d

        //check witch place this score would have if added
        function checkRank(score) {
            var idx, len = heighscoreModel.count;
            if (len === 0) {
                return 1;
            }
            for (idx = 0; idx < len; ++idx) {
                //bether then current score?
                if (heighscoreModel.get(idx).score < score.score) {
                    //then take place of current score
                    return idx+1;
                }
            }
            //is no heighscore, return false
            return false;
        }


        function openDBConnection() {
            //FIXME use Config sinelton for dbname etc.
            return LocalStorage.openDatabaseSync(
                Config.storage.dbMame,
                Config.storage.dbVersion,
                Config.storage.dbDescription,
                Config.storage.estimatedSize
            );

        }

        function addHeighscore(score) {
            if (!(score ||score.name || score.score || score.gametype)) {
                    throw new TypeError("score data is not valide");
            }

            //open db connection every time, it is not often needed so its bether this way
            var db =  openDBConnection();

            var scores = [];
            db.transaction(
                function(tx) {
                    tx.executeSql("INSERT INTO Scores VALUES(?,?,?,?)", [score.name, score.score, score.gametype, score.levelCount]);
                    tx.executeSql("DELETE FROM Scores WHERE rowid NOT IN (SELECT rowid FROM Scores ORDER BY score DESC LIMIT 5)");
                }
            );
            root.updateData(db)
        }

        function loadScores() {
            //open db connection every time, it is not often needed so its bether this way
            //FIXME use Config sinelton for dbname etc.
            var db = arguments[0] || openDBConnection()
            var scores = [];
            db.transaction(
                function(tx) {
                    var resultSet, idx, len;

                    // create db if not existing
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Scores(name TEXT, score INTEGER, type TEXT, levelCount INTEGER)');

                    // Show all added greetings
                    resultSet = tx.executeSql('SELECT * FROM Scores ORDER BY score DESC');

                    len = resultSet.rows.length;
                    for (idx = 0; idx < len; ++idx) {
                        var item = resultSet.rows.item(idx);
                        scores.push({
                            name: item.name,
                            score: item.score,
                            gametype: item.type,
                            levelCount: item.levelCount
                        });
                    }
                }
            );
            return scores;
        }
    }

    //update the displyed heighscores by reloading them from the
    //database. A DB connection can be optinaly passed to updateData,
    //if no is supplied it will automaticly use the name, version supplied by
    //the Config singeltion
    function updateData() {
        var scores = d.loadScores(arguments[0])
        heighscoreModel.clear()
        scores.forEach(function(score, idx) {
            score.rank = idx+1;
            heighscoreModel.append(score);
            col.update();
        });
    }

    //if this methode is used it switches
    //into editing mode allowing adding
    //the highscore score
    function optionalNewHeighscore(score) {
        var rank = d.checkRank(score);
        if (rank) {
            score.rank = rank;
            enterNameDialog.score = score;
            enterNameDialog.open();
        }
    }


    Component.onCompleted: {
        updateData();
    }

    /////////////
    // content //
    /////////////

    EnterOneLineDialog {
        id: enterNameDialog

        text: qsTr("Pleas Enter a Alias:")

        property var score

        onScoreChanged: {
            if (enterNameDialog.score) {
                enterNameDialog.setTitle(qsTr("New Heighscore, Rank: ")+enterNameDialog.score.rank);
            }
        }

        onLineEntered: {
            var score = enterNameDialog.score;
            //due to a workaround this signal might
            //fired twice insted of once! So make sure
            //that even if this happen the score is not
            //added twice
            if (score) {
                score.name = line;
                d.addHeighscore(score);
                enterNameDialog.score = null;
            }
        }
    }


    ListModel {
        id: heighscoreModel
        //TODO remove dummy data
       /* ListElement { rank: 1; name: "Tom";  score: 1200; gametype: "splitsecond" }
        ListElement { rank: 2; name: "Kit";  score: 1100; gametype: "splitsecond" }
        ListElement { rank: 3; name: "Mine"; score: 800;  gametype: "timerush"    }
        ListElement { rank: 4; name: "Mori"; score: 110;  gametype: "normal"      }
        ListElement { rank: 5; name: "Liz";  score: 200;  gametype: "easy"        }*/
    }

    //TODO change to Table??, Row?, Grid?
    Item {
        id: myTableView

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: continueButton.top
        }


        function formatScore(score, len) {
            var x = ""+score;
            while (x.length < len) {
                x = "0" + x;
            }
            return x;
        }

        Column {
            id: col
            Repeater {
                model: heighscoreModel.count
                Item {
                    property var ele: heighscoreModel.get(index)
                    implicitHeight: name.height+DIP.get(15);
                    width: myTableView.width
                    Text {
                        id: rank
                        anchors {
                            top: parent.top
                            topMargin: DIP.get(20);
                            left: parent.left
                            leftMargin: DIP.get(10);
                        }
                        color: Config.style.solver.accent
                        font {
                            pixelSize: DIP.get(20);
                        }

                        text: ele?ele.rank:""
                    }
                    Text {
                        id: name
                        anchors {
                            top: rank.top
                            left: rank.right;
                            leftMargin: DIP.get(10);
                            right: score.left;
                            rightMargin: DIP.get(10);
                        }
                        wrapMode: Text.Wrap
                        color: Config.style.solver.accent
                        font {
                            pixelSize: DIP.get(20)
                        }

                        text: ele?ele.name:""
                    }
                    Text {
                        id: score
                        anchors {
                            top: rank.top
                            right: parent.right
                            rightMargin: DIP.get(10)
                        }
                        color: Config.style.solver.accent
                        font {
                            pixelSize: DIP.get(20)
                        }
                        text: ele?myTableView.formatScore(ele.score, 6):"      "
                    }
                    /*Text {
                        id: type
                        text: ele?ele.gametype:""
                    }
                    Text {
                        id: lvCount
                        text: ele?ele.levelCount:""
                    }*/

                }
            }

        }
    }

    /*TableView {
        id: table

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: continueButton.top
        }

        model: heighscoreModel

        TableViewColumn { role: "rank"; title: qsTr("Rank"); width: DIP.get(60) }
        TableViewColumn { role: "name"; title: qsTr("Name"); width: DIP.get(60) }
        TableViewColumn { role: "score"; title: qsTr("Score"); width: DIP.get(60) }
        TableViewColumn { role: "gametype"; title: qsTr("Game Type"); width: DIP.get(90) }
        TableViewColumn { role: "levelCount"; title: qsTr("Solved Level"); width: DIP.get(110) }
    }*/

    //TODO place buttons here

    FlatButton {
        id: continueButton

        anchors {
            left: parent.left
            leftMargin: DIP.get(10)
            bottom: parent.bottom
            bottomMargin: DIP.get(10)
        }
        radius: 10
        color: Config.style.solver.atomBoardButtonColor
        fontColor: Config.style.solver.atomBoardFgColor
        font {
            pixelSize: DIP.get(20);
        }

        label: qsTr("Go To Menu");
        onActivated: requestedLeaveHighscoreView()
    }
}
