package com.library.servlet;

import com.library.dao.BookDAO;
import com.library.model.Book;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import javax.servlet.annotation.WebServlet;

@WebServlet("/BookServlet")
public class BookServlet extends HttpServlet {
    private BookDAO bookDAO;
    
    @Override
    public void init() {
        bookDAO = new BookDAO();
        System.out.println("=== BookServlet 初始化 ===");
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("=== BookServlet.doGet() 被调用 ===");
        System.out.println("请求URL: " + request.getRequestURI());
        System.out.println("查询字符串: " + request.getQueryString());
        System.out.println("ContextPath: " + request.getContextPath());
        System.out.println("ServletPath: " + request.getServletPath());
        
        String action = request.getParameter("action");
        System.out.println("action参数: " + action);
        
        try {
            if ("delete".equals(action)) {
                int bookId = Integer.parseInt(request.getParameter("bookId"));
                System.out.println("删除图书，ID: " + bookId);
                boolean result = bookDAO.deleteBook(bookId);
                if (result) {
                    response.sendRedirect(request.getContextPath() + "/admin/book_management.jsp?success=删除成功");
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/book_management.jsp?error=删除失败");
                }
            } else if ("edit".equals(action)) {
                int bookId = Integer.parseInt(request.getParameter("bookId"));
                System.out.println("编辑图书，ID: " + bookId);
                // 使用重定向传递参数
                response.sendRedirect(request.getContextPath() + "/admin/book_management.jsp?action=edit&bookId=" + bookId);
            } else {
                System.out.println("无action参数，重定向到管理页面");
                response.sendRedirect(request.getContextPath() + "/admin/book_management.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/book_management.jsp?error=操作失败：" + e.getMessage());
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("=== BookServlet.doPost() 被调用 ===");
        System.out.println("请求URL: " + request.getRequestURI());
        System.out.println("ContextPath: " + request.getContextPath());
        System.out.println("ServletPath: " + request.getServletPath());
        
        // 打印所有表单参数
        System.out.println("=== 表单参数 ===");
        java.util.Enumeration<String> params = request.getParameterNames();
        while (params.hasMoreElements()) {
            String paramName = params.nextElement();
            System.out.println(paramName + ": " + request.getParameter(paramName));
        }
        
        String action = request.getParameter("action");
        boolean success = false;
        String message = "";
        String redirectUrl = request.getContextPath() + "/admin/book_management.jsp";
        
        try {
            if ("add".equals(action)) {
                System.out.println("执行添加操作");
                Book book = new Book();
                book.setIsbn(request.getParameter("isbn"));
                book.setTitle(request.getParameter("title"));
                book.setAuthor(request.getParameter("author"));
                book.setPublisher(request.getParameter("publisher"));
                
                // 处理出版年份（可能为空）
                String publishYearStr = request.getParameter("publish_year");
                if (publishYearStr != null && !publishYearStr.trim().isEmpty()) {
                    book.setPublishYear(Integer.parseInt(publishYearStr));
                } else {
                    book.setPublishYear(0);
                }
                
                book.setCategory(request.getParameter("category"));
                
                // 处理总册数
                String totalCopiesStr = request.getParameter("total_copies");
                if (totalCopiesStr != null && !totalCopiesStr.trim().isEmpty()) {
                    book.setTotalCopies(Integer.parseInt(totalCopiesStr));
                } else {
                    book.setTotalCopies(1);
                }
                
                book.setLocation(request.getParameter("location"));
                book.setDescription(request.getParameter("description"));
                
                success = bookDAO.addBook(book);
                message = success ? "添加成功" : "添加失败";
                System.out.println("添加结果: " + (success ? "成功" : "失败"));
                
            } else if ("update".equals(action)) {
                System.out.println("执行更新操作");
                Book book = new Book();
                
                String bookIdStr = request.getParameter("bookId");
                if (bookIdStr != null && !bookIdStr.trim().isEmpty()) {
                    book.setBookId(Integer.parseInt(bookIdStr));
                }
                
                book.setIsbn(request.getParameter("isbn"));
                book.setTitle(request.getParameter("title"));
                book.setAuthor(request.getParameter("author"));
                book.setPublisher(request.getParameter("publisher"));
                
                String publishYearStr = request.getParameter("publish_year");
                if (publishYearStr != null && !publishYearStr.trim().isEmpty()) {
                    book.setPublishYear(Integer.parseInt(publishYearStr));
                } else {
                    book.setPublishYear(0);
                }
                
                book.setCategory(request.getParameter("category"));
                
                String totalCopiesStr = request.getParameter("total_copies");
                if (totalCopiesStr != null && !totalCopiesStr.trim().isEmpty()) {
                    book.setTotalCopies(Integer.parseInt(totalCopiesStr));
                } else {
                    book.setTotalCopies(1);
                }
                
                book.setLocation(request.getParameter("location"));
                book.setDescription(request.getParameter("description"));
                
                success = bookDAO.updateBook(book);
                message = success ? "更新成功" : "更新失败";
                System.out.println("更新结果: " + (success ? "成功" : "失败"));
            } else {
                System.out.println("未知的action: " + action);
                message = "未知操作";
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "操作失败：" + e.getMessage();
        }
        
        // 构建重定向URL
        String param = success ? "success" : "error";
        response.sendRedirect(redirectUrl + "?" + param + "=" + java.net.URLEncoder.encode(message, "UTF-8"));
    }
}