<%@ page import="java.util.*" %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@page import="dbservlet.*"%>

<jsp:include page="islogin.jsp"></jsp:include>

<%
	String data = request.getParameter("plan");
	//System.out.println("submitplan.jsp,data size: "+data.length());
	JSONObject jsonObj = new JSONObject(data);
	
	FlightData obj=new FlightData();
	String userName = (String)session.getAttribute("name");
	int userType = Integer.parseInt((String)session.getAttribute("type"));
	boolean result = obj.submitPlan(userName, userType, jsonObj);
	String message = "success";
	if(!result)
		message = "计划提交失败";
	out.println(message);

%>