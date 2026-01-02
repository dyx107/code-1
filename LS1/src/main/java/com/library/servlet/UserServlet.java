package com.library.servlet;

import com.library.dao.UserDAO;
import javax.servlet.annotation.WebServlet;  // 添加这行
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/UserServlet")  // 添加这行
public class UserServlet extends HttpServlet {
    private UserDAO userDAO;
    
    @Override
    public void init() {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        String userIdStr = request.getParameter("userId");
        
        if (userIdStr == null || userIdStr.isEmpty()) {
            response.sendRedirect("user_management.jsp");
            return;
        }
        
        int userId = Integer.parseInt(userIdStr);
        
        if ("suspend".equals(action)) {
            userDAO.updateUserStatus(userId, "suspended");
            response.sendRedirect("user_management.jsp?message=用户已停用");
        } else if ("activate".equals(action)) {
            userDAO.updateUserStatus(userId, "active");
            response.sendRedirect("user_management.jsp?message=用户已启用");
        } else if ("delete".equals(action)) {
            userDAO.deleteUser(userId);
            response.sendRedirect("user_management.jsp?message=用户已删除");
        } else {
            response.sendRedirect("user_management.jsp");
        }
    }
}