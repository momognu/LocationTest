import QtQuick 2.5
import QtLocation 5.5
import QtPositioning 5.3

Map {
    id: map
    property real m_ctLat: 21.478394
    property real m_ctLon: 109.118653//默认中心定位“北海”
    property int m_curZoomLv: 13//当前缩放级别
    plugin: Plugin {
        name: "osm"
    }
    center {
        latitude: m_ctLat
        longitude: m_ctLon
    }
    zoomLevel: m_curZoomLv
    gesture.enabled: true
    anchors.fill: parent
    property int lastX : -1
    property int lastY : -1
    property int pressX : -1
    property int pressY : -1

    MouseArea {
        id: mouseArea
        property variant lastCoordinate
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed : {
            map.lastX = mouse.x
            map.lastY = mouse.y
            map.pressX = mouse.x
            map.pressY = mouse.y
            lastCoordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y))
        }

        onPositionChanged: {
            if (mouse.button == Qt.LeftButton) {
                map.lastX = mouse.x
                map.lastY = mouse.y
            }
        }

        onDoubleClicked: {
            map.center = map.toCoordinate(Qt.point(mouse.x, mouse.y))
            if (mouse.button === Qt.LeftButton) {
                map.zoomLevel++
            } else if (mouse.button === Qt.RightButton) {
                //map.zoomLevel--
                lastCoordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y))
                console.log(lastCoordinate.latitude + " - " + lastCoordinate.longitude)
            }
            map.lastX = -1
            map.lastY = -1
        }
    }

    function addMarker(title, lat, lon) {//添加标记图标
        var marker = Qt.createQmlObject('Marker {}', map)
        marker.m_makerTitle = title
        marker.z = map.z + 1//使图层在地图之上
        marker.coordinate.latitude = lat//QtPositioning.coordinate(lat, lon)//mouseArea.lastCoordinate
        marker.coordinate.longitude = lon
        map.addMapItem(marker)
    }

    property real pi: 3.14159265358979324
    property real x_pi: pi * 3000.0 / 180.0

    function bd09ToGcj02(bdLat, bdLon) {
        var x = bdLon - 0.0065, y = bdLat - 0.006
        var z = Math.sqrt(x * x + y * y) - 0.00002 * Math.sin(y * x_pi)
        var theta = Math.atan2(y, x) - 0.000003 * Math.cos(x * x_pi)
        var gcjLon = z * Math.cos(theta)
        var gcjLat = z * Math.sin(theta)
        return new Array(gcjLat, gcjLon)//{'lat' : gcjLat, 'lon' : gcjLon};
    }

    function gcj02ToWgs84(gcjLat, gcjLon) {
        var initDelta = 0.01;
        var threshold = 0.000000001;
        var dLat = initDelta, dLon = initDelta;
        var mLat = gcjLat - dLat, mLon = gcjLon - dLon;
        var pLat = gcjLat + dLat, pLon = gcjLon + dLon;
        var wgsLat, wgsLon, i = 0;
        while (1) {
            wgsLat = (mLat + pLat) / 2;
            wgsLon = (mLon + pLon) / 2;
            var tmp = this.gcj_encrypt(wgsLat, wgsLon)
            dLat = tmp.lat - gcjLat;
            dLon = tmp.lon - gcjLon;
            if ((Math.abs(dLat) < threshold) && (Math.abs(dLon) < threshold))
                break;

            if (dLat > 0) pLat = wgsLat; else mLat = wgsLat;
            if (dLon > 0) pLon = wgsLon; else mLon = wgsLon;

            if (++i > 10000) break;
        }
        return new Array(wgsLat, wgsLon) //{'lat': wgsLat, 'lon': wgsLon};
    }

    function gcj_encrypt(wgsLat, wgsLon) {
        var d = this.delta(wgsLat, wgsLon);
        return {'lat' : wgsLat + d.lat,'lon' : wgsLon + d.lon};
    }

    function delta(lat, lon) {
        var a = 6378245.0; //  a: 卫星椭球坐标投影到平面地图坐标系的投影因子。
        var ee = 0.00669342162296594323; //  ee: 椭球的偏心率。
        var dLat = transformLat(lon - 105.0, lat - 35.0);
        var dLon = transformLon(lon - 105.0, lat - 35.0);
        var radLat = lat / 180.0 * pi;
        var magic = Math.sin(radLat);
        magic = 1 - ee * magic * magic;
        var sqrtMagic = Math.sqrt(magic);
        dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
        dLon = (dLon * 180.0) / (a / sqrtMagic * Math.cos(radLat) * pi);
        return {'lat': dLat, 'lon': dLon};
    }

    function transformLat(x, y) {
        var ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * Math.sqrt(Math.abs(x));
        ret += (20.0 * Math.sin(6.0 * x * pi) + 20.0 * Math.sin(2.0 * x * pi)) * 2.0 / 3.0;
        ret += (20.0 * Math.sin(y * pi) + 40.0 * Math.sin(y / 3.0 * pi)) * 2.0 / 3.0;
        ret += (160.0 * Math.sin(y / 12.0 * pi) + 320 * Math.sin(y * pi / 30.0)) * 2.0 / 3.0;
        return ret;
    }

    function transformLon(x, y) {
        var ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * Math.sqrt(Math.abs(x));
        ret += (20.0 * Math.sin(6.0 * x * pi) + 20.0 * Math.sin(2.0 * x * pi)) * 2.0 / 3.0;
        ret += (20.0 * Math.sin(x * pi) + 40.0 * Math.sin(x / 3.0 * pi)) * 2.0 / 3.0;
        ret += (150.0 * Math.sin(x / 12.0 * pi) + 300.0 * Math.sin(x / 30.0 * pi)) * 2.0 / 3.0;
        return ret;
    }
}
