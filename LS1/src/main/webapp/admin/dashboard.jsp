<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.library.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getUserType())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>管理员首页 - 图书管理系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <div class="header">
        <h1>图书管理系统 - 管理后台</h1>
        <div class="user-info">
            管理员：<%= user.getRealName() %> | 
            <a href="${pageContext.request.contextPath}/LogoutServlet">退出登录</a>
        </div>
    </div>
    
    <div class="sidebar">
        <ul>
            <li class="active"><a href="${pageContext.request.contextPath}/admin/dashboard.jsp">首页</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/book_management.jsp">图书管理</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/user_management.jsp">用户管理</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/borrow_management.jsp">借阅管理</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/statistics.jsp">统计分析</a></li>
        </ul>
    </div>
    
    <div class="main-content">
        <h2>系统概览</h2>
        <div class="dashboard-stats">
            <div class="stat-card">
                <h3>图书总数</h3>
                <p class="stat-number">3568</p>
                <p>册</p>
            </div>
            <div class="stat-card">
                <h3>注册用户</h3>
                <p class="stat-number">1245</p>
                <p>人</p>
            </div>
            <div class="stat-card">
                <h3>在借图书</h3>
                <p class="stat-number">289</p>
                <p>册</p>
            </div>
            <div class="stat-card">
                <h3>今日借阅</h3>
                <p class="stat-number">23</p>
                <p>次</p>
            </div>
        </div>
        
        <div class="quick-actions">
            <h3>管理操作</h3>
            <a href="${pageContext.request.contextPath}/admin/book_management.jsp?action=add" class="btn-action">添加图书</a>
            <a href="${pageContext.request.contextPath}/admin/user_management.jsp" class="btn-action">用户管理</a>
            <a href="#" class="btn-action">借阅审批</a>
            <a href="#" class="btn-action">生成报表</a>
        </div>
        
        <div class="recent-activity">
            <h3>系统通知</h3>
            <div class="notifications">
                <div class="notification-item">
                    <strong>图书库存预警：</strong>《活着》仅剩1本，请及时补充。
                </div>
                <div class="notification-item">
                    <strong>逾期提醒：</strong>有15本图书逾期未还。
                </div>
                <div class="notification-item">
                    <strong>新用户注册：</strong>今日新增3位注册用户。
                </div>
            </div>
        </div>
    </div>
</body>
</html>