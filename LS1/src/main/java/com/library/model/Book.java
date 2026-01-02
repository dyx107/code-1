package com.library.model;

import java.util.Date;

public class Book {
    private int bookId;
    private String isbn;
    private String title;
    private String author;
    private String publisher;
    private int publishYear;
    private String category;
    private int totalCopies;
    private int availableCopies;
    private String location;
    private String description;
    private String coverImage;
    private Date addDate;
    
    // 构造方法
    public Book() {}
    
    public Book(String isbn, String title, String author, String publisher, 
                int publishYear, String category, int totalCopies) {
        this.isbn = isbn;
        this.title = title;
        this.author = author;
        this.publisher = publisher;
        this.publishYear = publishYear;
        this.category = category;
        this.totalCopies = totalCopies;
        this.availableCopies = totalCopies;
    }
    
    // Getter和Setter方法
    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }
    
    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }
    
    public String getPublisher() { return publisher; }
    public void setPublisher(String publisher) { this.publisher = publisher; }
    
    public int getPublishYear() { return publishYear; }
    public void setPublishYear(int publishYear) { this.publishYear = publishYear; }
    
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public int getTotalCopies() { return totalCopies; }
    public void setTotalCopies(int totalCopies) { 
        this.totalCopies = totalCopies; 
    }
    
    public int getAvailableCopies() { return availableCopies; }
    public void setAvailableCopies(int availableCopies) { 
        this.availableCopies = availableCopies; 
    }
    
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getCoverImage() { return coverImage; }
    public void setCoverImage(String coverImage) { this.coverImage = coverImage; }
    
    public Date getAddDate() { return addDate; }
    public void setAddDate(Date addDate) { this.addDate = addDate; }
}