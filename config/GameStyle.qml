import QtQuick 2.0

QtObject {
	
	//the background color for the game/timeline/gamecells etc.
	property string background

	//to "group" all cell properties
	//you still have to initialise some of them when initialising this class 
	//mainly: width, frontIcon, backIcon
	property CellStyle cell: CellStyle {}

	//again, you have to initalise!! 
	property TimeLineStyle timeLine: TimeLineStyle {}

	
	//again, you have to initalise!!
	property PauseScreenStyle pause: PauseScreenStyle {}

	//again, you have to initalise!!
	property SolverStyle solver: SolverStyle {}

    //again, you have to initalise!!
    property MenuStyle menu: MenuStyle {}
}
