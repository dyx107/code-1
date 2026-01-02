package com.library.servlet;

import com.library.dao.UserDAO;
import com.library.model.User;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;  // 添加这行
import java.io.IOException;

@WebServlet("/RegisterServlet")  // 添加这行
public class RegisterServlet extends HttpServlet {
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
        String realName = request.getParameter("realName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // 验证密码是否一致
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "两次输入的密码不一致");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        // 检查用户名是否已存在
        if (userDAO.isUsernameExists(username)) {
            request.setAttribute("error", "用户名已存在");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
        // 创建新用户
        User user = new User(username, password, realName, email, phone, "reader");
        
        if (userDAO.register(user)) {
            // 注册成功，跳转到登录页面
            request.setAttribute("success", "注册成功，请登录");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            // 注册失败
            request.setAttribute("error", "注册失败，请重试");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("register.jsp");
    }
}