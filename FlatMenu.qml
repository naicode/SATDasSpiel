import QtQuick 2.4

Rectangle {
    id: root

    property color seperatorColor
    property color fillColor

    color: seperatorColor


    Component.onCompleted: {
        //this will arange the child elements similar to Row
        var idx, len = root.children.length,
                child, last;

        for (idx = 0; idx < len; ++idx) {
            child = root.children[idx];
            child.anchors.left = root.left;
            child.anchors.right = root.right;
            //make sure fill is always placed last
            if (child !== fill) {
                if (last) {
                    child.anchors.topMargin = 3;
                    child.anchors.top = last.bottom;
                } else {
                    child.anchors.top = root.top;
                }
                last = child;
            }
        }

        //setup fill
        if (last) {
            fill.anchors.topMargin = 3;
            fill.anchors.top = last.bottom;
        } else {
            fill.anchors.top = root.top;
        }
    }

    Rectangle {
        id: fill
        anchors.bottom: parent.bottom
        color: fillColor
    }
}

