$(function () {
        function filterhandler(evt, ui) {

            var $toolbar = $grid.find('.pq-toolbar-search'),
                $value = $toolbar.find(".filterValue"),
                value = $value.val(),
                condition = $toolbar.find(".filterCondition").val(),
                dataIndx = $toolbar.find(".filterColumn").val(),
                filterObject;

            if (dataIndx == "") {//search through all fields when no field selected.
				return;
                filterObject = [];
                var CM = $grid.pqGrid("getColModel");
                for (var i = 0, len = CM.length; i < len; i++) {
                    var dataIndx = CM[i].dataIndx;
                    filterObject.push({ dataIndx: dataIndx, condition: condition, value: value });
                }
            }
            else {//search through selected field.
                filterObject = [{ dataIndx: dataIndx, condition: condition, value: value}];
            }
            $grid.pqGrid("filter", {
                oper: 'replace',
                data: filterObject
            });
        }
        //filterRender to highlight matching cell text.
        function filterRender(ui) {
            var val = ui.cellData,
                filter = ui.column.filter;
            if (filter && filter.on && filter.value) {
                var condition = filter.condition,
                    valUpper = val.toUpperCase(),
                    txt = filter.value,
                    txt = (txt == null) ? "" : txt.toString(),
                    txtUpper = txt.toUpperCase(),
                    indx = -1;
                if (condition == "end") {
                    indx = valUpper.lastIndexOf(txtUpper);
                    //if not at the end
                    if (indx + txtUpper.length != valUpper.length) {
                        indx = -1;
                    }
                }
                else if (condition == "contain") {
                    indx = valUpper.indexOf(txtUpper);
                }
                else if (condition == "begin") {
                    indx = valUpper.indexOf(txtUpper);
                    //if not at the beginning.
                    if (indx > 0) {
                        indx = -1;
                    }
                }
                if (indx >= 0) {
                    var txt1 = val.substring(0, indx);
                    var txt2 = val.substring(indx, indx + txt.length);
                    var txt3 = val.substring(indx + txt.length);
                    return txt1 + "<span style='background:yellow;color:#333;'>" + txt2 + "</span>" + txt3;
                }
                else {
                    return val;
                }
            }
            else {
                return val;
            }
        }
		
		//to check whether any row is currently being edited.
        function isEditing($grid) {
            var rows = $grid.pqGrid("getRowsByClass", { cls: 'pq-row-edit' });
            if (rows.length > 0) {
                //focus on editor if any 
                $grid.find(".pq-editor-focus").focus();
                return true;
            }
            return false;
        }
		var routeArray = null;
		window.drawRouteButtonClick = function (target) {
			var $tr = $(target).closest("tr");
            var rowIndx = $grid.pqGrid("getRowIndx", { $tr: $tr }).rowIndx;
            var $tdUserName = $grid.pqGrid( "getCell", { rowIndx: rowIndx, dataIndx: "userName" } );
            var $tdPlanNum = $grid.pqGrid( "getCell", { rowIndx: rowIndx, dataIndx: "planNum" } );
            var index = $tdPlanNum.text();
			onDrawRoute(routeArray[index]);
            return false;
		}
		window.addApplicationStatusRow = function (jsonData) {
			//routeArray.splice(0, routeArray.length);
			routeArray = null;
			routeArray = new Array();
			$grid.pqGrid("option", "dataModel.data", jsonData);
			$grid.pqGrid("refreshDataAndView");
			$grid.pqGrid("hideLoading");
			
			for(var i = 0; i < jsonData.length; i++) {
				var index = jsonData[i].planNum;
				routeArray[index] = jsonData[i].route;
				//routeArray.push(jsonData[i].route);
			}
			/*
			//draw route button
	        $grid.find("button.drawRoute_btn").unbind("click")
	        .bind("click", function (evt) {
	            var $tr = $(this).closest("tr");
	            var rowIndx = $grid.pqGrid("getRowIndx", { $tr: $tr }).rowIndx;
				onDrawRoute(routeArray[rowIndx]);
	            return false;
	        });
	        */
        }
		
		window.onDrawButton = function (target) {
			var $tr = target.closest("tr");
            var rowIndx = $grid.pqGrid("getRowIndx", { $tr: $tr }).rowIndx;
			var $td = $( ".selector" ).pqGrid( "getCell", { rowIndx: rowIndx, dataIndx: "route" } );
			onDrawRoute($td.text());
		}
		function initDetail( ui ) {
            var rowData = ui.rowData.route;
			var str = "<div>"+rowData+"</div>";
            var $detail = $(str);

            return $detail;
        }
        var colM = [
			{ title: "计划编号", width: 100, dataType: "string", dataIndx: "planNum", render: filterRender },
			{ title: "起飞机场", width: 80, dataType: "string", dataIndx: "startName", render: filterRender },
            { title: "降落机场", width: 80, dataType: "string", dataIndx: "endName", render: filterRender },
            { title: "飞行日期", width: 80, dataType: "string", dataIndx: "planDate", render: filterRender },
            { title: "起飞时间", width: 80, dataType: "string", dataIndx: "planTime", render: filterRender },
			{ title: "机型", width: 60, dataType: "string", dataIndx: "planeType", render: filterRender },
			{ title: "航班号", width: 80, dataType: "string", dataIndx: "planeId", render: filterRender },
			{ title: "任务种类", width: 80, dataType: "string", dataIndx: "task", render: filterRender },
			{ title: "飞行高度", width: 80, dataType: "string", dataIndx: "altitude", render: filterRender },
			{ title: "审批意见", width: 200, dataType: "string", dataIndx: "comments", render: filterRender },
			{ title: "审批状态", width: 70, dataType: "string", dataIndx: "status", render: filterRender },
			{ title: "", editable: false, minWidth: 80, sortable: false, render: function (ui) {
				return "<button type='button' style='width:70px' class='drawRoute_btn' onclick='drawRouteButtonClick(this)'>显示航线</button>";
				}
			},
			{ title: "", minWidth: 27, width: 27, type: "detail", resizable: false, editable: false /* no need to mention dataIndx */ },
		];
        
        var dataModel = {
            recIndx: "planNum", //primary key
            location: "local",
        }
        var newObj = {
            flexHeight: true,
            flexWidth: true,
            pageModel: { type: 'local' },
            dataModel: dataModel,
            colModel: colM,
            selectionModel: { type: 'cell', mode: 'single' },
            filterModel: { mode: 'OR' },
            toolbar: {
                cls: "pq-toolbar-search",
                items: [
                    { type: "<span style='margin:5px;'>Filter</span>" },
                    { type: 'textbox', attr: 'placeholder="Enter your keyword"', cls: "filterValue", listeners: [{ 'keyup': filterhandler}] },
                    { type: 'select', cls: "filterColumn",
                        listeners: [{ 'change': filterhandler}],
                        options: function (ui) {
                            var CM = ui.colModel;
                            var opts = [];
                            for (var i = 0; i < CM.length; i++) {
                                var column = CM[i];
                                var obj = {};
                                obj[column.dataIndx] = column.title;
                                opts.push(obj);
                            }
                            return opts;
                        }
                    },
                    { type: 'select', style: "margin:0px 5px;", cls: "filterCondition",
                        listeners: [{ 'change': filterhandler}],
                        options: [
                        { "begin": "从头匹配 " },
                        { "contain": "包含" },
                        { "end": "从尾匹配 " },
                        { "notcontain": "不包含" },
                        { "equal": "等于" },
                        { "notequal": "不等于" },
                        ]
                    }
                ]
            },
            editable: false,
            showTitle: false,
            columnBorders: true,
			collapsible: false,
			detailModel: { init: initDetail }
        };
        var $grid=null;
        window.createApplicationTable = function () {
        	if($grid != null)
        		return;
        	$grid = $("#grid_search").pqGrid(newObj);
            //var column =  $grid.pqGrid( "getColumn",{ dataIndx: "route" } );
           
    		var buttons = document.getElementsByTagName("button");
    		for(var i = 0; i < buttons.length; i++) {
    			if(buttons[i].getAttribute("title") == "Refresh") {
    				buttons[i].onclick = function(){
    					onRequestApplicationStatus();
    				}; 
    			}
    		}
    		
    		$grid.pqGrid("option", $.paramquery.pqGrid.regional['zh']);            
            $grid.find(".pq-pager").pqPager("option", $.paramquery.pqPager.regional['zh']);
        }
        /*
        var $grid = $("#grid_search").pqGrid(newObj);
        //var column =  $grid.pqGrid( "getColumn",{ dataIndx: "route" } );
       
		var buttons = document.getElementsByTagName("button");
		for(var i = 0; i < buttons.length; i++) {
			if(buttons[i].getAttribute("title") == "Refresh") {
				buttons[i].onclick = function(){
					onRequestApplicationStatus();
				}; 
			}
		}
		
		$grid.pqGrid("option", $.paramquery.pqGrid.regional['zh']);            
        $grid.find(".pq-pager").pqPager("option", $.paramquery.pqPager.regional['zh']);       
        */
        window.refreshApplicationStatus = function () {
        	$grid.pqGrid("refreshDataAndView");
        }
        window.showLoadingApplication = function () {
        	$grid.pqGrid("showLoading");
        }
        window.hideLoadingApplication = function () {
        	$grid.pqGrid("hideLoading");
        }
        window.clearApplication = function () {
        	var data = [];
            $grid.pqGrid("option", "dataModel.data", data);
        }
    });
	