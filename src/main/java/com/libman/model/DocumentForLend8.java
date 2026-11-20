package com.libman.model;

public class DocumentForLend8 {
    private int id;                 // id = mã tài liệu
    private String lendingStatus, physicalStatus;   // physicalStatus: NORMAL | WARPED | TORN
    private Document8 document;

    public int getId() { return id; }                       public void setId(int id) { this.id = id; }
    public String getLendingStatus() { return lendingStatus; } public void setLendingStatus(String v) { lendingStatus = v; }
    public String getPhysicalStatus() { return physicalStatus; } public void setPhysicalStatus(String v) { physicalStatus = v; }
    public Document8 getDocument() { return document; }     public void setDocument(Document8 v) { document = v; }

    public String getPhysicalStatusText() {
        if ("NORMAL".equals(physicalStatus)) return "Bình thường";
        if ("WARPED".equals(physicalStatus)) return "Cong vênh, méo mó";
        if ("TORN".equals(physicalStatus)) return "Rách, mất trang";
        return physicalStatus;
    }
}
