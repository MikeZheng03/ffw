<%@ page import="java.util.*" %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@page import="dbservlet.*"%>

<jsp:include page="islogin.jsp"></jsp:include>

<%
	String data = request.getParameter("route");
	//System.out.println("saveroute.jsp,data size: "+data.length());
	if(data.getBytes().length > 4000) {
		out.println("数据太大，请重新规划");
	} else {
		
	    FlightData obj=new FlightData();
	    String userName = (String)session.getAttribute("name");
		int userType = Integer.parseInt((String)session.getAttribute("type"));
	    boolean result = obj.saveRoute(userName, userType, data);
	    String message = "success";
	    if(!result)
	    	message = "该航线已经保存，请勿重复保存";
	    out.println(message);
    }
    //String jsonS = jsonObj.toString();
    //out.println(jsonObj.toString());
    
   // out.flush();
    //response.getWriter().write(jsonObj);
%>