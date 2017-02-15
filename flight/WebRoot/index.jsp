<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
  <HEAD>
   <TITLE> Flight </TITLE>
   <link rel="SHORTCUT ICON" href="img/marker.png"/>
  </HEAD>
  <body>
  <%
	int userType = Integer.parseInt((String)session.getAttribute("type"));
	if(userType == 1) {
  %>
  		<%@ include file="adminmap.jsp"%>
  <%
  	} else {
  %>
  		<%@ include file="map.jsp"%>
  <%
  	}
  %>

  </body>
 </HTML>
