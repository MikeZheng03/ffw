<%@ page import="java.util.*" %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@page import="dbservlet.*"%>

<jsp:include page="islogin.jsp"></jsp:include> 

<%
	String userName = (String)session.getAttribute("name");
	int userType = Integer.parseInt((String)session.getAttribute("type"));
    FlightData obj=new FlightData();
    JSONObject jsonObj = obj.getApplicationStatus(userName, userType);
    String jsonS = jsonObj.toString();
    System.out.println("applicationstatus.jsp,json: "+jsonS);
    out.println(jsonObj.toString());
    
   // out.flush();
    //response.getWriter().write(jsonObj);
%>