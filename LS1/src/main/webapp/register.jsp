<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>图书管理系统 - 注册</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="login-container">
        <div class="login-box">
            <h2>用户注册</h2>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="error-message"><%= request.getAttribute("error") %></div>
            <% } %>
            
            <form action="RegisterServlet" method="post">
                <div class="form-group">
                    <label for="username">用户名：</label>
                    <input type="text" id="username" name="username" required>
                </div>
                
                <div class="form-group">
                    <label for="password">密码：</label>
                    <input type="password" id="password" name="password" required>
                </div>
                
                <div class="form-group">
                    <label for="confirmPassword">确认密码：</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" required>
                </div>
                
                <div class="form-group">
                    <label for="realName">真实姓名：</label>
                    <input type="text" id="realName" name="realName" required>
                </div>
                
                <div class="form-group">
                    <label for="email">邮箱：</label>
                    <input type="email" id="email" name="email">
                </div>
                
                <div class="form-group">
                    <label for="phone">电话：</label>
                    <input type="tel" id="phone" name="phone">
                </div>
                
                <div class="form-group">
                    <button type="submit" class="btn-register">注册</button>
                    <a href="login.jsp" class="btn-back">返回登录</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>