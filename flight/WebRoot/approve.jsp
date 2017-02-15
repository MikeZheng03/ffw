<%@ page import="java.util.*" %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@page import="dao.*"%>

<%
	String name = request.getParameter("name");
	String company = request.getParameter("company");
	String type = request.getParameter("type");
	String email = request.getParameter("email");
	String tel = request.getParameter("tel");
	String flag = request.getParameter("flag");
	//System.out.println("data.jsp, id: "+id);
    NormalDao obj=new NormalDao();
    
    boolean result = obj.approve(name,company,type,email,tel,flag);
    String message = "success";
	if(!result)
	    message = "操作失败";
	out.println(message);
%>