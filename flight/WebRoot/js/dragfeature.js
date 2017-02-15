var lineAttributeDialogStr = '<div align="center"><table><tr><td><div align="left">线的颜色:</div></td><td><select id="strokeColorSelect" size="1" style="width:85px"><option value="255,255,255,1" id="whiteColorOptionId" style="background-color:white; color:black">White</option><option value="0,0,0,1" id="blackColorOptionId" style="background-color:black; color:white">Black</option><option value="255,0,0,1" id="redColorOptionId" style="background-color:red;">Red</option><option value="255,255,0,1" id="yellowColorOptionId" style="background-color:yellow;">Yellow</option><option value="255,192,203,1" id="pinkColorOptionId" style="background-color:pink;">Pink</option><option value="0,255,0,1" id="greenColorOptionId" style="background-color:green;">Green</option><option value="255,165,0,1" id="orangeColorOptionId" selected="selected" style="background-color:orange;">Orange</option><option value="128,0,128,1" id="purpleColorOptionId" style="background-color:purple;">Purple</option><option value="0,0,255,1" id="blueColorOptionId" style="background-color:blue;">Blue</option><option value="165,42,42,1" id="brownColorOptionId" style="background-color:brown;">Brown</option><option value="0,128,128,1" id="tealColorOptionId" style="background-color:teal;">Teal</option><option value="0,0,128,1" id="navyColorOptionId" style="background-color:navy;">Navy</option><option value="128,0,0,1" id="maroonColorOptionId" style="background-color:maroon;">Maroon</option><option value="50,205,50,1" id="limegreenColorOptionId" style="background-color:limegreen;">LimeGreen</option></select></td></tr><tr style="display: none"><td><div align="left">线的宽度:</div></td><td><input type="number" name="strokeWidthInput" id="strokeWidthInput" min="1" max="1000" step="1" value="2" style="width:85px" /></td></tr><tr><td><div align="left">透明度:</div></td><td><input type="number" name="opacityInput" id="opacityInput" min="0.1" max="1" step="0.1" value="1" style="width:85px" /></td></tr><tr><td><div align="left">样式:</div></td><td><select id="lineStyleSelect"  style="width:85px"><option value="solid" selected="selected" style="background-color:white; color:black">普通</option><option value="dash" style="background-color:white; color:black">虚线</option><tr><td><div align="left">名称:</div></td><td><input id="featureNameInput" name="featureNameInput" style="width:85px"/></td></tr><tr><td><div align="left">旋转角度:</div></td><td><input type="number" name="rotateDegreeInput" id="rotateDegreeInput" min="-180" max="180" step="1" value="0" style="width:85px" /></td></tr><tr><td><div align="left">zIndex:</div></td><td><input type="number" name="zIndexInput" id="zIndexInput" min="1" max="10" step="1" value="1" style="width:85px" /></td></tr></table></div>';
var polygonAttributeDialogStr = '<div align="center"><table><tr><td><div align="left">边框颜色:</div></td><td><select id="strokeColorSelect" size="1" style="width:85px"><option value="255,255,255,1" id="whiteColorOptionId" style="background-color:white; color:black">White</option><option value="0,0,0,1" id="blackColorOptionId" style="background-color:black; color:white">Black</option><option value="255,0,0,1" id="redColorOptionId" style="background-color:red;">Red</option><option value="255,255,0,1" id="yellowColorOptionId" style="background-color:yellow;">Yellow</option><option value="255,192,203,1" id="pinkColorOptionId" style="background-color:pink;">Pink</option><option value="0,255,0,1" id="greenColorOptionId" style="background-color:green;">Green</option><option value="255,165,0,1" id="orangeColorOptionId" selected="selected" style="background-color:orange;">Orange</option><option value="128,0,128,1" id="purpleColorOptionId" style="background-color:purple;">Purple</option><option value="0,0,255,1" id="blueColorOptionId" style="background-color:blue;">Blue</option><option value="165,42,42,1" id="brownColorOptionId" style="background-color:brown;">Brown</option><option value="0,128,128,1" id="tealColorOptionId" style="background-color:teal;">Teal</option><option value="0,0,128,1" id="navyColorOptionId" style="background-color:navy;">Navy</option><option value="128,0,0,1" id="maroonColorOptionId" style="background-color:maroon;">Maroon</option><option value="50,205,50,1" id="limegreenColorOptionId" style="background-color:limegreen;">LimeGreen</option></select></td></tr><tr style="display: none"><td><div align="left">边框宽度:</div></td><td><input type="number" name="strokeWidthInput" id="strokeWidthInput" min="0" max="100" step="1" value="0" style="width:85px" /></td></tr><tr><td><div align="left">边框样式:</div></td><td><select id="lineStyleSelect"  style="width:85px"><option value="solid" selected="selected" style="background-color:white; color:black">普通</option><option value="dash" style="background-color:white; color:black">虚线</option></select></td></tr><tr><td><div align="left">显示边框:</div></td><td><input name="strokeWidthCheckbox" id="strokeWidthCheckbox" type="checkbox" value="checkbox" checked="checked" /></td></tr><tr><td><div align="left">填充颜色:</div></td><td><select id="fillColorSelect" size="1" style="width:85px"><option value="255,255,255,1" id="whiteColorOptionId" style="background-color:white; color:black">White</option><option value="0,0,0,1" id="blackColorOptionId" style="background-color:black; color:white">Black</option><option value="255,0,0,1" id="redColorOptionId" style="background-color:red;">Red</option><option value="255,255,0,1" id="yellowColorOptionId" style="background-color:yellow;">Yellow</option><option value="255,192,203,1" id="pinkColorOptionId" style="background-color:pink;">Pink</option><option value="0,255,0,1" id="greenColorOptionId" style="background-color:green;">Green</option><option value="255,165,0,1" id="orangeColorOptionId" selected="selected" style="background-color:orange;">Orange</option><option value="128,0,128,1" id="purpleColorOptionId" style="background-color:purple;">Purple</option><option value="0,0,255,1" id="blueColorOptionId" style="background-color:blue;">Blue</option><option value="165,42,42,1" id="brownColorOptionId" style="background-color:brown;">Brown</option><option value="0,128,128,1" id="tealColorOptionId" style="background-color:teal;">Teal</option><option value="0,0,128,1" id="navyColorOptionId" style="background-color:navy;">Navy</option><option value="128,0,0,1" id="maroonColorOptionId" style="background-color:maroon;">Maroon</option><option value="50,205,50,1" id="limegreenColorOptionId" style="background-color:limegreen;">LimeGreen</option></select></td></tr><tr><td><div align="left">透明度:</div></td><td><input type="number" name="opacityInput" id="opacityInput" min="0.1" max="1" step="0.1" value="1" style="width:85px" /></td></tr><tr><td><div align="left">名称:</div></td><td><input id="featureNameInput" name="featureNameInput" style="width:85px"/></td></tr><tr><td><div align="left">旋转角度:</div></td><td><input type="number" name="rotateDegreeInput" id="rotateDegreeInput" min="-180" max="180" step="1" value="0" style="width:85px" /></td></tr><tr><td><div align="left">zIndex:</div></td><td><input type="number" name="zIndexInput" id="zIndexInput" min="1" max="10" step="1" value="1" style="width:85px" /></td></tr></table></div>';
var circleAttributeDialogStr = '<div align="center"><table><tr><td><div align="left">边框颜色:</div></td><td><select id="strokeColorSelect" size="1" style="width:85px"><option value="255,255,255,1" id="whiteColorOptionId" style="background-color:white; color:black">White</option><option value="0,0,0,1" id="blackColorOptionId" style="background-color:black; color:white">Black</option><option value="255,0,0,1" id="redColorOptionId" style="background-color:red;">Red</option><option value="255,255,0,1" id="yellowColorOptionId" style="background-color:yellow;">Yellow</option><option value="255,192,203,1" id="pinkColorOptionId" style="background-color:pink;">Pink</option><option value="0,255,0,1" id="greenColorOptionId" style="background-color:green;">Green</option><option value="255,165,0,1" id="orangeColorOptionId" selected="selected" style="background-color:orange;">Orange</option><option value="128,0,128,1" id="purpleColorOptionId" style="background-color:purple;">Purple</option><option value="0,0,255,1" id="blueColorOptionId" style="background-color:blue;">Blue</option><option value="165,42,42,1" id="brownColorOptionId" style="background-color:brown;">Brown</option><option value="0,128,128,1" id="tealColorOptionId" style="background-color:teal;">Teal</option><option value="0,0,128,1" id="navyColorOptionId" style="background-color:navy;">Navy</option><option value="128,0,0,1" id="maroonColorOptionId" style="background-color:maroon;">Maroon</option><option value="50,205,50,1" id="limegreenColorOptionId" style="background-color:limegreen;">LimeGreen</option></select></td></tr><tr style="display: none"><td><div align="left">边框宽度:</div></td><td><input type="number" name="strokeWidthInput" id="strokeWidthInput" min="0" max="100" step="1" value="0" style="width:85px" /></td></tr><tr><td><div align="left">边框样式:</div></td><td><select id="lineStyleSelect"  style="width:85px"><option value="solid" selected="selected" style="background-color:white; color:black">普通</option><option value="dash" style="background-color:white; color:black">虚线</option></select></td></tr><tr><td><div align="left">显示边框:</div></td><td><input name="strokeWidthCheckbox" id="strokeWidthCheckbox" type="checkbox" value="checkbox" checked="checked" /></td></tr><tr><td><div align="left">填充颜色:</div></td><td><select id="fillColorSelect" size="1" style="width:85px"><option value="255,255,255,1" id="whiteColorOptionId" style="background-color:white; color:black">White</option><option value="0,0,0,1" id="blackColorOptionId" style="background-color:black; color:white">Black</option><option value="255,0,0,1" id="redColorOptionId" style="background-color:red;">Red</option><option value="255,255,0,1" id="yellowColorOptionId" style="background-color:yellow;">Yellow</option><option value="255,192,203,1" id="pinkColorOptionId" style="background-color:pink;">Pink</option><option value="0,255,0,1" id="greenColorOptionId" style="background-color:green;">Green</option><option value="255,165,0,1" id="orangeColorOptionId" selected="selected" style="background-color:orange;">Orange</option><option value="128,0,128,1" id="purpleColorOptionId" style="background-color:purple;">Purple</option><option value="0,0,255,1" id="blueColorOptionId" style="background-color:blue;">Blue</option><option value="165,42,42,1" id="brownColorOptionId" style="background-color:brown;">Brown</option><option value="0,128,128,1" id="tealColorOptionId" style="background-color:teal;">Teal</option><option value="0,0,128,1" id="navyColorOptionId" style="background-color:navy;">Navy</option><option value="128,0,0,1" id="maroonColorOptionId" style="background-color:maroon;">Maroon</option><option value="50,205,50,1" id="limegreenColorOptionId" style="background-color:limegreen;">LimeGreen</option></select></td></tr><tr><td><div align="left">透明度:</div></td><td><input type="number" name="opacityInput" id="opacityInput" min="0.1" max="1" step="0.1" value="1" style="width:85px" /></td></tr><tr><td><div align="left">名称:</div></td><td><input id="featureNameInput" name="featureNameInput" style="width:85px"/></td></tr><tr><td><div align="left">半径:</div></td><td><input type="number" name="radiusInput" id="radiusInput" min="1" max="10000" step="1" value="100" style="width:85px" /></td></tr><tr><td><div align="left">zIndex:</div></td><td><input type="number" name="zIndexInput" id="zIndexInput" min="1" max="10" step="1" value="1" style="width:85px" /></td></tr></table></div>';

var enableDragFlag = false;
function enableDragFunction() {
	enableDragFlag = true;
}
function disableDragFunction() {
	enableDragFlag = false;
}
function getEnableDragFlag() {
	return enableDragFlag;
}
	  /**
       * Define a namespace for the application.
       */
      var app = {};


      /**
       * @constructor
       * @extends {ol.interaction.Pointer}
       */
      app.Drag = function() {

        ol.interaction.Pointer.call(this, {
          handleDownEvent: app.Drag.prototype.handleDownEvent,
          handleDragEvent: app.Drag.prototype.handleDragEvent,
          handleMoveEvent: app.Drag.prototype.handleMoveEvent,
          handleUpEvent: app.Drag.prototype.handleUpEvent
        });

        /**
         * @type {ol.Pixel}
         * @private
         */
        this.coordinate_ = null;

        /**
         * @type {string|undefined}
         * @private
         */
        this.cursor_ = 'pointer';

        /**
         * @type {ol.Feature}
         * @private
         */
        this.feature_ = null;

        /**
         * @type {string|undefined}
         * @private
         */
        this.previousCursor_ = undefined;

      };
      ol.inherits(app.Drag, ol.interaction.Pointer);


      /**
       * @param {ol.MapBrowserEvent} evt Map browser event.
       * @return {boolean} `true` to start the drag sequence.
       */
      var lastPixel = null;
      var alertMessagOpened = false;
      app.Drag.prototype.handleDownEvent = function(evt) {
    	if(enableDragFlag == false)
    		return;
        var map = evt.map;

        var opt_options = {
        	layerFilter:function(layer) {
				console.log("click enter drawShapeFeatureLayer check");
				return layer === drawShapeFeatureLayer;
	        },};
        var feature = map.forEachFeatureAtPixel(evt.pixel,
            function(feature) {
              return feature;
            }, /*null,*/ 
            opt_options);

        if (feature) {
        	//if(feature.getStyle())
        	//	console.log("zIndex:"+feature.getStyle().getZIndex());
        	if(lastPixel == null)
        		lastPixel = evt.pixel;
        	else if(evt.pixel[0] == lastPixel[0] && evt.pixel[1] == lastPixel[1]) {
        		if(feature.getGeometry().getType() == "LineString") {
        			alertMsg(lineAttributeDialogStr, 3, feature);
        		} else if(feature.getGeometry().getType() == "Polygon") {
        			alertMsg(polygonAttributeDialogStr, 3, feature);
        		} else if(feature.getGeometry().getType() == "Circle") {
        			alertMsg(circleAttributeDialogStr, 3, feature);
        		}
        		
        		return true;
        	} else {
        		lastPixel = evt.pixel;
        	}
            this.coordinate_ = evt.coordinate;
            this.feature_ = feature;
        }

        return !!feature;
      };


      /**
       * @param {ol.MapBrowserEvent} evt Map browser event.
       */
      app.Drag.prototype.handleDragEvent = function(evt) {
    	if(enableDragFlag == false)
      		return;
        var deltaX = evt.coordinate[0] - this.coordinate_[0];
        var deltaY = evt.coordinate[1] - this.coordinate_[1];

        var geometry = /** @type {ol.geom.SimpleGeometry} */
            (this.feature_.getGeometry());
        geometry.translate(deltaX, deltaY);

        this.coordinate_[0] = evt.coordinate[0];
        this.coordinate_[1] = evt.coordinate[1];
      };


      /**
       * @param {ol.MapBrowserEvent} evt Event.
       */
      app.Drag.prototype.handleMoveEvent = function(evt) {
    	if(enableDragFlag == false)
      		return;
        if (this.cursor_ && isAlertMessageOpened() == false) {
          var map = evt.map;
          var feature = map.forEachFeatureAtPixel(evt.pixel,
                  function(feature) {
                    return feature;
                  }, /*null, */
      			function(layer) {
      				console.log("click enter layer check");
      				return layer === drawShapeFeatureLayer;
      	  });
          var element = evt.map.getTargetElement();
          if (feature) {
            if (element.style.cursor != this.cursor_) {
              this.previousCursor_ = element.style.cursor;
              element.style.cursor = this.cursor_;
            }
          } else if (this.previousCursor_ !== undefined) {
            element.style.cursor = this.previousCursor_;
            this.previousCursor_ = undefined;
          }
        }
      };


      /**
       * @return {boolean} `false` to stop the drag sequence.
       */
      app.Drag.prototype.handleUpEvent = function() {
        this.coordinate_ = null;
        this.feature_ = null;
        return false;
      };
      