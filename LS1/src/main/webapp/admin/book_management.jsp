<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.library.model.User" %>
<%@ page import="com.library.model.Book" %>
<%@ page import="com.library.dao.BookDAO" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getUserType())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    BookDAO bookDAO = new BookDAO();
    List<Book> books = bookDAO.getAllBooks();
    String action = request.getParameter("action");
    
    // 获取编辑的图书信息
    Book editBook = null;
    if ("edit".equals(action) && request.getParameter("bookId") != null) {
        editBook = bookDAO.getBookById(Integer.parseInt(request.getParameter("bookId")));
    }
    
    // 处理搜索
    String searchKeyword = request.getParameter("search");
    if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
        books = bookDAO.searchBooks(searchKeyword);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>图书管理 - 图书管理系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script>
        // JavaScript放在头部，确保页面加载时可用
        function showAddForm() {
            console.log("显示添加表单");
            // 清空表单
            var form = document.getElementById('book-form').querySelector('form');
            form.reset();
            
            // 设置action为add
            var actionInput = form.querySelector('input[name="action"]');
            if (actionInput) {
                actionInput.value = 'add';
            }
            
            // 清空bookId
            var bookIdInput = form.querySelector('input[name="bookId"]');
            if (bookIdInput) {
                bookIdInput.value = '';
            }
            
            // 更新标题
            var titleElement = document.getElementById('book-form').querySelector('h3');
            if (titleElement) {
                titleElement.textContent = '添加图书';
            }
            
            // 显示表单
            document.getElementById('book-form').style.display = 'block';
        }
        
        function hideForm() {
            console.log("隐藏表单");
            document.getElementById('book-form').style.display = 'none';
            // 重定向回当前页面，清除action参数
            window.location.href = '${pageContext.request.contextPath}/admin/book_management.jsp';
        }
        
        // 页面加载时检查是否需要显示表单
        window.onload = function() {
            <% if ("add".equals(action) || "edit".equals(action)) { %>
                document.getElementById('book-form').style.display = 'block';
            <% } else { %>
                document.getElementById('book-form').style.display = 'none';
            <% } %>
        };
        
        // 确认删除函数
        function confirmDelete(bookId, title) {
            if (confirm("确定要删除图书《" + title + "》吗？")) {
                window.location.href = '${pageContext.request.contextPath}/BookServlet?action=delete&bookId=' + bookId;
            }
            return false;
        }
    </script>
</head>
<body>
    <div class="header">
        <h1>图书管理系统 - 图书管理</h1>
        <div class="user-info">
            管理员：<%= user.getRealName() %> | 
            <a href="${pageContext.request.contextPath}/LogoutServlet">退出登录</a>
        </div>
    </div>
    
    <div class="sidebar">
        <ul>
            <li><a href="${pageContext.request.contextPath}/admin/dashboard.jsp">首页</a></li>
            <li class="active"><a href="${pageContext.request.contextPath}/admin/book_management.jsp">图书管理</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/user_management.jsp">用户管理</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/borrow_management.jsp">借阅管理</a></li>
            <li><a href="#">统计分析</a></li>
        </ul>
    </div>
    
    <div class="main-content">
        <h2>图书管理
            <button class="btn-add" onclick="showAddForm()">添加图书</button>
        </h2>
        
        <!-- 显示成功/错误消息 -->
        <% 
            String success = request.getParameter("success");
            String error = request.getParameter("error");
            if (success != null && !success.trim().isEmpty()) { 
        %>
            <div class="success-message"><%= success %></div>
        <% } %>
        <% if (error != null && !error.trim().isEmpty()) { %>
            <div class="error-message"><%= error %></div>
        <% } %>
        
        <!-- 添加/编辑图书表单 -->
        <div id="book-form">
            <h3><%= "edit".equals(action) ? "编辑图书" : "添加图书" %></h3>
            <form action="${pageContext.request.contextPath}/BookServlet" method="post">
                <input type="hidden" name="action" value="<%= "edit".equals(action) ? "update" : "add" %>">
                <input type="hidden" name="bookId" value="<%= editBook != null ? editBook.getBookId() : "" %>">
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="isbn">ISBN：</label>
                        <input type="text" id="isbn" name="isbn" required 
                               value="<%= editBook != null ? editBook.getIsbn() : "" %>">
                    </div>
                    <div class="form-group">
                        <label for="title">书名：</label>
                        <input type="text" id="title" name="title" required 
                               value="<%= editBook != null ? editBook.getTitle() : "" %>">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="author">作者：</label>
                        <input type="text" id="author" name="author" required 
                               value="<%= editBook != null ? editBook.getAuthor() : "" %>">
                    </div>
                    <div class="form-group">
                        <label for="publisher">出版社：</label>
                        <input type="text" id="publisher" name="publisher" 
                               value="<%= editBook != null ? editBook.getPublisher() : "" %>">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="publish_year">出版年份：</label>
                        <input type="number" id="publish_year" name="publish_year" min="1900" max="2024"
                               value="<%= editBook != null ? editBook.getPublishYear() : "" %>">
                    </div>
                    <div class="form-group">
                        <label for="category">分类：</label>
                        <select id="category" name="category">
                            <option value="">请选择</option>
                            <option value="文学" <%= editBook != null && "文学".equals(editBook.getCategory()) ? "selected" : "" %>>文学</option>
                            <option value="历史" <%= editBook != null && "历史".equals(editBook.getCategory()) ? "selected" : "" %>>历史</option>
                            <option value="科学" <%= editBook != null && "科学".equals(editBook.getCategory()) ? "selected" : "" %>>科学</option>
                            <option value="技术" <%= editBook != null && "技术".equals(editBook.getCategory()) ? "selected" : "" %>>技术</option>
                            <option value="艺术" <%= editBook != null && "艺术".equals(editBook.getCategory()) ? "selected" : "" %>>艺术</option>
                            <option value="哲学" <%= editBook != null && "哲学".equals(editBook.getCategory()) ? "selected" : "" %>>哲学</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="total_copies">总册数：</label>
                        <input type="number" id="total_copies" name="total_copies" min="1" value="<%= editBook != null ? editBook.getTotalCopies() : 1 %>">
                    </div>
                    <div class="form-group">
                        <label for="location">存放位置：</label>
                        <input type="text" id="location" name="location" 
                               value="<%= editBook != null ? editBook.getLocation() : "" %>">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="description">简介：</label>
                    <textarea id="description" name="description" rows="4"><%= editBook != null ? editBook.getDescription() : "" %></textarea>
                </div>
                
                <div class="form-buttons">
                    <button type="submit" class="btn-save">保存</button>
                    <button type="button" class="btn-cancel" onclick="hideForm()">取消</button>
                </div>
            </form>
        </div>
        
        <!-- 图书列表 -->
        <div class="book-list">
            <h3>图书列表</h3>
            
            <!-- 搜索栏 -->
            <div class="search-bar">
                <form action="${pageContext.request.contextPath}/admin/book_management.jsp" method="get">
                    <input type="text" name="search" placeholder="输入书名、作者或ISBN搜索" 
                           value="<%= searchKeyword != null ? searchKeyword : "" %>">
                    <button type="submit" class="btn-search">搜索</button>
                    <% if (searchKeyword != null && !searchKeyword.trim().isEmpty()) { %>
                        <a href="${pageContext.request.contextPath}/admin/book_management.jsp" class="btn-clear">清除搜索</a>
                    <% } %>
                </form>
            </div>
            
            <table>
                <thead>
                    <tr>
                        <th>ISBN</th>
                        <th>书名</th>
                        <th>作者</th>
                        <th>出版社</th>
                        <th>分类</th>
                        <th>总册数</th>
                        <th>可借数</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        if (books != null && !books.isEmpty()) {
                            for (Book book : books) { 
                    %>
                    <tr>
                        <td><%= book.getIsbn() %></td>
                        <td><%= book.getTitle() %></td>
                        <td><%= book.getAuthor() %></td>
                        <td><%= book.getPublisher() != null ? book.getPublisher() : "-" %></td>
                        <td><%= book.getCategory() != null ? book.getCategory() : "-" %></td>
                        <td><%= book.getTotalCopies() %></td>
                        <td><%= book.getAvailableCopies() %></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/BookServlet?action=edit&bookId=<%= book.getBookId() %>" class="btn-edit">编辑</a>
                            <a href="#" onclick="return confirmDelete(<%= book.getBookId() %>, '<%= book.getTitle() %>')" class="btn-delete">删除</a>
                        </td>
                    </tr>
                    <% 
                            }
                        } else { 
                    %>
                    <tr>
                        <td colspan="8" style="text-align: center;">暂无图书数据</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>