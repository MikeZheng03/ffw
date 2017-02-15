package dbservlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject; 

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

//import bean.Page;
import bean.FlightInfo;

public class FlightData extends HttpServlet {
	/**
	 * 
	 */
	private static long dataID = 1;
	 //doPostæ–¹æ³•
	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		    request.setCharacterEncoding("UTF-8");
   		    response.setCharacterEncoding("UTF-8");
			String flightName=request.getParameter("name");
			System.out.println(flightName);
		try {  
				select(dataID++, flightName);
			} catch (ClassNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	}
	//doGetæ–¹æ³•
	public void doGet(HttpServletRequest request, HttpServletResponse response)
	throws ServletException, IOException {
       doPost(request,response);
    }
	
    //æ•°æ�®åº“è¿žæŽ¥æ–¹æ³•
	public Connection connect() throws ClassNotFoundException, SQLException{
    	Connection conn=null; 
		
    	//System.out.println("mike, 1 conn:"+conn);
	    Class.forName("oracle.jdbc.driver.OracleDriver");
	    
		String url="jdbc:oracle:thin:@localhost:1521:geoserver"; 
	    String user="scott"; 
		String password="scott"; 
		conn=DriverManager.getConnection(url,user,password); 
		//System.out.println("mike, 2 conn:"+conn);
		return conn;
	}
	//å…³é—­æ•°æ�®åº“èµ„æº�
	public void close(Statement stat,Connection conn) throws SQLException{
		if(stat!=null){
	    	   stat.close();
	    }
	    if(conn!=null){
	    	   conn.close();
	    }
	}
	//æ�’å…¥æ–¹æ³•
	public void insert(HttpServletRequest request, HttpServletResponse response) throws ClassNotFoundException, SQLException{
    	Connection conn=null;
    	Statement stat=null;
		String id=request.getParameter("id");
        String name=request.getParameter("name");
        String lon=request.getParameter("lon");
        String lat=request.getParameter("lat");
        String ori=request.getParameter("ori");
		conn=connect();
		stat=conn.createStatement();
    	stat.execute("insert into student(id,name,lon,lat,ori) values("+id+",'"+name+"',"+lon+",'"+lat+"','"+ori+"')"); 
    	close(stat,conn);
    }
	
	public void addResult(Statement stat, long id, String tableName, JSONArray jsonArr) throws ClassNotFoundException, SQLException, JSONException{
		ResultSet rs=null;
		String idString = Long.toString(id);
		
		if(id > 0)
			rs=stat.executeQuery("select * from "+tableName+" where id="+idString+"");
		else
			rs=stat.executeQuery("select * from "+tableName+"");
		//System.out.println("mike, addResult id:"+id+",name:"+tableName+", rs:"+rs);
		while(rs.next()){
//			System.out.println("mike, addResult id:"+rs.getInt("id")+",name:"+rs.getString("name")+",lon:"+
//		rs.getFloat("lon")+",lat:"+rs.getFloat("lat")+",ori:"+rs.getInt("ori"));
			JSONObject obj=new JSONObject();
			obj.put("id",rs.getInt("id"));
			obj.put("name",rs.getString("name"));
			obj.put("lon",rs.getFloat("lon"));
			obj.put("lat",rs.getFloat("lat"));
			obj.put("ori",rs.getInt("ori"));
			int type = rs.getInt("type");
			if(type == 0)
				obj.put("rname","");
			else
				obj.put("rname",rs.getString("rname"));
			obj.put("alt",rs.getInt("alt"));
			obj.put("type",rs.getInt("type"));//0:without radar data, 1:start, 2:radar data, 3:end
			obj.put("time",rs.getString("time"));
			jsonArr.put(obj);
	    }
		if(rs!=null){
	    	rs.close();
	    }
	}
	
/*
 * {
	"sFlight":[
		{"name":"start","cName":"city1","lon1":118,"lat1":48,"lon2":0,"lat2":0},
		{"name":"mid","cName":"city2","lon1":118,"lat1":48,"lon2":0,"lat2":0},
		{"name":"end","cName":"city3","lon1":118,"lat1":48,"lon2":0,"lat2":0},
		{"name":"line","fName":"hb1234","lon1":118,"lat1":48,"lon2":118,"lat2":48},
		{"name":"line","fName":"hb1234","lon1":118,"lat1":48,"lon2":118,"lat2":48}
	]
   }
 * 
 */
	public JSONArray getLinesJSON(long id, JSONArray jsonArr) throws JSONException {
		JSONArray linesJsonArr = new JSONArray();
		
		
		//start, add city for demo
		JSONObject sJO = (JSONObject) jsonArr.get(0);
		JSONObject eJO = (JSONObject) jsonArr.get(jsonArr.length()-1);
		JSONObject sObj = new JSONObject();
		sObj.put("name","start");
		sObj.put("cName","city1");
		sObj.put("lon1",sJO.get("lon"));
		sObj.put("lat1",sJO.get("lat"));
		sObj.put("lon2",0);
		sObj.put("lat2",0);
		linesJsonArr.put(sObj);
		//System.out.println("mike, getLinesJSON start lon:"+sJO.get("lon")+", lat:"+sJO.get("lat"));
		
		JSONObject eObj = new JSONObject();
		eObj.put("name","end");
		eObj.put("cName","city2");
		eObj.put("lon1",eJO.get("lon"));
		eObj.put("lat1",eJO.get("lat"));
		eObj.put("lon2",0);
		eObj.put("lat2",0);
		linesJsonArr.put(eObj);
		//System.out.println("mike, getLinesJSON jsonArr.length():"+jsonArr.length()+", id:"+id);
		//System.out.println("mike, getLinesJSON end lon:"+eJO.get("lon")+", lat:"+eJO.get("lat"));
		//end
		int basePos = 0;
	    int baseOri = Integer.parseInt(sJO.get("ori").toString());
	    int subOri = 0;
		int pointNum = 0;
	    
		JSONObject lsJo = sJO;
		for (int i = 1; i < jsonArr.length() && i < id; i++) {
            JSONObject jo = (JSONObject) jsonArr.get(i);
            int ori = Integer.parseInt(jo.get("ori").toString());
            subOri += ori - baseOri;
			baseOri = ori;
			if(subOri > 5 || subOri < -5) {// > 5 degree, switch line
				//System.out.println("mike, getLinesJSON new line");
				JSONObject lObj = new JSONObject();
				lObj.put("name","line");
				lObj.put("fName",lsJo.get("name"));
				lObj.put("lon1",lsJo.get("lon"));
				lObj.put("lat1",lsJo.get("lat"));
				lObj.put("lon2",jo.get("lon"));
				lObj.put("lat2",jo.get("lat"));
				linesJsonArr.put(lObj);
				
				subOri = 0;
				basePos = i;
				baseOri = Integer.parseInt(jo.get("ori").toString());
				lsJo = jo;
			}
		}
		JSONObject lObj = new JSONObject();
		JSONObject bObj = (JSONObject) jsonArr.get(basePos);
		int intId=(int)id-1;
		//System.out.println("mike, getLinesJSON intId:"+intId+", id:"+id);
		JSONObject cObj = (JSONObject) jsonArr.get((int)id-1);
		lObj.put("name","line");
		lObj.put("fName",sJO.get("name"));
		lObj.put("lon1",bObj.get("lon"));
		lObj.put("lat1",bObj.get("lat"));
		lObj.put("lon2",cObj.get("lon"));
		lObj.put("lat2",cObj.get("lat"));
		linesJsonArr.put(lObj);
		//System.out.println("mike, getLinesJSON end!!!");
		return linesJsonArr;
	}
	
/*
 * {
	"radar":[
		{"id":0,"rName":"start","lon":118,"lat":48,"alt":0,"type":1},
		{"id":40,"rName":"r1","lon":117,"lat":48,"alt":5000,"type":1},
		{"id":140,"rName":"r2","lon":110,"lat":48,"alt":9000,"type":2},
		{"id":400,"rName":"end","lon":108,"lat":48,"alt":0,"type":3}
	]
   }
 */
	public JSONArray getRadarJSON(JSONArray jsonArr) throws JSONException {
		JSONArray radarJsonArr = new JSONArray();
		
		
		//start, add city for demo
		JSONObject sJO = (JSONObject) jsonArr.get(0);
		JSONObject eJO = (JSONObject) jsonArr.get(jsonArr.length()-1);
		JSONObject sObj = new JSONObject();
		sObj.put("id",sJO.get("id"));
		sObj.put("rname",sJO.get("rname"));
		sObj.put("lon",sJO.get("lon"));
		sObj.put("lat",sJO.get("lat"));
		sObj.put("alt",sJO.get("alt"));
		sObj.put("type",sJO.get("type"));
		sObj.put("time",sJO.get("time"));

		radarJsonArr.put(sObj);
		//System.out.println("mike, getLinesJSON start lon:"+sJO.get("lon")+", lat:"+sJO.get("lat"));
	
		//System.out.println("mike, getLinesJSON jsonArr.length():"+jsonArr.length()+", id:"+id);
		//System.out.println("mike, getLinesJSON end lon:"+eJO.get("lon")+", lat:"+eJO.get("lat"));
		//end

		for (int i = 1; i < jsonArr.length(); i++) {
            JSONObject jo = (JSONObject) jsonArr.get(i);
            if(Integer.parseInt(jo.get("type").toString()) == 0) {
            	continue;
            }
            JSONObject rObj = new JSONObject();
            rObj.put("id",jo.get("id"));
            rObj.put("rname",jo.get("rname"));
            rObj.put("lon",jo.get("lon"));
            rObj.put("lat",jo.get("lat"));
            rObj.put("alt",jo.get("alt"));
            rObj.put("type",jo.get("type"));
            rObj.put("time",jo.get("time"));
    		radarJsonArr.put(rObj);
    		//System.out.println("mike, getRadarJSON id:"+jo.get("id")+", rname:"+jo.get("rname")
    		//	+", lon:"+jo.get("lon")+", lat:"+jo.get("lat")+", alt:"+jo.get("alt")+", type:"+jo.get("type"));
		}
		/*
		JSONObject eObj = new JSONObject();
		eObj.put("id",eJO.get("id"));
		eObj.put("rname",eJO.get("rname"));
		eObj.put("lon",eJO.get("lon"));
		eObj.put("lat",eJO.get("lat"));
		eObj.put("alt",eJO.get("alt"));
		eObj.put("type",eJO.get("type"));
		radarJsonArr.put(eObj);
		*/
		//System.out.println("mike, getLinesJSON end!!!");
		return radarJsonArr;
	}
	
    //æŸ¥è¯¢æ–¹æ³•
    public JSONObject select(/*String*/long id,String name) throws ClassNotFoundException, SQLException, JSONException{
    	Connection conn=null;
    	Statement stat=null;
	    ResultSet rs=null;
	    conn=connect();
 		stat=conn.createStatement();
    	
    	ArrayList<FlightInfo> result=new ArrayList<FlightInfo>();
		/*
    	if(id==""&&name==""){
    	     rs=stat.executeQuery("select * from FLIGHT1"); 
    	}
    	if(id!=""&&name==""){
   	        rs=stat.executeQuery("select * from FLIGHT1 where id="+id+""); 
     	}
		
    	if(id==""&&name!=""){
   	        rs=stat.executeQuery("select * from FLIGHT1 where name='"+name+"'"); 
   	    }
		
    	if(id!=""&&name!=""){
      	    rs=stat.executeQuery("select * from FLIGHT1 where id="+id+" and name='"+name+"'"); 
      	}
		*/
		JSONObject jsonObj = new JSONObject();
		JSONArray jsonArr = new JSONArray();
		if(id>0) {
			String tableName1 = "FLIGHT1";
			if(id <= 237)
				addResult(stat, id, tableName1, jsonArr);
			String tableName2 = "FLIGHT2";
			if(id <= 413)
				addResult(stat, id, tableName2, jsonArr);
			String tableName3 = "FLIGHT3";
			if(id <= 420)
				addResult(stat, id, tableName3, jsonArr);
		}
		jsonObj.put("flight",jsonArr);
		if(name != ""  && id>0) {
			String tableName="11";
			//System.out.println("name:"+name);
			int nameNum=0;
			if("hb1234".equals(name)) {
				nameNum = 237;
				tableName = "FLIGHT1";
			}
			if("hb5678".equals(name)) {
				nameNum = 413;
				tableName = "FLIGHT2";
			}
			if("hb9012".equals(name)) {
				nameNum = 420;
				tableName = "FLIGHT3";
			}
			//System.out.println("tableName:"+tableName);
			JSONArray specificJsonArr = new JSONArray();
			addResult(stat, 0, tableName, specificJsonArr);
			if(nameNum >= id) {
				JSONArray linesJsonArr = getLinesJSON(id, specificJsonArr);
				jsonObj.put("sFlight",linesJsonArr);
				System.out.println("sFlight completed:");
			}
			else
				jsonObj.put("sFlight","[]");
			JSONArray radarJsonArr = getRadarJSON(specificJsonArr);
			jsonObj.put("radar",radarJsonArr);
			System.out.println("radar completed:"+radarJsonArr);
		}
	    close(stat,conn);
		
    	return jsonObj;
    }
    
    public void readTableData(Statement stat, String tableName, JSONArray jsonArr) throws ClassNotFoundException, SQLException, JSONException{
		ResultSet rs=null;
		
		rs=stat.executeQuery("select * from "+tableName+"");
		while(rs.next()){
//			System.out.println("mike, addResult id:"+rs.getInt("id")+",name:"+rs.getString("name")+",lon:"+
//		rs.getFloat("lon")+",lat:"+rs.getFloat("lat")+",ori:"+rs.getInt("ori"));
			JSONObject obj=new JSONObject();
			obj.put("name",rs.getString("name"));
			obj.put("lon",rs.getFloat("lon"));
			obj.put("lat",rs.getFloat("lat"));
			jsonArr.put(obj);
	    }
		if(rs!=null){
	    	rs.close();
	    }
	}
    
    public JSONObject getAirport() throws ClassNotFoundException, SQLException, JSONException{
    	Connection conn=null;
    	Statement stat=null;
	    conn=connect();
 		stat=conn.createStatement();
		
 		JSONObject jsonObj=new JSONObject();
		JSONArray jsonArr = new JSONArray();
		readTableData(stat, "airport", jsonArr);
		jsonObj.put("airport",jsonArr);
	    close(stat,conn);
		
    	return jsonObj;
    }
    
    public boolean saveRoute(String name, int type, String data) throws ClassNotFoundException, SQLException, JSONException{
    	Connection conn=null;
    	Statement stat=null;
    	ResultSet rs=null;
	    conn=connect();
 		stat=conn.createStatement();
		
 		//String shaData = sha256(data);
 		//System.out.println("mike, saveRoute shaData length:"+shaData.length());
 		//System.out.println("mike, saveRoute 3 shaData:"+shaData);
 		
 		String[] sourceStrArray = data.split("--");
		String tStr = "\\(";
		String startName = sourceStrArray[0].split(tStr)[0];
		String endName = sourceStrArray[sourceStrArray.length-1].split(tStr)[0];
		
 		rs=stat.executeQuery("select * from route"+" where name='"+name+
 				"' and type="+type+" and startname='"+startName+"' and endname='"+endName+"'");
 		String convertedData=data.replaceAll("'", "<>");
 		while (rs.next()) {
 			if(convertedData.equals(rs.getString("data"))) {
 				rs.close();
 			    close(stat,conn);
 			    return false;
 			}
 		}
		//System.out.println("mike, saveRoute convertedData:"+convertedData);
    	stat.execute("insert into route(name,type,data,startname,endname) values('"+name+"',"+type+",'"+convertedData+"','"+startName+"','"+endName+"')"); 
    	rs.close();
	    close(stat,conn);
		
    	return true;
    }
    
    public void deleteRoute(String name, int type, String data) throws ClassNotFoundException, SQLException, JSONException{
    	Connection conn=null;
    	Statement stat=null;
    	ResultSet rs=null;
	    conn=connect();
 		stat=conn.createStatement();
		
 		//String shaData = sha256(data);
 		//System.out.println("mike, saveRoute shaData length:"+shaData.length());
 		//System.out.println("mike, saveRoute 3 shaData:"+shaData);
 		
 		String[] sourceStrArray = data.split("--");
		String tStr = "\\(";
		String startName = sourceStrArray[0].split(tStr)[0];
		String endName = sourceStrArray[sourceStrArray.length-1].split(tStr)[0];

 		String convertedData=data.replaceAll("'", "<>");
 		stat.execute("delete from route where name='"+name+"' and type="+type+" and data='"+convertedData+"'");
	    close(stat,conn);
		
    }
    
    public JSONObject readRoute(String name, int type, String startName, String endName) throws ClassNotFoundException, SQLException, JSONException{
    	Connection conn=null;
    	Statement stat=null;
    	ResultSet rs=null;
	    conn=connect();
 		stat=conn.createStatement();
 		
 		rs=stat.executeQuery("select * from route"+" where type="+type+
 				" and name='"+name+"' and startName='"+startName+"' and endName='"+endName+"'");
 		JSONObject jsonObj=new JSONObject();
 		JSONArray jsonArr = new JSONArray();
 		int count = 0;
 		while(rs.next()){
			JSONObject obj=new JSONObject();
			obj.put("num",count);
			String data = rs.getString("data").replaceAll("<>","'");
			obj.put("data",data);
			jsonArr.put(obj);
			count++;
	    }
		if(rs!=null){
	    	rs.close();
	    }

		//String convertedData=data.replaceAll("'", "<>");
		//System.out.println("mike, saveRoute convertedData:"+convertedData);
    	//stat.execute("insert into route(sha,shaid,name,type,data) values('"+shaData+"',"+shaid+",'"+name+"',"+type+",'"+convertedData+"')"); 
    	rs.close();
	    close(stat,conn);
		
	    jsonObj.put("route",jsonArr);
    	return jsonObj;
    }
    
    /*
     * status: 0-submit(审批中), 1-grant(批准), 2-reject(拒绝), 3-flighting(飞行中), 4-done(已完成)
     */
    public boolean submitPlan(String userName, int userType, JSONObject jsonObj) throws JSONException, SQLException, ClassNotFoundException {
    	boolean result = true;
    	int status = 0;
    	String startName = jsonObj.getString("start");
    	String endName = jsonObj.getString("end");
    	String planDate = jsonObj.getString("date");
    	String planTime = jsonObj.getString("time");
    	String planeType = jsonObj.getString("type");
    	String planeTask = jsonObj.getString("task");
    	
    	Connection conn=null;
    	Statement stat=null;
    	ResultSet rs=null;
	    conn=connect();
 		stat=conn.createStatement();
    	
 		rs=stat.executeQuery("select * from flightplan"+" where username='"+userName+"'");
 		int count = 0;
 		while (rs.next()) {
 			count++;
 		}
 		String countStr="";
 		if(count < 10)
 			countStr = "000"+count;
 		else if(count < 100)
 			countStr = "00"+count;
 		else if(count < 1000)
 			countStr = "0"+count;
 		String[] dateStrArray = planDate.split("-");
 		String planNum = userName + dateStrArray[0] + dateStrArray[1] + dateStrArray[2] + countStr;
 
    	stat.execute("insert into flightplan(username,startname,endname,plandate,plantime,task,planetype,plannum,status) "
    			+ "values('"+userName+"','"+startName+"','"+endName+"','"+planDate
    			+"','"+planTime+"','"+planeTask+"','"+planeType+"','"+planNum+"',"+status+")"); 
    	rs.close();
	    close(stat,conn);
    	return result;
    }
    
    public boolean processPlan(JSONObject jsonObj) throws JSONException, SQLException, ClassNotFoundException {
    	boolean result = true;
    	String planNum = jsonObj.getString("planNum");
    	System.out.println("mike, processPlan planNum:"+planNum);
    	int status = jsonObj.getInt("status");
    	String route = jsonObj.getString("route");
    	route = route.replaceAll("\\[\\]","\"");
    	String comments = jsonObj.getString("comments");
    	String altitude = jsonObj.getString("altitude");
    	String planeId = jsonObj.getString("planeId");
    	
    	Connection conn=null;
    	Statement stat=null;
	    conn=connect();
 		stat=conn.createStatement();

 		stat.execute("update flightplan set status="+status+",route='"+route+"',comments='"+comments+"',altitude='"+altitude+"',planeId='"+planeId+"' where planNum='"+planNum+"'");
 		
	    close(stat,conn);
    	return result;
    }
    
    public JSONObject readPlan() throws ClassNotFoundException, SQLException, JSONException{
    	Connection conn=null;
    	Statement stat=null;
    	ResultSet rs=null;
	    conn=connect();
 		stat=conn.createStatement();
 		
 		rs=stat.executeQuery("select * from flightplan"+" where status="+0+"");
 		JSONObject jsonObj=new JSONObject();
 		JSONArray jsonArr = new JSONArray();
 		while(rs.next()){
			JSONObject obj=new JSONObject();
			String userName = rs.getString("username");
			obj.put("userName",userName);
			String startName = rs.getString("startname");
			obj.put("startName",startName);
			String endName = rs.getString("endname");
			obj.put("endName",endName);
			String planDate = rs.getString("plandate");
			obj.put("planDate",planDate);
			String planTime = rs.getString("plantime");
			obj.put("planTime",planTime);
			String task = rs.getString("task");
			obj.put("task",task);
			String planeType = rs.getString("planetype");
			obj.put("planeType",planeType);
			String planNum = rs.getString("plannum");
			obj.put("planNum",planNum);
			jsonArr.put(obj);
	    }
		if(rs!=null){
	    	rs.close();
	    }

		rs.close();
	    close(stat,conn);
		
	    jsonObj.put("plan",jsonArr);
    	return jsonObj;
    }
    
    public JSONObject getApplicationStatus(String userName, int userType) throws ClassNotFoundException, SQLException, JSONException{
    	Connection conn=null;
    	Statement stat=null;
    	ResultSet rs=null;
	    conn=connect();
 		stat=conn.createStatement();
 		if(userType == 1)
 			rs=stat.executeQuery("select * from flightplan");
 		else
 			rs=stat.executeQuery("select * from flightplan"+" where username='"+userName+"'");
 		JSONObject jsonObj=new JSONObject();
 		JSONArray jsonArr = new JSONArray();
 		while(rs.next()){
			JSONObject obj=new JSONObject();
			if(userType == 1) {
				userName = rs.getString("username");
				obj.put("userName",userName);
			}
			String startName = rs.getString("startname");
			obj.put("startName",startName);
			String endName = rs.getString("endname");
			obj.put("endName",endName);
			String planDate = rs.getString("plandate");
			obj.put("planDate",planDate);
			String planTime = rs.getString("plantime");
			obj.put("planTime",planTime);
			String task = rs.getString("task");
			obj.put("task",task);
			String planeType = rs.getString("planetype");
			obj.put("planeType",planeType);
			String planNum = rs.getString("plannum").split(userName)[1];
			obj.put("planNum",planNum);
			//status: 0-submit(审批中), 1-grant(批准), 2-reject(拒绝), 3-flighting(飞行中), 4-done(已完成)
			int status = rs.getInt("status");
			String statusStr = "审批中";
			switch(status) {
				case 1:
					statusStr = "批准";
					break;
				case 2:
					statusStr = "拒绝";
					break;
				case 3:
					statusStr = "飞行中";
					break;
				case 4:
					statusStr = "已完成";
					break;
			}
			obj.put("status",statusStr);
			String planeId = rs.getString("planeid");
			obj.put("planeId",planeId);
			String comments = rs.getString("comments");
			obj.put("comments",comments);
			int altitude = rs.getInt("altitude");
			obj.put("altitude",altitude);
			String route = "";
			if(status == 1 || status == 3 || status == 4)
				route = rs.getString("route").replaceAll("<>","'");
			obj.put("route",route);
			jsonArr.put(obj);
	    }
		if(rs!=null){
	    	rs.close();
	    }

		rs.close();
	    close(stat,conn);
		
	    jsonObj.put("application",jsonArr);
    	return jsonObj;
    }
    /*
    //æ�¡ä»¶æŸ¥è¯¢è·³è½¬
    public void dispatch(HttpServletRequest request, HttpServletResponse response) throws ClassNotFoundException, SQLException, ServletException, IOException{
    	String id5=request.getParameter("id");
    	String name5=request.getParameter("name");  
     if(select(id5,name5).isEmpty()){
        	request.getRequestDispatcher("selectnothing.jsp").forward(request, response);
        }
       else{
    		request.setAttribute("result", select(id5,name5));
            request.getRequestDispatcher("idnameselect.jsp").forward(request, response);	
        }
    }
    //è®¾ç½®åˆ†é¡µç›¸å…³å�‚æ•°æ–¹æ³•
	public Page setpage(HttpServletRequest request, HttpServletResponse response) throws ClassNotFoundException, SQLException{
		String crd=request.getParameter("currentRecord");
		//String id=request.getParameter("id");
        String name=request.getParameter("name");
    	ArrayList<FlightInfo> result=select("",name);
    	Page pager=new Page();
    	pager.setTotalRecord(result.size()); 
    	pager.setTotalPage(result.size(),pager.getPageSize());
    	if(crd!=null)
        {
    		int currentRecord=Integer.parseInt(crd);
            pager.setCurrentRecord(currentRecord);
            pager.setCurrentPage(currentRecord,pager.getPageSize());
        }
    	return pager;
	}
	//èŽ·å¾—åˆ†é¡µæ˜¾ç¤ºçš„å­�é›†
	 public void difpage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, ClassNotFoundException, SQLException{
		// String id=request.getParameter("id");
	     String name=request.getParameter("name");
		 ArrayList<FlightInfo> result=select("",name);
		 Page pager=new Page();
		 pager=setpage(request,response);
  	     List<FlightInfo> subResult=null;
  	     int currentRecord=pager.getCurrentRecord();
         if(currentRecord==0){
         	if(pager.getTotalRecord()<8){
         		subResult=(List<FlightInfo>) result.subList(0,pager.getTotalRecord());
         	}
         	else{
         		subResult=(List<FlightInfo>) result.subList(0,pager.getPageSize());
         	}         
         }
         else if(pager.getCurrentRecord()+pager.getPageSize()<result.size())
         {
               subResult=(List<FlightInfo>) result.subList(pager.getCurrentRecord(),pager.getCurrentRecord()+pager.getPageSize());
         }
         else
         {
              subResult=(List<FlightInfo>) result.subList(pager.getCurrentRecord(),result.size());
         }
         request.setAttribute("pager", pager);
	     request.setAttribute("subResult", subResult);
		 request.getRequestDispatcher("layout.jsp").forward(request, response);
     }
    //ä¿¡æ�¯åˆ é™¤æ–¹æ³•
    public void delete(HttpServletRequest request, HttpServletResponse response) throws ClassNotFoundException, SQLException, ServletException, IOException{
    	Connection conn=null;
    	Statement stat=null;
    	conn=connect();
 		stat=conn.createStatement();
 		String id2=request.getParameter("id");
		String name=request.getParameter("name");
		if(name=="hb1234")
		    stat.execute("delete from FLIGHT1 where id="+id2+"");
		if(name=="hb5678")
		    stat.execute("delete from FLIGHT2 where id="+id2+"");
		request.getRequestDispatcher("delete.jsp").forward(request, response);
    } 
    */
    //ä¿¡æ�¯ä¿®æ”¹æ–¹æ³•
    public void update1(HttpServletRequest request, HttpServletResponse response) throws ClassNotFoundException, SQLException, ServletException, IOException{
    	String id4=request.getParameter("id");
	    //request.setAttribute("result", select(id4,""));
        //request.getRequestDispatcher("update1.jsp").forward(request, response);
    }   
    public void update(HttpServletRequest request, HttpServletResponse response) throws ClassNotFoundException, SQLException, ServletException, IOException{
    	Connection conn=null;
    	Statement stat=null;
        String id3=request.getParameter("id");
        String name3=request.getParameter("name");
        String lon3=request.getParameter("lon");
        String lat3=request.getParameter("lat");
        String ori3=request.getParameter("ori");
    	conn=connect();
 		stat=conn.createStatement();
		if(name3=="hb1234")
		   stat.execute("update FLIGHT1 set id="+id3+",name='"+name3+"',lon="+lon3+",lat='"+lat3+"',ori='"+ori3+"' where id="+id3+"");
		//request.setAttribute("result", select(id3,""));    
	    //request.getRequestDispatcher("update.jsp").forward(request, response); 
    } 
   
}
