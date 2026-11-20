package com.libman.dao;

import com.libman.model.Document8;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DocumentDAO8 extends DAO8 {

    /** Tìm tài liệu có tên chứa từ khoá. */
    public List<Document8> searchByName(String keyword) throws SQLException {
        String like = "%" + keyword.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%";
        List<Document8> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT * FROM tblDocument WHERE name LIKE ? ORDER BY name, publicYear")) {
            ps.setString(1, like);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs, "id"));
            }
        }
        return list;
    }

    /** Thông tin chi tiết một tài liệu, null nếu không có. */
    public Document8 getDetail(int idDocument) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT * FROM tblDocument WHERE id = ?")) {
            ps.setInt(1, idDocument);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs, "id") : null;
            }
        }
    }

    static Document8 map(ResultSet rs, String idColumn) throws SQLException {
        Document8 d = new Document8();
        d.setId(rs.getInt(idColumn));
        d.setCoverPicture(rs.getString("coverPicture"));
        d.setName(rs.getString("name"));
        d.setType(rs.getString("type"));
        d.setAuthor(rs.getString("author"));
        d.setPublicYear(rs.getInt("publicYear"));
        d.setPublicHouse(rs.getString("publicHouse"));
        d.setDescription(rs.getString("description"));
        d.setQuantity(rs.getInt("quantity"));
        d.setBorrowDuration(rs.getInt("borrowDuration"));
        return d;
    }
}
