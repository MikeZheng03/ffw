package dao;

import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class UserDao extends NormalDao{
	static final int userType = 2;
	//验证登录
	public boolean userCheckLogin(String name, String password) throws ClassNotFoundException, SQLException, NoSuchAlgorithmException{
		return checkLogin(name, password, userType);
	}
	
	public boolean userInsertLogin(String name, String password) throws ClassNotFoundException, SQLException, NoSuchAlgorithmException{
		return insertLogin(name, password, userType);
    }
}
