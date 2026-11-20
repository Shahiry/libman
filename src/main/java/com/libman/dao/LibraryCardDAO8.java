package com.libman.dao;

import com.libman.model.LibraryCard8;
import com.libman.model.Reader8;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class LibraryCardDAO8 extends DAO8 {

    /** Tìm thẻ bạn đọc theo mã thẻ (= id). Null nếu không có hoặc mã không phải số. */
    public LibraryCard8 searchByCode(String keyword0) throws SQLException {
        int id;
        try { id = Integer.parseInt(keyword0.trim()); } catch (NumberFormatException e) { return null; }
        String sql = "SELECT c.id, c.cardStatus, c.dateOfIssue, c.expireDate, "
                + "u.id AS uid, u.fullName, u.avatar, r.studentCode, r.classCode "
                + "FROM tblLibraryCard c JOIN tblReader r ON c.tblReadertblUserid = r.tblUserid "
                + "JOIN tblUser u ON u.id = r.tblUserid WHERE c.id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Reader8 r = new Reader8();
                r.setId(rs.getInt("uid"));
                r.setFullName(rs.getString("fullName"));
                r.setAvatar(rs.getString("avatar"));
                r.setStudentCode(rs.getString("studentCode"));
                r.setClassCode(rs.getString("classCode"));
                LibraryCard8 c = new LibraryCard8();
                c.setId(rs.getInt("id"));
                c.setCardStatus(rs.getString("cardStatus"));
                c.setDateOfIssue(rs.getDate("dateOfIssue"));
                c.setExpireDate(rs.getDate("expireDate"));
                c.setReader(r);
                return c;
            }
        }
    }
}
