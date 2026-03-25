package com.helpdesk.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL  = "jdbc:postgresql://localhost:5432/helpdesk_db";
    private static final String USER = "postgres";
    private static final String PASS = "changeme";

    /**
     * Returns a fresh JDBC Connection each call.
     * Uses try-with-resources pattern at call site.
     */
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("PostgreSQL Driver not found in WEB-INF/lib!", e);
        }
        return DriverManager.getConnection(URL, USER, PASS);
    }

    /**
     * Quick test — run this main() to verify DB connection works.
     */
    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            System.out.println("Connected!");
        } catch (SQLException e) {
            System.err.println("Connection failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
