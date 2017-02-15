<%@ page import="java.util.*" %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@page import="dao.*"%>

<%
	String data = request.getParameter("userinfo");
	//System.out.println("submitinfo.jsp,data size: "+data.length());
	String requestType = request.getParameter("requestType");
	JSONObject jsonObj = new JSONObject(data);
	
	NormalDao obj=new NormalDao();
	int result = -1;
	String message = "success";
	if(requestType.equals("register")) {
		result = obj.submitInfo(jsonObj);
		if(result==0)
			message = "用户名已经存在";
	}
	else if(requestType.equals("forgetpsw")) {
		result = obj.forgetPassword(jsonObj);
		if(result==0)
			message = "用户名不存在，请注册";
		else if(result==-10)
			message = "用户名和邮箱不匹配";
	}
	
	if(result==-1)
		message = "提交失败";
	out.println(message);

%>