<%@ page import="java.util.*" %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@page import="dao.*"%>

<jsp:include page="islogin.jsp"></jsp:include> 

<%
	String data = request.getParameter("userinfo");
	//System.out.println("changeuserinfo.jsp,data size: "+data.length());
	String infoType = request.getParameter("info");
	JSONObject jsonObj = new JSONObject(data);
	String userName = (String)session.getAttribute("name");
	int userType = Integer.parseInt((String)session.getAttribute("type"));
	
	NormalDao obj=new NormalDao();
	int result = -1;
	String message = "success";
	if(infoType.equals("psw")) {
		result = obj.changePsw(userName, userType, jsonObj);
		if(result==0)
			message = "旧密码输入错误";
	} else if(infoType.equals("email")) {
		result = obj.changeEmail(userName, userType, jsonObj);
		if(result==0)
			message = "设置错误";
	} else if(infoType.equals("tel")) {
		result = obj.changeTel(userName, userType, jsonObj);
		if(result==0)
			message = "设置错误";
	}
	
	if(result==-1)
		message = "提交失败";
	out.println(message);

%>