<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Servlet调试页面</title>
</head>
<body>
    <h1>Servlet调试工具</h1>
    
    <h2>测试1：直接访问Servlet（GET请求）</h2>
    <p><a href="LoginServlet">点击这里直接访问LoginServlet</a></p>
    
    <h2>测试2：POST方式提交表单</h2>
    <form action="LoginServlet" method="post">
        <input type="hidden" name="test" value="debug">
        用户名：<input type="text" name="username" value="admin"><br>
        密码：<input type="password" name="password" value="admin123"><br>
        <input type="submit" value="测试POST请求">
    </form>
    
    <h2>系统信息</h2>
    <ul>
        <li>上下文路径: <%= request.getContextPath() %></li>
        <li>请求URI: <%= request.getRequestURI() %></li>
        <li>服务器信息: <%= application.getServerInfo() %></li>
        <li>Servlet版本: <%= application.getMajorVersion() %>.<%= application.getMinorVersion() %></li>
    </ul>
    
    <h2>检查Servlet是否存在</h2>
    <%
        try {
            Class clazz = Class.forName("com.library.servlet.LoginServlet");
            out.println("<p style='color:green'>✓ LoginServlet类存在</p>");
            out.println("<p>类名: " + clazz.getName() + "</p>");
            out.println("<p>类路径: " + clazz.getResource("") + "</p>");
        } catch (ClassNotFoundException e) {
            out.println("<p style='color:red'>✗ LoginServlet类不存在</p>");
            out.println("<p>错误: " + e.getMessage() + "</p>");
        }
    %>
    
    <h2>web.xml配置</h2>
    <p><a href="WEB-INF/web.xml" target="_blank">查看web.xml文件</a></p>
</body>
</html>