package com.library.util;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class AuthFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // 初始化代码
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, 
                         FilterChain chain) throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        
        String requestURI = req.getRequestURI();
        
        // 检查是否是管理员页面
        if (requestURI.contains("/admin/")) {
            if (session == null || session.getAttribute("user") == null) {
                res.sendRedirect(req.getContextPath() + "/login.jsp");
                return;
            }
            
            String userType = (String) session.getAttribute("userType");
            if (!"admin".equals(userType)) {
                res.sendRedirect(req.getContextPath() + "/login.jsp?error=无权限访问");
                return;
            }
        }
        
        // 检查是否是读者页面
        if (requestURI.contains("/reader/")) {
            if (session == null || session.getAttribute("user") == null) {
                res.sendRedirect(req.getContextPath() + "/login.jsp");
                return;
            }
        }
        
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        // 清理代码
    }
}