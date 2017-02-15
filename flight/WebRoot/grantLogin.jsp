<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<base href="<%=basePath%>"> 
<title>登录</title>
<link href="css/login-1.css" rel="stylesheet" type="text/css" />
<link href="css/login-2.css" rel="stylesheet" type="text/css" />
<style type="text/css">
<!--
.STYLE1 {
	color: #ffffff;
	font-size: 12px;
}
.STYLE4 {
	color: #8da8c3;
	font-size: 12px;
}
.STYLE6 {
	font-size: 12px;
	color: #5593ce;
}
-->
</style>
<!--<link  href="Css/layout.css" rel="stylesheet" type="text/css" />-->
<script>
function check(){
	f=document.form1;
	if(f.username.value==""){
		alert("请填写用户名");
		return false;
	}
	if(f.password.value==""){
		alert("请填写密码");
		return false;
	}
}
</script>
</head>

<body>
<table width="100%" height="594" border="0" align="center" cellpadding="0" cellspacing="0"  style="margin:0px; padding:0px">
  <tr>
    <td height="594"  align="center" valign="top" background="img/bj.gif">
	<table width="465" height="414" border="0" align="center" cellpadding="0" cellspacing="0" >
      <tr>
        <td  height="152" colspan="3" valign="bottom"><img src="img/tonghang.jpg" width="465" height="100" /></td>
      </tr>
      <tr>
        <td width="15" height="262" background="img/bj1.gif">&nbsp;</td>
        <td width="420" valign="middle" background="img/bj2.gif">
		<form id="form1" name="form1" method="post" action="GrantAction.action" onsubmit="return check();">
		<table width="100%" height="170" border="0" align="center" cellpadding="0" cellspacing="0">
            <tr>
              <td width="31%" align="right"><span class="STYLE1">用户名：</span></td>
              <td colspan="3" align="left"><label>
                <input name="name" type="text" id="name" value="" />
              </label></td>
            </tr>
            <tr>
              <td align="right"><span class="STYLE1">密码：</span></td>
              <td colspan="3" align="left"><label>
                <input name="password" type="password" id="password" value="" />
              </label></td>
            </tr>
            <tr>
              <td>&nbsp;</td>
              
              <td width="34%" height="55" align="left"> 
			  <input type="image"  style="width:60px; height:55px;" src="img/login2.gif" />			  </td>
            </tr>
        </table>
		 </form>		</td>
        <td width="13" background="img/bj3.gif">&nbsp;</td>
      </tr>
    </table>
	<table width="465" height="76" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td height="76">&nbsp;</td>
      </tr>
    </table>
	<br />
	<table width="100%" height="64" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td height="64" align="center" valign="middle"><span class="STYLE6">版权所有：xxxxxx <br />
              <br />
          xxxxxx</span></td>
      </tr>
    </table>
	</td>
  </tr>
</table>
<%if(request.getAttribute("Msg")!=null){%>
<script>
alert("<%=request.getAttribute("Msg")%>");
</script>
<%}%>
</body>
</html>
