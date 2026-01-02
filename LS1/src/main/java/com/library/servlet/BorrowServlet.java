package com.library.servlet;

import com.library.dao.BookDAO;
import com.library.dao.BorrowRecordDAO;
import com.library.model.BorrowRecord;
import com.library.model.User;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.Date;
import java.util.Calendar;
import java.util.List;

@WebServlet("/BorrowServlet")
public class BorrowServlet extends HttpServlet {
    private BookDAO bookDAO;
    private BorrowRecordDAO borrowRecordDAO;
    
    @Override
    public void init() {
        bookDAO = new BookDAO();
        borrowRecordDAO = new BorrowRecordDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        String userType = user.getUserType();
        
        try {
            if ("borrow".equals(action)) {
                // 借阅图书
                int bookId = Integer.parseInt(request.getParameter("bookId"));
                
                // 检查用户是否已借阅太多书（限制：读者最多借5本）
                int currentBorrowCount = borrowRecordDAO.getCurrentBorrowCount(user.getUserId());
                if ("reader".equals(userType) && currentBorrowCount >= 5) {
                    session.setAttribute("error", "您已达到最大借阅数量（5本），请先归还部分图书。");
                    response.sendRedirect("reader/search.jsp");
                    return;
                }
                
                // 检查图书是否可借
                if (bookDAO.borrowBook(bookId)) {
                    // 创建借阅记录
                    Date borrowDate = new Date();
                    Calendar calendar = Calendar.getInstance();
                    calendar.setTime(borrowDate);
                    calendar.add(Calendar.DAY_OF_YEAR, 30); // 借期30天
                    Date dueDate = calendar.getTime();
                    
                    BorrowRecord record = new BorrowRecord(user.getUserId(), bookId, borrowDate, dueDate);
                    boolean success = borrowRecordDAO.addBorrowRecord(record);
                    
                    if (success) {
                        session.setAttribute("success", "借阅成功！请按时归还。");
                        response.sendRedirect("reader/records.jsp");
                    } else {
                        // 如果添加记录失败，回滚图书库存
                        bookDAO.returnBook(bookId);
                        session.setAttribute("error", "借阅记录创建失败，请重试。");
                        response.sendRedirect("reader/search.jsp");
                    }
                } else {
                    session.setAttribute("error", "借阅失败，该书可能已被借完或不存在。");
                    response.sendRedirect("reader/search.jsp");
                }
                
            } else if ("return".equals(action)) {
                // 归还图书
                int recordId = Integer.parseInt(request.getParameter("recordId"));
                String bookIdStr = request.getParameter("bookId");
                
                if (borrowRecordDAO.returnBook(recordId)) {
                    // 更新图书库存
                    if (bookIdStr != null) {
                        int bookId = Integer.parseInt(bookIdStr);
                        bookDAO.returnBook(bookId);
                    }
                    
                    // 计算并显示罚款
                    BorrowRecord record = borrowRecordDAO.getBorrowRecordById(recordId);
                    if (record != null && record.getFineAmount() > 0) {
                        session.setAttribute("success", "归还成功！罚款金额：¥" + 
                                             String.format("%.2f", record.getFineAmount()));
                    } else {
                        session.setAttribute("success", "归还成功！");
                    }
                } else {
                    session.setAttribute("error", "归还失败，请重试。");
                }
                
                if ("admin".equals(user.getUserType())) {
                    response.sendRedirect("admin/borrow_management.jsp");
                } else {
                    response.sendRedirect("reader/records.jsp");
                }
                
            } else if ("renew".equals(action)) {
                // 续借图书
                int recordId = Integer.parseInt(request.getParameter("recordId"));
                
                // 获取当前借阅记录
                BorrowRecord currentRecord = borrowRecordDAO.getBorrowRecordById(recordId);
                if (currentRecord == null) {
                    session.setAttribute("error", "借阅记录不存在");
                    response.sendRedirect("reader/records.jsp");
                    return;
                }
                
                // 检查是否可以续借
                if (!borrowRecordDAO.canRenewBook(recordId)) {
                    session.setAttribute("error", "续借失败，您已经续借过一次或该书不可续借。");
                    response.sendRedirect("reader/records.jsp");
                    return;
                }
                
                // 计算新的到期日期（在原到期日期基础上续借30天）
                Calendar calendar = Calendar.getInstance();
                calendar.setTime(currentRecord.getDueDate());
                calendar.add(Calendar.DAY_OF_YEAR, 30);
                Date newDueDate = calendar.getTime();
                
                if (borrowRecordDAO.renewBook(recordId, newDueDate)) {
                    session.setAttribute("success", "续借成功！新的到期日期为：" + 
                                         new java.text.SimpleDateFormat("yyyy-MM-dd").format(newDueDate));
                } else {
                    session.setAttribute("error", "续借失败，请重试。");
                }
                
                response.sendRedirect("reader/records.jsp");
                
            } else if ("calculateFine".equals(action)) {
                // 计算罚款
                int recordId = Integer.parseInt(request.getParameter("recordId"));
                double fine = borrowRecordDAO.calculateFine(recordId);
                
                if (fine > 0) {
                    session.setAttribute("success", "罚款计算完成：¥" + String.format("%.2f", fine));
                } else {
                    session.setAttribute("info", "没有逾期罚款");
                }
                
                response.sendRedirect("admin/borrow_management.jsp");
                
            } else {
                // 默认跳转
                if ("admin".equals(user.getUserType())) {
                    response.sendRedirect("admin/dashboard.jsp");
                } else {
                    response.sendRedirect("reader/dashboard.jsp");
                }
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
            session.setAttribute("error", "参数错误：" + e.getMessage());
            response.sendRedirect("reader/dashboard.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "操作失败：" + e.getMessage());
            response.sendRedirect("reader/dashboard.jsp");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}