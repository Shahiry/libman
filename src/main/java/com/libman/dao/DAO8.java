package com.libman.dao;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/** Lớp cha của mọi DAO, giữ kết nối (conn). Dùng try-with-resources để tự đóng. */
public class DAO8 implements AutoCloseable {
    private static final Properties CFG = new Properties();
    static {
        try (InputStream in = DAO8.class.getResourceAsStream("/db.properties")) {
            CFG.load(in);
            Class.forName(CFG.getProperty("driver"));
        } catch (Exception e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    protected Connection conn;
    private final boolean ownsConnection;

    public DAO8() {
        try {
            conn = DriverManager.getConnection(CFG.getProperty("url"), CFG.getProperty("user"), CFG.getProperty("password"));
            ownsConnection = true;
        } catch (SQLException e) {
            throw new RuntimeException("Không kết nối được CSDL", e);
        }
    }

    /** Dùng chung kết nối của DAO khác (để chạy chung một transaction). */
    protected DAO8(Connection shared) { conn = shared; ownsConnection = false; }

    public Connection getConn() { return conn; }

    @Override
    public void close() {
        if (ownsConnection && conn != null) {
            try { conn.close(); } catch (SQLException ignored) { }
        }
    }
}
