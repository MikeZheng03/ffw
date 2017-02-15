<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
	<HEAD>
	<TITLE> Flight </TITLE>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	
	<jsp:include page="islogin.jsp"></jsp:include> 
	
	<link rel="stylesheet" href="./css/ol.css" type="text/css" />
	<link rel="SHORTCUT ICON" href="img/marker.png"/>
	<script src="./js/ol-debug.js"></script>
	<script src="./js/zhHash.js"></script>
	<script src="./js/jquery-3.1.1.min.js"></script>
	<script src="./js/highcharts.js"></script>
	<script src="./js/woco.accordion.js"></script>
	<!-- 
	<link rel="stylesheet" href="./css/popover.css">
	<script src="./js/bootstrap.js"></script>
	 -->
	<link rel="stylesheet" href="./css/tabDiv.css">
	<link rel="stylesheet" href="./css/ol-popup.css">
	<link rel="stylesheet" href="./css/message.css">
	<link rel="stylesheet" href="./css/measure.css" type="text/css" />
	<link rel="stylesheet" href="./css/woco-accordion.css">
    <script src="./js/measure.js"></script>
    <script src="./js/dragfeature.js"></script>
    
    <!--jQuery dependencies-->
    <link rel="stylesheet" href="./css/jquery-ui.min.css" />
    <script src="./js/jquery-ui.min.js"></script>
<!--PQ Grid files-->
    <link rel="stylesheet" href="./css/pqgrid.min.css" />
    <script src="./js/pqgrid.min.js"></script>
<!--PQ Grid Office theme-->
	<link rel="stylesheet" href="./css/pqgrid.css" />
	<script src="./js/gridtable-admin.js"></script>
	<script src="./js/pq-localize-zh.js"></script>
	
	<link rel="stylesheet" href="./css/alertMessage.css" />
	<script src="./js/alertMessage.js"></script>

	<script>
	function closeWindow(){	
		open(location, '_self').close();
	}
	</script>

	<script>
	function formatDegree(value, isLon) {
        value = Math.abs(value);
		
        var du = Math.floor(value);
        var fen = Math.floor((value - du) * 60);
        var miao = Math.round((value - du) * 3600 % 60);
		/*
		var str1 = String(value).split(".");
		var du = str1[0];
		var tp = "0."+str1[1]
		var tpStr = String(tp*60);
		var str2 = tpStr.split(".");
		var fen =str2[0];
		tp = "0."+str2[1];
		miao = String(tp*60);
		*/
		var prefix;
		if(isLon) {
			if(value >= 0)
				prefix = "E";
			else
				prefix = "W";
		} else {
			if(value >=0)
				prefix = "N";
			else
				prefix = "S";
		}
        return prefix +du + '°' + fen + '\'' + miao + '"';
    }
	
	function getDegreeValue(coordinate) {
		var lonDegreeValue = formatDegree(coordinate[0], true);
		var latDegreeValue = formatDegree(coordinate[1], false);
		return (lonDegreeValue + ", " + latDegreeValue);
	}
    function DegreeConvertBack(value)
    {
        var du = value.split("°")[0];
        var fen = value.split("°")[1].split("'")[0];
        var miao = value.split("°")[1].split("'")[1].split('"')[0];
		
		var str = parseInt((Math.abs(fen)/60 + Math.abs(miao)/3600) * 10000);
		var str = (Math.abs(fen)/60 + Math.abs(miao)/3600).toFixed(5)+"";
		str = str.split(".");
        return Math.abs(du) + "." + str[1];
    }
	</script>
	<script  type="text/javascript">
	var drawShapeZIndexOffset = 500;
	var markerLayerZIndexOffset = 600;
	var isChrome = window.navigator.userAgent.indexOf("Chrome") !== -1;
	var userName = "<%=session.getAttribute("name")%>";
	var userType = <%=session.getAttribute("type")%>;
	console.log("userName:"+userName+",userType:"+userType);
	var map;
	var chart;//for chart
	var waitingData=false;
	var hashtable = new Hashtable();
	var clickedMarkerName="";
	var markerClickStatus = false;
	var markerVectorSource = new ol.source.Vector();
	var markerLayer = new ol.layer.Vector({source: markerVectorSource});
	var startMarker=null, endMarker=null;
	var enabledDrawRoute=false;
	var useHandCursor=false;
	var drawRouteArrayObj = new Array();//array[0] is end point; array[1] is start point
	var measureDraw = null;
	var selectSingleClick = null;
	var translateSelectObject = null;
	var selectMeasureCollection;
	var overviewMapControl = null;
	var globalAirportJsonData = null;
	var planDataRefreshTime = 30 * 1000;
	var needPlanDataRefresh = false;
	var transferRadian = 3.14 / 180;

	var routeMarkerVectorSource = new ol.source.Vector();
	var routeMarkerLayer = new ol.layer.Vector({source: routeMarkerVectorSource});
	var routeVectorSource = new ol.source.Vector();
	var routeLayer = new ol.layer.Vector({source: routeVectorSource});
	
	var drawShapeFeatureLayer = null;
	var drawFeatureFeatureObject = null;
	var drawFeatureDrawObject = null;
	
	function isNull(data){
		return (data == "" || data == undefined || data == null); 
	}

	function getFeatures() {
		var f = selectSingleClick.getFeatures();
		return f;
	}
    function init()  
    {
		var format = 'image/png';
		var bounds = [44.999999999999986,11.198298268415371,168.7706491551653,61.60640512730129];//[73.44695998458512,3.6193745040060596,135.07924998249888,53.557498986448266];
		var gr = new ol.tilegrid.TileGrid({
		origin : [ -180.0,-90.0 ],
		resolutions : [ 0.703125, 0.3515625, 0.17578125, 0.087890625, 0.0439453125, 0.02197265625, 0.010986328125, 0.0054931640625, 0.00274658203125, 0.001373291015625, 6.866455078125E-4, 3.4332275390625E-4, 1.71661376953125E-4, 8.58306884765625E-5, 4.291534423828125E-5, 2.1457672119140625E-5, 1.0728836059570312E-5, 5.364418029785156E-6, 2.682209014892578E-6, 1.341104507446289E-6, 6.705522537231445E-7, 3.3527612686157227E-7 ]
		//resolutions : [ 0.0439453125, 0.02197265625, 0.010986328125, 0.0054931640625, 0.00274658203125, 0.001373291015625, 6.866455078125E-4, 3.4332275390625E-4, 1.71661376953125E-4, 8.58306884765625E-5]
		});
		var layer1 = [new ol.layer.Tile({
			source : new ol.source.TileWMS({
				//url : 'http://127.0.0.1:8080/geoserver/gwc/service/wms',
				url:'../geoserver/gwc/service/wms',
				params : {
					'FORMAT' : format,
					'VERSION' : '1.1.1',
					'SRS' : 'EPSG:4326',
					'tiled' : true,
					//'LAYERS' : 'china-shp-bou2_4p:bou2_4p',
					'LAYERS' : 'sjz5-map5:sjz-big12_pro-5',
					STYLES : ''
				},
				tileGrid : gr,
				serverType: 'geoserver'
			})
		})];
		var projection = new ol.proj.Projection({
          code: 'EPSG:4326',
          units: 'degrees',
          //axisOrientation: 'neu'
		});
        
        var mouseFormat = function() {
        	return (
        		function(coord) {
        			return getDegreeValue(coord);
        		}
        	);
        };
		map = new ol.Map({
			interactions: ol.interaction.defaults({doubleClickZoom :false}).extend([new app.Drag()]),
			controls: ol.control.defaults().extend([
        		//new ol.control.MousePosition({coordinateFormat: ol.coordinate.createStringXY(4)}),
        		new ol.control.MousePosition({coordinateFormat: mouseFormat()}),
      		]),
			target: 'map',
			layers: layer1,
			view: new ol.View({
			   projection: projection,
			   minZoom: 4,
			   maxZoom: 11,
			   extent:[70,16,139,54]//zoom 9
						//center: [76.5, 9.5],               
						//zoom: 5
			})
		});
		
		//console.log("layer getMaxResolution:"+layer1.getMaxResolution());
		//console.log("map getMaxResolution:"+map.getView().getMaxResolution());
		//console.log("overviewMap getMaxResolution:"+overviewMap.getMap().getView().getMaxResolution());
       //var extent= [73.446940449218,16.3186411857604,135.08583068847,53.557926177978];
		var extent= [44.999999999999986,11.198298268415371,168.7706491551653,61.60640512730129];
		map.getView().fit(extent, map.getSize());

		map.getView().setCenter([106,35]);
		map.getView().setZoom(4);
	
		map.addLayer(routeLayer);
		routeLayer.setZIndex(2);
		map.addLayer(routeMarkerLayer);
		routeMarkerLayer.setZIndex(2);
		map.addLayer(markerLayer);
		//markerLayer.setZIndex(markerLayerZIndexOffset);
		markerLayer.setZIndex(5);
		
		drawShapeFeatureLayer = creatDrawFeatureLayer(map);
		drawShapeFeatureLayer.setZIndex(0);
		map.addLayer(drawShapeFeatureLayer);
		
		measureDraw = measureAddInteraction(map, true);
		measureDraw.setActive(false);
	
		// select interaction working on "singleclick"
		selectSingleClick = new ol.interaction.Select({
		
			layers: function(layer) {
				if(layer === drawShapeFeatureLayer)
					return true;
				return false;
			},
			multi: true // multi is used in this example if hitTolerance > 0
		});
		
		if (selectSingleClick !== null) {
			map.addInteraction(selectSingleClick);
			selectSingleClick.setActive(false);
			selectSingleClick.on('select', function(e) {
				selectMeasureCollection = e.target.getFeatures();
			});
			
			translateSelectObject = new ol.interaction.Translate({
		        features: getFeatures(),
		    });
		    translateSelectObject.setActive(false);
		    map.addInteraction(translateSelectObject);
		}

		var opt_options = {
        	layerFilter:function(layer) {
					console.log("click enter markerLayer check");
					return layer === markerLayer;
	        },};
		map.on('click', function(evt) {
			console.log("click start!!!");
			var f = map.forEachFeatureAtPixel(
				evt.pixel,
				function(feature, layer) {
					console.log("click enter feature check");
					return feature;
				}, /*null, */
				opt_options);
			
			console.log("click enter map.getView.getCenter:"+map.getView().getCenter());
			//var center = map.getView().getCenter();
			//console.log("center lon:"+center[0]+", lat:"+center[1]+", zoom:"+map.getView().getZoom());
			
			if (f || markerClickStatus) {
				//onMarkerClick(f, element);
			}
			
			if(enabledDrawRoute) {
				//console.log("click enter 1111111");
				var coordinate = map.getCoordinateFromPixel(evt.pixel);
				var degreeValue = getDegreeValue(coordinate);
				var point = createPoint(degreeValue,coordinate[0],coordinate[1]);
				drawRouteArrayObj.push(point);
				addRoutePointInTable(degreeValue);
				
				routeVectorSource.clear();
				drawRoute(false);
			}
			
			console.log("click enter end");
		});
		
		var cursorHoverStyle="pointer";
		var cursorTarget=map.getTarget();
		var jTarget=typeof cursorTarget === "string" ? $("#"+cursorTarget) : $(cursorTarget);
		map.on('pointermove', function(evt) {
			var mouseCoord=[evt.originalEvent.offsetX, evt.originalEvent.offsetY];
			//var hit=map.forEachFeatureAtPixel(mouseCoord, function(feature,layer){
			//	return true;
			//});
			if(useHandCursor){
				jTarget.css("cursor", cursorHoverStyle);
			} else {
				jTarget.css("cursor","");
			}
			
			pointerMoveHandler(evt);
		});

		//window.setInterval("onRequestAllFlightsData(\"FLIGHT1\")",1000); 
		window.setInterval("start()",400); 
    }   
	
	function clearRouteSource() {
		routeVectorSource.clear(); 
		routeMarkerVectorSource.clear();
	}
	
	function addOverviewMap() {
		var overviewMapView = new ol.View({
			projection: 'EPSG:4326',
			center: [116.5, 39.5],
			zoom: 4
		});
		overviewMapControl = new ol.control.OverviewMap({view:overviewMapView});
		map.addControl(overviewMapControl);
	}
	
	function removeOverviewMap() {
		map.removeControl(overviewMapControl);
		overviewMapControl = null;
	}
	
	function setOverviewMapControl() {
		if(overviewMapControl == null)
			addOverviewMap();
		else
			removeOverviewMap();
	}
	
	function overviewMapControlDisabled() {
		if(overviewMapControl == null)
			return true;
		else
			return false;
	}
	
	function setMeasureControl() {
		if(measureDraw.getActive()) {
			closeMeasureControl();
		} else {
			openMeasureControl();
		}
	}
	
	function drawLine(lon1, lat1, lon2, lat2, dashline) {

		var line = new ol.Feature({
			geometry:new ol.geom.LineString(
				[[lon1, lat1], [lon2,lat2]])
		});
		if(!dashline) {
			line.setStyle(new ol.style.Style({
				stroke: new ol.style.Stroke({
				width: 3,
				color: [255, 0, 0, 1]
				})
			}));
		} else {
			line.setStyle(new ol.style.Style({
				stroke: new ol.style.Stroke({
				width: 3,
				color: [0, 0, 255, 1],
				lineDash: [.1, 5]
				})
			}));
		}
		routeVectorSource.addFeature(line);
	}
	
	function drawRoute(fromDB){
		var sPoint = drawRouteArrayObj[1];
		var sCoordinate=sPoint.getGeometry().getCoordinates();
		for(var i = 2; i < drawRouteArrayObj.length; i++){
			var ePoint = drawRouteArrayObj[i];
			routeVectorSource.addFeature(ePoint);
			var eCoordinate=ePoint.getGeometry().getCoordinates();
			drawLine(sCoordinate[0], sCoordinate[1], eCoordinate[0], eCoordinate[1], false);
			sCoordinate = eCoordinate;
		}
		var ePoint = drawRouteArrayObj[0];
		var eCoordinate=ePoint.getGeometry().getCoordinates();
		if(fromDB)
			drawLine(sCoordinate[0], sCoordinate[1], eCoordinate[0], eCoordinate[1], false);
		else
			drawLine(sCoordinate[0], sCoordinate[1], eCoordinate[0], eCoordinate[1], true);
	}
	
	function createFlightPopup(marker, strArray){
		var popupDiv = document.createElement("div");
		popupDiv.setAttribute('class','ol-popup');
		popupDiv.setAttribute('style','-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;');
		
		popupDiv.onclick = function () {
			if(popupDiv.style.backgroundColor == "red")
				popupDiv.style.backgroundColor = "white";
			else
           		popupDiv.style.backgroundColor = "red";
        }
        
		var contentDiv = document.createElement("div");
		popupDiv.appendChild(contentDiv);
        var mapElement = document.getElementById("map");
        mapElement.appendChild(popupDiv);

	    var popup = new ol.Overlay({
          element: popupDiv,
          
        });
        popup.popup_marker = marker;
	    map.addOverlay(popup);
	  
        var coordinate =  marker.getGeometry().getCoordinates();


        popup.setPosition(coordinate);
        
        contentDiv.innerHTML=
        		'<span>'+strArray[0]+'</span><br>'+
          		'<span>'+strArray[1]+'</span><br>'+
          		'<span>'+strArray[2]+'</span><br>'+
          		'<image src=./img/zoom-world-mini.png></image><span>' + strArray[3] + '</span>';

        return popup;
	}
	function deletePopup(popup){
		popup.popup_marker = null;
		//delete popup;???
	}
	function deleteFlightMarker(marker){
		marker.marker_popup = null;
	}
	function createFlightMarker(name, lon, lat, ori, strArray) {

		var currentPoint = new ol.geom.Point([lon, lat]);
		var rotation = ori*3.14/180;
		var styleGeomarker = new ol.style.Style({
			image: new ol.style.Icon({  
				src: 'img/marker.png',  
				rotateWithView: false,  
				rotation: rotation  
			})
		});
		
		var feature = new ol.Feature(currentPoint);
		feature.setStyle(styleGeomarker);
		feature.name = name;
		feature.marker_popup = createFlightPopup(feature, strArray);
		return feature;
	}

	var globalTime=0;
	function start() {
		//map.on('postcompose', animationTest);
		//map.render();
		//testLine();
		
		//console.log("zoom:"+map.getView().getZoom());
		//console.log("start: start");
		if(waitingData) {
			console.log("waiting data!!!");
			return;
		}
		waitingData = true;
		onRequestAllFlightsData(clickedMarkerName);
		//console.log("start: end");
		
		if(globalTime == 0) {
			globalTime = new Date().getTime();
		} else {
			var tTime = new Date().getTime();
			if((tTime - globalTime) > planDataRefreshTime && needPlanDataRefresh) {
				requirePlan();
				globalTime = tTime;
			}
		}
	}

	function onMarkerClick(marker, ele) {
		if(markerClickStatus) {
			//$("#map").height("100%");
			//$("#path").hide();
			//map.updateSize();
			
			markerClickStatus = false;
			document.getElementById("name").value = "";
			document.getElementById("lon").value = 0;
			document.getElementById("lat").value = 0;
			document.getElementById("start").value = "";
			document.getElementById("end").value = "";
			clickedMarkerName = "";
			clearRouteSource();
			//markerVectorSource.removeFeature(startMarker);
			startMarker = null;
			//markerVectorSource.removeFeature(endMarker);
			endMarker = null;
			
			if(chart.series.length > 1) {
				chart.series[1].remove(false);
				chart.series[0].remove(false);
			}
			else if(chart.series.length == 1)
				chart.series[0].remove(false);
			if(chart_time.series.length > 1) {
				chart_time.series[1].remove(false);
				chart_time.series[0].remove(false);
			}
			else if(chart_time.series.length == 1)
				chart_time.series[0].remove(false);
			popupMarker = null;
			return;
		}

		//$("#map").height("80%");
		//$("#path").show();
		map.updateSize();

		markerClickStatus = true;
		var style = marker.getStyle();
		if(style.getImage()) {
			var coordiante = marker.getGeometry().getCoordinates();
			var name=marker.name;
			clickedMarkerName = name;
			var lon=coordiante[0];
			var lat=coordiante[1];
			document.getElementById("name").value = name;
			document.getElementById("lon").value = lon;
			document.getElementById("lat").value = lat;
		}
	}

	var lastTime=null;
	function parserAllFlightsData(jsonData)
	{
		if(lastTime==null){
			lastTime=new Date().getTime();
		} else {
			tTime=new Date().getTime();
			//console.log("subTime:"+(tTime-lastTime));
			lastTime = tTime;
		}
		//var jsonObj = JSON.parse(string);
		//for (var i = 0; i < persons.length; i++)
		//alert(jsonData.flight[0].name);
		
		for(var p in jsonData.flight){
			var name = jsonData.flight[p].name;
			var lon = jsonData.flight[p].lon;
			var lat = jsonData.flight[p].lat;
			var ori = jsonData.flight[p].ori;
			var marker = hashtable.get(name);

			if (!marker) {
				var strArray=new Array(4);
				strArray[0]="AL";
				strArray[1]="CXA0533 A605";
				strArray[2]="0950A 0889";
				strArray[3]="厦门航空公司";
				marker = createFlightMarker(name, lon, lat, ori,strArray);
				console.log("new marker, ori:"+ori);
				hashtable.add(name,marker);
				markerVectorSource.addFeature(marker);
			} else {
				marker.getGeometry().setCoordinates([lon, lat]);
				marker.marker_popup.setPosition([lon, lat]);
				var style = marker.getStyle();
				var image = style.getImage();
				var rotation = ori*3.14/180;
				image.setRotation(rotation);
				marker.setStyle(style);
				
				if(clickedMarkerName == name){
					document.getElementById("name").value = name;
					document.getElementById("lon").value = lon;
					document.getElementById("lat").value = lat;
				}
				//console.log("parserAllFlightsData new style!!! lon:"+lon+", lat:"+lat);
			}
			if(map.getView().getZoom()>=7) {
				//if($(marker.marker_popup.getElement()).hasClass('in')==false)
				marker.marker_popup.getElement().style.display="";
			} else {
				//if($(marker.marker_popup.getElement()).hasClass('in'))
					marker.marker_popup.getElement().style.display="none";
			}
		}
		if(clickedMarkerName != "") {
			if (typeof(jsonData.sFlight) != "undefined")
				parserSpecificFlightData(jsonData.sFlight);
			if (typeof(jsonData.radar) != "undefined") {
				parserRadarData(jsonData.radar);
				parserRadarTimeData(jsonData.radar);
			}
		}
		
		if(markerClickStatus) {
			var coordinates = popupMarker.getGeometry().getCoordinates();
			popup.setPosition(coordinates);
		}

	}


	var globalId = 1;
	function onRequestAllFlightsData(flightName)
	{
		var idString = String(globalId);
		var urlString = "data.jsp?name="+flightName+"&id="+idString;
		globalId++;
		
		//test!!!
		if(globalId > 200) globalId = 1;
		
		//var urlString = "http://127.0.0.1:8080/geoserverData.jsp?name="+flightName;
		//console.log("mike:" + urlString);
		$.ajax({
			type:"GET",
			url: urlString,
			dataType:"json",
			crossDomain: true,
			success:function(jsonData){
				waitingData = false;
				//console.log("mike:"+ jsonData);
				map.once('postcompose', function(){parserAllFlightsData(jsonData);});
				map.render();
			},
			error:function()
			{
				waitingData = false;
				console.log("ajax error!!! "+arguments[1]);
			}
		});
	}

	function onRequestSpecificFlightData(name)
	{
		var urlString = "data.jsp?name="+name;
		//var urlString = "http://127.0.0.1:8080/geoserverData.jsp?name="+name;
		console.log("mike:" + urlString);
		$.ajax({
			type:"GET",
			url: urlString,
			dataType:"json",
			crossDomain: true,
			success:function(jsonData){
				console.log("mike:"+ jsonData);

				map.once('postcompose', function(jsonData){parserSpecificFlightData(jsonData);});
				map.render();
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
	}
	
	function getAirportCoord(airportName) {
		for(var p in globalAirportJsonData){
			var name = globalAirportJsonData[p].name;
			if(airportName == name) {
				var lon = globalAirportJsonData[p].lon;
				var lat = globalAirportJsonData[p].lat;
				return [lon, lat];
			}
		}
		return null;
	}
	
	function parserAirportData(jsonData)
	{
		var objStartSelect=document.getElementById("start_select");
		var objEndSelect=document.getElementById("end_select");
		for(var p in jsonData.airport){
			var name = jsonData.airport[p].name;
			var lon = jsonData.airport[p].lon;
			var lat = jsonData.airport[p].lat;
			var objStartOption = document.createElement("OPTION");
			objStartOption.text= name;
			objStartOption.value=lon+","+lat;
			objStartSelect.options.add(objStartOption);
			var objEndOption = document.createElement("OPTION");
			objEndOption.text= name;
			objEndOption.value=lon+","+lat;
			objEndSelect.options.add(objEndOption);
		}

	}
	
	function onRequestAirport()
	{
		var urlString = "airport.jsp";
		$.ajax({
			type:"GET",
			url: urlString,
			dataType:"json",
			crossDomain: true,
			success:function(jsonData){
				console.log("mike:"+ jsonData);
				globalAirportJsonData = jsonData.airport;
				parserAirportData(jsonData);
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
	}
	onRequestAirport();
	
	function onSaveRoute()
	{
		var urlString = "saveroute.jsp";
		var content = document.getElementById("routeContent").value;
		if(content.indexOf("[") > 0 || content.indexOf("<") > 0){
			alert("航线不能包括 [ 和 < 字符");
			return;
		}
		$.ajax({
			type:"POST",
			url: urlString,
			async: true,
			data: "route="+content,
			//dataType:"json",
			crossDomain: true,
			success:function(message){
				var result = message.trim();
				if(result == "success") {
					alert("保存成功");
				} else {
					alert(result);
				}
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
	}
	
	function parserRouteData(jsonData) {
	
		if(jsonData.route.length > 0) {
			document.getElementById("readRouteSpanId").style.display = "none"
			document.getElementById("readRouteTableId").style.display = "";
			
			for(var p in jsonData.route){
				var data = jsonData.route[p].data;
				addReadRouteInTable(data);
			}
		} else {
			document.getElementById("readRouteSpanId").style.display = ""
			document.getElementById("readRouteTableId").style.display = "none";
		}
		
	}
	function onRequestRoute()
	{
		var startName = $('#start_select option:selected').text();
		var endName = $('#end_select option:selected').text();
		var urlString = "readroute.jsp?startName="+startName+"&endName="+endName;
		$.ajax({
			type:"POST",
			url: urlString,
			dataType:"json",
			crossDomain: true,
			success:function(jsonData){
				console.log("onRequestRoute:"+ jsonData);
				parserRouteData(jsonData);
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
	}
	
	function onDrawRoute(route) {
		clearRouteSource();
		if(isNull(route))
			return;
		createRouteFromDB(route);
		drawRoute(true);
	}
	</script> 
	<script>
	function createPoint(name, lon, lat) {
		var circle = new ol.style.Style({
	    	image: new ol.style.Circle({
	        	radius: 5,
	        	fill: new ol.style.Fill({
	            	color: 'rgba(255, 0, 0, 1)',}),
	        	//stroke: new ol.style.Stroke({color: 'rgba(255,0,0,0.9)',width: 1})
	    	}),
			text: new ol.style.Text({
	        	text: name,
	        	scale: 1,
				offsetX: 12,
				offsetY: -12,
	        	fill: new ol.style.Fill({
	          		color: '#000000'
	        	}),
	        	stroke: new ol.style.Stroke({
	          		color: '#FFFF99',
	          	width: 3.5
	        	})
	      	})
		});
	
		var feature = new ol.Feature({
			geometry: new ol.geom.Point([lon, lat]),
			name: 'Point'
		});
	
		feature.setStyle(circle);
		return feature;
	}
	
	function createStartAndEndMarker(sCoord, eCoord) {
		var adjustY = 0;
		var sPixel = map.getPixelFromCoordinate(sCoord);
		sPixel[1] = sPixel[1] + adjustY;//adjust image position
		var sPoint = new ol.geom.Point(map.getCoordinateFromPixel(sPixel));
		var sStyleGeomarker = new ol.style.Style({  
			image: new ol.style.Icon({  
				src: './img/start-big.png',  
				rotateWithView: false,
			})
		});
		var sFeature = new ol.Feature(sPoint);
		sFeature.setStyle(sStyleGeomarker);
		sFeature.name = $('#start_select option:selected').text() + '(' + getDegreeValue(sCoord) + ')';
		routeMarkerVectorSource.addFeature(sFeature);
		
		var ePixel = map.getPixelFromCoordinate(eCoord);
		ePixel[1] = ePixel[1] + adjustY;//adjust image position
		var ePoint = new ol.geom.Point(map.getCoordinateFromPixel(ePixel));
		var eStyleGeomarker = new ol.style.Style({  
			image: new ol.style.Icon({  
				src: './img/end-big.png',  
				rotateWithView: false,
			})
		});
		var eFeature = new ol.Feature(ePoint);
		eFeature.setStyle(eStyleGeomarker);
		eFeature.name = $('#end_select option:selected').text() + '(' + getDegreeValue(eCoord) + ')';
		routeMarkerVectorSource.addFeature(eFeature);
		
		drawRouteArrayObj.push(eFeature);//index==0 is the end point
		drawRouteArrayObj.push(sFeature);
	}
	
	function enableDrawRouteFlag() {
		enabledDrawRoute=true;
		useHandCursor=true;
		var objStartSelect=document.getElementById("start_select");
		objStartSelect.setAttribute('disabled', "disabled");
		var objEndSelect=document.getElementById("end_select");
		objEndSelect.setAttribute('disabled', "disabled");
		
		var objRouteEditDiv=document.getElementById("routeEditDivId");
		objRouteEditDiv.style.display="";
		disableReadRoute();
	}
	
	function disableDrawRouteFlag() {
		enabledDrawRoute=false;
		useHandCursor=false;
		//var objStartSelect=document.getElementById("start_select");
		//objStartSelect.removeAttribute('disabled');
		//var objEndSelect=document.getElementById("end_select");
		//objEndSelect.removeAttribute('disabled');
		
		var objRouteEditDiv=document.getElementById("routeEditDivId");
		objRouteEditDiv.style.display="none";
		
		var element=document.getElementById("drawButtonId");
		element.style.backgroundColor=oriButtonColor;
		clearRouteSource();
		drawRouteArrayObj.splice(0,drawRouteArrayObj.length);
		enableToolsScale();
	}
	
	var oriButtonColor=null;
	function enableDrawRoute() {
		$("#editRouteTableBodyId").html("");
		var clickedButtonColor = "#50ff50";
		var element=document.getElementById("drawButtonId");
		if(oriButtonColor==null) {
			oriButtonColor=element.style.backgroundColor;
		}
		if(enabledDrawRoute){
			//element.style.backgroundColor=oriButtonColor;
			disableDrawRouteFlag();
			
			//routeVectorSource.clear();
			//routeMarkerVectorSource.clear();
			//drawRouteArrayObj.splice(0,drawRouteArrayObj.length);
			//enableToolsScale();
		} else {
			element.style.backgroundColor=clickedButtonColor;
			enableDrawRouteFlag();
			
			var startName = $('#start_select option:selected').text();
			var endName = $('#end_select option:selected').text();
			var sCoordinate = getAirportCoord(startName);
			var eCoordinate = getAirportCoord(endName);
			createStartAndEndMarker(sCoordinate, eCoordinate);
			
			var sV1 = "起飞";
			var sV2 = startName + '(' + getDegreeValue(sCoordinate) + ')';
			var sV3 = "<input disabled='disabled' type='button' value='删除' onclick='onDeleteRouteTableRow(this)' class='input2' />";
			createRouteTableRow(sV1, sV2, sV3, -1);
			
			var eV1 = "降落";
			var eV2 = endName + '(' + getDegreeValue(eCoordinate) + ')';
			var eV3 = "<input disabled='disabled' type='button' value='删除' onclick='onDeleteRouteTableRow(this)' class='input2' />";
			createRouteTableRow(eV1, eV2, eV3, -1);
			disableToolsScale();
			disableDrawShapeFlag();
		}
		//document.getElementById("routeEditAndSelectId").innerHTML = "航线编辑";
	}
	
	function createRouteTableRow(v1, v2, v3, index) {
		var tBody=document.getElementById("editRouteTableBodyId");
		var rowIndex = index;
		if(rowIndex < 0)
			rowIndex = tBody.rows.length;
		var tr = tBody.insertRow(rowIndex);
		var td0 = tr.insertCell(0);
		td0.style.width = "10%";
		td0.innerHTML = v1;
		var td1 = tr.insertCell(1);
		td1.style.width = "80%";
		td1.innerHTML = v2;
		var td2 = tr.insertCell(2);
		td2.style.width = "10%";
		td2.style.align = "right";
		td2.innerHTML = v3;	
	}
	
	function addRoutePointInTable(degree) {
		var v1 = "途径";
		var v2 = degree;
		var v3 = "<input type='button' value='删除' onclick='onDeleteRouteTableRow(this)' class='input2' />";
		var tBody=document.getElementById("editRouteTableBodyId");
		createRouteTableRow(v1, v2, v3, (tBody.rows.length-1));
	}
	function onDeleteRouteTableRow(target) {
		var i=target.parentNode.parentNode.rowIndex;
		document.getElementById('editRouteTableBodyId').deleteRow(i);

		drawRouteArrayObj.splice((i+1), 1);//[0] is end, [1] is start
		routeVectorSource.clear();
		drawRoute(false);
	}
	
	function enableReadRoute() {
		$("#readRouteTableBodyId").html("");
		if(enabledDrawRoute){
			disableDrawRouteFlag();
			document.getElementById("routeContent").value = "";
		} else {
			clearRouteSource();
		}
		var objReadRouteDiv=document.getElementById("readRouteDivId");
		objReadRouteDiv.style.display="";
		onRequestRoute();
	}
	
	function disableReadRoute() {

		var objReadRouteDiv=document.getElementById("readRouteDivId");
		objReadRouteDiv.style.display="none";
		clearRouteSource();
		drawRouteArrayObj.splice(0,drawRouteArrayObj.length);
	}
	
	function saveRouteInDB() {
		///test
		for(var i = 0; i < selectMeasureCollection.getLength(); i++) {
			var feature = selectMeasureCollection.getArray()[i];
			//getMeasureSource().removeFeature(feature);
		}
		selectMeasureCollection.clear();
	}
	function routeCreationDone() {
		var result=null;
		var sPoint = drawRouteArrayObj[1];
		var sCoordinate=sPoint.getGeometry().getCoordinates();
		var sV = sPoint.name;
		result = sV + "--";
		for(var i = 2; i < drawRouteArrayObj.length; i++){
			var point = drawRouteArrayObj[i];
			result = result + "(" + point.getStyle().getText().getText() + ")" + "--";
		}
		var ePoint = drawRouteArrayObj[0];
		result = result + ePoint.name;
		document.getElementById("routeContent").value = result;
	}
	
	function routeSelectionDone() {
		var chkObjs = document.getElementsByName("readRouteRadio");
        for(var i=0;i<chkObjs.length;i++){
        	if(chkObjs[i].checked){
                var row=chkObjs[i].parentNode.parentNode;
				var data = row.cells[1].childNodes[0].value;
				document.getElementById("routeContent").value = data;
                break;
            }
        }
		
	}
	
	function getCoordinateFromDB(str) {
		var regex="\\((.+?)\\)";
		var degreeValue = str.match(regex);
		var coord = degreeValue[1].split(",");
		//TODU: 目前没有处理西经和南纬
		var lon = DegreeConvertBack(coord[0].split("E")[1]);
		var lat = DegreeConvertBack(coord[1].split("N")[1]);
		return [lon, lat];
	}
	function createRouteFromDB(data) {
		drawRouteArrayObj.splice(0,drawRouteArrayObj.length);
		var strArray = data.split("--");
		var sCoord = getCoordinateFromDB(strArray[0]);
		var eCoord = getCoordinateFromDB(strArray[strArray.length-1]);
		createStartAndEndMarker(sCoord, eCoord);
		for(var i = 1; i < strArray.length-1; i++) {
			var coord = getCoordinateFromDB(strArray[i]);
			var regex="\\((.+?)\\)";
			var temp = strArray[i].match(regex);
			var degreeValue = temp[1];

			var point = createPoint(degreeValue,coord[0],coord[1]);
			drawRouteArrayObj.push(point);
		}
	}
	function onDisplayRouteFromDB(target) {
		clearRouteSource();
		
		var row=target.parentNode.parentNode;
		var data = row.cells[1].childNodes[0].value;
		createRouteFromDB(data);
		drawRoute(true);
	}
	
	function onDeleteRouteFromDB(target) {
		
		var row=target.parentNode.parentNode;
		var data = row.cells[1].childNodes[0].value;
		
		var i=target.parentNode.parentNode.rowIndex;
		var tBody=document.getElementById("readRouteTableBodyId");
		tBody.deleteRow(i);
		
		if(tBody.rows.length == 0) {
			rowIndex = tBody.rows.length;
			var objReadRouteDiv=document.getElementById("readRouteDivId");
			objReadRouteDiv.style.display="none";
		}
		var urlString = "deleteroute.jsp";
		$.ajax({
			type:"POST",
			url: urlString,
			async: true,
			data: "data="+data,
			//dataType:"json",
			crossDomain: true,
			success:function(message){
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
	}
	
	function createReadRouteTableRow(v1, v2, v3, index) {
		var tBody=document.getElementById("readRouteTableBodyId");
		var rowIndex = index;
		if(rowIndex < 0)
			rowIndex = tBody.rows.length;
		var tr = tBody.insertRow(rowIndex);
		var td0 = tr.insertCell(0);
		td0.style.width = "5%";
		td0.innerHTML = v1;
		var td1 = tr.insertCell(1);
		td1.style.width = "85%";
		td1.innerHTML = v2;
		var td2 = tr.insertCell(2);
		td2.style.width = "10%";
		td2.style.align = "right";
		td2.innerHTML = v3;	
	}
	
	function addReadRouteInTable(route) {
		var v1 = "<input type='radio' name='readRouteRadio' />";
		var v2 = "<textarea cols='50' rows='3'>"+route+"</textarea>";
		var v3_1 = "<input type='button' value='显示航线' onclick='onDisplayRouteFromDB(this)' class='input2' />";
		var v3_2 = "<input type='button' value='从数据库删除' onclick='onDeleteRouteFromDB(this)' class='input2' />";
		var v3 = v3_1 + v3_2;
		var tBody=document.getElementById("readRouteTableBodyId");
		createReadRouteTableRow(v1, v2, v3, (tBody.rows.length-1));
	}
	
	function clearContent() {
		var objStartSelect=document.getElementById("start_select");
		objStartSelect.removeAttribute('disabled');
		var objEndSelect=document.getElementById("end_select");
		objEndSelect.removeAttribute('disabled');
		
		var planDateId=document.getElementById("planDateId");
		planDateId.value = "";
		var planTimeId=document.getElementById("planTimeId");
		planTimeId.value = "";
		var planTaskId=document.getElementById("planTaskId");
		planTaskId.value = "";
		var planeType=document.getElementById("planeType");
		planeType.value = "";
		var altitude=document.getElementById("planeAltitude");
		altitude.value = "";
		var planeId=document.getElementById("planeId");
		planeId.value = "";
		var routeComments=document.getElementById("routeComments");
		routeComments.value = "";
		var routeContent=document.getElementById("routeContent");
		routeContent.value = "";
	}
	
	function processPlan(isApproved) {
		var planNum = $('#start_select').attr('planNum');
		if(isNull(planNum))
			return;
		var status = 2;
		if(isApproved) {
			status = 1;
		}
			
		var route=document.getElementById("routeContent").value;
		//in jsonobject, replace ' & " for DB
		if(route.indexOf("[") > 0 || route.indexOf("<") > 0){
			alert("航线不能包括 [ 和 < 字符");
			return;
		}
		route = route.replace(/\"/g,"[]");
		route = route.replace(/\'/g,"<>");
		var comments=document.getElementById("routeComments").value;
		comments = comments.replace(/\"/g,"[]");
		comments = comments.replace(/\'/g,"<>");
		if(comments.length > 1000) {
			alert("注释内容过长");
			return;
		}
		if(isApproved && isNull(route)) {
			alert("航线不能为空");
			return;
		}
		
		var altitude=document.getElementById("planeAltitude").value;
		var planeId=document.getElementById("planeId").value;
		
		var processData = "{planNum:'" + planNum +
			"',route:'" + route +
			"',comments:'" + comments +
			"',status:'" + status +
			"',altitude:'" + altitude +
			"',planeId:'" + planeId +
			"'}";
			
		var urlString = "processplan.jsp";
		$.ajax({
			type:"POST",
			url: urlString,
			async: true,
			data: "process="+processData,
			//dataType:"json",
			crossDomain: true,
			success:function(message){
				var result = message.trim();
				if(result == "success") {
					var planNum = $('#start_select').attr('planNum');
					var taskDiv = document.getElementById(planNum);
					var parent = taskDiv.parentNode;
					parent.removeChild(taskDiv);
					if(parent.childNodes.length == 0) {
						parent = parent.parentNode;
						parent.parentNode.removeChild(parent);
					}
					decreaseCounterSpan(false);
					//clearContent();
					//clearRouteSource();
					$('#start_select').attr('planNum',"");
					onClearRouteButton();
					alert("提交成功");
				} else {
					alert(result);
				}
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
		
	}
	
	function parserPlanData(planData) {
		if(planData.length > 0) {
			var string_value = String(planData.length); 
			setCounterSpan(string_value, false);
			parserPendingTask(planData);
		}
	}
	function requirePlan() {
		var urlString = "readplan.jsp";
		$.ajax({
			type:"POST",
			url: urlString,
			dataType:"json",
			crossDomain: true,
			success:function(jsonData){
				parserPlanData(jsonData.plan);
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
	}
	</script>
	<script>
	function setOption(selectEle, name){
		for(var i = 0; i < selectEle.options.length; i++){
			if(selectEle.options[i].innerHTML == name){
				selectEle.options[i].selected=true;
				break;
			}
		}
	}
	function planOnClick(target) {
		onClearRouteButton();
		var startName = target.getAttribute('startName');
		setOption(document.getElementById("start_select"), startName);
		$('#start_select').attr('planNum',target.getAttribute('planNum'));
		$('#start_select').attr('disabled',"disabled");
		var endName = target.getAttribute('endName');
		setOption(document.getElementById("end_select"), endName);
		$('#end_select').attr('disabled',"disabled");
		$('#planDateId').val(target.getAttribute('planDate'));
		$('#planTimeId').val(target.getAttribute('planTime'));
		$('#planTaskId').val(target.getAttribute('planTask'));
		$('#planeType').val(target.getAttribute('planeType'));
	}
	
	function onRadioChange(target){
		if(target.checked) {
			if(target.parentNode.childNodes.length != 2) {
				alert("plan nodes abnormal!!!");
				return;
			}
			var aNode=target.nextSibling;
			planOnClick(aNode);
			target.checked = true;//planOnClick will clear the flag, so revert
		}
	}
	function clearPlanRadio() {
		var radios = document.getElementsByName("planRadio");
		for(var i = 0; i < radios.length; i++) {
			if(radios[i].checked==true)
				radios[i].checked=false;
		}
	}
	function insertPendingTask(jsonObj) {
		var name = jsonObj.userName;
		var planNum = jsonObj.planNum;
		var taskName = planNum.split(name)[1];
		var ele = document.getElementById(name);
		
		var taskDiv = document.createElement("div");
		taskDiv.setAttribute('id',planNum);
		var radio=document.createElement("input");
		radio.setAttribute("type","radio");
		radio.setAttribute("name","planRadio");
		radio.setAttribute("onchange","onRadioChange(this)");
		taskDiv.appendChild(radio);
		
		var taskA = document.createElement("a");
		taskA.setAttribute('class',"zh-accordion-a");
		taskA.setAttribute('href',"javascript:void(0)");
		taskA.setAttribute('startName',jsonObj.startName);
		taskA.setAttribute('endName',jsonObj.endName);
		taskA.setAttribute('planDate',jsonObj.planDate);
		taskA.setAttribute('planTime',jsonObj.planTime);
		taskA.setAttribute('planTask',jsonObj.task);
		taskA.setAttribute('planeType',jsonObj.planeType);
		taskA.setAttribute('planNum',jsonObj.planNum);
		taskA.innerHTML = taskName;
		taskDiv.appendChild(taskA);
			
		if(ele == null) {
			var taskListDiv = document.getElementById("taskListDivId");
			var itemDiv = document.createElement("div");
			itemDiv.setAttribute('class','accordion-item');
			itemDiv.setAttribute('id',name);
			taskListDiv.appendChild(itemDiv);
			
			var headerDiv = document.createElement("div");
			headerDiv.setAttribute('class','accordion-header');
			itemDiv.appendChild(headerDiv);
			var hDiv = document.createElement("h1");
			hDiv.innerHTML = name;
			headerDiv.appendChild(hDiv);
			var iconDiv = document.createElement("div");
			iconDiv.setAttribute('class','accordion-header-icon');
			iconDiv.innerHTML = "&#9660";
			headerDiv.appendChild(iconDiv);
			
			var contentDiv = document.createElement("div");
			contentDiv.setAttribute('class','accordion-content');
			itemDiv.appendChild(contentDiv);
			
			contentDiv.appendChild(taskDiv);
		} else {
			var count= ele.childElementCount;
			var contentDiv = null;
			for(var i=0;i<count;i++) {
				if(ele.children[i].getAttribute('class')=="accordion-content") {
					contentDiv = ele.children[i];
					break;
				}
			}
			if(contentDiv != null) {
				var count= contentDiv.childElementCount;
				var newPlan = true;
				for(var i=0;i<count;i++) {
					if(contentDiv.children[i].getAttribute('id')==planNum) {
						newPlan = false;
						break;
					}
				}
				if(newPlan)
					contentDiv.appendChild(taskDiv);
			}
		}
	}
	function parserPendingTask(planData) {
		for(var p in planData){
			insertPendingTask(planData[p]);
		}
		$(".accordion").accordionwoco("resize");
	}
	
	function onClearRouteButton() {
		disableDrawRouteFlag();
		disableReadRoute();
		clearContent();
		clearPlanRadio();
	}
	function onRequestApplicationStatus() {
		showLoadingApplication();
		var urlString = "applicationstatus.jsp";
		$.ajax({
			type:"GET",
			url: urlString,
			dataType:"json",
			crossDomain: true,
			success:function(jsonData){
				console.log("application:"+ jsonData.application);
				clearApplication();
				addApplicationStatusRow(jsonData.application);
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
	}
	function onRequestUserInfo() {
		var urlString = "requestuserinfo.jsp?info=one";
		$.ajax({
			type:"GET",
			url: urlString,
			dataType:"json",
			crossDomain: true,
			success:function(jsonData){
				//console.log("application:"+ jsonData.userinfo);
				$('#tUserName').val(jsonData.name);
				$('#tCompany').val(jsonData.company);
				var typeStr = "";
				if(jsonData.type == 1)
					typeStr = "管理员";
				else if(jsonData.type == 2)
					typeStr = "普通用户";
				$('#tType').val(typeStr);
				$('#tEmail').val(jsonData.email);
				$('#tTel').val(jsonData.tel);
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
	}
	function changePassword() {
		var newPswEle = document.getElementById("cNewPassword");
		var newPsw = newPswEle.value;
		var rNewPswEle = document.getElementById("cReNewPassword");
		var rNewPsw = rNewPswEle.value;
		if(newPsw==""){
		   alert("密码不能为空");
		   return false;
		}
		if(newPsw!=rNewPsw){
			alert('密码不一致');
			return false;
		}
		var oldPswEle = document.getElementById("cPassword");
		var oldPsw = oldPswEle.value;
		var submitData = "{old:'" + oldPsw +
			"',new:'" + newPsw +
			"'}";
			
		var urlString = "changeuserinfo.jsp?info=psw";
		$.ajax({
			type:"POST",
			url: urlString,
			async: true,
			data: "userinfo="+submitData,
			//dataType:"json",
			crossDomain: true,
			success:function(message){
				var result = message.trim();
				if(result == "success") {
					alert("提交成功");
				} else {
					alert(result);
				}
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
		newPswEle.value = "";
		rNewPswEle.value = "";
		oldPswEle.value = "";
	}
	function changeEmail() {
		var cEmailEle = document.getElementById("cEmail");
		var email = cEmailEle.value;
		if(email==""){
		   alert("邮箱不能为空");
		   return false;
		}
		
		var submitData = "{email:'" + email +
			"'}";
			
		var urlString = "changeuserinfo.jsp?info=email";
		$.ajax({
			type:"POST",
			url: urlString,
			async: true,
			data: "userinfo="+submitData,
			//dataType:"json",
			crossDomain: true,
			success:function(message){
				var result = message.trim();
				if(result == "success") {
					alert("提交成功");
					onRequestUserInfo();
				} else {
					alert(result);
				}
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
		cEmailEle.value = "";
		
	}
	function changeTel() {
		var cTelEle = document.getElementById("cTel");
		var tel = cTelEle.value;
		if(tel==""){
		   alert("电话不能为空");
		   return false;
		}
		
		var submitData = "{tel:'" + tel +
			"'}";
			
		var urlString = "changeuserinfo.jsp?info=tel";
		$.ajax({
			type:"POST",
			url: urlString,
			async: true,
			data: "userinfo="+submitData,
			//dataType:"json",
			crossDomain: true,
			success:function(message){
				var result = message.trim();
				if(result == "success") {
					alert("提交成功");
					onRequestUserInfo();
				} else {
					alert(result);
				}
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
		cTelEle.value = "";
	}
	</script>
	</HEAD>
	<BODY  onload="init()">
  
   	<div style="position:relative; width:100%; background-color:rgb(200,200,200)" id="map" class="smallmap">
   		
   	</div>
 
 	<div id="editArea" style="display:none; height:29.5%; background:#eff7ff">
 	
	<ul class="tabUl" id="tabUlId">  
    	<li><a id="tabA1Id" onclick="sela(this);" href="#tabDiv1Id" class="sel">审批</a></li>  
    	<li><a id="tabA2Id" onclick="sela(this);" href="#tabDiv2Id">审批记录</a></li>
    	<li><a id="tabA3Id" onclick="sela(this);" href="#tabDiv3Id">用户信息</a></li>
	</ul>  
	<div id="tabDiv1Id" class="onTabDiv">
		<div style="width:14%;height:80%;float:left;">
			<div align="center">待审批计划</div>
			<div class="accordion" id="taskListDivId" style="width:90%;height:90%;float:left;overflow :auto;">
			
			</div>
		</div>
		<div style="width:40%;float:left"  style = "overflow: auto;">
			<table width="100%" cellpadding="0.5" cellspacing="1" style="font-size:12px">
			<tr>
				<td style="width:13%" align="left"><div align="left">起飞机场： </div></td>
				<td style="width:20%"><select id="start_select" style="width:80%" name="start_select"></select></td>
				<td style="width:13%" align="left"><div align="left">飞行日期：</div></td>
				<td style="width:20%">
					<input id="planDateId" readonly="readonly" style="width:80%" name="start_date" class="input_2"/>
				</td>
				<td style="width:13%" align="left"><div align="left">机型：</div></td>
				<td style="width:20%"><input id="planeType" readonly="readonly" style="width:80%" name="planeType" class="input_2"/></td>
				
			</tr>
			<tr>
				<td style="width:13%" align="left"><div align="left">降落机场： </div></td>
				<td style="width:20%"><select id="end_select" style="width:80%" name="end_select"></select></td>
				
				<td style="width:13%" align="left"><div align="left">起飞时间： </div></td>
				<td style="width:20%">
					<input id="planTimeId" readonly="readonly" style="width:80%" name="start_time" class="input_2"/>
				</td>
				<td style="width:13%" align="left"><div align="left">任务种类：</div></td>
				<td style="width:20%"><input id="planTaskId" readonly="readonly" style="width:80%" name="planTaskId" class="input_2"/></td>
			</tr>
			<tr>
				<td style="width:13%" align="left"><div align="left">高度(m)：</div></td>
				<td style="width:20%">
					<input id="planeAltitude" style="width:80%" name="planeAltitude" class="input_2"
						onkeyup="if(this.value.length==1){this.value=this.value.replace(/[^1-9]/g,'')}else{this.value=this.value.replace(/\D/g,'')}"  
    					onafterpaste="if(this.value.length==1){this.value=this.value.replace(/[^1-9]/g,'0')}else{this.value=this.value.replace(/\D/g,'')}"
    				/>
    			</td>
				<td style="width:13%" align="left"><div align="left">航班号：</div></td>
				<td style="width:20%"><input id="planeId" style="width:80%" name="planeId" class="input_2"/></td>
			<!-- 
				<td style="width:13%" align="left"><div align="left">二次代码： </div></td>
				<td style="width:20%"><input id="planeCode" style="width:80%" name="planeCode" class="input_2"/></td>
			 -->
				
			</tr>
			<tr>
				<td colspan="2" align="left">
					<table  style="font-size:12px">
						<tr>
							<td><div align="center">航线：</div></td>
						</tr>
						<tr>
							<td align="center">
								<div align="center" >
									<input id="readButtonId" type="submit" value="读取" onclick="enableReadRoute()" class="input2" />
									<input id="drawButtonId" type="submit" value="绘制" onclick="enableDrawRoute()" class="input2" />
									<input type="submit" value="保存" onclick="onSaveRoute()" class="input2" />
									
								</div>
							</td>
						</tr>
					</table>
				</td>
				<td colspan="4"><textarea style="width:94%" name="routeContent" cols="60" rows="3" id="routeContent" class="input_2"></textarea></td>
			</tr>
			<tr>
				<td style="width:10%" align="left"><div align="left">备注： </div></td>
				<td colspan="3" ><input id="routeComments" style="width:90%" name="routeComments" class="input_2"/></td>
				<td colspan="2" align="center">
					<div align="left" >
						<input type="submit" value="清除" onclick="onClearRouteButton()" class="input2" />
						<input type="submit" value="拒绝" onclick="processPlan(false)" class="input2" />
						<input type="submit" value="批准" onclick="processPlan(true)" class="input2" />
					</div>
				</td>
			</tr>
			</table>
    	</div>
		<div id = "routeEditDivId" style="width:34%; float:left; display:none; vertical-align:middle;">
			<div style="width:16%; font-size:14px; float:left;" align="center">
				<br><br>
				<span id="routeEditAndSelectId">航线编辑</span><br><br>
				<input type="button" value="确定" onclick="routeCreationDone()" class="input2" />
			</div>
			<div style="width:80%; float:left" align="center">
				<div style="height:80%; overflow :auto;">
					<table id="editRouteTableId" style="font-size:12px;" border="2">
						<tbody id="editRouteTableBodyId">
						</tbody>
					</table>
				</div>
			</div>
		</div>
		<div id = "readRouteDivId" style="width:45%; float:left; display:none; vertical-align:middle;">
			<div style="width:12%; font-size:14px; float:left;" align="center">
				<br><br>
				<span id="readRouteId">航线选择</span><br><br>
				<input type="button" value="确定" onclick="routeSelectionDone()" class="input2" />
			</div>
			<div style="width:87%; float:left" align="center">
				<div style="height:80%; overflow :auto;">
					<table id="readRouteTableId" style="font-size:12px; display:none" border="2">
						<tbody id="readRouteTableBodyId">
						</tbody>
					</table>
					<span id = "readRouteSpanId"> 没有记录，请添加</span>
				</div>
			</div>
		</div>

	</div>  
  
	<div id="tabDiv2Id" class="tabDiv" align="center"> 
		<div style="width:100%; height:80%;" align="center">  
			<div id="grid_search" style="width:100%; height:100%; font-size:12px" align="center" >
			</div> 
		</div>
	</div>
	<div id="tabDiv3Id" class="tabDiv" align="center"> 
		<div style="width:40%; height:80%;float:left;overflow:auto" align="center"> 
			<span>当前用户信息</span><br> 
			<table cellpadding="0.5" cellspacing="1" style="font-size:12px">
			<tr>
				<td style="width:20%" align="left"><div align="left">用户名： </div></td>
				<td style="width:70%"><input id="tUserName" readonly="readonly" style="width:80%;background-color:#a0a0a0" name="tUserName" class="input_2"/></td>
			</tr>
			<tr>
				<td style="width:20%" align="left"><div align="left">公司名称： </div></td>
				<td style="width:70%"><input id="tCompany" readonly="readonly" style="width:80%;background-color:#a0a0a0" name="tCompany" class="input_2"/></td>
			</tr>
			<tr>
				<td style="width:20%" align="left"><div align="left">用户类型： </div></td>
				<td style="width:70%"><input id="tType" readonly="readonly" style="width:80%;background-color:#a0a0a0" name="tType" class="input_2"/></td>
			</tr>
			<tr>
				<td style="width:20%" align="left"><div align="left">邮箱： </div></td>
				<td style="width:70%"><input id="tEmail" readonly="readonly" style="width:80%;background-color:#a0a0a0" name="tEmail" class="input_2"/></td>
			</tr>
			<tr>
				<td style="width:20%" align="left"><div align="left">电话： </div></td>
				<td style="width:70%"><input id="tTel" readonly="readonly" style="width:80%;background-color:#a0a0a0" name="tTel" class="input_2"/></td>
			</tr>
			</table>
		</div>
		<div style="width:50%; height:80%;float:left;overflow:auto" align="center">
			<span>修改用户信息</span><br>
			<table width="100%" cellpadding="0.5" cellspacing="1" style="font-size:12px">
				<tr>
					<td style="width:10%" align="left"><div align="left">旧密码： </div></td>
					<td style="width:37%"><input id="cPassword" type="password" style="width:80%" name="cPassword" class="input_2"/></td>
					<td style="width:10%"> </td>
					<td style="width:37%"> </td>
				</tr>
				<tr>
					<td style="width:10%" align="left"><div align="left">新密码： </div></td>
					<td style="width:37%"><input id="cNewPassword" type="password" style="width:80%" name="cNewPassword" class="input_2"/></td>
					<td style="width:10%" align="left"><div align="left">再次输入： </div></td>
					<td style="width:37%"><input id="cReNewPassword" type="password" style="width:80%" name="cReNewPassword" class="input_2"/></td>
				</tr>
			</table>
			<input id="cPasswordButtonId" type="button" value="修改密码" onclick="changePassword()" class="input2" />
			<table width="100%" cellpadding="0.5" cellspacing="1" style="font-size:12px">
				<tr>
					<td style="width:10%" align="left"><div align="left">新邮箱： </div></td>
					<td style="width:50%"><input id="cEmail" style="width:80%" name="cEmail" class="input_2"/></td>
					<td style="width:10%"><input id="cEmailButtonId" type="button" value="修改邮箱" onclick="changeEmail()" class="input2" /></td>
					<td style="width:30%"> </td>
				</tr>
			</table>
			
			<table width="100%" cellpadding="0.5" cellspacing="1" style="font-size:12px">
				<tr>
					<td style="width:10%" align="left"><div align="left">新电话： </div></td>
					<td style="width:50%"><input id="cTel" style="width:80%" name="cTel" class="input_2"/></td>
					<td style="width:10%"><input id="cTelButtonId" type="button" value="修改电话" onclick="changeTel()" class="input2" /></td>
					<td style="width:30%"> </td>
				</tr>
			</table>
			
		</div>
	</div>
 	</div>
 	<style type="text/css" >
    .moveDiv
    {
        width:240px;
        height:70px;
		top:50px;
		left:50px;
        position:absolute;
        background-color:#ccc;
        -webkit-box-shadow:1px 1px 3px #292929;
        -moz-box-shadow:1px 1px 3px #292929;
        box-shadow:1px 1px 3px #292929;
        margin:10px;
    }
            
    .moveDiv-title
    {
        color:#fff;
        background-color:rgb(13,42,73);
        font-size:12pt;
        font-weight:bold;
        padding:4px 6px;
        cursor:move;
    }
            
    .moveDiv-content
    {
        padding:4px;
    }
</style>
 	<div id="moveDiv" class="moveDiv" style="position:fixed;display:none">
		<div class="moveDiv-title" >
			<span>绘画板</span>
			<img src="img/close-16.png" alt="关闭" style="float:right"onclick="closeMoveDiv()"/>
		</div>
		
        <div class="moveDiv-content">
            <img id="drawLineImageId" src="img/line-32.png"  title="画线" onclick="drawLineMoveDiv()"/>
			<img id="drawRectangleImageId" src="img/rectangle-32.png"  title="画矩形" onclick="drawRectangleMoveDiv()"/>
			<img id="drawPolygonImageId" src="img/polygon-32.png"  title="画多边形" onclick="drawPolygonMoveDiv()"/>
			<img id="drawCircleImageId" src="img/circle-32.png"  title="画圆形" onclick="drawCircleMoveDiv()"/>
			<img id="handImageId" src="img/hand-32.png"  title="删除" onclick="handFeatureMoveDiv()"/>
			<img id="deleteImageId" src="img/delete-32.png"  title="删除所有图形" onclick="deleteFeatureMoveDiv()"/>
        </div>
    </div>
    <script type="text/javascript">
    function showDrawMoveDiv() {
    	var div = document.getElementById("moveDiv");
    	div.style.top = "50px";
    	div.style.left = "50px";
		div.style.display = "";
    }
    var isMoveDivTitle=false;
    function down(e){
        if(e.target.className.indexOf('moveDiv-title')!=-1){
            isMoveDivTitle=true;
        }
    }
            
    function move(e){
        var div=document.getElementById('moveDiv');
        if(isMoveDivTitle){//只有点击Div Title的时候才能拖动
            div.style.left=e.clientX+'px';
                div.style.top=e.clientY+'px';
        }
    }
            
    function up(e){
        isMoveDivTitle=false;
    }
            
    document.addEventListener('mousedown',down);
    document.addEventListener('mousemove',move);
    document.addEventListener('mouseup',up);

	function creatDrawFeatureLayer(map) {
		drawFeatureFeatureObject = new ol.Collection();
        var featureOverlay = new ol.layer.Vector({
        	source: new ol.source.Vector({features: drawFeatureFeatureObject}),
        	style: new ol.style.Style({
            	fill: new ol.style.Fill({
            		color: 'rgba(255, 255, 255, 0.2)'
          		}),
	          	stroke: new ol.style.Stroke({
	         	    color: [255,165,0],
	         	    width: 2
	        	}),
	         	image: new ol.style.Circle({
	         	    radius: 7,
	          	    fill: new ol.style.Fill({
	         	    	color: [255,165,0]
	         	    })
	        	})
       	 	})
        });
        //featureOverlay.setMap(map);
        return featureOverlay;
	}
	function closeMoveDiv() {
		disableDragFunction();
		document.getElementById("handImageId").style.background="";

		removeDrawFeatureFeatureObject();
		
		var div = document.getElementById("moveDiv");
		div.style.display = "none";
	}
	
	function disableDrawShapeFlag() {
		closeMoveDiv();
	}
	function removeDrawFeatureFeatureObject() {
		map.removeInteraction(drawFeatureDrawObject);
		drawFeatureDrawObject = null;
	}
	function drawShapeMoveDiv(shape) {
		if(drawFeatureDrawObject != null)
			return;
		var geometryFunction = null;
		if(shape == "Rectangle") {
			shape = "Circle";
			geometryFunction = ol.interaction.Draw.createBox();
		}
		drawFeatureDrawObject = new ol.interaction.Draw({
        	features: drawFeatureFeatureObject,
        	type: shape,
        	geometryFunction: geometryFunction,
        });
        //drawFeatureFeatureObject.vectorLayer = drawShapeFeatureLayer;
    	map.addInteraction(drawFeatureDrawObject);
    	
    	drawFeatureDrawObject.on('drawend', function(evt) {
			removeDrawFeatureFeatureObject();
		});
	}
	function drawLineMoveDiv() {
		//disableSelectMoveDiv();
		drawShapeMoveDiv("LineString");
	}
	function drawRectangleMoveDiv() {
		drawShapeMoveDiv("Rectangle");
	}
	function drawPolygonMoveDiv() {
		drawShapeMoveDiv("Polygon");
	}
	function drawCircleMoveDiv() {
		drawShapeMoveDiv("Circle");
	}
	function handFeatureMoveDiv() {
		if(getEnableDragFlag()) {
			disableDragFunction();
			document.getElementById("handImageId").style.background="";
		} else {
			enableDragFunction();
			document.getElementById("handImageId").style.background="green";
		}
	}
	function deleteFeatureMoveDiv() {
		var result = confirm("确定要删除所有图形吗？");
		if(result) {
			drawShapeFeatureLayer.getSource().clear();
		}
	}
	/*
	function enableSelectMoveDiv() {
		useHandCursor=true;
		selectSingleClick.setActive(true);
		translateSelectObject.setActive(true);
		map.removeInteraction(drawFeatureDrawObject);
	}
	function disableSelectMoveDiv() {
		useHandCursor=false;
		selectSingleClick.setActive(false);
		translateSelectObject.setActive(false);
	}
	*/
	var translateRadius = 0.001;
	function getDrawShapeAttribute(feature) {
		var data = new Array();
		var style = feature.getStyle();
		if(style == null)
			return null;
		if(feature.getGeometry().getType() == "LineString") {
			var color = null;
			var width = null;
			var opacity = null;
			var type = null;
			var name = style.getText().getText();;
			var zindex = style.getZIndex() - drawShapeZIndexOffset;
			var stroke = style.getStroke();
			if(stroke != null) {
				var tColor = stroke.getColor();
				color = tColor[0] + "," + tColor[1] + "," + tColor[2] + "," + "1";
				opacity = tColor[3];
				width = stroke.getWidth();
				if(stroke.getLineDash())
					type = "dash";
				else
					type = "solid";
			}
			data["color"] = color;
			data["width"] = width;
			data["opacity"] = opacity;
			data["type"] = type;
			data["name"] = name;
			data["zindex"] = zindex;
			return data;
		} else if(feature.getGeometry().getType() == "Polygon") {
			var color = null;
			var width = null;
			var opacity = null;
			var type = null;
			var fill = null;
			var name = style.getText().getText();;
			var zindex = style.getZIndex() - drawShapeZIndexOffset;
			var stroke = style.getStroke();
			if(stroke != null) {
				var tColor = stroke.getColor();
				color = tColor[0] + "," + tColor[1] + "," + tColor[2] + "," + "1";
				//opacity = tColor[3];
				width = stroke.getWidth();
				if(stroke.getLineDash())
					type = "dash";
				else
					type = "solid";
			}
			var styleFill = style.getFill();
			if(styleFill != null) {
				var tColor = styleFill.getColor();
				fill = tColor[0] + "," + tColor[1] + "," + tColor[2] + "," + "1";
				opacity = tColor[3];
			}
			data["color"] = color;
			data["width"] = width;
			data["opacity"] = opacity;
			data["type"] = type;
			data["fill"] = fill;
			data["name"] = name;
			data["zindex"] = zindex;
			return data;
		} else if(feature.getGeometry().getType() == "Circle") {
			var color = null;
			var width = null;
			var opacity = null;
			var type = null;
			var fill = null;
			var name = style.getText().getText();;
			var radius = Math.round(feature.getGeometry().getRadius()/translateRadius);
			var zindex = style.getZIndex() - drawShapeZIndexOffset;
			var stroke = style.getStroke();
			if(stroke != null) {
				var tColor = stroke.getColor();
				color = tColor[0] + "," + tColor[1] + "," + tColor[2] + "," + "1";
				//opacity = tColor[3];
				width = stroke.getWidth();
				if(stroke.getLineDash())
					type = "dash";
				else
					type = "solid";
			}
			var styleFill = style.getFill();
			if(styleFill != null) {
				var tColor = styleFill.getColor();
				fill = tColor[0] + "," + tColor[1] + "," + tColor[2] + "," + "1";
				opacity = tColor[3];
			}
			data["color"] = color;
			data["width"] = width;
			data["opacity"] = opacity;
			data["type"] = type;
			data["fill"] = fill;
			data["name"] = name;
			data["radius"] = radius;
			data["zindex"] = zindex;
			return data;
		}
	}
	function lineAlertMessageCB(data, feature) {
		var color = data["color"].split(",");
		var width = parseInt(data["width"]);
		var opacity = data["opacity"];
		color[3] = opacity;
		var type = data["type"];
		var name = data["name"];
		var degree = parseInt(data["degree"]) * transferRadian;
		var zindex = parseInt(data["zindex"]) + drawShapeZIndexOffset;
		
		var firstCoord = feature.getGeometry().getFirstCoordinate();
		feature.getGeometry().rotate(degree, firstCoord);
		
		var style = feature.getStyle();
		if(style == null) {
			style = new ol.style.Style({
				stroke: new ol.style.Stroke({
				width: width,
				color: color
				})
			});
		}
		var stroke = style.getStroke();
		stroke.setColor(color);
		stroke.setWidth(width);
		if(type == "solid") {
			stroke.setLineDash(null);
		} else if(type == "dash") {
			var dash = new Array();
			dash[0] = 2 * width;
			dash[1] = 5 * width;
			stroke.setLineDash(dash);
		}
		style.setStroke(stroke);
		style.setZIndex(zindex);
		var text = style.getText();
		if(text == null) {
			var textColor = new Array();
			textColor[0] = color[0];
			textColor[1] = color[1];
			textColor[2] = color[2];
			text = new ol.style.Text({
	        	text: name,
	        	scale: 1,
				//offsetX: 12,
				//offsetY: -12,
	        	fill: new ol.style.Fill({
	          		color: '#000000'
	        	}),
	        	stroke: new ol.style.Stroke({
	          		color: textColor,
	          	width: 3.5
	        	})
	      	});
		}
		text.setText(name);
		style.setText(text);
		feature.setStyle(style);
	}
	
	function polygonAlertMessageCB(data, feature) {
		var color = data["color"].split(",");
		color[3] = 1;
		var width = parseInt(data["width"]);
		var opacity = data["opacity"];
		var type = data["type"];
		var fill = data["fill"].split(",");
		fill[3] = opacity;
		var name = data["name"];
		var degree = parseInt(data["degree"]) * transferRadian;
		var zindex = parseInt(data["zindex"]) + drawShapeZIndexOffset;
		
		var firstCoord = feature.getGeometry().getFirstCoordinate();
		feature.getGeometry().rotate(degree, firstCoord);
		
		var style = feature.getStyle();
		if(style == null) {
			style = new ol.style.Style({
				stroke: new ol.style.Stroke({
					width: width,
					color: color
				}),
				fill: new ol.style.Fill({
            		color: fill,
          		}),
			});
		}
		style.getFill().setColor(fill);
		var stroke = style.getStroke();
		if(width == 0) {
			color[3] = 0;
		}
		stroke.setColor(color);
		stroke.setWidth(width);
		if(type == "solid") {
			stroke.setLineDash(null);
		} else if(type == "dash") {
			var dash = new Array();
			dash[0] = 2 * width;
			dash[1] = 5 * width;
			stroke.setLineDash(dash);
		}
		style.setStroke(stroke);
		style.setZIndex(zindex);
		var text = style.getText();
		if(text == null) {
			var textColor = new Array();
			textColor[0] = color[0];
			textColor[1] = color[1];
			textColor[2] = color[2];
			text = new ol.style.Text({
	        	text: name,
	        	scale: 1,
				//offsetX: 12,
				//offsetY: -12,
	        	fill: new ol.style.Fill({
	          		color: '#000000'
	        	}),
	        	stroke: new ol.style.Stroke({
	          		color: textColor,
	          	width: 3.5
	        	})
	      	});
		}
		text.setText(name);
		style.setText(text);
		feature.setStyle(style);
	}
	
	function circleAlertMessageCB(data, feature) {
		var color = data["color"].split(",");
		color[3] = 1;
		var width = parseInt(data["width"]);
		var opacity = data["opacity"];
		var type = data["type"];
		var fill = data["fill"].split(",");
		fill[3] = opacity;
		var name = data["name"];
		var radius = parseInt(data["radius"]) * translateRadius;
		var zindex = parseInt(data["zindex"]) + drawShapeZIndexOffset;
	
		feature.getGeometry().setRadius(radius);
		
		var style = feature.getStyle();
		if(style == null) {
			style = new ol.style.Style({
				stroke: new ol.style.Stroke({
					width: width,
					color: color
				}),
				fill: new ol.style.Fill({
            		color: fill,
          		}),
			});
		}
		style.getFill().setColor(fill);
		
		var stroke = style.getStroke();
		if(width == 0) {
			color[3] = 0;
		}
		stroke.setColor(color);
		stroke.setWidth(width);
		if(type == "solid") {
			stroke.setLineDash(null);
		} else if(type == "dash") {
			var dash = new Array();
			dash[0] = 2 * width;
			dash[1] = 5 * width;
			stroke.setLineDash(dash);
		}
		style.setStroke(stroke);
		style.setZIndex(zindex);
		var text = style.getText();
		if(text == null) {
			var textColor = new Array();
			textColor[0] = color[0];
			textColor[1] = color[1];
			textColor[2] = color[2];
			text = new ol.style.Text({
	        	text: name,
	        	scale: 1,
				//offsetX: 12,
				//offsetY: -12,
	        	fill: new ol.style.Fill({
	          		color: '#000000'
	        	}),
	        	stroke: new ol.style.Stroke({
	          		color: textColor,
	          	width: 3.5
	        	})
	      	});
		}
		text.setText(name);
		style.setText(text);
		
		feature.setStyle(style);
		
	}
	function deleteFeatureAlertMessageCB(feature) {
		if(drawShapeFeatureLayer && feature)
			drawShapeFeatureLayer.getSource().removeFeature(feature);
	}
	function alertMessageCB(data, feature) {
		console.log("feature type:"+feature.getGeometry().getType());
		if(feature.getGeometry().getType() == "LineString") {
			lineAlertMessageCB(data, feature);
		} else if(feature.getGeometry().getType() == "Polygon") {
			polygonAlertMessageCB(data, feature);
		}  else if(feature.getGeometry().getType() == "Circle") {
			circleAlertMessageCB(data, feature);
		}
	}
	function featuresAlertMessageCB() {
		setAlertMessageCB(alertMessageCB, deleteFeatureAlertMessageCB);
	}
	featuresAlertMessageCB();
    </script>
 	<script type="text/javascript">
 	function openTimeTable() {
 	/*
		if(!isChrome)
			$('#nonChromeDateId').fdatepicker({
				format: 'yyyy-mm-dd',
			});
			*/
	}
	
	function sela(link){  
	    var ul = document.getElementById("tabUlId"); 
	    var link1 = document.getElementById("tabA1Id");
	    link1.className = "";
	    var link2 = document.getElementById("tabA2Id");
	    link2.className = "";
	    var link3 = document.getElementById("tabA3Id");
	    link3.className = "";
	    link.className = "sel";
	    
	    var div1 = document.getElementById("tabDiv1Id");
	    div1.className = "tabDiv";
	    var div2 = document.getElementById("tabDiv2Id");
	    div2.className = "tabDiv";
	    var div3 = document.getElementById("tabDiv3Id");
	    div3.className = "tabDiv";
	    
	    var divId = link.getAttribute("href").split("#")[1];
	    divId = document.getElementById(divId);  
	    divId.className = "onTabDiv";
	    
	    if(divId == div2) {
	    	createApplicationTable();
	    	onRequestApplicationStatus();
	    	needPlanDataRefresh = false;
	    } else if(divId == div1) {
	    	needPlanDataRefresh = true;
	    } else if(divId == div3) {
	    	onRequestUserInfo();
	    	needPlanDataRefresh = false;
	    }
	    clearRouteSource();
	    
	    return false;
	}  
	</script>
 	<script src="./js/controlbar.js"></script>
 	<script>
	
 	createControlBar(document.getElementById("map"), userType);
 	setHideControlBarCB(
		function() {
			disableDrawRouteFlag();
			disableReadRoute();
		});
	requirePlan();
	</script>
<!-- 
	<script src="./js/highcharts-instance.js"></script>
	<script src="./js/highcharts-time.js"></script>
 -->
	</BODY>
</HTML>
