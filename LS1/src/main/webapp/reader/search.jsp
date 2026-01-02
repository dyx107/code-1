<%-- file name: search.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.library.model.User" %>
<%@ page import="com.library.dao.BookDAO" %>
<%@ page import="com.library.model.Book" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    BookDAO bookDAO = new BookDAO();
    List<Book> books = bookDAO.getAllBooks();
    String searchKeyword = request.getParameter("search");
    String category = request.getParameter("category");
    
    if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
        books = bookDAO.searchBooks(searchKeyword);
    } else if (category != null && !category.trim().isEmpty()) {
        books = bookDAO.getBooksByCategory(category);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>图书查询 - 图书管理系统</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .book-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .book-card {
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 15px;
            background: #fff;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }
        
        .book-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .book-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
        }
        
        .book-info {
            color: #666;
            font-size: 14px;
            margin-bottom: 5px;
        }
        
        .book-status {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .available {
            background: #d4edda;
            color: #155724;
        }
        
        .unavailable {
            background: #f8d7da;
            color: #721c24;
        }
        
        .filters {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .filter-group {
            display: inline-block;
            margin-right: 20px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>图书管理系统 - 图书查询</h1>
        <div class="user-info">
            欢迎，<%= user.getRealName() %> | 
            <a href="../LogoutServlet">退出登录</a>
        </div>
    </div>
    
    <div class="sidebar">
        <ul>
            <li><a href="dashboard.jsp">首页</a></li>
            <li class="active"><a href="search.jsp">图书查询</a></li>
            <li><a href="borrow.jsp">借阅图书</a></li>
            <li><a href="records.jsp">我的借阅记录</a></li>
        </ul>
    </div>
    
    <div class="main-content">
        <h2>图书查询</h2>
        
        <!-- 显示消息 -->
        <% 
            String success = (String) session.getAttribute("success");
            String error = (String) session.getAttribute("error");
            if (success != null) { 
        %>
            <div class="success-message"><%= success %></div>
        <% 
                session.removeAttribute("success");
            } 
        %>
        <% if (error != null) { %>
            <div class="error-message"><%= error %></div>
        <% 
                session.removeAttribute("error");
            } 
        %>
        
        <!-- 搜索和筛选 -->
        <div class="filters">
            <form action="search.jsp" method="get" class="search-form">
                <div class="filter-group">
                    <input type="text" name="search" placeholder="输入书名、作者或ISBN搜索" 
                           value="<%= searchKeyword != null ? searchKeyword : "" %>">
                    <button type="submit" class="btn-search">搜索</button>
                </div>
                
                <div class="filter-group">
                    <select name="category" onchange="this.form.submit()">
                        <option value="">全部分类</option>
                        <option value="文学" <%= "文学".equals(category) ? "selected" : "" %>>文学</option>
                        <option value="历史" <%= "历史".equals(category) ? "selected" : "" %>>历史</option>
                        <option value="科学" <%= "科学".equals(category) ? "selected" : "" %>>科学</option>
                        <option value="技术" <%= "技术".equals(category) ? "selected" : "" %>>技术</option>
                        <option value="艺术" <%= "艺术".equals(category) ? "selected" : "" %>>艺术</option>
                        <option value="哲学" <%= "哲学".equals(category) ? "selected" : "" %>>哲学</option>
                    </select>
                </div>
                
                <% if (searchKeyword != null || category != null) { %>
                    <a href="search.jsp" class="btn-clear">清除筛选</a>
                <% } %>
            </form>
        </div>
        
        <!-- 图书列表 -->
        <div class="book-grid">
            <% 
                if (books != null && !books.isEmpty()) {
                    for (Book book : books) { 
            %>
            <div class="book-card">
                <div class="book-title"><%= book.getTitle() %></div>
                <div class="book-info">作者：<%= book.getAuthor() %></div>
                <div class="book-info">ISBN：<%= book.getIsbn() %></div>
                <div class="book-info">出版社：<%= book.getPublisher() != null ? book.getPublisher() : "未知" %></div>
                <div class="book-info">分类：<%= book.getCategory() != null ? book.getCategory() : "未分类" %></div>
                <div class="book-info">出版年份：<%= book.getPublishYear() > 0 ? book.getPublishYear() : "未知" %></div>
                
                <div style="margin-top: 10px;">
                    <span class="book-status <%= book.getAvailableCopies() > 0 ? "available" : "unavailable" %>">
                        <%= book.getAvailableCopies() > 0 ? "可借阅" : "已借完" %>
                    </span>
                    <span style="color: #666; font-size: 12px; margin-left: 10px;">
                        库存：<%= book.getAvailableCopies() %>/<%= book.getTotalCopies() %>
                    </span>
                </div>
                
                <% if (book.getAvailableCopies() > 0) { %>
                <div style="margin-top: 15px;">
                    <form action="../BorrowServlet" method="get">
                        <input type="hidden" name="action" value="borrow">
                        <input type="hidden" name="bookId" value="<%= book.getBookId() %>">
                        <button type="submit" class="btn-borrow" 
                                onclick="return confirm('确定要借阅《<%= book.getTitle() %>》吗？')">
                            立即借阅
                        </button>
                    </form>
                </div>
                <% } %>
            </div>
            <% 
                    }
                } else { 
            %>
            <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #666;">
                没有找到相关图书
            </div>
            <% } %>
        </div>
    </div>
    
    <script>
        // 确认借阅
        function confirmBorrow(bookId, title) {
            if (confirm("确定要借阅《" + title + "》吗？")) {
                window.location.href = '../BorrowServlet?action=borrow&bookId=' + bookId;
            }
            return false;
        }
    </script>
</body>
</html>