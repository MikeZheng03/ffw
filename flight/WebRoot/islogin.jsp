<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>

<%  
    if(session.getAttribute("name") == null) {  
%>  
        <script type="text/javascript" language="javascript">  
            alert("您还没有登录，请登录...");  
            window.document.location.href="login.jsp";  
        </script>   
<%  
    }  
%>