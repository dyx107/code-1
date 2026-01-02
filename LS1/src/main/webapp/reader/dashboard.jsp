<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.library.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"reader".equals(user.getUserType())) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>读者首页 - 图书管理系统</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="header">
        <h1>图书管理系统 - 读者中心</h1>
        <div class="user-info">
            欢迎，<%= user.getRealName() %> | 
            <a href="../LogoutServlet">退出登录</a>
        </div>
    </div>
    
    <div class="sidebar">
        <ul>
            <li class="active"><a href="dashboard.jsp">首页</a></li>
            <li><a href="search.jsp">图书查询</a></li>
            <li><a href="borrow.jsp">借阅图书</a></li>
            <li><a href="records.jsp">我的借阅记录</a></li>
        </ul>
    </div>
    
    <div class="main-content">
        <h2>欢迎使用图书管理系统</h2>
        <div class="dashboard-stats">
            <div class="stat-card">
                <h3>可借阅图书</h3>
                <p class="stat-number">1500</p>
                <p>册</p>
            </div>
            <div class="stat-card">
                <h3>当前借阅</h3>
                <p class="stat-number">3</p>
                <p>册</p>
            </div>
            <div class="stat-card">
                <h3>逾期图书</h3>
                <p class="stat-number">0</p>
                <p>册</p>
            </div>
        </div>
        
        <div class="quick-actions">
            <h3>快速操作</h3>
            <a href="search.jsp" class="btn-action">查询图书</a>
            <a href="borrow.jsp" class="btn-action">借阅图书</a>
            <a href="records.jsp" class="btn-action">查看记录</a>
        </div>
        
        <div class="recent-activity">
            <h3>最近借阅记录</h3>
            <table>
                <thead>
                    <tr>
                        <th>图书名称</th>
                        <th>借阅日期</th>
                        <th>应还日期</th>
                        <th>状态</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>红楼梦</td>
                        <td>2023-10-01</td>
                        <td>2023-11-01</td>
                        <td>已借阅</td>
                    </tr>
                    <tr>
                        <td>三国演义</td>
                        <td>2023-10-05</td>
                        <td>2023-11-05</td>
                        <td>已借阅</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>