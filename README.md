# code-1
# 图书管理系统

一个完整的Java Web图书管理系统，使用JSP + Servlet + MySQL技术栈实现。

## 项目概述

这是一个功能完善的图书管理系统，包含管理员和读者两种角色，实现了图书管理、借阅管理、用户管理等核心功能。

## 技术栈

- 后端：Java Servlet 3.1, JSP 2.3, JDBC
- 数据库：MySQL 5.1
- 前端：HTML5, CSS3, JavaScript
- 构建工具：Maven
- 服务器：Apache Tomcat 8+

## 功能模块

### 1. 用户管理
- 用户注册、登录、注销
- 密码加密存储（SHA1）
- 角色权限控制（管理员/读者）
- 用户状态管理（激活/停用）

### 2. 图书管理
- 图书信息的增删改查
- 图书分类管理
- 图书搜索（按书名、作者、ISBN）
- 库存管理
- ISBN重复检查

### 3. 借阅管理
- 图书借阅与归还
- 逾期计算和罚款
- 图书续借（最多1次）
- 借阅记录查询
- 逾期状态自动更新

### 4. 统计分析
- 图书借阅排行榜
- 活跃读者统计
- 图书分类统计
- 借阅趋势图表
- 系统数据概览

## 数据库设计

### 主要数据表

1. users表 - 用户信息
   - 字段：user_id, username, password, real_name, email, phone, user_type, status, register_date

2. books表 - 图书信息
   - 字段：book_id, isbn, title, author, publisher, publish_year, category, total_copies, available_copies, location, description

3. borrow_records表 - 借阅记录
   - 字段：record_id, user_id, book_id, borrow_date, due_date, return_date, status, fine_amount, renew_count

## 安装部署

### 环境要求
- JDK 8或更高版本
- Apache Tomcat 8或更高版本
- MySQL 5.1或更高版本
- Maven 3.6+

### 部署步骤

1. 克隆项目
```
git clone https://github.com/yourusername/library-management-system.git
```

2. 创建数据库
```sql
CREATE DATABASE library_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE library_db;
```

3. 导入数据库脚本
```sql
-- 创建users表
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    real_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    user_type ENUM('admin', 'reader') DEFAULT 'reader',
    status ENUM('active', 'suspended') DEFAULT 'active',
    register_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建books表
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(20),
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100),
    publisher VARCHAR(100),
    publish_year INT,
    category VARCHAR(50),
    total_copies INT DEFAULT 1,
    available_copies INT DEFAULT 1,
    location VARCHAR(100),
    description TEXT,
    cover_image VARCHAR(200),
    add_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建borrow_records表
CREATE TABLE borrow_records (
    record_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('借阅中', '已归还', '逾期') DEFAULT '借阅中',
    fine_amount DECIMAL(10,2) DEFAULT 0.00,
    renew_count INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- 插入管理员用户（密码：admin123）
INSERT INTO users (username, password, real_name, user_type) 
VALUES ('admin', SHA1('admin123'), '系统管理员', 'admin');
```

4. 配置数据库连接
修改`DatabaseConnection.java`中的数据库配置：
```java
private static final String URL = "jdbc:mysql://localhost:3306/library_db?useUnicode=true&characterEncoding=UTF-8&useSSL=false";
private static final String USER = "root";
private static final String PASSWORD = "your_password";
```

5. 构建项目
```
mvn clean package
```

6. 部署到Tomcat
- 将生成的WAR文件复制到Tomcat的webapps目录
- 启动Tomcat服务器

## 使用说明

### 默认账户
- 管理员：用户名`admin`，密码`admin123`
- 读者：需要先注册

### 读者权限
- 最多可借阅5本书
- 借期30天，可续借1次
- 查看个人借阅记录

### 管理员权限
- 管理所有图书信息
- 管理用户账户
- 处理借阅归还
- 查看统计分析

## 项目结构

```
src/main/java/com/library/
├── dao/           # 数据访问层
│   ├── BookDAO.java
│   ├── UserDAO.java
│   ├── BorrowRecordDAO.java
│   └── DatabaseConnection.java
├── model/         # 实体类
│   ├── Book.java
│   ├── User.java
│   └── BorrowRecord.java
├── servlet/       # 控制器
│   ├── BookServlet.java
│   ├── LoginServlet.java
│   ├── BorrowServlet.java
│   ├── RegisterServlet.java
│   ├── LogoutServlet.java
│   └── UserServlet.java
└── util/          # 工具类
    └── AuthFilter.java

src/main/webapp/
├── WEB-INF/
│   └── web.xml
├── css/
│   └── style.css
├── admin/         # 管理员页面
│   ├── dashboard.jsp
│   ├── book_management.jsp
│   ├── user_management.jsp
│   ├── borrow_management.jsp
│   └── statistics.jsp
├── reader/        # 读者页面
├── login.jsp
├── register.jsp
└── index.jsp
```

## 安全特性

1. 用户密码使用SHA1加密存储
2. 基于Session的用户认证
3. 权限过滤器控制访问
4. SQL语句预编译防止注入
5. 数据库事务保证数据一致性

## 功能特点

1. **完整的CRUD操作**：所有实体都有完整的增删改查功能
2. **借阅管理**：自动计算逾期和罚款
3. **库存管理**：实时跟踪图书库存状态
4. **统计分析**：多维度数据统计和分析
5. **用户友好**：简洁直观的操作界面
6. **响应式设计**：适配不同屏幕尺寸

## 开发规范

1. 包命名：com.library.模块名
2. 类命名：大驼峰式
3. 方法命名：小驼峰式
4. 变量命名：小驼峰式
5. 常量命名：全大写加下划线

## 常见问题

### 数据库连接失败
1. 确认MySQL服务正在运行
2. 检查数据库用户名和密码
3. 验证数据库连接URL格式

### 中文乱码
1. 确保数据库使用UTF-8编码
2. 在JSP页面设置charset=UTF-8
3. 数据库连接字符串包含字符编码参数

### 权限问题
1. 检查用户是否已登录
2. 确认用户角色权限
3. 验证过滤器配置

## 后续开发建议

1. 增加Redis缓存提高性能
2. 实现分页功能优化大数据查询
3. 添加全文搜索功能
4. 实现邮件通知功能
5. 增加移动端适配
6. 添加API接口支持
7. 实现图书推荐功能

## 联系方式

如有问题或建议，请通过GitHub Issues提交反馈。
