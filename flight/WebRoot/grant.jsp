<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>

<jsp:include page="islogin.jsp"></jsp:include> 

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
	<HEAD>
	<TITLE> Flight </TITLE>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	
	<script src="./js/jquery-3.1.1.min.js"></script>
    
    <link rel="stylesheet" href="./css/tabDiv.css">
    <!--jQuery dependencies-->
    <link rel="stylesheet" href="./css/jquery-ui.min.css" />
    <script src="./js/jquery-ui.min.js"></script>
<!--PQ Grid files-->
    <link rel="stylesheet" href="./css/pqgrid.min.css" />
    <script src="./js/pqgrid.min.js"></script>
<!--PQ Grid Office theme-->
	<link rel="stylesheet" href="./css/pqgrid.css" />
	<script src="./js/gridtable-grant.js"></script>
	<script src="./js/pq-localize-zh.js"></script>
	
	<script>
	

	function submitGrantResult() {
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
	
	function onRequestUserInfo(rStr) {
		showLoadingApplication();
		var urlString = "requestuserinfo.jsp?info="+rStr;
		$.ajax({
			type:"GET",
			url: urlString,
			dataType:"json",
			crossDomain: true,
			success:function(jsonData){
				console.log("data:"+ jsonData.data);
				clearUserInfo();
				addUserInfoRow(jsonData.data);
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
	}
	function applicationProcess(name, company, type, email, tel, flag) {
		if(type=="普通用户")
			type = 2;
		else if(type=="管理员")
			type = 1;
		else {
			alert("用户类型错误");
			return;
		}
		var urlString = "approve.jsp?name="+name+"&company="+company+"&type="+type+"&email="+email+"&tel="+tel+"&flag="+flag;
		$.ajax({
			type:"GET",
			url: urlString,
			crossDomain: true,
			success:function(message){
				var result = message.trim();
				if(result == "success") {
					alert("保存成功");
				} else {
					alert(result);
				}
				onRequestUserInfo("register");
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
	}
	</script>
	<script>
 		function init() {
 			createApplicationTable();
			onRequestUserInfo("register");
		}
	</script>
	</HEAD>
	<BODY onload="init()">
  
 	<div id="editArea" style="background:#eff7ff">
 	<!--  
 		<ul class="tabUl" id="tabUlId">  
	    	<li><a id="tabA1Id" onclick="sela(this);" href="#tabDiv1Id" class="sel">申请审批</a></li>  
	    	<li><a id="tabA2Id" onclick="sela(this);" href="#tabDiv2Id">用户记录</a></li>
		</ul> 
	
		<div id="tabA1Id" class="onTabDiv" align="center"> 
			<div style="width:100%; height:80%;" align="center">  
				<div id="grid_search" style="width:100%; height:100%; font-size:12px" align="center" >
				</div> 
			</div>
		</div>
		<div id="tabA2Id" class="tabDiv" align="center"> 
			<div style="width:100%; height:80%;" align="center">  
				<div id="grid_search" style="width:100%; height:100%; font-size:12px" align="center" >
				</div> 
			</div>
		</div>
	-->
		<div style="width:100%; height:80%;" align="center">  
			<div id="grid_search" style="width:100%; height:100%; font-size:12px" align="center" >
			</div> 
		</div>
 	</div>
 	<script>
 	function sela(link){  
	    var ul = document.getElementById("tabUlId"); 
	    var link1 = document.getElementById("tabA1Id");
	    link1.className = "";
	    var link2 = document.getElementById("tabA2Id");
	    link2.className = "";
	    link.className = "sel";
	    
	    var div1 = document.getElementById("tabDiv1Id");
	    div1.className = "tabDiv";
	    var div2 = document.getElementById("tabDiv2Id");
	    div2.className = "tabDiv";
	    
	    var divId = link.getAttribute("href").split("#")[1];
	    divId = document.getElementById(divId);  
	    divId.className = "onTabDiv";
	    if(divId == div1) {
	    	
	    } else if(divId == div2) {
	    	
	    }
	    return false;
	}  
	</script>
	</BODY>
</HTML>
