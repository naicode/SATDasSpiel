import QtQuick 2.4
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.2
import "."

Dialog {
    id: root

    ///////////
    // setup //
    ///////////

    //:link-in://

    property string text
    property string placeHolder: ""

    //:link-inout:
    property alias input: inputField.text

    //:link-out:
    signal lineEntered(string line)

    //FIXME no custom styling aviable (low,low priority)

    ///////////
    // state //
    ///////////

    onAccepted: {
        var ip = root.input.trim()
        if (ip) {
            lineEntered(ip)
        }
    }


    /////////////
    // content //
    /////////////

    Item {
        id: content
        anchors {
            margins: DIP.get(10)
            left: parent.left
            right: parent.right
            top: parent.top
        }

        implicitHeight: textHolder.height + inputField.height+10


        Item {
            id: textHolder
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }

            implicitHeight: inner.height*1.5
            implicitWidth: inner.width+(inner.height >> 1)

            Text {
                id: inner
                anchors.centerIn: parent

                text: root.text
            }
        }

        TextField {
            id: inputField

            anchors {
                top: textHolder.bottom
                left: parent.left
                right: parent.right
            }

            focus: true

            placeholderText: root.placeHolder

            onAccepted: {
                if (root.input.trim().length) {
                    //1. close dialog
                    root.close()
                    //2. handle as if it was accepted -> prevent more code paths with same meaning
                    root.accept()
                }

            }
        }
    }
}

