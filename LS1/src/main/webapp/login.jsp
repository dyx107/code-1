<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>图书管理系统 - 登录</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="login-container">
        <div class="login-box">
            <h2>图书管理系统登录</h2>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="error-message"><%= request.getAttribute("error") %></div>
            <% } %>
            
            <% if (request.getAttribute("success") != null) { %>
                <div class="success-message"><%= request.getAttribute("success") %></div>
            <% } %>
            
            <form action="LoginServlet" method="post">
                <div class="form-group">
                    <label for="username">用户名：</label>
                    <input type="text" id="username" name="username" required>
                </div>
                
                <div class="form-group">
                    <label for="password">密码：</label>
                    <input type="password" id="password" name="password" required>
                </div>
                
                <div class="form-group">
                    <button type="submit" class="btn-login">登录</button>
                </div>
                
                <div class="form-footer">
                    <p>还没有账号？ <a href="register.jsp">立即注册</a></p>
                </div>
            </form>
        </div>
    </div>
</body>
</html>