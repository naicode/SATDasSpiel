import QtQuick 2.0


Item {
    id: root

    property ListModel model
    property real cellWidth
    property real cellHeight
    property real horizontalSpacing
    property real verticalSpacing: 0
    property int columnCount: 1
    readonly property int rowCount: model.count

    property Component delegate

    implicitWidth: inner.width
    implicitHeight: inner.height

    Column {
        id: inner
        width: cellWidth*columnCount + horizontalSpacing*(columnCount-1)
        height: cellHeight*rowCount + (rowCount-1)*verticalSpacing

        spacing: root.verticalSpacing

        Repeater {
            model: rowCount
            Row {
                id: rowTop
                property var rowData: root.model.get(index);
                spacing: root.horizontalSpacing

                Repeater {
                    model: root.columnCount
                    Item {
                        id: cell
                        property var cellData: rowData[""+index]

                        width: root.cellWidth
                        height: root.cellHeight
                        //TODO clone and insert delegate into cell
                        Component.onCompleted: {
                            //TODO bind width heigh
                            delegate.createObject(cell, {
                                "x": 0, "y": 0,
                                "width":Qt.binding(function() {
                                    return root.cellWidth
                                }),
                                "height": Qt.binding(function() {
                                    return root.cellHeight
                                })
                            });

                        }
                    }
                }
            }
        }
    }
}
