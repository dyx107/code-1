package com.library.model;

import java.util.Date;

public class BorrowRecord {
    private int recordId;
    private int userId;
    private int bookId;
    private Date borrowDate;
    private Date dueDate;
    private Date returnDate;
    private String status;
    private double fineAmount;
    private String userName;
    private String bookTitle;
    private int renewCount;
    
    public BorrowRecord() {}
    
    public BorrowRecord(int userId, int bookId, Date borrowDate, Date dueDate) {
        this.userId = userId;
        this.bookId = bookId;
        this.borrowDate = borrowDate;
        this.dueDate = dueDate;
        this.status = "借阅中";
        this.renewCount = 0;
    }
    
    // Getter和Setter方法
    public int getRecordId() { return recordId; }
    public void setRecordId(int recordId) { this.recordId = recordId; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }
    
    public Date getBorrowDate() { return borrowDate; }
    public void setBorrowDate(Date borrowDate) { this.borrowDate = borrowDate; }
    
    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }
    
    public Date getReturnDate() { return returnDate; }
    public void setReturnDate(Date returnDate) { this.returnDate = returnDate; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public double getFineAmount() { return fineAmount; }
    public void setFineAmount(double fineAmount) { this.fineAmount = fineAmount; }
    
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    
    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }
    
    public int getRenewCount() { return renewCount; }
    public void setRenewCount(int renewCount) { this.renewCount = renewCount; }
}