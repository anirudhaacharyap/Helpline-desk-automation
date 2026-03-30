package com.helpdesk.dao;

import java.sql.*;

public class AuditDAO {

    // ── LOG AUDIT EVENT ──────────────────────────────────────
    public void log(int userId, String action, String entityType, int entityId) {
        String sql = "INSERT INTO audit_log (user_id, action, entity_type, entity_id) " +
                "VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, action);
            ps.setString(3, entityType);
            ps.setInt(4, entityId);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
