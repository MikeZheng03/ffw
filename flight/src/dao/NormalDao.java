package dao;

import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject; 
/*
 * type: 
 * 	1: admin
 * 	2: user
 *  11: superadmin
 */
public class NormalDao {
	public static String sha256(String data) throws NoSuchAlgorithmException {  
        MessageDigest md = MessageDigest.getInstance("SHA-256");  
        md.update(data.getBytes());  
        StringBuffer buf = new StringBuffer();  
        byte[] bits = md.digest();  
        for(int i=0;i<bits.length;i++){  
            int a = bits[i];  
            if(a<0) a+=256;  
            if(a<16) buf.append("0");  
            buf.append(Integer.toHexString(a));  
        }  
        return buf.toString();  
    }  
	
	private boolean isInvalid(String value) {
		return (value == null || value.length() == 0);
	}
	
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
	
	public void close(Statement stat,Connection conn) throws SQLException{
		if(stat!=null){
	    	   stat.close();
	    }
	    if(conn!=null){
	    	   conn.close();
	    }
	}
	
	public boolean insertLogin(String name, String password, int type) throws ClassNotFoundException, SQLException, NoSuchAlgorithmException{
    	Connection conn=null;
    	Statement stat=null;
    	ResultSet rs=null;
    	boolean result = true;

		conn=connect();
		stat=conn.createStatement();
		
		rs=stat.executeQuery("select * from login where name='"+name+"'"); 
    	while(rs.next())
        {
        	result = false;
        	rs.close();
        	close(stat,conn);
        	return result;
        }
	    if(rs!=null){
			rs.close();
	    }
	    
		String shaData = sha256(password);
    	stat.execute("insert into login(name,password,type) values('"+name+"','"+shaData+"',"+type+")"); 
    	close(stat,conn);
    	return result;
    }
	
	public void deleteLogin(String name) throws ClassNotFoundException, SQLException, IOException{
    	Connection conn=null;
    	Statement stat=null;
    	conn=connect();
 		stat=conn.createStatement();
		stat.execute("delete from login where name="+name+"");
    } 
	
	public boolean checkLogin(String name,String password, int type) throws ClassNotFoundException, SQLException, NoSuchAlgorithmException{
    	Connection conn=null;
    	Statement stat=null;
	    ResultSet rs=null;
		boolean result = false;
		if(isInvalid(password)||isInvalid(name))
			return false;
	    conn=connect();
		stat=conn.createStatement();
    	
		//System.out.println("mike, name:"+name+", type:"+type);
 		String shaData = sha256(password);
 		//System.out.println("mike, password:"+password+", shaData:"+shaData);
      	//rs=stat.executeQuery("select * from login where name='"+name+"'"); 
      	rs=stat.executeQuery("select * from login where password='"+shaData+"' and name='"+name+"' and type="+type+""); 
    	while(rs.next())
        {
        	result = true;
        }
	    if(rs!=null){
			rs.close();
	    }
	    close(stat,conn);
    	return result;
	}
	/*
	 * result: 0: user name exists, 1: submit successfully
	 * status: 0: register request
	 */
	public int submitInfo(JSONObject jsonObj) throws ClassNotFoundException, SQLException, NoSuchAlgorithmException, JSONException{
    	Connection conn=null;
    	Statement stat=null;
    	ResultSet rs=null;
    	int result = 0;

		conn=connect();
		stat=conn.createStatement();
		
		String userName = jsonObj.getString("user");
		int type = jsonObj.getInt("type");
		rs=stat.executeQuery("select * from login where name='"+userName+"' and type="+type+"");
    	while(rs.next())
        {
        	rs.close();
        	close(stat,conn);
        	return result;
        }
	    if(rs!=null){
			rs.close();
	    }
	    
	    rs=stat.executeQuery("select * from request where name='"+userName+"' and type="+type+"");
    	while(rs.next())
        {
        	rs.close();
        	close(stat,conn);
        	return result;
        }
	    if(rs!=null){
			rs.close();
	    }
	    
	    String company = jsonObj.getString("company");
	    String pwd = jsonObj.getString("pwd");
		String password = sha256(pwd);
		String email = jsonObj.getString("email");
		String tel = jsonObj.getString("tel");
		int status = 0;
		
		stat.execute("insert into request(name,password,type,company,email,tel,status) "
    			+ "values('"+userName+"','"+password+"',"+type+",'"+company
    			+"','"+email+"','"+tel+"',"+status+")");
    	close(stat,conn);
    	result = 1;
    	return result;
    }
	/*
	 * status: 1: request reset psw
	 * result: -10: email and userName not match
	 */
	public int forgetPassword(JSONObject jsonObj) throws ClassNotFoundException, SQLException, NoSuchAlgorithmException, JSONException{
    	Connection conn=null;
    	Statement stat=null;
    	ResultSet rs=null;
    	int result = 0;

		conn=connect();
		stat=conn.createStatement();
		
		String userName = jsonObj.getString("user");
		int type = jsonObj.getInt("type");
		rs=stat.executeQuery("select * from login where name='"+userName+"' and type="+type+""); 
    	if(!rs.next())
        {
        	rs.close();
        	close(stat,conn);
        	return result;
        }
    	String email = jsonObj.getString("email");
    	if(!rs.getString("email").equals(email)) {
    		result = -10;
        	rs.close();
        	close(stat,conn);
        	return result;
        }
	    if(rs!=null){
			rs.close();
	    }
	    
	    String company = jsonObj.getString("company");
		String tel = jsonObj.getString("tel");
		int status = 1;
		
		stat.execute("insert into requestpsw(name,type,company,email,tel) "
    			+ "values('"+userName+"',"+type+",'"+company
    			+"','"+email+"','"+tel+"')");
    	close(stat,conn);
    	result = 1;
    	return result;
    }
	public JSONObject getUserInfo(String name, int type) throws ClassNotFoundException, SQLException, NoSuchAlgorithmException, JSONException{
		Connection conn=null;
    	Statement stat=null;
    	ResultSet rs=null;
	    conn=connect();
 		stat=conn.createStatement();
 		
 		rs=stat.executeQuery("select * from login"+" where type="+type+
 				" and name='"+name+"'");
 		JSONObject jsonObj=new JSONObject();

 		if(rs.next()){
 			jsonObj.put("name",name);
 			jsonObj.put("type",type);
 			jsonObj.put("company",rs.getString("company"));
 			jsonObj.put("email",rs.getString("email"));
 			jsonObj.put("tel",rs.getString("tel"));
	    }
		if(rs!=null){
	    	rs.close();
	    }

		rs.close();
	    close(stat,conn);
		
    	return jsonObj;
    }
	public JSONObject getRegisterInfo() throws ClassNotFoundException, SQLException, NoSuchAlgorithmException, JSONException{
		Connection conn=null;
    	Statement stat=null;
    	ResultSet rs=null;
	    conn=connect();
 		stat=conn.createStatement();
 		
 		rs=stat.executeQuery("select * from request");
 		JSONObject jsonObj=new JSONObject();
 		JSONArray jsonArr = new JSONArray();
 		
 		while(rs.next()){
 			JSONObject obj=new JSONObject();
 			obj.put("name",rs.getString("name"));
 			String typeStr = "";
 			switch(rs.getInt("type")) {
 				case 1:
 					typeStr = "管理员";
 					break;
 				case 2:
 					typeStr = "普通用户";
 					break;
 			}
 			obj.put("type",typeStr);
 			obj.put("company",rs.getString("company"));
 			obj.put("email",rs.getString("email"));
 			obj.put("tel",rs.getString("tel"));
 			jsonArr.put(obj);
	    }
		if(rs!=null){
	    	rs.close();
	    }

		rs.close();
	    close(stat,conn);
	    jsonObj.put("data",jsonArr);
	    
    	return jsonObj;
    }
	public int changePsw(String name, int type, JSONObject jsonObj) throws ClassNotFoundException, SQLException, NoSuchAlgorithmException, JSONException{
    	Connection conn=null;
    	Statement stat=null;
    	ResultSet rs=null;
    	int result = 0;

		conn=connect();
		stat=conn.createStatement();
		
		String oldPsw = jsonObj.getString("old");
		String shaData = sha256(oldPsw);

      	rs=stat.executeQuery("select * from login where password='"+shaData+"' and name='"+name+"' and type="+type+""); 
    	if(!rs.next())
        {
    		rs.close();
        	close(stat,conn);
        	return result;
        }
	    if(rs!=null){
			rs.close();
	    }
	    
	    String newPsw = jsonObj.getString("new");
		String newPswData = sha256(newPsw);
		
		stat.execute("update login set password='"+newPswData+"' where name='"+name+"' and type="+type+"");
    	close(stat,conn);
    	result = 1;
    	return result;
    }
	public int changeEmail(String name, int type, JSONObject jsonObj) throws ClassNotFoundException, SQLException, NoSuchAlgorithmException, JSONException{
    	Connection conn=null;
    	Statement stat=null;
    	int result = 0;

		conn=connect();
		stat=conn.createStatement();
		    
	    String email = jsonObj.getString("email");
		
		stat.execute("update login set email='"+email+"' where name='"+name+"' and type="+type+"");
    	close(stat,conn);
    	result = 1;
    	return result;
    }
	public int changeTel(String name, int type, JSONObject jsonObj) throws ClassNotFoundException, SQLException, NoSuchAlgorithmException, JSONException{
    	Connection conn=null;
    	Statement stat=null;
    	int result = 0;

		conn=connect();
		stat=conn.createStatement();
		    
	    String tel = jsonObj.getString("tel");
		
		stat.execute("update login set tel='"+tel+"' where name='"+name+"' and type="+type+"");
    	close(stat,conn);
    	result = 1;
    	return result;
    }
	public boolean approve(String name, String company, String type, String email, String tel, String flag) throws ClassNotFoundException, SQLException, NoSuchAlgorithmException, JSONException{
    	Connection conn=null;
    	Statement stat=null;
    	ResultSet rs=null;
    	boolean result = false;
    	String psw;

		conn=connect();
		stat=conn.createStatement();
		    
		rs=stat.executeQuery("select * from request where name='"+name+"' and company='"+company+"' and type="+String.valueOf(type)+" and email='"+email+"' and tel='"+tel+"'"); 
    	if(!rs.next())
        {
    		rs.close();
        	close(stat,conn);
        	return result;
        }
	    if(rs!=null){
	    	psw = rs.getString("password");
	    	rs.close();
	    	int status = 1;
	    	if(Integer.parseInt(flag) == 1)
	    		stat.execute("insert into login(name,password,type,company,email,tel,status) "
	    			+ "values('"+name+"','"+psw+"',"+type+",'"+company
	    			+"','"+email+"','"+tel+"',"+status+")");
			
			stat.execute("delete from request where name='"+name+"' and company='"+company+"' and type="+Integer.parseInt(type)+" and email='"+email+"' and tel='"+tel+"'");
	    }
		
	    
    	close(stat,conn);
    	result = true;
    	return result;
    }
}
