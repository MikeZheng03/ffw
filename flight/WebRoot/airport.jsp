<%@ page import="java.util.*" %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@page import="dbservlet.*"%>

<jsp:include page="islogin.jsp"></jsp:include> 

<%
    FlightData obj=new FlightData();
    JSONObject jsonObj = obj.getAirport();
    String jsonS = jsonObj.toString();
    System.out.println("data.jsp,json: "+jsonS);
    out.println(jsonObj.toString());
    
   // out.flush();
    //response.getWriter().write(jsonObj);
%>