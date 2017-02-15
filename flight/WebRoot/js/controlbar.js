var layersPanelInBar, layersButtonInBar;
var userButtonInBar, adminButtonInBar, toolsButtonInBar;
var toolsPanelInBar, toolsButtonInBar, toolsScaleImage, toolsEyeImage;
var toolsScaleDisabled = false;
var editAreaHidden = true;
var hideControlBarCB = null;

function createCheckbox(name) {
	var input = document.createElement('input');
	input.type = 'checkbox';
	input.checked = false;
	input.name = name;
	input.onchange = function(e) {
		console.log("name:"+e.target.name+", checked:"+e.target.checked);
		//this_.setVisible_(lyr, e.target.checked);
	};
	return input;
}

function showLayersPanel() {
	layersPanelInBar.style.display = "";
	layersButtonInBar.style.display = "none";
}

function hideLayersPanel() {
	layersPanelInBar.style.display = "none";
	layersButtonInBar.style.display = "";
}

function createLayersControl() {
	var element = document.createElement('div');
	//element.setAttribute('style', "position:absolute; top:90%; left:1%;");
	
    layersButtonInBar = document.createElement('button');
    layersButtonInBar.setAttribute('title', "图层");
	layersButtonInBar.setAttribute('style', "background:url(./img/layers-64.png);width:64px;height:64px;border:0;outline:none;");
    element.appendChild(layersButtonInBar);
	layersButtonInBar.onmouseover = function(e) {
        //this_.showLayersPanel();
    };

    layersButtonInBar.onclick = function(e) {
        e = e || window.event;
        showLayersPanel();
        e.preventDefault();
    };

    layersPanelInBar = document.createElement('div');
    layersPanelInBar.className = 'panel';
	layersPanelInBar.setAttribute('style', "margin-top:-40px;float:left;display:none;border:1px solid #96c2f1;background:#eff7ff");
    element.appendChild(layersPanelInBar);
	layersPanelInBar.onmouseout = function(e) {
        e = e || window.event;
        if (!layersPanelInBar.contains(e.toElement || e.relatedTarget)) {
            hideLayersPanel();
        }
    };
	
	var ul = document.createElement('ul');
	ul.setAttribute('style', "margin-left:10px;padding:0px");
    layersPanelInBar.appendChild(ul);
	
    var li = document.createElement('li');
	li.className = 'group';
	li.setAttribute('style', "list-style-type:none;");
	ul.appendChild(li);
    var titleLabel = document.createElement('label');
	titleLabel.innerHTML = "图层选择";
    li.appendChild(titleLabel);
        
	var layersUl = document.createElement('ul');
	layersUl.setAttribute('style', "margin-left:10px;padding-left:1px;padding-right:10px;");
	li.appendChild(layersUl);
	
	var routeLi = document.createElement('li');
	routeLi.className = 'routeLi';
	routeLi.setAttribute('style', "list-style-type:none;");
	layersUl.appendChild(routeLi);
	
    var routeInput = createCheckbox("route");
    routeLi.appendChild(routeInput);
	var routeLabel = document.createElement('label');
	routeLabel.innerHTML = "航线";
	routeLi.appendChild(routeLabel);
	
	var trackLi = document.createElement('li');
	trackLi.className = 'trackLi';
	trackLi.setAttribute('style', "list-style-type:none;");
	layersUl.appendChild(trackLi);
	var trackInput = createCheckbox("track");
	trackLi.appendChild(trackInput);
	var trackLabel = document.createElement('label');
	trackLabel.innerHTML = "航迹";
	trackLi.appendChild(trackLabel);

	return element;
}

function showEditArea() {
	var map = document.getElementById("map");
	map.style.height = "70%";
	var editArea = document.getElementById("editArea");
	editArea.style.display = "";
	layersButtonInBar.style.background="url(./img/layers-32.png)";
	layersButtonInBar.style.width = "32px";
	layersButtonInBar.style.height = "32px";
	userButtonInBar.style.background="url(./img/edit-focus-32.png)";
	userButtonInBar.style.width = "32px";
	userButtonInBar.style.height = "32px";
	adminButtonInBar.style.background="url(./img/list-focus-32.png)";
	adminButtonInBar.style.width = "32px";
	adminButtonInBar.style.height = "32px";
	toolsButtonInBar.style.background="url(./img/design-tool-32.png)";
	toolsButtonInBar.style.width = "32px";
	toolsButtonInBar.style.height = "32px";
	
	if(measureDraw.getActive()) {
		toolsScaleImage.src = "./img/scale-ruler-focus-32.png";
	} else {
		toolsScaleImage.src = "./img/scale-ruler-32.png";
	}
	
	if(overviewMapControlDisabled()) {
		toolsEyeImage.src = "./img/eye-32.png";
	} else {
		toolsEyeImage.src = "./img/eye-focus-32.png";
	}
	
	toolsDrawImage.src = "./img/draw-32.png";
	
	openTimeTable();
}

function hideEditArea() {
	var map = document.getElementById("map");
	map.style.height = "";
	var editArea = document.getElementById("editArea");
	editArea.style.display = "none";
	layersButtonInBar.style.background="url(./img/layers-64.png)";
	layersButtonInBar.style.width = "64px";
	layersButtonInBar.style.height = "64px";
	userButtonInBar.style.background="url(./img/edit-64.png)";
	userButtonInBar.style.width = "64px";
	userButtonInBar.style.height = "64px";
	adminButtonInBar.style.background="url(./img/list-64.png)";
	adminButtonInBar.style.width = "64px";
	adminButtonInBar.style.height = "64px";
	toolsButtonInBar.style.background="url(./img/design-tool-64.png)";
	toolsButtonInBar.style.width = "64px";
	toolsButtonInBar.style.height = "64px";
	
	if(measureDraw.getActive()) {
		toolsScaleImage.src = "./img/scale-ruler-focus-64.png";
	} else {
		toolsScaleImage.src = "./img/scale-ruler-64.png";
	}
	
	if(overviewMapControlDisabled()) {
		toolsEyeImage.src = "./img/eye-64.png";
	} else {
		toolsEyeImage.src = "./img/eye-focus-64.png";
	}
	
	toolsDrawImage.src = "./img/draw-64.png";
	
	if(hideControlBarCB != null)
		hideControlBarCB();
}

function createUserControl() {
	var parent = document.createElement('div');
	var element = document.createElement('div');
	element.setAttribute('id', "userControlId");
	element.setAttribute('style', "position:relative;");
	parent.appendChild(element);
	var userCounterSpan = document.createElement('span');
	userCounterSpan.setAttribute('id', "userCounterSpanId");
	userCounterSpan.setAttribute('class', "message-counter");
	userCounterSpan.setAttribute('style', "display:none;");
	element.appendChild(userCounterSpan);
	
    userButtonInBar = document.createElement('button');
    userButtonInBar.setAttribute('title', "申报");
	userButtonInBar.setAttribute('style', "background:url(./img/edit-64.png);width:64px;height:64px;border:0;outline:none;");
    element.appendChild(userButtonInBar);
	userButtonInBar.onmouseover = function(e) {
        //this_.showPanel();
    };

    userButtonInBar.onclick = function(e) {
        e = e || window.event;
        if(editAreaHidden) {
        	editAreaHidden = false;
			showEditArea();
		} else {
			editAreaHidden = true;
			hideEditArea();
		}
        map.updateSize();
        e.preventDefault();
    };
	
	return parent;
}

function createAdminControl() {
	var parent = document.createElement('div');
	var element = document.createElement('div');
	element.setAttribute('id', "adminControlId");
	element.setAttribute('style', "position:relative;");
	parent.appendChild(element);
	var adminCounterSpan = document.createElement('span');
	adminCounterSpan.setAttribute('id', "adminCounterSpanId");
	adminCounterSpan.setAttribute('class', "message-counter");
	adminCounterSpan.setAttribute('style', "display:none;");
	element.appendChild(adminCounterSpan);
	
    adminButtonInBar = document.createElement('button');
    adminButtonInBar.setAttribute('title', "审批");
	adminButtonInBar.setAttribute('style', "background:url(./img/list-64.png);width:64px;height:64px;border:0;outline:none;");
    element.appendChild(adminButtonInBar);
	adminButtonInBar.onmouseover = function(e) {
        //this_.showPanel();
    };

    adminButtonInBar.onclick = function(e) {
        e = e || window.event;
        if(editAreaHidden) {
        	editAreaHidden = false;
			showEditArea();
		} else {
			editAreaHidden = true;
			hideEditArea();
		}
        map.updateSize();
        e.preventDefault();
    };
	
	return parent;
}

function showToolsPanel() {
	toolsPanelInBar.style.display = "";
	toolsButtonInBar.style.display = "none";
}

function hideToolsPanel() {
	toolsPanelInBar.style.display = "none";
	toolsButtonInBar.style.display = "";
}

function createToolsControl() {
	var element = document.createElement('div');
	
    toolsButtonInBar = document.createElement('button');
    toolsButtonInBar.setAttribute('title', "工具");
	
	toolsButtonInBar.setAttribute('style', "background:url(./img/design-tool-64.png);width:64px;height:64px;border:0;outline:none;");
    element.appendChild(toolsButtonInBar);
	toolsButtonInBar.onmouseover = function(e) {
        //this_.showPanel();
    };

    toolsButtonInBar.onclick = function(e) {
        e = e || window.event;
        showToolsPanel();
        e.preventDefault();
    };
	
	toolsPanelInBar = document.createElement('div');
    toolsPanelInBar.className = 'panel';
	toolsPanelInBar.setAttribute('style', "float:left;display:none;outline:none;");
    element.appendChild(toolsPanelInBar);
	toolsPanelInBar.onmouseout = function(e) {
        e = e || window.event;
        if (!toolsPanelInBar.contains(e.toElement || e.relatedTarget)) {
            hideToolsPanel();
        }
    };
	
	toolsScaleImage = document.createElement('img');
	toolsScaleImage.setAttribute('style', "float:left;outline:none;");
    toolsScaleImage.setAttribute('title', "测距");
	toolsScaleImage.src = "./img/scale-ruler-64.png";
	toolsPanelInBar.appendChild(toolsScaleImage);
	toolsScaleImage.onclick = function(e) {
        hideToolsPanel();
		if(toolsScaleDisabled == false) {
			if(measureDraw.getActive() == false) {
				if(editAreaHidden)
					toolsScaleImage.src = "./img/scale-ruler-focus-64.png";
				else
					toolsScaleImage.src = "./img/scale-ruler-focus-32.png";
				
				disableDrawShapeFlag();
			} else {
				if(editAreaHidden)
					toolsScaleImage.src = "./img/scale-ruler-64.png";
				else
					toolsScaleImage.src = "./img/scale-ruler-32.png";
			}
			setMeasureControl();
		}
    };
	
	toolsEyeImage = document.createElement('img');
	toolsEyeImage.setAttribute('style', "float:left;outline:none;margin-left:20px;");
    toolsEyeImage.setAttribute('title', "鹰眼");
	toolsEyeImage.src = "./img/eye-64.png";
	toolsPanelInBar.appendChild(toolsEyeImage);
	toolsEyeImage.onclick = function(e) {
        hideToolsPanel();
		if(overviewMapControlDisabled()) {
			if(editAreaHidden)
				toolsEyeImage.src = "./img/eye-focus-64.png";
			else
				toolsEyeImage.src = "./img/eye-focus-32.png";
		} else {
			if(editAreaHidden)
				toolsEyeImage.src = "./img/eye-64.png";
			else
				toolsEyeImage.src = "./img/eye-32.png";
		}
		setOverviewMapControl();
    };
	
    toolsDrawImage = document.createElement('img');
    toolsDrawImage.setAttribute('style', "float:left;outline:none;margin-left:20px;");
    toolsDrawImage.setAttribute('title', "画图");
    toolsDrawImage.src = "./img/draw-64.png";
	toolsPanelInBar.appendChild(toolsDrawImage);
	toolsDrawImage.onclick = function(e) {
		if(measureDraw.getActive()) {
			if(editAreaHidden)
				toolsScaleImage.src = "./img/scale-ruler-64.png";
			else
				toolsScaleImage.src = "./img/scale-ruler-32.png";
			closeMeasureControl();
		}
        hideToolsPanel();
        showDrawMoveDiv();
    };
	
	return element;
}

function createControlBar(mapElement,type) {
	var element = document.createElement('div');
	element.setAttribute('style', "background-color:rgb(13,42,73);position:absolute; top:90%; left:40%;z-index:999");
	mapElement.appendChild(element);
	
	var layers = createLayersControl();
	layers.setAttribute('style', "float:left;");
	element.appendChild(layers);
	
	var user = createUserControl();
	user.setAttribute('style', "float:left;margin-left:25px;");
	element.appendChild(user);
	
	var admin = createAdminControl();
	admin.setAttribute('style', "float:left;margin-left:20px;");
	element.appendChild(admin);
	
	if(type == 1) {
		user.style.display = "none";
	} else {
		admin.style.display = "none";
	}
	var tools = createToolsControl();
	tools.setAttribute('style', "float:left;margin-left:20px;");
	element.appendChild(tools);
} 

function setCounterSpan(value, isUser) {
	if(isUser) {
		if(value == '') {
			if($('#userCounterSpanId').css('display') != 'none')
				$('#userCounterSpanId').css('display','none');
		} else {
			if($('#userCounterSpanId').css('display') == 'none')
				$('#userCounterSpanId').css('display','block');
			$('#userCounterSpanId').text(value);
		}
	} else {
		if(value == '') {
			if($('#adminCounterSpanId').css('display') != 'none')
				$('#adminCounterSpanId').css('display','none');
		} else {
			if($('#adminCounterSpanId').css('display') == 'none')
				$('#adminCounterSpanId').css('display','block');
			$('#adminCounterSpanId').text(value);
		}
	}
	
}

function decreaseCounterSpan(isUser) {
	if(isUser) {
		var value = parseInt($('#userCounterSpanId').text()) - 1;
		if(value <= 0) {
			$('#userCounterSpanId').css('display','none');
		} else {
			$('#userCounterSpanId').text(value);
		}
	} else {
		var value = parseInt($('#adminCounterSpanId').text()) - 1;
		if(value <= 0) {
			$('#adminCounterSpanId').css('display','none');
		} else {
			$('#adminCounterSpanId').text(value);
		}
	}
	
}

	function disableToolsScale() {
		toolsScaleDisabled = true;
		if(editAreaHidden)
			toolsScaleImage.src = "./img/scale-ruler-disable-64.png";
		else
			toolsScaleImage.src = "./img/scale-ruler-disable-32.png";
		closeMeasureControl();
	}
	
	function enableToolsScale() {
		if(toolsScaleDisabled == false)
			return;
		toolsScaleDisabled = false;
		if(editAreaHidden)
			toolsScaleImage.src = "./img/scale-ruler-64.png";
		else
			toolsScaleImage.src = "./img/scale-ruler-32.png";

	}
	
function setHideControlBarCB(cb) {
	hideControlBarCB = cb;
}