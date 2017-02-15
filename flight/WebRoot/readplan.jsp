<%@ page import="java.util.*" %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@page import="dbservlet.*"%>

<jsp:include page="islogin.jsp"></jsp:include> 

<%
    FlightData obj=new FlightData();
    JSONObject jsonObj = obj.readPlan();
    String jsonS = jsonObj.toString();
    //System.out.println("readplan.jsp,json: "+jsonS);
    out.println(jsonObj.toString());

%>