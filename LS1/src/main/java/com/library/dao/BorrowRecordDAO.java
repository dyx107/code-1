package com.library.dao;

import com.library.model.BorrowRecord;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Date;

public class BorrowRecordDAO {
    
    // 添加借阅记录
    public boolean addBorrowRecord(BorrowRecord record) {
        String sql = "INSERT INTO borrow_records (user_id, book_id, borrow_date, due_date, status, renew_count) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, record.getUserId());
            pstmt.setInt(2, record.getBookId());
            pstmt.setDate(3, new java.sql.Date(record.getBorrowDate().getTime()));
            pstmt.setDate(4, new java.sql.Date(record.getDueDate().getTime()));
            pstmt.setString(5, record.getStatus());
            pstmt.setInt(6, record.getRenewCount());
            
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 根据用户ID获取借阅记录
    public List<BorrowRecord> getBorrowRecordsByUserId(int userId) {
        List<BorrowRecord> records = new ArrayList<>();
        String sql = "SELECT br.*, b.title as book_title, u.real_name as user_name " +
                     "FROM borrow_records br " +
                     "JOIN books b ON br.book_id = b.book_id " +
                     "JOIN users u ON br.user_id = u.user_id " +
                     "WHERE br.user_id = ? " +
                     "ORDER BY br.borrow_date DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                BorrowRecord record = extractBorrowRecordFromResultSet(rs);
                records.add(record);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return records;
    }
    
    // 获取所有借阅记录（管理员用）
    public List<BorrowRecord> getAllBorrowRecords() {
        List<BorrowRecord> records = new ArrayList<>();
        String sql = "SELECT br.*, b.title as book_title, u.real_name as user_name " +
                     "FROM borrow_records br " +
                     "JOIN books b ON br.book_id = b.book_id " +
                     "JOIN users u ON br.user_id = u.user_id " +
                     "ORDER BY br.borrow_date DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                BorrowRecord record = extractBorrowRecordFromResultSet(rs);
                records.add(record);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return records;
    }
    
    // 从ResultSet提取BorrowRecord对象
    private BorrowRecord extractBorrowRecordFromResultSet(ResultSet rs) throws SQLException {
        BorrowRecord record = new BorrowRecord();
        record.setRecordId(rs.getInt("record_id"));
        record.setUserId(rs.getInt("user_id"));
        record.setBookId(rs.getInt("book_id"));
        record.setBorrowDate(rs.getDate("borrow_date"));
        record.setDueDate(rs.getDate("due_date"));
        record.setReturnDate(rs.getDate("return_date"));
        record.setStatus(rs.getString("status"));
        record.setFineAmount(rs.getDouble("fine_amount"));
        record.setBookTitle(rs.getString("book_title"));
        record.setUserName(rs.getString("user_name"));
        record.setRenewCount(rs.getInt("renew_count"));
        return record;
    }
    
    // 更新借阅状态（归还图书）
    public boolean returnBook(int recordId) {
        String sql = "UPDATE borrow_records SET return_date = CURDATE(), status = '已归还' " +
                     "WHERE record_id = ? AND status IN ('借阅中', '逾期')";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, recordId);
            
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 续借图书（修复类型问题）
    public boolean renewBook(int recordId, java.util.Date newDueDate) {
        // 检查是否可以续借（最多续借1次）
        if (!canRenewBook(recordId)) {
            return false;
        }
        
        String sql = "UPDATE borrow_records SET due_date = ?, renew_count = renew_count + 1 " +
                     "WHERE record_id = ? AND status = '借阅中'";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // 将java.util.Date转换为java.sql.Date
            java.sql.Date sqlDueDate = new java.sql.Date(newDueDate.getTime());
            pstmt.setDate(1, sqlDueDate);
            pstmt.setInt(2, recordId);
            
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 检查是否可以续借
    public boolean canRenewBook(int recordId) {
        String sql = "SELECT renew_count FROM borrow_records WHERE record_id = ? AND status = '借阅中'";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, recordId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                int renewCount = rs.getInt("renew_count");
                // 最多允许续借1次
                return renewCount < 1;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // 获取逾期记录
    public List<BorrowRecord> getOverdueRecords() {
        List<BorrowRecord> records = new ArrayList<>();
        String sql = "SELECT br.*, b.title as book_title, u.real_name as user_name " +
                     "FROM borrow_records br " +
                     "JOIN books b ON br.book_id = b.book_id " +
                     "JOIN users u ON br.user_id = u.user_id " +
                     "WHERE br.due_date < CURDATE() AND br.status = '借阅中' " +
                     "ORDER BY br.due_date";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                BorrowRecord record = extractBorrowRecordFromResultSet(rs);
                record.setStatus("逾期");
                records.add(record);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return records;
    }
    
    // 更新逾期状态
    public boolean updateOverdueStatus() {
        String sql = "UPDATE borrow_records SET status = '逾期' " +
                     "WHERE due_date < CURDATE() AND status = '借阅中'";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            int rows = stmt.executeUpdate(sql);
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 计算逾期罚款
    public double calculateFine(int recordId) {
        double fine = 0.0;
        String sql = "SELECT DATEDIFF(CURDATE(), due_date) as overdue_days " +
                     "FROM borrow_records " +
                     "WHERE record_id = ? AND due_date < CURDATE() AND status = '借阅中'";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, recordId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                int overdueDays = rs.getInt("overdue_days");
                if (overdueDays > 0) {
                    fine = overdueDays * 0.5; // 每天0.5元罚款
                    // 更新罚款金额
                    updateFineAmount(recordId, fine);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return fine;
    }
    
    // 更新罚款金额
    private void updateFineAmount(int recordId, double fine) {
        String sql = "UPDATE borrow_records SET fine_amount = ? WHERE record_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setDouble(1, fine);
            pstmt.setInt(2, recordId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // 获取用户的当前借阅数量
    public int getCurrentBorrowCount(int userId) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM borrow_records " +
                     "WHERE user_id = ? AND status IN ('借阅中', '逾期')";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }
    
    // 根据ID获取借阅记录
    public BorrowRecord getBorrowRecordById(int recordId) {
        String sql = "SELECT br.*, b.title as book_title, u.real_name as user_name " +
                     "FROM borrow_records br " +
                     "JOIN books b ON br.book_id = b.book_id " +
                     "JOIN users u ON br.user_id = u.user_id " +
                     "WHERE br.record_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, recordId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return extractBorrowRecordFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // 搜索借阅记录
    public List<BorrowRecord> searchBorrowRecords(String keyword) {
        List<BorrowRecord> records = new ArrayList<>();
        String sql = "SELECT br.*, b.title as book_title, u.real_name as user_name " +
                     "FROM borrow_records br " +
                     "JOIN books b ON br.book_id = b.book_id " +
                     "JOIN users u ON br.user_id = u.user_id " +
                     "WHERE b.title LIKE ? OR u.real_name LIKE ? OR u.username LIKE ? " +
                     "ORDER BY br.borrow_date DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);
            pstmt.setString(3, searchPattern);
            
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                BorrowRecord record = extractBorrowRecordFromResultSet(rs);
                records.add(record);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return records;
    }
    
    // 新增方法：获取最近7天借阅统计
    public Map<String, Integer> getWeeklyBorrowStats() {
        Map<String, Integer> stats = new LinkedHashMap<>();
        String sql = "SELECT DATE(borrow_date) as date, COUNT(*) as count " +
                     "FROM borrow_records " +
                     "WHERE borrow_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) " +
                     "GROUP BY DATE(borrow_date) " +
                     "ORDER BY date";
        
        // 初始化最近7天的数据（包括今天）
        Calendar cal = Calendar.getInstance();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        for (int i = 6; i >= 0; i--) {
            cal.setTime(new Date());
            cal.add(Calendar.DATE, -i);
            String date = sdf.format(cal.getTime());
            stats.put(date, 0);
        }
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                String date = rs.getString("date");
                int count = rs.getInt("count");
                if (stats.containsKey(date)) {
                    stats.put(date, count);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }
    
    // 新增方法：获取热门图书（借阅次数最多的图书）
    public List<Map<String, Object>> getPopularBooks(int limit) {
        List<Map<String, Object>> popularBooks = new ArrayList<>();
        String sql = "SELECT b.book_id, b.title, b.author, b.available_copies, COUNT(br.record_id) as borrow_count " +
                     "FROM books b " +
                     "LEFT JOIN borrow_records br ON b.book_id = br.book_id " +
                     "GROUP BY b.book_id, b.title, b.author, b.available_copies " +
                     "ORDER BY borrow_count DESC " +
                     "LIMIT ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, limit);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> book = new HashMap<>();
                book.put("book_id", rs.getInt("book_id"));
                book.put("title", rs.getString("title"));
                book.put("author", rs.getString("author"));
                book.put("available_copies", rs.getInt("available_copies"));
                book.put("borrow_count", rs.getInt("borrow_count"));
                popularBooks.add(book);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return popularBooks;
    }
    
    // 新增方法：获取活跃读者（借阅次数最多的读者）
    public List<Map<String, Object>> getActiveReaders(int limit) {
        List<Map<String, Object>> activeReaders = new ArrayList<>();
        String sql = "SELECT u.user_id, u.real_name, u.username, " +
                     "COUNT(br.record_id) as borrow_count, " +
                     "SUM(CASE WHEN br.status IN ('借阅中', '逾期') THEN 1 ELSE 0 END) as current_borrow " +
                     "FROM users u " +
                     "LEFT JOIN borrow_records br ON u.user_id = br.user_id " +
                     "WHERE u.user_type = 'reader' " +
                     "GROUP BY u.user_id, u.real_name, u.username " +
                     "ORDER BY borrow_count DESC " +
                     "LIMIT ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, limit);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> reader = new HashMap<>();
                reader.put("user_id", rs.getInt("user_id"));
                reader.put("real_name", rs.getString("real_name"));
                reader.put("username", rs.getString("username"));
                reader.put("borrow_count", rs.getInt("borrow_count"));
                reader.put("current_borrow", rs.getInt("current_borrow"));
                activeReaders.add(reader);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return activeReaders;
    }
    
    // 新增方法：获取总借阅记录数量
    public int getTotalBorrowRecordsCount() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM borrow_records";
        
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
    
    // 新增方法：获取当前借阅中数量
    public int getCurrentBorrowingCount() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM borrow_records WHERE status IN ('借阅中', '逾期')";
        
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
    
    // 新增方法：获取逾期记录数量
    public int getOverdueRecordsCount() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM borrow_records WHERE status = '逾期'";
        
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
    
    // 新增方法：获取总罚款金额
    public double getTotalFines() {
        double total = 0.0;
        String sql = "SELECT SUM(fine_amount) FROM borrow_records WHERE fine_amount > 0";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                total = rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }
}