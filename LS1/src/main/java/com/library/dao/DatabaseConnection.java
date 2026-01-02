package com.library.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    // MySQL 5.1 配置
    private static final String URL = "jdbc:mysql://localhost:3306/library_db?useUnicode=true&characterEncoding=UTF-8&useSSL=false";
    private static final String USER = "root";
    private static final String PASSWORD = "dyx134097"; 
    private static final String DRIVER = "com.mysql.jdbc.Driver"; // MySQL 5.1 使用这个驱动
    
    private static Connection connection = null;
    
    static {
        try {
            Class.forName(DRIVER);
            System.out.println("MySQL驱动加载成功！");
        } catch (ClassNotFoundException e) {
            System.err.println("加载MySQL驱动失败！");
            e.printStackTrace();
        }
    }
    
    public static Connection getConnection() throws SQLException {
        try {
            if (connection == null || connection.isClosed()) {
                connection = DriverManager.getConnection(URL, USER, PASSWORD);
                System.out.println("数据库连接成功！");
            }
        } catch (SQLException e) {
            System.err.println("数据库连接失败！");
            System.err.println("URL: " + URL);
            System.err.println("用户名: " + USER);
            e.printStackTrace();
            throw e; // 重新抛出异常，让上层知道连接失败
        }
        return connection;
    }
    
    public static void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                System.out.println("数据库连接已关闭！");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}