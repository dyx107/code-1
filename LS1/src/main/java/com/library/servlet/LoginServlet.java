package com.library.servlet;

import com.library.dao.UserDAO;
import com.library.model.User;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import javax.servlet.annotation.WebServlet;

@WebServlet("/LoginServlet")  // 添加这行注解
public class LoginServlet extends HttpServlet {
    private UserDAO userDAO;
    
    @Override
    public void init() {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        User user = userDAO.login(username, password);
        
        if (user != null) {
            // 登录成功，将用户信息存入session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("username", user.getUsername());
            session.setAttribute("userType", user.getUserType());
            
            // 根据用户类型跳转到不同的页面
            if ("admin".equals(user.getUserType())) {
                response.sendRedirect("admin/dashboard.jsp");
            } else {
                response.sendRedirect("reader/dashboard.jsp");
            }
        } else {
            // 登录失败
            request.setAttribute("error", "用户名或密码错误");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
}