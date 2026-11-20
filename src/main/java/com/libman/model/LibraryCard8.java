package com.libman.model;

import java.sql.Date;
import java.time.LocalDate;

public class LibraryCard8 {
    private int id;                 // id = mã thẻ bạn đọc
    private String cardStatus;
    private Date dateOfIssue, expireDate;
    private Reader8 reader;

    public int getId() { return id; }                       public void setId(int id) { this.id = id; }
    public String getCardStatus() { return cardStatus; }    public void setCardStatus(String v) { cardStatus = v; }
    public Date getDateOfIssue() { return dateOfIssue; }    public void setDateOfIssue(Date v) { dateOfIssue = v; }
    public Date getExpireDate() { return expireDate; }      public void setExpireDate(Date v) { expireDate = v; }
    public Reader8 getReader() { return reader; }           public void setReader(Reader8 v) { reader = v; }

    /** Thông báo lỗi nếu thẻ không dùng được (kịch bản ngoại lệ 5.1, 5.2), null nếu hợp lệ. */
    public String validate(LocalDate today) {
        if (!"ACTIVE".equals(cardStatus)) {
            return "Thẻ bạn đọc đã bị vô hiệu hoá, xin hãy kiểm tra lại thẻ";
        }
        if ((dateOfIssue != null && today.isBefore(dateOfIssue.toLocalDate()))
                || (expireDate != null && today.isAfter(expireDate.toLocalDate()))) {
            return "Thẻ bạn đọc ngoài thời gian hiệu lực, xin hãy kiểm tra lại thẻ/gia hạn thẻ";
        }
        return null;
    }
}
