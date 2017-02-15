<%@ page import="java.util.*" %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@page import="dbservlet.*"%>

<jsp:include page="islogin.jsp"></jsp:include>

<%
	String route = request.getParameter("data");
	System.out.println("deleteroute.jsp,value: "+route);
	String userName = (String)session.getAttribute("name");
	int userType = Integer.parseInt((String)session.getAttribute("type"));
    FlightData obj=new FlightData();
    obj.deleteRoute(userName,userType,route);
    //String jsonS = jsonObj.toString();
    //out.println(jsonObj.toString());
    
   // out.flush();
    //response.getWriter().write(jsonObj);
%>