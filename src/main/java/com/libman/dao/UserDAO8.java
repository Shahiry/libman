package com.libman.dao;

import com.libman.model.User8;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO8 extends DAO8 {
    public User8 login(String username, String password) throws SQLException {
        String sql = "SELECT id, username, fullName, email, phoneNumber, avatar, role FROM tblUser WHERE username = ? AND password = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, sha256(password));
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                User8 u = new User8();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setFullName(rs.getString("fullName"));
                u.setEmail(rs.getString("email"));
                u.setPhoneNumber(rs.getString("phoneNumber"));
                u.setAvatar(rs.getString("avatar"));
                u.setRole(rs.getString("role"));
                return u;
            }
        }
    }

    static String sha256(String s) {
        try {
            StringBuilder sb = new StringBuilder();
            for (byte b : MessageDigest.getInstance("SHA-256").digest(s.getBytes(StandardCharsets.UTF_8))) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
