pragma Singleton
import QtQuick 2.2

QtObject {
    id: dip

    function setupZoom() {
		var spaceWidth = screenWidth*pixelWrapedDensity
        //console.debug("dvwidth:", spaceWidth)
        var spaceHeight = screenHeight*pixelWrapedDensity
        //console.debug("dvheigh:", spaceHeight)
        var spaceArea = Math.sqrt(spaceWidth*spaceWidth + spaceHeight*spaceHeight)
        //console.debug("dvarea:", spaceArea)
        if (upperBoundZoomSpace && spaceArea > upperBoundZoomSpace) {
            return spaceArea/upperBoundZoomSpace;
        } else if (lowerBoundZoomSpace && spaceArea < lowerBoundZoomSpace) {
            return spaceArea/lowerBoundZoomSpace;
        }
        return 1
    }


    //updated from elsewhere, this is needed because
    //this singelton is deisplayed on no display
    //should be Screen.pixelDensity*25.4/160
    property real pixelWrapedDensity
    property real screenHeight
    property real screenWidth

    //FIXME this feature does not jet work correctly e.g. on Desktop
    //set this value to automaticly zoom in on
    //larger (mobile) displays
    property real upperBoundZoomSpace
    property real lowerBoundZoomSpace
    property real zoom: setupZoom()


    //:dib as real -> :px as real
    function get(dip) {
        //use 25.4 to convert to inch -> ppi
        return zoom*dip*pixelWrapedDensity;
    }
}
