import QtQuick 2.5
import QtQuick.Window 2.2
import QtLocation 5.5
import QtPositioning 5.3

Window {
    id: page
    width: 800
    height: 600
    visible: true
    property variant map

    Component.onCompleted: {
        map = mapComponent.createObject(page);
        var arrCoor = map.bd09ToGcj02(22.244466, 113.553595)
        console.log(arrCoor)
        arrCoor = map.gcj02ToWgs84(arrCoor[0], arrCoor[1])
        console.log(arrCoor)
        map.m_ctLat = arrCoor[0]
        map.m_ctLon = arrCoor[1]
        map.m_curZoomLv = 15
        map.addMarker("格力-香樟", arrCoor[0], arrCoor[1])
    }

    Component {
        id: mapComponent
        MapComponent{
        }
    }
}
