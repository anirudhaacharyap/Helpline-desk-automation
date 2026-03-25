package com.helpdesk.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class AuditDAO {

    /**
     * Log an audit event.
     * SQL: INSERT INTO audit_log (user_id, action, entity_type, entity_id) VALUES (?,?,?,?)
     *
     * @param userId     The user performing the action
     * @param action     The action performed (e.g. "TICKET_CREATED", "STATUS_CHANGED")
     * @param entityType The type of entity (e.g. "ticket", "user")
     * @param entityId   The ID of the entity
     */
    public void log(int userId, String action, String entityType, int entityId) {
        String sql = "INSERT INTO audit_log (user_id, action, entity_type, entity_id) VALUES (?, ?, ?, ?)";
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
