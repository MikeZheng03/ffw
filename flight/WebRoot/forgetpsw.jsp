<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>用户注册</title>
<link href="Css/cb.css" rel="stylesheet" type="text/css" />
<link href="Css/n.css" rel="stylesheet" type="text/css" />
<style type="text/css">
.STYLE1 {
	color: #ffffff;
	font-size: 12px;
}
.STYLE6 {
	font-size: 12px;
	color: #5593ce;
}
.STYLE8 {color: #ffffff}
.STYLE11 {font-size: 12px; color: #bab92b; }
.STYLE12 {
	color: #8da6c4;
	font-size: 12px;
}
input{ width:180px;}
select{ width:150px;}
</style>
<script src="./js/jquery-3.1.1.min.js"></script>
<script>
 	function checkf(){
		f=document.form1;
		if(f.truename.value==""){
		  alert("请填写公司名称");
		  return false;
		}
		if(f.username.value==""){
		  alert('用户名不能为空');
		  return false;
		}
		if(f.type.value==""){
			alert("用户类型不能为空");
			return false;
		}
		if(f.email.value==""){
			alert("邮箱不能为空");
			return false;
		}
		if(f.tel.value==""){
			alert("电话不能为空");
			return false;
		}
		
		return true;
	}

	function submitInfo() {
		if(!checkf())
			return false;
		f=document.form1;
		var submitData = "{company:'" + f.truename.value +
			"',user:'" + f.username.value +
			"',type:'" + f.type.value +
			"',email:'" + f.email.value +
			"',tel:'" + f.tel.value +
			"'}";
			
		var urlString = "submitinfo.jsp?requestType=forgetpsw";
		$.ajax({
			type:"POST",
			url: urlString,
			async: true,
			data: "userinfo="+submitData,
			//dataType:"json",
			crossDomain: true,
			success:function(message){
				var result = message.trim();
				if(result == "success") {
					alert("提交成功");
				} else {
					alert(result);
				}
				//parserAirportData(jsonData);
			},
			error:function()
			{
				alert(arguments[1]);
			}
		});
		clearContent();
	}
	
	function clearContent() {
		var truename=document.getElementById("truename");
		truename.value = "";
		var username=document.getElementById("username");
		username.value = "";
		var type=document.getElementById("type");
		type.options[0].selected = true;
		var email=document.getElementById("email");
		email.value = "";
		var tel=document.getElementById("tel");
		tel.value = "";
	}
</script>
<script src="Scripts/jquery.js" language="javascript"></script>
</head>

<body>
<table width="100%" height="600" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td height="554"  align="center" valign="top" background="img/bj.gif">
	<form id="form1" name="form1" method="post" action="reg.php?action=save" onsubmit="return checkf();">
	<table width="465" height="314" border="0" align="center" cellpadding="0" cellspacing="0" >
      <tr>
        <td  height="51" colspan="3"><img src="img/tonghang.jpg" width="464" height="77" /></td>
      </tr>
      <tr>
        <td width="16" height="403" >&nbsp;</td>
        <td width="500" align="center" valign="middle" ><table width="100%" height="403" border="0" cellpadding="0" cellspacing="0">
          <tr bordercolor="#185089">
            <td height="22" colspan="4" align="left" style="border-bottom:solid #8BA9C5 2px"><span class="STYLE8">找回密码</span></td>
            </tr>
          <tr>
            <td width="19%" height="23" align="right"><span class="STYLE1">公司名称：</span></td>
            <td colspan="2" align="left"><input name="truename" type="text" id="truename" /></td>
            <td width="27%" align="left"><span class="STYLE11">*请填写公司名称</span></td>
          </tr>
          <tr>
            <td height="24" align="right"><span class="STYLE1">用户名：</span></td>
            <td colspan="2" align="left"><input name="username" type="text" id="username" onkeyup="checkusername(this.value)" /></td>
            <td align="left"><span class="STYLE11" id="username_result">*请填写用户名</span></td>
          </tr>
          <tr>
            <td height="24" align="right"><span class="STYLE1">用户类型：</span></td>
            <td colspan="2" align="left">
              <label>
                <select name="type" id="type">
					<option value="">请选择...</option>
					<option value="2">普通用户</option>
				 	<option value="1">管理员</option>
				</select>
              </label>
            </td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td height="27" align="right"><span class="STYLE1">电子邮箱：</span></td>
            <td colspan="2" align="left"><input name="email" type="text" id="email" value="" /></td>
            <td align="left"><span class="STYLE11">*新密码将邮件告知</span></td>
          </tr>
		  <tr>
            <td height="31" align="right"><span class="STYLE1">联系电话：</span></td>
            <td colspan="2" align="left"><input name="tel" type="text" id="tel"/></td>
          </tr>
          <tr>
            <td height="53">&nbsp;</td>
            <td colspan="2" align="right" valign="middle">&nbsp;</td>
            <td align="left" valign="middle">
				<input name="image" type="button"  style="width:58px; height:33px; font-size:20px" value="提交" onclick="submitInfo()"></input>
			</td>
          </tr>
        </table></td>
        
      </tr>
    </table>
	
	 </form>
	 <br />
   <table width="100%" height="55" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td height="55" align="center" valign="middle"><span class="STYLE6">版权所有：xxxxxxx<br />
              <br />
          联系地址：xxxxxxxx</span></td>
      </tr>
    </table></td>
  </tr>
</table>
<%if(request.getAttribute("Msg")!=null){%>
<script>
alert("<%=request.getAttribute("Msg")%>");
</script>
<%}%>
</body>
</html>
