import QtQuick 2.5
import QtLocation 5.5

//! [mqi-top]
MapQuickItem {
    id: marker
    //! [mqi-top]
    property alias lastMouseX: maMarker.lastX
    property alias lastMouseY: maMarker.lastY
    property string m_makerTitle: "标注物"

    //! [mqi-anchor]
    anchorPoint.x: image.width/4
    anchorPoint.y: image.height

    sourceItem: Rectangle {
        anchors.fill: parent

        Rectangle {
            z: 2
            width: image.width - 4
            height: 2
            color: "#DA122F"
            anchors.bottom: rectMaker.bottom
            x: image.x + 2
        }

        Rectangle {
            id: rectMaker
            z: 1
            width: txtMakerName.width + 20
            height: txtMakerName.height + 10//image.height*4/5
            x: image.width/2 - width/2
            y: image.y - number.height/2
            border.color: "#ffffff"
            border.width: 2
            color: "#DA122F"
            Text {
                id: txtMakerName
                anchors.centerIn: parent
                text: m_makerTitle
                color: "#FFFFFF"
            }
        }

        Image {
            height: rectMaker.height*5/4
            id: image
            //! [mqi-anchor]
            source: "images/map/marker.png"

            Text{
                id: number
                y: image.height/10
                width: image.width
                color: "white"
                font.bold: true
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                Component.onCompleted: {
                    text = ""//map.markerCounter
                }
            }

            MouseArea  {
                id: maMarker
                property int pressX : -1
                property int pressY : -1
                property int jitterThreshold : 10
                property int lastX: -1
                property int lastY: -1
                anchors.fill: parent
                hoverEnabled : false
                drag.target: marker
                preventStealing: true
            }
            //! [mqi-closeimage]
        }
        //! [mqi-closeimage]
    }
    //Component.onCompleted: coordinate = map.toCoordinate(Qt.point(maMarker.mouseX, maMarker.mouseY));
    //! [mqi-close]
}
//! [mqi-close]
