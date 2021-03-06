package service;

import javax.servlet.http.HttpSession;
import org.apache.struts2.ServletActionContext;
import dao.*;

import com.opensymphony.xwork2.ActionSupport;

public class GrantAction extends ActionSupport {

	//下面是Action内用于封装用户请求参数的属性
	private String Name;
	private String Password;
	private String Msg;
	
	public String getName() {
		return Name;
	}
	public void setName(String name) {
		Name = name;
	}
	public String getPassword() {
		return Password;
	}
	public void setPassword(String password) {
		Password = password;
	}
	public String getMsg() {
		return Msg;
	}
	public void setMsg(String msg) {
		Msg = msg;
	}
	//处理用户请求的execute方法
	public String execute() throws Exception {
		ServletActionContext.getRequest().getSession().setMaxInactiveInterval(60);
		System.out.println("mike, execute, session expire:"+
				ServletActionContext.getRequest().getSession().getMaxInactiveInterval());
		
		if (false == new AdminDao().superadminCheckLogin(Name, Password)) {
			Msg = "用户名或者密码错误";
			return INPUT;
		}
		else
		{
			//创建session
			HttpSession session = ServletActionContext.getRequest().getSession();
			session.setAttribute("name", Name);
			session.setAttribute("type", "11");
			return SUCCESS;
		}
		
	}
}
