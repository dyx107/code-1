package com.library.dao;

import com.library.model.Book;
import java.sql.*;
import java.util.*;

public class BookDAO {
    
    // 获取所有图书
    public List<Book> getAllBooks() {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT * FROM books ORDER BY add_date DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Book book = new Book();
                book.setBookId(rs.getInt("book_id"));
                book.setIsbn(rs.getString("isbn"));
                book.setTitle(rs.getString("title"));
                book.setAuthor(rs.getString("author"));
                book.setPublisher(rs.getString("publisher"));
                book.setPublishYear(rs.getInt("publish_year"));
                book.setCategory(rs.getString("category"));
                book.setTotalCopies(rs.getInt("total_copies"));
                book.setAvailableCopies(rs.getInt("available_copies"));
                book.setLocation(rs.getString("location"));
                book.setDescription(rs.getString("description"));
                book.setCoverImage(rs.getString("cover_image"));
                book.setAddDate(rs.getTimestamp("add_date"));
                
                books.add(book);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return books;
    }
    
    // 根据ID获取图书
    public Book getBookById(int bookId) {
        Book book = null;
        String sql = "SELECT * FROM books WHERE book_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                book = new Book();
                book.setBookId(rs.getInt("book_id"));
                book.setIsbn(rs.getString("isbn"));
                book.setTitle(rs.getString("title"));
                book.setAuthor(rs.getString("author"));
                book.setPublisher(rs.getString("publisher"));
                book.setPublishYear(rs.getInt("publish_year"));
                book.setCategory(rs.getString("category"));
                book.setTotalCopies(rs.getInt("total_copies"));
                book.setAvailableCopies(rs.getInt("available_copies"));
                book.setLocation(rs.getString("location"));
                book.setDescription(rs.getString("description"));
                book.setCoverImage(rs.getString("cover_image"));
                book.setAddDate(rs.getTimestamp("add_date"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return book;
    }
    
    // 添加图书
    public boolean addBook(Book book) {
        String sql = "INSERT INTO books (isbn, title, author, publisher, publish_year, " +
                     "category, total_copies, available_copies, location, description) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        System.out.println("尝试添加图书：" + book.getTitle());
        System.out.println("SQL: " + sql);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, book.getIsbn());
            pstmt.setString(2, book.getTitle());
            pstmt.setString(3, book.getAuthor());
            pstmt.setString(4, book.getPublisher());
            pstmt.setInt(5, book.getPublishYear());
            pstmt.setString(6, book.getCategory());
            pstmt.setInt(7, book.getTotalCopies());
            pstmt.setInt(8, book.getTotalCopies()); // 初始时可用数量等于总数量
            pstmt.setString(9, book.getLocation());
            pstmt.setString(10, book.getDescription());
            
            System.out.println("设置参数完成，准备执行SQL...");
            
            int rows = pstmt.executeUpdate();
            System.out.println("执行成功，影响行数：" + rows);
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("添加图书失败！");
            System.err.println("错误信息：" + e.getMessage());
            System.err.println("错误代码：" + e.getErrorCode());
            e.printStackTrace();
            return false;
        }
    }
    
    // 更新图书信息
    public boolean updateBook(Book book) {
        String sql = "UPDATE books SET isbn = ?, title = ?, author = ?, publisher = ?, " +
                     "publish_year = ?, category = ?, total_copies = ?, location = ?, " +
                     "description = ? WHERE book_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, book.getIsbn());
            pstmt.setString(2, book.getTitle());
            pstmt.setString(3, book.getAuthor());
            pstmt.setString(4, book.getPublisher());
            pstmt.setInt(5, book.getPublishYear());
            pstmt.setString(6, book.getCategory());
            pstmt.setInt(7, book.getTotalCopies());
            pstmt.setString(8, book.getLocation());
            pstmt.setString(9, book.getDescription());
            pstmt.setInt(10, book.getBookId());
            
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 删除图书
    public boolean deleteBook(int bookId) {
        String sql = "DELETE FROM books WHERE book_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 搜索图书（按标题、作者或ISBN）
    public List<Book> searchBooks(String keyword) {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT * FROM books WHERE title LIKE ? OR author LIKE ? OR isbn LIKE ? " +
                     "ORDER BY add_date DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);
            pstmt.setString(3, searchPattern);
            
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Book book = new Book();
                book.setBookId(rs.getInt("book_id"));
                book.setIsbn(rs.getString("isbn"));
                book.setTitle(rs.getString("title"));
                book.setAuthor(rs.getString("author"));
                book.setPublisher(rs.getString("publisher"));
                book.setPublishYear(rs.getInt("publish_year"));
                book.setCategory(rs.getString("category"));
                book.setTotalCopies(rs.getInt("total_copies"));
                book.setAvailableCopies(rs.getInt("available_copies"));
                book.setLocation(rs.getString("location"));
                book.setDescription(rs.getString("description"));
                book.setCoverImage(rs.getString("cover_image"));
                book.setAddDate(rs.getTimestamp("add_date"));
                
                books.add(book);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return books;
    }
    
    // 根据分类获取图书
    public List<Book> getBooksByCategory(String category) {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT * FROM books WHERE category = ? ORDER BY add_date DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, category);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Book book = new Book();
                book.setBookId(rs.getInt("book_id"));
                book.setIsbn(rs.getString("isbn"));
                book.setTitle(rs.getString("title"));
                book.setAuthor(rs.getString("author"));
                book.setPublisher(rs.getString("publisher"));
                book.setPublishYear(rs.getInt("publish_year"));
                book.setCategory(rs.getString("category"));
                book.setTotalCopies(rs.getInt("total_copies"));
                book.setAvailableCopies(rs.getInt("available_copies"));
                book.setLocation(rs.getString("location"));
                book.setDescription(rs.getString("description"));
                book.setCoverImage(rs.getString("cover_image"));
                book.setAddDate(rs.getTimestamp("add_date"));
                
                books.add(book);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return books;
    }
    
    // 更新图书库存
    public boolean updateBookCopies(int bookId, int newTotalCopies) {
        String sql = "UPDATE books SET total_copies = ?, available_copies = ? " +
                     "WHERE book_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // 首先获取当前借出的数量
            Book book = getBookById(bookId);
            int borrowedCopies = book.getTotalCopies() - book.getAvailableCopies();
            int newAvailableCopies = Math.max(0, newTotalCopies - borrowedCopies);
            
            pstmt.setInt(1, newTotalCopies);
            pstmt.setInt(2, newAvailableCopies);
            pstmt.setInt(3, bookId);
            
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 获取图书统计信息
    public int getTotalBooksCount() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM books";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }
    
    // 获取可借图书数量
    public int getAvailableBooksCount() {
        int count = 0;
        String sql = "SELECT SUM(available_copies) FROM books";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }
    
    // 检查ISBN是否已存在
    public boolean isIsbnExists(String isbn) {
        String sql = "SELECT COUNT(*) FROM books WHERE isbn = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, isbn);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // 更新图书借阅状态（借出）
    public synchronized boolean borrowBook(int bookId) {
        // 使用事务确保数据一致性
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            
            // 1. 检查图书是否存在且可借
            String checkSql = "SELECT available_copies FROM books WHERE book_id = ? FOR UPDATE";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setInt(1, bookId);
            ResultSet rs = checkStmt.executeQuery();
            
            if (!rs.next() || rs.getInt("available_copies") <= 0) {
                conn.rollback();
                return false;
            }
            // 2. 减少可用数量
            String updateSql = "UPDATE books SET available_copies = available_copies - 1 " +
                              "WHERE book_id = ? AND available_copies > 0";
            PreparedStatement updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setInt(1, bookId);
            
            int rows = updateStmt.executeUpdate();
            
            if (rows > 0) {
                conn.commit();
                return true;
            } else {
                conn.rollback();
                return false;
            }
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    // 更新图书借阅状态（归还）
    public synchronized boolean returnBook(int bookId) {
        // 使用事务确保数据一致性
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            
            // 1. 检查图书是否存在且库存未满
            String checkSql = "SELECT total_copies, available_copies FROM books WHERE book_id = ? FOR UPDATE";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setInt(1, bookId);
            ResultSet rs = checkStmt.executeQuery();
            
            if (!rs.next() || rs.getInt("available_copies") >= rs.getInt("total_copies")) {
                conn.rollback();
                return false;
            }
            // 2. 增加可用数量
            String updateSql = "UPDATE books SET available_copies = available_copies + 1 " +
                              "WHERE book_id = ? AND available_copies < total_copies";
            PreparedStatement updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setInt(1, bookId);
            
            int rows = updateStmt.executeUpdate();
            
            if (rows > 0) {
                conn.commit();
                return true;
            } else {
                conn.rollback();
                return false;
            }
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    // 新增方法：获取图书分类统计
    public Map<String, Integer> getBooksCountByCategory() {
        Map<String, Integer> categoryStats = new HashMap<>();
        String sql = "SELECT category, COUNT(*) as count FROM books WHERE category IS NOT NULL AND category != '' GROUP BY category ORDER BY count DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                String category = rs.getString("category");
                int count = rs.getInt("count");
                categoryStats.put(category, count);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return categoryStats;
    }
}