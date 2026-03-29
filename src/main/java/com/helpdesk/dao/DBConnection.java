package com.helpdesk.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // Oracle XE default port is 1521
    // "XE" is the service name for Oracle Express Edition
    private static final String URL  =
            "jdbc:oracle:thin:@localhost:1521:XE";
    private static final String USER = "helpdesk_user";   // or your Oracle username
    private static final String PASS = "helpdesk123";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Oracle JDBC Driver not found", e);
        }
        return DriverManager.getConnection(URL, USER, PASS);
    }

    public static void main(String[] args) throws SQLException {
        Connection conn = getConnection();
        System.out.println("Connected to Oracle XE!");
        conn.close();
    }
}