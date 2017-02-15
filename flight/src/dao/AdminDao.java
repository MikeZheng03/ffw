package dao;

import java.security.NoSuchAlgorithmException;
import java.sql.SQLException;

public class AdminDao extends NormalDao {
	static final int adminType = 1;
	static final int superadminType = 11;
	public boolean adminCheckLogin(String username, String password) throws ClassNotFoundException, SQLException, NoSuchAlgorithmException{
		return checkLogin(username, password, adminType);
	}
	
	public boolean superadminCheckLogin(String username, String password) throws ClassNotFoundException, SQLException, NoSuchAlgorithmException{
		return checkLogin(username, password, superadminType);
	}
	
	public boolean adminInsertLogin(String name, String password) throws ClassNotFoundException, SQLException, NoSuchAlgorithmException{
		return insertLogin(name, password, adminType);
    }
}
