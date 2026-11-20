package com.libman.dao;

import com.libman.model.BorrowingSlip8;
import com.libman.model.BorrowingSlipDetail8;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;

public class BorrowingSlipDetailDAO8 extends DAO8 {

    /**
     * Lưu phiếu mượn (lấy từ BorrowingSlip8 của các chi tiết) rồi lưu từng chi tiết.
     * Gán id phiếu và id chi tiết sau khi lưu. Không tự commit.
     */
    public void saveBorrowingSlipDetail(List<BorrowingSlipDetail8> BRSlipDetail) throws SQLException {
        BorrowingSlip8 slip = BRSlipDetail.get(0).getBorrowingSlip();
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO tblBorrowingSlip (borrowDate, tblReadertblUserid, tblLibrariantblUserid) VALUES (?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS)) {
            ps.setDate(1, slip.getBorrowDate());
            ps.setInt(2, slip.getReader().getId());
            ps.setInt(3, slip.getLibrarian().getId());
            ps.executeUpdate();
            try (ResultSet k = ps.getGeneratedKeys()) { k.next(); slip.setId(k.getInt(1)); }
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO tblBorrowSlipDetail (returnDeadline, tblBorrowingSlipid, tblDocumentForLendid) VALUES (?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS)) {
            for (BorrowingSlipDetail8 d : BRSlipDetail) {
                ps.setDate(1, d.getReturnDeadline());
                ps.setInt(2, slip.getId());
                ps.setInt(3, d.getDocumentForLend().getId());
                ps.executeUpdate();
                try (ResultSet k = ps.getGeneratedKeys()) { k.next(); d.setId(k.getInt(1)); }
            }
        }
    }
}
