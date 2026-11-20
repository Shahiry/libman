package com.libman.model;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

public class BorrowingSlip8 {
    private int id;                 // id = mã phiếu mượn; 0 nghĩa là chưa lưu
    private Date borrowDate;
    private Reader8 reader;
    private Librarian8 librarian;
    private List<BorrowingSlipDetail8> details = new ArrayList<>();   // để hiển thị/in phiếu

    public int getId() { return id; }                       public void setId(int id) { this.id = id; }
    public Date getBorrowDate() { return borrowDate; }      public void setBorrowDate(Date v) { borrowDate = v; }
    public Reader8 getReader() { return reader; }           public void setReader(Reader8 v) { reader = v; }
    public Librarian8 getLibrarian() { return librarian; }  public void setLibrarian(Librarian8 v) { librarian = v; }
    public List<BorrowingSlipDetail8> getDetails() { return details; }
    public void setDetails(List<BorrowingSlipDetail8> v) { details = v; }
}
