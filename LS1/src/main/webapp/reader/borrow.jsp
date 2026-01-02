<%-- file name: borrow.jsp --%>
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
    // 获取热门书籍（按借阅次数排序）
    List<Book> popularBooks = bookDAO.getAllBooks().subList(0, Math.min(10, bookDAO.getAllBooks().size()));
    // 获取新书（按添加日期排序）
    List<Book> newBooks = bookDAO.getAllBooks().subList(0, Math.min(10, bookDAO.getAllBooks().size()));
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>借阅图书 - 图书管理系统</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .section {
            margin-bottom: 30px;
        }
        
        .book-list {
            display: flex;
            overflow-x: auto;
            gap: 20px;
            padding: 15px 0;
        }
        
        .book-item {
            min-width: 200px;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 15px;
            background: #fff;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .book-item h4 {
            margin: 0 0 10px 0;
            color: #333;
        }
        
        .quick-search {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .search-input {
            width: 300px;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 3px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>图书管理系统 - 借阅图书</h1>
        <div class="user-info">
            欢迎，<%= user.getRealName() %> | 
            <a href="../LogoutServlet">退出登录</a>
        </div>
    </div>
    
    <div class="sidebar">
        <ul>
            <li><a href="dashboard.jsp">首页</a></li>
            <li><a href="search.jsp">图书查询</a></li>
            <li class="active"><a href="borrow.jsp">借阅图书</a></li>
            <li><a href="records.jsp">我的借阅记录</a></li>
        </ul>
    </div>
    
    <div class="main-content">
        <h2>借阅图书</h2>
        
        <!-- 快速搜索 -->
        <div class="quick-search">
            <h3>快速搜索</h3>
            <form action="search.jsp" method="get">
                <input type="text" name="search" class="search-input" placeholder="输入书名、作者或ISBN">
                <button type="submit" class="btn-search">搜索</button>
            </form>
        </div>
        
        <!-- 热门借阅 -->
        <div class="section">
            <h3>热门借阅</h3>
            <div class="book-list">
                <% for (Book book : popularBooks) { %>
                <div class="book-item">
                    <h4><%= book.getTitle() %></h4>
                    <p>作者：<%= book.getAuthor() %></p>
                    <p>可借：<%= book.getAvailableCopies() %>本</p>
                    <% if (book.getAvailableCopies() > 0) { %>
                    <form action="../BorrowServlet" method="get">
                        <input type="hidden" name="action" value="borrow">
                        <input type="hidden" name="bookId" value="<%= book.getBookId() %>">
                        <button type="submit" class="btn-borrow">借阅</button>
                    </form>
                    <% } else { %>
                    <button disabled class="btn-disabled">已借完</button>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>
        
        <!-- 新书推荐 -->
        <div class="section">
            <h3>新书推荐</h3>
            <div class="book-list">
                <% for (Book book : newBooks) { %>
                <div class="book-item">
                    <h4><%= book.getTitle() %></h4>
                    <p>作者：<%= book.getAuthor() %></p>
                    <p>可借：<%= book.getAvailableCopies() %>本</p>
                    <% if (book.getAvailableCopies() > 0) { %>
                    <form action="../BorrowServlet" method="get">
                        <input type="hidden" name="action" value="borrow">
                        <input type="hidden" name="bookId" value="<%= book.getBookId() %>">
                        <button type="submit" class="btn-borrow">借阅</button>
                    </form>
                    <% } else { %>
                    <button disabled class="btn-disabled">已借完</button>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>
        
        <!-- 借阅规则 -->
        <div class="section">
            <h3>借阅规则</h3>
            <div class="rules">
                <ul>
                    <li>每位读者最多可同时借阅5本图书</li>
                    <li>每本图书借阅期限为30天</li>
                    <li>可续借一次，续借期限为30天</li>
                    <li>逾期归还将产生罚款，每天0.5元</li>
                    <li>图书损坏或丢失需照价赔偿</li>
                </ul>
            </div>
        </div>
    </div>
    
    <script>
        function borrowBook(bookId, title) {
            if (confirm("确定要借阅《" + title + "》吗？")) {
                window.location.href = '../BorrowServlet?action=borrow&bookId=' + bookId;
            }
        }
    </script>
</body>
</html>