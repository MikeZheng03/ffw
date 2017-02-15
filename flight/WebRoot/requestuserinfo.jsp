<%@ page import="java.util.*" %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@page import="dao.*"%>

<jsp:include page="islogin.jsp"></jsp:include> 

<%
	String infoType = request.getParameter("info");
    NormalDao obj=new NormalDao();
    JSONObject jsonObj = null;
    if(infoType.equals("register")) {
    	jsonObj = obj.getRegisterInfo();
    } else {
    	String userName = (String)session.getAttribute("name");
		int userType = Integer.parseInt((String)session.getAttribute("type"));
    	jsonObj = obj.getUserInfo(userName, userType);
    }
    String jsonS = jsonObj.toString();
    //System.out.println("requestuserinfo.jsp,json: "+jsonS);
    out.println(jsonS);
%>