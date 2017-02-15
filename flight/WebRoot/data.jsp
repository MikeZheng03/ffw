<%@ page import="java.util.*" %>
<%@page contentType="text/html; charset=UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@page import="dbservlet.*"%>
<%
/*
{  
    "flight": [  
        {  
            "name": "f1111",  
            "lng": "122",  
            "lat": "51",  
            "status": "1"  
        },  
        {  
            "name": "f2222",  
            "lng": "111",  
            "lat": "24",  
            "status": "1"  
        }]  
}   

{
	"sFlight":[
		{"name":"start","cName":"city1","lon1":118.67460632324219,"lat1":48.0791015625,"lon2":0,"lat2":0},
		{"name":"mid","cName":"city2","lon1":118.67460632324219,"lat1":48.0791015625,"lon2":0,"lat2":0},
		{"name":"end","cName":"city3","lon1":118.67460632324219,"lat1":48.0791015625,"lon2":0,"lat2":0},
		{"name":"line","fName":"hb1234","lon1":118.67460632324219,"lat1":48.0791015625,"lon2":118.67460632324219,"lat2":48.0791015625},
		{"name":"line","fName":"hb1234","lon1":118.67460632324219,"lat1":48.0791015625,"lon2":118.67460632324219,"lat2":48.0791015625}
	]
}
*/
%>
<%
	String name = request.getParameter("name");
	//System.out.println("data.jsp name: "+name);
	String id = request.getParameter("id");
	//System.out.println("data.jsp, id: "+id);
    FlightData obj=new FlightData();
    
    JSONObject jsonObj = obj.select(Long.parseLong(id),name);
    String jsonS = jsonObj.toString();
    //System.out.println("data.jsp,json: "+jsonS);
    out.println(jsonObj.toString());
    
   // out.flush();
    //response.getWriter().write(jsonObj);
%>