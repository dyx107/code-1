<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.library.model.User" %>
<%@ page import="com.library.dao.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getUserType())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // 初始化DAO对象
    BookDAO bookDAO = new BookDAO();
    UserDAO userDAO = new UserDAO();
    BorrowRecordDAO borrowRecordDAO = new BorrowRecordDAO();
    
    // 更新逾期状态
    borrowRecordDAO.updateOverdueStatus();
    
    // 获取统计数据
    int totalBooks = bookDAO.getTotalBooksCount();
    int availableBooks = bookDAO.getAvailableBooksCount();
    int totalUsers = userDAO.getTotalUsersCount();
    int activeUsers = userDAO.getActiveUsersCount();
    int totalBorrowRecords = borrowRecordDAO.getTotalBorrowRecordsCount();
    int currentBorrowing = borrowRecordDAO.getCurrentBorrowingCount();
    int overdueRecords = borrowRecordDAO.getOverdueRecordsCount();
    double totalFines = borrowRecordDAO.getTotalFines();
    
    // 获取热门图书（借阅次数最多的10本书）
    List<Map<String, Object>> popularBooks = borrowRecordDAO.getPopularBooks(10);
    
    // 获取活跃读者（借阅次数最多的10位读者）
    List<Map<String, Object>> activeReaders = borrowRecordDAO.getActiveReaders(10);
    
    // 获取图书分类统计
    Map<String, Integer> categoryStats = bookDAO.getBooksCountByCategory();
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String today = sdf.format(new Date());
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>统计分析 - 图书管理系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <div class="header">
        <h1>图书管理系统 - 统计分析</h1>
        <div class="user-info">
            欢迎，管理员 <%= user.getRealName() %> | 
            <a href="${pageContext.request.contextPath}/LogoutServlet">退出登录</a>
        </div>
    </div>
    
    <div class="sidebar">
        <ul>
            <li><a href="${pageContext.request.contextPath}/admin/dashboard.jsp">首页</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/book_management.jsp">图书管理</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/user_management.jsp">用户管理</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/borrow_management.jsp">借阅管理</a></li>
            <li class="active"><a href="${pageContext.request.contextPath}/admin/statistics.jsp">统计分析</a></li>
        </ul>
    </div>
    
    <div class="main-content">
        <h2>系统统计分析</h2>
        
        <!-- 数据概览 -->
        <div class="dashboard-stats">
            <div class="stat-card">
                <h3>馆藏图书总数</h3>
                <p class="stat-number"><%= totalBooks %></p>
                <p>册</p>
                <p style="font-size: 12px; color: #2ecc71;">可借：<%= availableBooks %>册</p>
            </div>
            
            <div class="stat-card">
                <h3>注册用户总数</h3>
                <p class="stat-number"><%= totalUsers %></p>
                <p>人</p>
                <p style="font-size: 12px; color: #2ecc71;">活跃：<%= activeUsers %>人</p>
            </div>
            
            <div class="stat-card">
                <h3>当前借阅中</h3>
                <p class="stat-number"><%= currentBorrowing %></p>
                <p>册</p>
                <p style="font-size: 12px;">总借阅：<%= totalBorrowRecords %>次</p>
            </div>
            
            <div class="stat-card">
                <h3>逾期未还</h3>
                <p class="stat-number" style="color: <%= overdueRecords > 0 ? "#e74c3c" : "#2c3e50" %>">
                    <%= overdueRecords %>
                </p>
                <p>册</p>
                <p style="font-size: 12px; color: <%= overdueRecords > 0 ? "#e74c3c" : "#2ecc71" %>;">
                    <%= overdueRecords > 0 ? "需关注" : "良好" %>
                </p>
            </div>
            
            <div class="stat-card">
                <h3>待收罚款总额</h3>
                <p class="stat-number" style="color: <%= totalFines > 0 ? "#e74c3c" : "#2c3e50" %>">
                    ¥<%= String.format("%.2f", totalFines) %>
                </p>
                <p>元</p>
                <p style="font-size: 12px; color: <%= totalFines > 0 ? "#e74c3c" : "#2ecc71" %>;">
                    <%= totalFines > 0 ? "待收取" : "无欠款" %>
                </p>
            </div>
        </div>
        
        <!-- 数据表格 -->
        <div style="display: flex; gap: 20px; margin-bottom: 30px;">
            <!-- 热门图书排行榜 -->
            <div style="flex: 1; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                <h3 style="color: #333; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #eee;">热门图书排行榜</h3>
                <div style="overflow-x: auto;">
                    <% if (popularBooks != null && !popularBooks.isEmpty()) { %>
                    <table>
                        <thead>
                            <tr>
                                <th width="60">排名</th>
                                <th>图书名称</th>
                                <th width="100">作者</th>
                                <th width="100">借阅次数</th>
                                <th width="80">可借数量</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                int rank = 1;
                                for (Map<String, Object> book : popularBooks) { 
                            %>
                            <tr>
                                <td>
                                    <span style="display: inline-block; width: 24px; height: 24px; line-height: 24px; text-align: center; background: #667eea; color: white; border-radius: 50%; font-size: 12px; font-weight: bold;">
                                        <%= rank %>
                                    </span>
                                </td>
                                <td><%= book.get("title") %></td>
                                <td><%= book.get("author") %></td>
                                <td><strong><%= book.get("borrow_count") %></strong></td>
                                <td>
                                    <% 
                                        int available = (Integer) book.get("available_copies");
                                        if (available > 0) {
                                    %>
                                        <span style="color:#10b981;"><%= available %></span>
                                    <% } else { %>
                                        <span style="color:#ef4444;">0</span>
                                    <% } %>
                                </td>
                            </tr>
                            <% 
                                rank++;
                                } 
                            %>
                        </tbody>
                    </table>
                    <% } else { %>
                    <div style="text-align: center; color: #999; padding: 40px; font-style: italic;">暂无热门图书数据</div>
                    <% } %>
                </div>
            </div>
            
            <!-- 活跃读者排行榜 -->
            <div style="flex: 1; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                <h3 style="color: #333; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #eee;">活跃读者排行榜</h3>
                <div style="overflow-x: auto;">
                    <% if (activeReaders != null && !activeReaders.isEmpty()) { %>
                    <table>
                        <thead>
                            <tr>
                                <th width="60">排名</th>
                                <th>读者姓名</th>
                                <th width="120">读者编号</th>
                                <th width="100">借阅次数</th>
                                <th width="80">当前借阅</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                int readerRank = 1;
                                for (Map<String, Object> reader : activeReaders) { 
                            %>
                            <tr>
                                <td>
                                    <span style="display: inline-block; width: 24px; height: 24px; line-height: 24px; text-align: center; background: #667eea; color: white; border-radius: 50%; font-size: 12px; font-weight: bold;">
                                        <%= readerRank %>
                                    </span>
                                </td>
                                <td><%= reader.get("real_name") %></td>
                                <td><%= reader.get("user_id") %></td>
                                <td><strong><%= reader.get("borrow_count") %></strong></td>
                                <td>
                                    <% 
                                        int currentBorrow = (Integer) reader.get("current_borrow");
                                        if (currentBorrow > 0) {
                                    %>
                                        <span style="color:#f59e0b;"><%= currentBorrow %></span>
                                    <% } else { %>
                                        <span style="color:#6b7280;">0</span>
                                    <% } %>
                                </td>
                            </tr>
                            <% 
                                readerRank++;
                                } 
                            %>
                        </tbody>
                    </table>
                    <% } else { %>
                    <div style="text-align: center; color: #999; padding: 40px; font-style: italic;">暂无活跃读者数据</div>
                    <% } %>
                </div>
            </div>
        </div>
        
        <!-- 分类统计 -->
        <div style="background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            <h3 style="color: #333; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #eee;">图书分类统计</h3>
            <div style="overflow-x: auto;">
                <% if (categoryStats != null && !categoryStats.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th width="150">分类</th>
                            <th width="100">图书数量</th>
                            <th>占比</th>
                            <th width="200">状态</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            int totalCategoryBooks = 0;
                            for (int count : categoryStats.values()) {
                                totalCategoryBooks += count;
                            }
                            
                            for (Map.Entry<String, Integer> entry : categoryStats.entrySet()) {
                                String category = entry.getKey();
                                int count = entry.getValue();
                                double percentage = totalCategoryBooks > 0 ? (count * 100.0 / totalCategoryBooks) : 0;
                        %>
                        <tr>
                            <td>
                                <span style="display: inline-block; padding: 3px 10px; background: #e3f2fd; color: #1976d2; border-radius: 15px; font-size: 12px;">
                                    <%= category %>
                                </span>
                            </td>
                            <td><strong><%= count %></strong> 册</td>
                            <td>
                                <div style="background: #f5f5f5; height: 20px; border-radius: 3px; overflow: hidden;">
                                    <div style="background: #667eea; width: <%= percentage %>% ; height: 100%;"></div>
                                </div>
                                <span style="font-size:12px; color:#666;"><%= String.format("%.1f", percentage) %>%</span>
                            </td>
                            <td>
                                <% if (percentage > 20) { %>
                                <span style="color:#10b981;">主要分类</span>
                                <% } else if (percentage > 5) { %>
                                <span style="color:#f59e0b;">一般分类</span>
                                <% } else { %>
                                <span style="color:#6b7280;">次要分类</span>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div style="text-align: center; color: #999; padding: 40px; font-style: italic;">暂无分类统计数据</div>
                <% } %>
            </div>
        </div>
        
        <!-- 最后更新时间 -->
        <div style="color: #999; font-size: 12px; text-align: right; margin-top: 10px;">
            数据更新时间：<%= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()) %>
        </div>
    </div>
</body>
</html>