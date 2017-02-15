<%@ page import="java.util.*" %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@page import="dbservlet.*"%>

<jsp:include page="islogin.jsp"></jsp:include>

<%
	String data = request.getParameter("process");
	//System.out.println("processplan.jsp,data size: "+data.length());
	JSONObject jsonObj = new JSONObject(data);
	String route = jsonObj.getString("route");
	int byteNum = route.getBytes().length;
	if(byteNum > 4000) {
		out.println("航线数据太大，请重新规划");
	} else {
		
	    FlightData obj=new FlightData();
	    boolean result = obj.processPlan(jsonObj);
	    String message = "success";
	    if(!result)
	    	message = "提交数据失败";
	    out.println(message);
    }
%>