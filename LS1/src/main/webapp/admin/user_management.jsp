<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.library.model.User, com.library.dao.UserDAO, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getUserType())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    UserDAO userDAO = new UserDAO();
    List<User> users = userDAO.getAllUsers();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>用户管理 - 图书管理系统</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="header">
        <h1>图书管理系统 - 用户管理</h1>
        <div class="user-info">
            管理员：<%= user.getRealName() %> | 
            <a href="../LogoutServlet">退出登录</a>
        </div>
    </div>
    
    <div class="sidebar">
        <ul>
            <li><a href="dashboard.jsp">首页</a></li>
            <li><a href="book_management.jsp">图书管理</a></li>
            <li class="active"><a href="user_management.jsp">用户管理</a></li>
            <li><a href="borrow_management.jsp">借阅管理</a></li>
            <li><a href="#">统计分析</a></li>
        </ul>
    </div>
    
    <div class="main-content">
        <h2>用户管理</h2>
        
        <div class="user-list">
            <h3>用户列表</h3>
            
            <table>
                <thead>
                    <tr>
                        <th>用户ID</th>
                        <th>用户名</th>
                        <th>真实姓名</th>
                        <th>邮箱</th>
                        <th>电话</th>
                        <th>用户类型</th>
                        <th>注册时间</th>
                        <th>状态</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (User u : users) { %>
                    <tr>
                        <td><%= u.getUserId() %></td>
                        <td><%= u.getUsername() %></td>
                        <td><%= u.getRealName() %></td>
                        <td><%= u.getEmail() != null ? u.getEmail() : "-" %></td>
                        <td><%= u.getPhone() != null ? u.getPhone() : "-" %></td>
                        <td><%= "admin".equals(u.getUserType()) ? "管理员" : "读者" %></td>
                        <td><%= u.getRegisterDate() %></td>
                        <td>
                            <span class="status-<%= u.getStatus() %>">
                                <%= "active".equals(u.getStatus()) ? "正常" : "停用" %>
                            </span>
                        </td>
                        <td>
                            <% if ("active".equals(u.getStatus())) { %>
                                <a href="UserServlet?action=suspend&userId=<%= u.getUserId() %>" 
                                   class="btn-suspend">停用</a>
                            <% } else { %>
                                <a href="UserServlet?action=activate&userId=<%= u.getUserId() %>" 
                                   class="btn-activate">启用</a>
                            <% } %>
                            <a href="UserServlet?action=delete&userId=<%= u.getUserId() %>" 
                               class="btn-delete" onclick="return confirm('确定删除用户吗？')">删除</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>