package com.libman.model;

import java.sql.Date;

public class BorrowingSlipDetail8 {
    private int id;
    private Date returnDeadline;
    private BorrowingSlip8 borrowingSlip;
    private DocumentForLend8 documentForLend;

    public int getId() { return id; }                       public void setId(int id) { this.id = id; }
    public Date getReturnDeadline() { return returnDeadline; } public void setReturnDeadline(Date v) { returnDeadline = v; }
    public BorrowingSlip8 getBorrowingSlip() { return borrowingSlip; } public void setBorrowingSlip(BorrowingSlip8 v) { borrowingSlip = v; }
    public DocumentForLend8 getDocumentForLend() { return documentForLend; }
    public void setDocumentForLend(DocumentForLend8 v) { documentForLend = v; }
}
