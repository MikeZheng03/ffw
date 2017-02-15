<%@ page import="java.util.*" %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@page import="dbservlet.*"%>

<jsp:include page="islogin.jsp"></jsp:include> 

<%
	String startName = request.getParameter("startName");
	String endName = request.getParameter("endName");
	String userName = (String)session.getAttribute("name");
	int userType = Integer.parseInt((String)session.getAttribute("type"));
    FlightData obj=new FlightData();
    JSONObject jsonObj = obj.readRoute(userName,userType,startName,endName);
    String jsonS = jsonObj.toString();
    System.out.println("readroute.jsp,json: "+jsonS);
    out.println(jsonObj.toString());

%>