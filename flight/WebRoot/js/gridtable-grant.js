(function () {
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
		
		window.grantButtonClick = function (target, flag) {
			var $tr = $(target).closest("tr");
            var rowIndx = $grid.pqGrid("getRowIndx", { $tr: $tr }).rowIndx;
            var $tdName = $grid.pqGrid( "getCell", { rowIndx: rowIndx, dataIndx: "name" } );
            var $tdCompany = $grid.pqGrid( "getCell", { rowIndx: rowIndx, dataIndx: "company" } );
            var $tdType = $grid.pqGrid( "getCell", { rowIndx: rowIndx, dataIndx: "type" } );
            var $tdEmail = $grid.pqGrid( "getCell", { rowIndx: rowIndx, dataIndx: "email" } );
            var $tdTel = $grid.pqGrid( "getCell", { rowIndx: rowIndx, dataIndx: "tel" } );

            applicationProcess($tdName.text(), $tdCompany.text(), $tdType.text(), $tdEmail.text(), $tdTel.text(), flag);
            return false;
		}
		window.addUserInfoRow = function (jsonData) {
			$grid.pqGrid("option", "dataModel.data", jsonData);
			$grid.pqGrid("refreshDataAndView");
			$grid.pqGrid("hideLoading");
        }
		
        var colM = [
			{ title: "公司名称", width: 200, dataType: "string", dataIndx: "company", render: filterRender },
			{ title: "用户名", width: 200, dataType: "string", dataIndx: "name", render: filterRender },
            { title: "用户类型", width: 100, dataType: "string", dataIndx: "type", render: filterRender },
            { title: "电子邮箱", width: 200, dataType: "string", dataIndx: "email", render: filterRender },
            { title: "联系电话", width: 200, dataType: "string", dataIndx: "tel", render: filterRender },
			{ title: "", editable: false, minWidth: 80, sortable: false, render: function (ui) {
				return "<button type='button' style='width:70px' class='drawRoute_btn' onclick='grantButtonClick(this, 1)'>批准</button>";
				}
			},
			{ title: "", editable: false, minWidth: 80, sortable: false, render: function (ui) {
				return "<button type='button' style='width:70px' class='drawRoute_btn' onclick='grantButtonClick(this, 0)'>拒绝</button>";
				}
			},
		];
        
        var dataModel = {
            recIndx: "name", //primary key
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
    					onRequestUserInfo("register");
    				}; 
    			}
    		}
    		
    		$grid.pqGrid("option", $.paramquery.pqGrid.regional['zh']);            
            $grid.find(".pq-pager").pqPager("option", $.paramquery.pqPager.regional['zh']);
        }
        
        window.refreshApplicationInfo = function () {
        	$grid.pqGrid("refreshDataAndView");
        }
        window.showLoadingApplication = function () {
        	$grid.pqGrid("showLoading");
        }
        window.hideLoadingApplication = function () {
        	$grid.pqGrid("hideLoading");
        }
        window.clearUserInfo = function () {
        	var data = [];
            $grid.pqGrid("option", "dataModel.data", data);
        }
    })();
	