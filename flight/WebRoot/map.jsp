<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
	<HEAD>
	<TITLE> Flight </TITLE>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	
	<jsp:include page="islogin.jsp"></jsp:include> 
	
	<link rel="stylesheet" href="./css/ol.css" type="text/css" />
	<link rel="SHORTCUT ICON" href="img/marker.png"/>
	<script src="./js/ol.js"></script>
	<script src="./js/zhHash.js"></script>
	<script src="./js/jquery-3.1.1.min.js"></script>
	<script src="./js/highcharts.js"></script>
	<!-- 
	<link rel="stylesheet" href="./css/popover.css">
	<script src="./js/bootstrap.js"></script>
	 -->
	<link rel="stylesheet" href="./css/tabDiv.css">
	<link rel="stylesheet" href="./css/ol-popup.css">
	<link rel="stylesheet" href="./css/message.css">
	<link rel="stylesheet" href="./css/measure.css" type="text/css" />
    <script src="./js/measure.js"></script>
    
    <!--jQuery dependencies-->
    <link rel="stylesheet" href="./css/jquery-ui.min.css" />
    <script src="./js/jquery-ui.min.js"></script>
<!--PQ Grid files-->
    <link rel="stylesheet" href="./css/pqgrid.min.css" />
    <script src="./js/pqgrid.min.js"></script>
<!--PQ Grid Office theme-->
	<link rel="stylesheet" href="./css/pqgrid.css" />
	<script src="./js/gridtable.js"></script>
	<script src="./js/pq-localize-zh.js"></script>
	
	<script>
	function closeWindow(){	
		open(location, '_self').close();
	}
	</script>

	<script  type="text/javascript">
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
	var drawRouteArrayObj = new Array();//array[0] is end point; array[1] is start point
	var measureDraw = null;
	var selectSingleClick = null;
	var selectMeasureCollection;
	var overviewMapControl = null;

	var routeMarkerVectorSource = new ol.source.Vector();
	var routeMarkerLayer = new ol.layer.Vector({source: routeMarkerVectorSource});
	var routeVectorSource = new ol.source.Vector();
	var routeLayer = new ol.layer.Vector({source: routeVectorSource});
	
	function isNull(data){
		return (data == "" || data == undefined || data == null); 
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
        
		map = new ol.Map({
			controls: ol.control.defaults().extend([
        		new ol.control.MousePosition({coordinateFormat: ol.coordinate.createStringXY(4)}),
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
		map.addLayer(routeMarkerLayer);
		map.addLayer(markerLayer);
		
		measureDraw = measureAddInteraction(map, true);
		measureDraw.setActive(false);
	
		// select interaction working on "singleclick"
		selectSingleClick = new ol.interaction.Select({
		
			layers: function(layer) {
				//if(layer.getSource() === measureSource)
				//	return true;
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
		}

		map.on('click', function(evt) {
			var f = map.forEachFeatureAtPixel(
				evt.pixel,
				function(feature, layer) {
					return feature;
				}, null, 
				function(layer) {
					return layer === markerLayer;
			});
		
			var center = map.getView().getCenter();
			console.log("center lon:"+center[0]+", lat:"+center[1]+", zoom:"+map.getView().getZoom());
			
			if (f || markerClickStatus) {
				//onMarkerClick(f, element);
			}		
			
		});
		
		map.on('pointermove', function(evt) {
			pointerMoveHandler(evt);
		});

		//window.setInterval("onRequestAllFlightsData(\"FLIGHT1\")",1000); 
		window.setInterval("start()",400); 
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

	var testCounter=-2;
	function start() {
		//map.on('postcompose', animationTest);
		//map.render();
		//testLine();
		
		console.log("zoom:"+map.getView().getZoom());
		
		if(waitingData) {
			console.log("waiting data!!!");
			return;
		}
		waitingData = true;
		onRequestAllFlightsData(clickedMarkerName);
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
			routeVectorSource.clear(); 
			routeMarkerVectorSource.clear();
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
			console.log("subTime:"+(tTime-lastTime));
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
				parserAirportData(jsonData);
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
	}
	onRequestAirport();
	

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
	
	function onDeleteRouteTableRow(target) {
		var i=target.parentNode.parentNode.rowIndex;
		document.getElementById('editRouteTableBodyId').deleteRow(i);

		drawRouteArrayObj.splice((i+1), 1);//[0] is end, [1] is start
		routeVectorSource.clear();
		drawRoute(false);
	}
	
	
	function disableReadRoute() {

		var objReadRouteDiv=document.getElementById("readRouteDivId");
		objReadRouteDiv.style.display="none";
		routeVectorSource.clear();
		routeMarkerVectorSource.clear();
		drawRouteArrayObj.splice(0,drawRouteArrayObj.length);
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
	

	function submitPlan() {
		var start = $('#start_select option:selected').text();
		var end = $('#end_select option:selected').text();
		var date, time;
		if(isChrome) {
			date=document.getElementById("chromeDateId").value;
			time=document.getElementById("chromeTimeId").value;
		} else {
			date=document.getElementById("nonChromeDateId").value;
			time=document.getElementById("nonChromeTimeId").value;
		}
		var task = $('#task_select option:selected').text();
		var type=document.getElementById("planeType").value;
		
		if(isNull(date) || isNull(time) || isNull(type)) {
			alert("数据不能为空");
			return;
		}
		
		var submitData = "{start:'" + start +
			"',end:'" + end +
			"',date:'" + date +
			"',time:'" + time +
			"',type:'" + type +
			"',task:'" + task +
			"'}";
			
		var urlString = "submitplan.jsp";
		$.ajax({
			type:"POST",
			url: urlString,
			async: true,
			data: "plan="+submitData,
			//dataType:"json",
			crossDomain: true,
			success:function(message){
				var result = message.trim();
				if(result == "success") {
					alert("提交成功");
				} else {
					alert(result);
				}
				//parserAirportData(jsonData);
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
	function clearRouteSource() {
		routeVectorSource.clear(); 
		routeMarkerVectorSource.clear();
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
 
 	<div id="editArea" style="display:none; height:30%; background:#eff7ff">
 	
	<ul class="tabUl" id="tabUlId">  
    	<li><a id="tabA1Id" onclick="sela(this);" href="#tabDiv1Id" class="sel">申报</a></li>  
    	<li><a id="tabA2Id" onclick="sela(this);" href="#tabDiv2Id">申报记录</a></li>
    	<li><a id="tabA3Id" onclick="sela(this);" href="#tabDiv3Id">用户信息</a></li>
	</ul>  
	<div id="tabDiv1Id" class="onTabDiv">
		<div style="width:100%;float:left"  style = "overflow: auto;">
		<table width="100%" cellpadding="0.5" cellspacing="1" style="font-size:12px">
        <tr>
        	<td style="width:6%" align="left"><div align="center">起飞机场： </div></td>
            <td style="width:11%"><select id="start_select" style="width:80%" align="left" name="start_select"></select></td>
            
            <td style="width:6%" align="left"><div align="center">降落机场： </div></td>
            <td style="width:11%"><select id="end_select" style="width:80%" name="end_select"></select></td>
            
            <td style="width:8%" align="left"><div align="center">计划飞行日期：</div></td>
            <td style="width:9%">
            	<input id="chromeDateId" type="date" name="start_date" class="input_2"/>
            	<input id="nonChromeDateId" type="date" style="display:none" name="start_date" class="input_2"/>
            </td>
            
            <td style="width:8%" align="left"><div align="center">计划起飞时间： </div></td>
            <td style="width:9%">
            	<input id="chromeTimeId" type="time" name="start_time" class="input_2"/>
            	<input id="nonChromeTimeId" name="time" type="text" style="display:none" onclick="_SetTime(this)"/>
            </td>
            
            <td style="width:6%" align="left"><div align="center">任务种类： </div></td>
            <td style="width:10%">
            	<select id="task_select" style="width:80%" name="end_select">
            		<option value ="巡航">巡航</option>
					<option value ="农林">农林</option>
					<option value="公务">公务</option>
					<option value="旅游">旅游</option>
					<option value="运输">运输</option>
					<option value="其他">其他</option>
            	</select>
            </td>
            
            <td style="width:6%" align="left"><div align="center">机型：</div></td>
            <td style="width:10%"><input id="planeType" style="width:80%" name="planeType" class="input_2"/></td>
            
        </tr>
      
        <tr>
            <td colspan="12">
                <div align="center" >
                	<br>
                    <input type="submit" value="提交" align="center" onclick="submitPlan()" class="input2" />
                </div>
            </td>
        </tr>
    	</table>
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
 	<script type="text/javascript">
 	if(!isChrome) {
 		document.write("<script src='./js/time.js'><\/script>");
		document.getElementById("nonChromeTimeId").style.display = "";
		document.getElementById("chromeTimeId").style.display = "none";
		
		var cssNode = document.createElement('link'); 
		cssNode.rel = 'stylesheet'; 
		cssNode.type = 'text/css'; 
		cssNode.href = './css/foundation-datepicker.all.css';
		document.head.appendChild(cssNode);
		document.write("<script src='./js/foundation-datepicker.js'><\/script>");
		document.write("<script src='./js/foundation-datepicker.zh-CN.js'><\/script>");
		document.getElementById("nonChromeDateId").style.display = "";
		document.getElementById("chromeDateId").style.display = "none";
	}
	function openTimeTable() {
		if(!isChrome)
			$('#nonChromeDateId').fdatepicker({
				format: 'yyyy-mm-dd',
			});
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
	    } else if(divId == div3) {
	    	onRequestUserInfo();
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
				clearRouteSource();
			});
	</script>
<!-- 
	<script src="./js/highcharts-instance.js"></script>
	<script src="./js/highcharts-time.js"></script>
 -->
	</BODY>
</HTML>
