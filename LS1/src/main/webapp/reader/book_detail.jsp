<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.library.model.User" %>
<%@ page import="com.library.dao.BookDAO" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    BookDAO bookDAO = new BookDAO();
    int totalBooks = bookDAO.getTotalBooksCount();
    int availableBooks = bookDAO.getAvailableBooksCount();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>读者首页 - 图书管理系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .dashboard-cards {
            display: flex;
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .dashboard-card {
            flex: 1;
            background: white;
            padding: 25px;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .card-title {
            font-size: 16px;
            color: #666;
            margin-bottom: 15px;
        }
        
        .card-number {
            font-size: 32px;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 10px;
        }
        
        .card-unit {
            font-size: 14px;
            color: #888;
        }
        
        .quick-actions {
            background: white;
            padding: 25px;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .action-title {
            font-size: 18px;
            margin-bottom: 20px;
            color: #333;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
        }
        
        .action-btn {
            flex: 1;
            padding: 15px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            text-align: center;
            font-weight: bold;
            transition: background 0.3s;
        }
        
        .action-btn:hover {
            background: #2980b9;
        }
        
        .action-btn.search {
            background: #2ecc71;
        }
        
        .action-btn.search:hover {
            background: #27ae60;
        }
        
        .action-btn.history {
            background: #9b59b6;
        }
        
        .action-btn.history:hover {
            background: #8e44ad;
        }
        
        .welcome-section {
            background: white;
            padding: 25px;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .welcome-title {
            font-size: 20px;
            color: #333;
            margin-bottom: 10px;
        }
        
        .welcome-text {
            color: #666;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>图书管理系统 - 读者首页</h1>
        <div class="user-info">
            欢迎，<%= user.getRealName() %> | 
            <a href="${pageContext.request.contextPath}/LogoutServlet">退出登录</a>
        </div>
    </div>
    
    <div class="sidebar">
        <ul>
            <li class="active"><a href="${pageContext.request.contextPath}/reader/dashboard.jsp">首页</a></li>
            <li><a href="${pageContext.request.contextPath}/reader/search.jsp">图书查询</a></li>
            <li><a href="${pageContext.request.contextPath}/reader/borrow_history.jsp">借阅记录</a></li>
            <li><a href="${pageContext.request.contextPath}/reader/profile.jsp">个人信息</a></li>
        </ul>
    </div>
    
    <div class="main-content">
        <!-- 欢迎信息 -->
        <div class="welcome-section">
            <div class="welcome-title">欢迎回来，<%= user.getRealName() %>！</div>
            <div class="welcome-text">
                欢迎使用图书管理系统。您可以通过左侧菜单访问各项功能，包括图书查询、借阅记录查看和个人信息管理等。
            </div>
        </div>
        
        <!-- 数据统计 -->
        <div class="dashboard-cards">
            <div class="dashboard-card">
                <div class="card-title">馆藏图书总数</div>
                <div class="card-number"><%= totalBooks %></div>
                <div class="card-unit">册</div>
            </div>
            <div class="dashboard-card">
                <div class="card-title">可借图书总数</div>
                <div class="card-number"><%= availableBooks %></div>
                <div class="card-unit">册</div>
            </div>
            <div class="dashboard-card">
                <div class="card-title">系统时间</div>
                <div class="card-number">
                    <%= new java.text.SimpleDateFormat("HH:mm").format(new java.util.Date()) %>
                </div>
                <div class="card-unit">
                    <%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>
                </div>
            </div>
        </div>
        
        <!-- 快捷操作 -->
        <div class="quick-actions">
            <div class="action-title">快捷操作</div>
            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/reader/search.jsp" class="action-btn search">
                    图书查询
                    <div style="font-size: 12px; font-weight: normal; margin-top: 5px;">
                        查找您想借阅的图书
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/reader/borrow_history.jsp" class="action-btn history">
                    借阅记录
                    <div style="font-size: 12px; font-weight: normal; margin-top: 5px;">
                        查看您的借阅历史
                    </div>
                </a>
                <a href="${pageContext.request.contextPath}/reader/profile.jsp" class="action-btn">
                    个人信息
                    <div style="font-size: 12px; font-weight: normal; margin-top: 5px;">
                        修改个人资料和密码
                    </div>
                </a>
            </div>
        </div>
        
        <!-- 通知公告（示例） -->
        <div class="welcome-section">
            <div class="welcome-title">系统公告</div>
            <div class="welcome-text">
                <ul style="list-style-type: disc; padding-left: 20px;">
                    <li>每本图书最长借阅期限为30天，请按时归还</li>
                    <li>逾期归还图书将产生滞纳金，每天0.1元</li>
                    <li>每位读者最多可同时借阅5本图书</li>
                    <li>图书到期前3天会发送提醒通知</li>
                    <li>如有问题请联系图书馆管理员</li>
                </ul>
            </div>
        </div>
    </div>
</body>
</html>