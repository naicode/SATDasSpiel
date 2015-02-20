import QtQuick 2.0

QtObject {

	//the "source" of the icon (can be async, and sync)
	property string pauseIcon
	
	//the icon displayed when paused
	property string continueIcon

	//the color to use for the different time lines
	property string relaxColor
	property string tenseColor
	property string panicColor
}
