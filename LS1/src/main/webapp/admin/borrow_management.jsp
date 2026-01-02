<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.library.model.User" %>
<%@ page import="com.library.dao.BorrowRecordDAO" %>
<%@ page import="com.library.model.BorrowRecord" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getUserType())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    BorrowRecordDAO borrowRecordDAO = new BorrowRecordDAO();
    List<BorrowRecord> records = borrowRecordDAO.getAllBorrowRecords();
    List<BorrowRecord> overdueRecords = borrowRecordDAO.getOverdueRecords();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    
    String filter = request.getParameter("filter");
    String search = request.getParameter("search");
    
    if (search != null && !search.trim().isEmpty()) {
        records = borrowRecordDAO.searchBorrowRecords(search);
    } else if ("overdue".equals(filter)) {
        records = overdueRecords;
    } else if ("borrowing".equals(filter)) {
        // 获取借阅中的记录
        records.removeIf(r -> !"借阅中".equals(r.getStatus()));
    } else if ("returned".equals(filter)) {
        // 获取已归还的记录
        records.removeIf(r -> !"已归还".equals(r.getStatus()));
    }
    
    // 统计信息
    long totalBorrows = records.size();
    long borrowingCount = records.stream().filter(r -> "借阅中".equals(r.getStatus())).count();
    long overdueCount = overdueRecords.size();
    long returnedCount = records.stream().filter(r -> "已归还".equals(r.getStatus())).count();
    double totalFines = records.stream().mapToDouble(BorrowRecord::getFineAmount).sum();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>借阅管理 - 图书管理系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: #fff;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .stat-value {
            font-size: 32px;
            font-weight: bold;
            margin: 10px 0;
        }
        
        .stat-value.borrowing { color: #007bff; }
        .stat-value.overdue { color: #dc3545; }
        .stat-value.returned { color: #28a745; }
        
        .filters {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .filter-buttons {
            display: flex;
            gap: 10px;
            margin-top: 10px;
            flex-wrap: wrap;
        }
        
        .filter-btn {
            padding: 5px 15px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 3px;
            cursor: pointer;
            text-decoration: none;
            color: #333;
            font-size: 14px;
        }
        
        .filter-btn:hover {
            background: #f0f0f0;
        }
        
        .filter-btn.active {
            background: #007bff;
            color: white;
            border-color: #007bff;
        }
        
        .search-box {
            margin-top: 15px;
        }
        
        .search-input {
            width: 300px;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 3px;
        }
        
        .status-badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .borrowing { background: #d4edda; color: #155724; }
        .overdue { background: #f8d7da; color: #721c24; }
        .returned { background: #cce5ff; color: #004085; }
        
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        
        .btn-action {
            padding: 3px 8px;
            font-size: 12px;
            border-radius: 3px;
            border: none;
            cursor: pointer;
        }
        
        .btn-return { background: #28a745; color: white; }
        .btn-renew { background: #ffc107; color: #212529; }
        .btn-fine { background: #dc3545; color: white; }
        
        .warning-text {
            color: #dc3545;
            font-weight: bold;
        }
        
        .overdue-date {
            color: #dc3545;
            font-weight: bold;
        }
        
        .fine-amount {
            color: #dc3545;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>图书管理系统 - 借阅管理</h1>
        <div class="user-info">
            管理员：<%= user.getRealName() %> | 
            <a href="${pageContext.request.contextPath}/LogoutServlet">退出登录</a>
        </div>
    </div>
    
    <div class="sidebar">
        <ul>
            <li><a href="dashboard.jsp">首页</a></li>
            <li><a href="book_management.jsp">图书管理</a></li>
            <li><a href="user_management.jsp">用户管理</a></li>
            <li class="active"><a href="borrow_management.jsp">借阅管理</a></li>
            <li><a href="#">统计分析</a></li>
        </ul>
    </div>
    
    <div class="main-content">
        <h2>借阅管理</h2>
        
        <!-- 显示消息 -->
        <% 
            String success = (String) session.getAttribute("success");
            String error = (String) session.getAttribute("error");
            String info = (String) session.getAttribute("info");
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
        <% if (info != null) { %>
            <div class="info-message"><%= info %></div>
        <% 
                session.removeAttribute("info");
            } 
        %>
        
        <!-- 统计卡片 -->
        <div class="stats-cards">
            <div class="stat-card">
                <h3>总借阅数</h3>
                <div class="stat-value borrowing"><%= totalBorrows %></div>
                <p>全部借阅记录</p>
            </div>
            
            <div class="stat-card">
                <h3>当前借阅</h3>
                <div class="stat-value borrowing"><%= borrowingCount %></div>
                <p>正在进行中</p>
            </div>
            
            <div class="stat-card">
                <h3>逾期记录</h3>
                <div class="stat-value overdue"><%= overdueCount %></div>
                <p>需要处理</p>
            </div>
            
            <div class="stat-card">
                <h3>已归还</h3>
                <div class="stat-value returned"><%= returnedCount %></div>
                <p>已完成借阅</p>
            </div>
            
            <div class="stat-card">
                <h3>待收罚款</h3>
                <div class="stat-value warning-text">¥<%= String.format("%.2f", totalFines) %></div>
                <p>逾期罚款总额</p>
            </div>
        </div>
        
        <!-- 筛选器和搜索 -->
        <div class="filters">
            <h3>筛选记录</h3>
            <div class="filter-buttons">
                <a href="borrow_management.jsp" class="filter-btn <%= filter == null && search == null ? "active" : "" %>">
                    全部记录
                </a>
                <a href="borrow_management.jsp?filter=borrowing" class="filter-btn <%= "borrowing".equals(filter) ? "active" : "" %>">
                    借阅中
                </a>
                <a href="borrow_management.jsp?filter=overdue" class="filter-btn <%= "overdue".equals(filter) ? "active" : "" %>">
                    逾期记录
                </a>
                <a href="borrow_management.jsp?filter=returned" class="filter-btn <%= "returned".equals(filter) ? "active" : "" %>">
                    已归还
                </a>
            </div>
            
            <div class="search-box">
                <form action="borrow_management.jsp" method="get">
                    <input type="text" name="search" class="search-input" 
                           placeholder="搜索图书名称、读者姓名" value="<%= search != null ? search : "" %>">
                    <button type="submit" class="btn-search">搜索</button>
                    <% if (search != null && !search.trim().isEmpty()) { %>
                        <a href="borrow_management.jsp" class="filter-btn">清除搜索</a>
                    <% } %>
                </form>
            </div>
        </div>
        
        <!-- 借阅记录表格 -->
        <div class="record-table">
            <h3>借阅记录列表</h3>
            
            <% if (records.isEmpty()) { %>
                <div style="text-align: center; padding: 40px; color: #666;">
                    没有找到相关借阅记录
                </div>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>记录ID</th>
                            <th>读者姓名</th>
                            <th>图书名称</th>
                            <th>借阅日期</th>
                            <th>应还日期</th>
                            <th>归还日期</th>
                            <th>状态</th>
                            <th>罚款金额</th>
                            <th>续借次数</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (BorrowRecord record : records) { 
                            boolean isOverdue = record.getDueDate().before(new java.util.Date()) && 
                                              ("借阅中".equals(record.getStatus()) || "逾期".equals(record.getStatus()));
                            boolean canRenew = record.getRenewCount() < 1 && 
                                              ("借阅中".equals(record.getStatus()) || "逾期".equals(record.getStatus()));
                        %>
                        <tr>
                            <td><%= record.getRecordId() %></td>
                            <td><%= record.getUserName() %></td>
                            <td><%= record.getBookTitle() %></td>
                            <td><%= sdf.format(record.getBorrowDate()) %></td>
                            <td class="<%= isOverdue ? "overdue-date" : "" %>">
                                <%= sdf.format(record.getDueDate()) %>
                            </td>
                            <td><%= record.getReturnDate() != null ? sdf.format(record.getReturnDate()) : "-" %></td>
                            <td>
                                <span class="status-badge <%= record.getStatus() %>">
                                    <%= record.getStatus() %>
                                </span>
                            </td>
                            <td class="<%= record.getFineAmount() > 0 ? "fine-amount" : "" %>">
                                <% if (record.getFineAmount() > 0) { %>
                                    ¥<%= String.format("%.2f", record.getFineAmount()) %>
                                <% } else { %>
                                    -
                                <% } %>
                            </td>
                            <td><%= record.getRenewCount() %>次</td>
                            <td>
                                <div class="action-buttons">
                                    <% if ("借阅中".equals(record.getStatus()) || "逾期".equals(record.getStatus())) { %>
                                        <% if (canRenew) { %>
                                            <button class="btn-action btn-renew"
                                                    onclick="renewBook(<%= record.getRecordId() %>)"
                                                    title="为用户续借30天">
                                                续借
                                            </button>
                                        <% } else { %>
                                            <button class="btn-action" disabled title="已续借过1次">
                                                已续借
                                            </button>
                                        <% } %>
                                        
                                        <button class="btn-action btn-return" 
                                                onclick="returnBook(<%= record.getRecordId() %>, <%= record.getBookId() %>)"
                                                title="确认用户已归还图书">
                                            归还
                                        </button>
                                        
                                        <% if ("逾期".equals(record.getStatus())) { %>
                                            <button class="btn-action btn-fine"
                                                    onclick="calculateFine(<%= record.getRecordId() %>)"
                                                    title="计算逾期罚款">
                                                计算罚款
                                            </button>
                                        <% } %>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
        
        <!-- 批量操作 -->
        <div class="bulk-actions" style="margin-top: 20px; padding: 15px; background: #f8f9fa; border-radius: 5px;">
            <h4>批量操作</h4>
            <div style="display: flex; gap: 10px; align-items: center;">
                <button onclick="batchUpdateOverdue()" class="btn-action" 
                        style="background: #6c757d; color: white;">
                    更新所有逾期状态
                </button>
                <button onclick="calculateAllFines()" class="btn-action" 
                        style="background: #dc3545; color: white;">
                    计算所有逾期罚款
                </button>
                <span style="color: #666; font-size: 12px;">
                    （批量操作会影响所有符合条件的记录）
                </span>
            </div>
        </div>
    </div>
    
    <script>
        // 归还图书
        function returnBook(recordId, bookId) {
            if (confirm("确认用户已归还图书？此操作不可撤销。")) {
                window.location.href = '${pageContext.request.contextPath}/BorrowServlet?action=return&recordId=' + recordId + '&bookId=' + bookId;
            }
        }
        
        // 续借图书
        function renewBook(recordId) {
            if (confirm("确认为用户续借图书30天？")) {
                window.location.href = '${pageContext.request.contextPath}/BorrowServlet?action=renew&recordId=' + recordId;
            }
        }
        
        // 计算罚款
        function calculateFine(recordId) {
            if (confirm("计算该记录的逾期罚款？")) {
                window.location.href = '${pageContext.request.contextPath}/BorrowServlet?action=calculateFine&recordId=' + recordId;
            }
        }
        
        // 批量更新逾期状态
        function batchUpdateOverdue() {
            if (confirm("确认更新所有逾期状态？这将把所有到期未还的记录标记为逾期。")) {
                // 这里可以调用一个专门的Servlet来处理批量操作
                alert("批量更新功能需要单独实现Servlet接口");
            }
        }
        
        // 批量计算所有罚款
        function calculateAllFines() {
            if (confirm("确认计算所有逾期记录的罚款？")) {
                // 这里可以调用一个专门的Servlet来处理批量操作
                alert("批量计算功能需要单独实现Servlet接口");
            }
        }
        
        // 页面加载时检查逾期记录
        window.onload = function() {
            <% if (overdueCount > 0) { %>
            setTimeout(function() {
                if (confirm("检测到<%= overdueCount %>条逾期记录，是否查看逾期列表？")) {
                    window.location.href = 'borrow_management.jsp?filter=overdue';
                }
            }, 1000);
            <% } %>
        };
    </script>
</body>
</html>