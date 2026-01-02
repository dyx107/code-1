<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.library.model.User" %>
<%@ page import="com.library.dao.BorrowRecordDAO" %>
<%@ page import="com.library.model.BorrowRecord" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    BorrowRecordDAO borrowRecordDAO = new BorrowRecordDAO();
    List<BorrowRecord> records = borrowRecordDAO.getBorrowRecordsByUserId(user.getUserId());
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    
    // 更新逾期状态
    borrowRecordDAO.updateOverdueStatus();
    
    // 计算统计数据
    long currentBorrowCount = 0;
    long overdueCount = 0;
    long returnedCount = 0;
    double totalFine = 0;
    
    for (BorrowRecord record : records) {
        String status = record.getStatus();
        if ("借阅中".equals(status) || "逾期".equals(status)) {
            currentBorrowCount++;
        }
        if ("逾期".equals(status)) {
            overdueCount++;
        }
        if ("已归还".equals(status)) {
            returnedCount++;
        }
        totalFine += record.getFineAmount();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>我的借阅记录 - 图书管理系统</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .record-status {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .borrowing { background: #d4edda; color: #155724; }
        .returned { background: #cce5ff; color: #004085; }
        .overdue { background: #f8d7da; color: #721c24; }
        
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        
        .btn-renew, .btn-return {
            padding: 3px 8px;
            font-size: 12px;
            border-radius: 3px;
            border: none;
            cursor: pointer;
        }
        
        .btn-renew {
            background: #ffc107;
            color: #212529;
        }
        
        .btn-renew:disabled {
            background: #ccc;
            cursor: not-allowed;
        }
        
        .btn-return {
            background: #28a745;
            color: white;
        }
        
        .stats-card {
            background: #f8f9fa;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 20px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
        }
        
        .stat-item {
            text-align: center;
            padding: 10px;
            background: white;
            border-radius: 5px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        
        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #007bff;
        }
        
        .warning-text {
            color: #dc3545;
            font-weight: bold;
        }
        
        .info-text {
            color: #17a2b8;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>图书管理系统 - 我的借阅记录</h1>
        <div class="user-info">
            欢迎，<%= user.getRealName() %> | 
            <a href="../LogoutServlet">退出登录</a>
        </div>
    </div>
    
    <div class="sidebar">
        <ul>
            <li><a href="dashboard.jsp">首页</a></li>
            <li><a href="search.jsp">图书查询</a></li>
            <li><a href="borrow.jsp">借阅图书</a></li>
            <li class="active"><a href="records.jsp">我的借阅记录</a></li>
        </ul>
    </div>
    
    <div class="main-content">
        <h2>我的借阅记录</h2>
        
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
        
        <!-- 统计信息 -->
        <div class="stats-card">
            <h3>借阅统计</h3>
            <div class="stats-grid">
                <div class="stat-item">
                    <div class="stat-value"><%= currentBorrowCount %></div>
                    <div>当前借阅</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value <%= overdueCount > 0 ? "warning-text" : "" %>">
                        <%= overdueCount %>
                    </div>
                    <div>逾期图书</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value"><%= records.size() %></div>
                    <div>总借阅次数</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value"><%= returnedCount %></div>
                    <div>已归还</div>
                </div>
                <% if (totalFine > 0) { %>
                <div class="stat-item">
                    <div class="stat-value warning-text">
                        ¥<%= String.format("%.2f", totalFine) %>
                    </div>
                    <div>待缴罚款</div>
                </div>
                <% } %>
            </div>
        </div>
        
        <!-- 借阅规则提醒 -->
        <div class="info-box" style="background: #e7f3ff; padding: 10px; border-radius: 5px; margin-bottom: 15px;">
            <strong>借阅规则：</strong>
            1. 最多可借5本图书 | 
            2. 借期30天 | 
            3. 每本书最多续借1次 | 
            4. 逾期罚款每天0.5元
        </div>
        
        <!-- 借阅记录表格 -->
        <div class="record-list">
            <h3>借阅历史</h3>
            
            <table>
                <thead>
                    <tr>
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
                    <% 
                        if (records != null && !records.isEmpty()) {
                            for (BorrowRecord record : records) { 
                                boolean canRenew = record.getRenewCount() < 1 && 
                                                  ("借阅中".equals(record.getStatus()) || "逾期".equals(record.getStatus()));
                                boolean canReturn = "借阅中".equals(record.getStatus()) || "逾期".equals(record.getStatus());
                    %>
                    <tr>
                        <td><%= record.getBookTitle() %></td>
                        <td><%= sdf.format(record.getBorrowDate()) %></td>
                        <td class="<%= "逾期".equals(record.getStatus()) ? "warning-text" : "" %>">
                            <%= sdf.format(record.getDueDate()) %>
                        </td>
                        <td><%= record.getReturnDate() != null ? sdf.format(record.getReturnDate()) : "-" %></td>
                        <td>
                            <span class="record-status <%= record.getStatus() %>">
                                <%= record.getStatus() %>
                            </span>
                        </td>
                        <td>
                            <% if (record.getFineAmount() > 0) { %>
                                <span class="warning-text">
                                    ¥<%= String.format("%.2f", record.getFineAmount()) %>
                                </span>
                            <% } else { %>
                                -
                            <% } %>
                        </td>
                        <td><%= record.getRenewCount() %>次</td>
                        <td>
                            <div class="action-buttons">
                                <% if (canRenew) { %>
                                    <button class="btn-renew" 
                                            onclick="renewBook(<%= record.getRecordId() %>)">
                                        续借
                                    </button>
                                <% } else if (record.getRenewCount() >= 1) { %>
                                    <button class="btn-renew" disabled title="已续借过1次">
                                        已续借
                                    </button>
                                <% } %>
                                
                                <% if (canReturn) { %>
                                    <button class="btn-return" 
                                            onclick="returnBook(<%= record.getRecordId() %>, <%= record.getBookId() %>)">
                                        归还
                                    </button>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <% 
                            }
                        } else { 
                    %>
                    <tr>
                        <td colspan="8" style="text-align: center;">暂无借阅记录</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    
    <script>
        // 续借图书
        function renewBook(recordId) {
            if (confirm("确定要续借这本书吗？续借期限为30天。")) {
                if (confirm("续借成功后，新的借阅期限将在原到期日期基础上延长30天。确认续借吗？")) {
                    window.location.href = '../BorrowServlet?action=renew&recordId=' + recordId;
                }
            }
        }
        
        // 归还图书
        function returnBook(recordId, bookId) {
            if (confirm("确定要归还这本书吗？")) {
                window.location.href = '../BorrowServlet?action=return&recordId=' + recordId + '&bookId=' + bookId;
            }
        }
        
        // 页面加载时检查逾期图书
        window.onload = function() {
            <% if (overdueCount > 0) { %>
            setTimeout(function() {
                alert("您有<%= overdueCount %>本图书已逾期，请尽快归还以避免罚款！");
            }, 500);
            <% } %>
        };
    </script>
</body>
</html>