package com.libman.dao;

import com.libman.model.DocumentForLend8;
import com.libman.model.LibraryCard8;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DocumentForLendDAO8 extends DAO8 {
    private static final String SEL =
            "SELECT f.id AS fid, f.lendingStatus, f.physicalStatus, "
            + "d.id AS did, d.coverPicture, d.name, d.type, d.author, d.publicYear, d.publicHouse, "
            + "d.description, d.quantity, d.borrowDuration "
            + "FROM tblDocumentForLend f JOIN tblDocument d ON f.tblDocumentid = d.id ";

    public DocumentForLendDAO8() { super(); }
    public DocumentForLendDAO8(Connection shared) { super(shared); }

    /** Tìm bản tài liệu theo mã (= id). Null nếu không có hoặc mã không hợp lệ. */
    public DocumentForLend8 searchByCode8(String keyword1) throws SQLException {
        Integer id = parseCodeToInt(keyword1);
        if (id == null) return null;
        try (PreparedStatement ps = conn.prepareStatement(SEL + "WHERE f.id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    /** Các tài liệu bạn đọc (chủ thẻ) đã mượn nhưng chưa trả (chưa có chi tiết phiếu trả). */
    public List<DocumentForLend8> getBorrowedDocumentByLibraryCard8(LibraryCard8 card) throws SQLException {
        String sql = SEL
                + "JOIN tblBorrowSlipDetail bd ON bd.tblDocumentForLendid = f.id "
                + "JOIN tblBorrowingSlip s ON s.id = bd.tblBorrowingSlipid "
                + "WHERE s.tblReadertblUserid = ? AND NOT EXISTS "
                + "(SELECT 1 FROM tblReturnSlipDetail r WHERE r.tblBorrowSlipDetailid = bd.id)";
        List<DocumentForLend8> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, card.getReader().getId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    /** Đặt trạng thái mượn và giảm số lượng hiện có. Không tự commit (caller quản lý transaction). */
    public boolean updateLendingStatusAndQuantity8(List<DocumentForLend8> document) throws SQLException {
        try (PreparedStatement p1 = conn.prepareStatement("UPDATE tblDocumentForLend SET lendingStatus = 'BORROWED' WHERE id = ?");
             PreparedStatement p2 = conn.prepareStatement("UPDATE tblDocument SET quantity = quantity - 1 WHERE id = ?")) {
            for (DocumentForLend8 f : document) {
                p1.setInt(1, f.getId());
                p1.executeUpdate();
                p2.setInt(1, f.getDocument().getId());
                p2.executeUpdate();
            }
        }
        return true;
    }

    private static DocumentForLend8 map(ResultSet rs) throws SQLException {
        DocumentForLend8 f = new DocumentForLend8();
        f.setId(rs.getInt("fid"));
        f.setLendingStatus(rs.getString("lendingStatus"));
        f.setPhysicalStatus(rs.getString("physicalStatus"));
        f.setDocument(DocumentDAO8.map(rs, "did"));
        return f;
    }
}
