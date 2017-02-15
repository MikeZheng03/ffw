
var alertMessageOpened = false;
var alertMessageOkCB =null;
var alertMessageDeleteCB = null;
function alertMsg(msg, mode, feature) { //mode为空，即只有一个确认按钮，mode为1时有确认和取消两个按钮
        msg = msg || '';
        mode = mode || 0;
        var top = document.body.scrollTop || document.documentElement.scrollTop;
        var isIe = (document.all) ? true : false;
        var isIE6 = isIe && !window.XMLHttpRequest;
        var sTop = document.documentElement.scrollTop || document.body.scrollTop;
        var sLeft = document.documentElement.scrollLeft || document.body.scrollLeft;
        var winSize = function(){
            var xScroll, yScroll, windowWidth, windowHeight, pageWidth, pageHeight;
            // innerHeight获取的是可视窗口的高度，IE不支持此属性
            if (window.innerHeight && window.scrollMaxY) {
                xScroll = document.body.scrollWidth;
                yScroll = window.innerHeight + window.scrollMaxY;
            } else if (document.body.scrollHeight > document.body.offsetHeight) { // all but Explorer Mac
                xScroll = document.body.scrollWidth;
                yScroll = document.body.scrollHeight;
            } else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
                xScroll = document.body.offsetWidth;
                yScroll = document.body.offsetHeight;
            }

            if (self.innerHeight) {    // all except Explorer
                windowWidth = self.innerWidth;
                windowHeight = self.innerHeight;
            } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
                windowWidth = document.documentElement.clientWidth;
                windowHeight = document.documentElement.clientHeight;
            } else if (document.body) { // other Explorers
                windowWidth = document.body.clientWidth;
                windowHeight = document.body.clientHeight;
            }

            // for small pages with total height less then height of the viewport
            if (yScroll < windowHeight) {
                pageHeight = windowHeight;
            } else {
                pageHeight = yScroll;
            }

            // for small pages with total width less then width of the viewport
            if (xScroll < windowWidth) {
                pageWidth = windowWidth;
            } else {
                pageWidth = xScroll;
            }

            return{
                'pageWidth':pageWidth,
                'pageHeight':pageHeight,
                'windowWidth':windowWidth,
                'windowHeight':windowHeight
            }
        }();
        //alert(winSize.pageWidth);
        //遮罩层
        var styleStr = 'top:0;left:0;position:absolute;z-index:10000;background:#666;width:' + winSize.pageWidth + 'px;height:' +  (winSize.pageHeight) + 'px;';
        styleStr += (isIe) ? "filter:alpha(opacity=80);" : "opacity:0.8;"; //遮罩层DIV
        var shadowDiv = document.createElement('div'); //添加阴影DIV
        shadowDiv.style.cssText = styleStr; //添加样式
        shadowDiv.id = "shadowDiv";
        //如果是IE6则创建IFRAME遮罩SELECT
        if (isIE6) {
            var maskIframe = document.createElement('iframe');
            maskIframe.style.cssText = 'width:' + winSize.pageWidth + 'px;height:' + (winSize.pageHeight + 30) + 'px;position:absolute;visibility:inherit;z-index:-1;filter:alpha(opacity=0);';
            maskIframe.frameborder = 0;
            maskIframe.src = "about:blank";
            shadowDiv.appendChild(maskIframe);
        }
        document.body.insertBefore(shadowDiv, document.body.firstChild); //遮罩层加入文档
        //弹出框
        var styleStr1 = 'display:block;position:fixed;_position:absolute;left:' + (winSize.windowWidth / 2 - 200) + 'px;top:' + (winSize.windowHeight / 2 - 150) + 'px;_top:' + (winSize.windowHeight / 2 + top - 150)+ 'px;'; //弹出框的位置
        var alertBox = document.createElement('div');
        alertBox.id = 'alertMsg';
        alertBox.style.cssText = styleStr1;
        //创建弹出框里面的内容P标签
        var alertMsg_info = document.createElement('div');
        alertMsg_info.id = 'alertMsg_info';
        alertMsg_info.innerHTML = msg;
        alertBox.appendChild(alertMsg_info);
        
        //创建按钮
        var btn1 = document.createElement('a');
        btn1.id = 'alertMsg_btn1';
        btn1.href = 'javas' + 'cript:void(0)';
        btn1.innerHTML = '<button>确定</button>';
        btn1.onclick = function () {
        	if(alertMessageOkCB != null) {
            	alertMessageOkCB(getDataAlertMessage(feature), feature);
            }
            document.body.removeChild(alertBox);
            document.body.removeChild(shadowDiv);
            alertMessageOpened = false;
            
            return true;
        };
        alertBox.appendChild(btn1);
        if (mode >= 2) {
            var btn2 = document.createElement('a');
            btn2.id = 'alertMsg_btn2';
            btn2.href = 'javas' + 'cript:void(0)';
            btn2.innerHTML = '<button>取消</button>';
            btn2.onclick = function () {
                document.body.removeChild(alertBox);
                document.body.removeChild(shadowDiv);
                alertMessageOpened = false;
                return false;
            };
            alertBox.appendChild(btn2);
        }
        if (mode === 3) {
            var btn3 = document.createElement('a');
            btn3.id = 'alertMsg_btn3';
            btn3.href = 'javas' + 'cript:void(0)';
            btn3.innerHTML = '<button>删除该图形</button>';
            btn3.onclick = function () {
                document.body.removeChild(alertBox);
                document.body.removeChild(shadowDiv);
                alertMessageOpened = false;
                if(alertMessageDeleteCB != null) {
                	alertMessageDeleteCB(feature);
                }
                return false;
            };
            alertBox.appendChild(btn3);
        }
        document.body.appendChild(alertBox);
        //var tempWidth = alertBox.style.width;
        var oldData = getDrawShapeAttribute(feature);
        setDataAlertMessage(oldData, feature);
        alertMessageOpened = true;
    }
var globalLineWidth_alertMesg = 2;
function getDataAlertMessage(feature) {
	var data = new Array();
	if(feature.getGeometry().getType() == "LineString") {
		var color = $('#strokeColorSelect option:selected').val();
		var width = document.getElementById("strokeWidthInput").value;
		//if(isNull(width))
		width = globalLineWidth_alertMesg;
		var opacity = document.getElementById("opacityInput").value;
		if(!isNull(opacity)) {
			opacity = parseInt(opacity*10) / 10;
			if(opacity > 1)
				opacity = 1;
		} else
			opacity = 1;
		var type = $('#lineStyleSelect option:selected').val();
		var name = document.getElementById("featureNameInput").value;
		var degree = document.getElementById("rotateDegreeInput").value;
		if(isNull(degree))
			degree = 0;
		var zindex = document.getElementById("zIndexInput").value;
		if(isNull(zindex))
			zindex = 1;
		data["color"] = color;
		data["width"] = width;
		data["opacity"] = opacity;
		data["type"] = type;
		data["name"] = name;
		data["degree"] = degree;
		data["zindex"] = zindex;
		return data;
	} else if(feature.getGeometry().getType() == "Polygon") {
		var color = $('#strokeColorSelect option:selected').val();
		var width = document.getElementById("strokeWidthInput").value;
		//if(isNull(width))
			width = globalLineWidth_alertMesg;
		if(!document.getElementById("strokeWidthCheckbox").checked)
			width = 0;
		var opacity = document.getElementById("opacityInput").value;
		if(!isNull(opacity)) {
			opacity = parseInt(opacity*10) / 10;
			if(opacity > 1)
				opacity = 1;
		} else
			opacity = 1;
		var type = $('#lineStyleSelect option:selected').val();
		var fill = $('#fillColorSelect option:selected').val();
		var name = document.getElementById("featureNameInput").value;
		var degree = document.getElementById("rotateDegreeInput").value;
		if(isNull(degree))
			degree = 0;
		var zindex = document.getElementById("zIndexInput").value;
		if(isNull(zindex))
			zindex = 1;
		data["color"] = color;
		data["width"] = width;
		data["opacity"] = opacity;
		data["type"] = type;
		data["fill"] = fill;
		data["name"] = name;
		data["degree"] = degree;
		data["zindex"] = zindex;
		return data;
	} else if(feature.getGeometry().getType() == "Circle") {
		var color = $('#strokeColorSelect option:selected').val();
		var width = document.getElementById("strokeWidthInput").value;
		//if(isNull(width))
			width = globalLineWidth_alertMesg;
		if(!document.getElementById("strokeWidthCheckbox").checked)
			width = 0;
		var opacity = document.getElementById("opacityInput").value;
		if(!isNull(opacity)) {
			opacity = parseInt(opacity*10) / 10;
			if(opacity > 1)
				opacity = 1;
		} else
			opacity = 1;
		var type = $('#lineStyleSelect option:selected').val();
		var fill = $('#fillColorSelect option:selected').val();
		var name = document.getElementById("featureNameInput").value;
		var radius = document.getElementById("radiusInput").value;
		if(isNull(radius))
			radius = 5;
		var zindex = document.getElementById("zIndexInput").value;
		if(isNull(zindex))
			zindex = 1;
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

function setDataAlertMessage(data, feature) {
	if(data == null)
		return;
	if(feature.getGeometry().getType() == "LineString") {
		var color = data["color"];
		var width = globalLineWidth_alertMesg;//data["width"];
		var opacity = data["opacity"];
		var type = data["type"];
		var name = data["name"];
		var zindex = data["zindex"];
		
		var colorOptions = document.getElementById("strokeColorSelect").options;
		for(var i = 0; i < colorOptions.length; i++) {
			if(colorOptions[i].value == color) {
				colorOptions[i].selected=true;
				break;
			}
		}
		if(!isNull(width) && !isNaN(width)) {
			document.getElementById("strokeWidthInput").value = width;
		}
		if(!isNull(opacity) && !isNaN(opacity)) {
			document.getElementById("opacityInput").value = opacity;
		}
		if(!isNull(type)) {
			var typeOptions = document.getElementById("lineStyleSelect").options;
			for(var i = 0; i < typeOptions.length; i++) {
				if(typeOptions[i].value == type) {
					typeOptions[i].selected=true;
					break;
				}
			}
		}
		if(!isNull(name)) {
			document.getElementById("featureNameInput").value = name;
		}
		if(!isNull(zindex) && !isNaN(zindex)) {
			document.getElementById("zIndexInput").value = zindex;
		}
	} else if(feature.getGeometry().getType() == "Polygon") {
		var color = data["color"];
		var width = data["width"];
		var opacity = data["opacity"];
		var type = data["type"];
		var fill = data["fill"];
		var name = data["name"];
		var zindex = data["zindex"];
		
		var colorOptions = document.getElementById("strokeColorSelect").options;
		for(var i = 0; i < colorOptions.length; i++) {
			if(colorOptions[i].value == color) {
				colorOptions[i].selected=true;
				break;
			}
		}
		if(!isNull(width) && !isNaN(width)) {
			document.getElementById("strokeWidthInput").value = width;
		}
		if(width == 0) {
			document.getElementById("strokeWidthCheckbox").removeAttribute("checked");
		} else {
			document.getElementById("strokeWidthCheckbox").checked = "checked";
		}
		if(!isNull(opacity) && !isNaN(opacity)) {
			document.getElementById("opacityInput").value = opacity;
		}
		if(!isNull(type)) {
			var typeOptions = document.getElementById("lineStyleSelect").options;
			for(var i = 0; i < typeOptions.length; i++) {
				if(typeOptions[i].value == type) {
					typeOptions[i].selected=true;
					break;
				}
			}
		}
		var fillOptions = document.getElementById("fillColorSelect").options;
		for(var i = 0; i < fillOptions.length; i++) {
			if(fillOptions[i].value == fill) {
				fillOptions[i].selected=true;
				break;
			}
		}
		if(!isNull(name)) {
			document.getElementById("featureNameInput").value = name;
		}
		if(!isNull(zindex) && !isNaN(zindex)) {
			document.getElementById("zIndexInput").value = zindex;
		}
	} else if(feature.getGeometry().getType() == "Circle") {
		var color = data["color"];
		var width = data["width"];
		var opacity = data["opacity"];
		var type = data["type"];
		var fill = data["fill"];
		var name = data["name"];
		var radius = data["radius"];
		var zindex = data["zindex"];
		
		var colorOptions = document.getElementById("strokeColorSelect").options;
		for(var i = 0; i < colorOptions.length; i++) {
			if(colorOptions[i].value == color) {
				colorOptions[i].selected=true;
				break;
			}
		}
		if(!isNull(width) && !isNaN(width)) {
			document.getElementById("strokeWidthInput").value = width;
		}
		if(width == 0) {
			document.getElementById("strokeWidthCheckbox").removeAttribute("checked");
		} else {
			document.getElementById("strokeWidthCheckbox").checked = "checked";
		}
		if(!isNull(opacity) && !isNaN(opacity)) {
			document.getElementById("opacityInput").value = opacity;
		}
		if(!isNull(type)) {
			var typeOptions = document.getElementById("lineStyleSelect").options;
			for(var i = 0; i < typeOptions.length; i++) {
				if(typeOptions[i].value == type) {
					typeOptions[i].selected=true;
					break;
				}
			}
		}
		var fillOptions = document.getElementById("fillColorSelect").options;
		for(var i = 0; i < fillOptions.length; i++) {
			if(fillOptions[i].value == fill) {
				fillOptions[i].selected=true;
				break;
			}
		}
		if(!isNull(name)) {
			document.getElementById("featureNameInput").value = name;
		}
		if(!isNull(radius) && !isNaN(radius)) {
			document.getElementById("radiusInput").value = radius;
		}
		if(!isNull(zindex) && !isNaN(zindex)) {
			document.getElementById("zIndexInput").value = zindex;
		}
	}
}

function isAlertMessageOpened() {
	return alertMessageOpened;
}

function setAlertMessageCB(cb1, cb2) {
	alertMessageOkCB = cb1;
	alertMessageDeleteCB = cb2;
}