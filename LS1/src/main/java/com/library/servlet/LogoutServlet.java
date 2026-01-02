package com.library.servlet;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;  // 添加这行
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/LogoutServlet")  // 添加这行
public class LogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        response.sendRedirect("login.jsp");
    }
}