package com.helpdesk.dao;

import com.helpdesk.model.Ticket;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TicketDAO {

    /**
     * Helper to build a Ticket from a ResultSet row.
     */
    private Ticket mapRow(ResultSet rs) throws SQLException {
        Ticket t = new Ticket();
        t.setTicketId(rs.getInt("ticket_id"));
        t.setTitle(rs.getString("title"));
        t.setDescription(rs.getString("description"));
        t.setPriority(rs.getString("priority"));
        t.setStatus(rs.getString("status"));
        t.setCategory(rs.getString("category"));
        t.setCreatedBy(rs.getInt("created_by"));
        t.setAssignedTo(rs.getInt("assigned_to"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        t.setSlaDeadline(rs.getTimestamp("sla_deadline"));
        t.setResolvedAt(rs.getTimestamp("resolved_at"));
        t.setSlaBreached(rs.getBoolean("is_sla_breached"));
        return t;
    }

    /**
     * Insert a new ticket.
     * SQL: INSERT INTO tickets (title,description,priority,status,category,created_by,assigned_to,sla_deadline)
     *      VALUES (?,?,?,?,?,?,?,?)
     * Returns the new ticket ID, or -1 on failure.
     */
    public int insertTicket(Ticket t) {
        String sql = "INSERT INTO tickets (title, description, priority, status, category, " +
                     "created_by, assigned_to, sla_deadline) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, t.getTitle());
            ps.setString(2, t.getDescription());
            ps.setString(3, t.getPriority());
            ps.setString(4, t.getStatus());
            ps.setString(5, t.getCategory());
            ps.setInt(6, t.getCreatedBy());
            ps.setInt(7, t.getAssignedTo());
            ps.setTimestamp(8, t.getSlaDeadline());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                ResultSet keys = ps.getGeneratedKeys();
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Get a single ticket by ID.
     * SQL: SELECT * FROM tickets WHERE ticket_id=?
     */
    public Ticket getTicketById(int id) {
        String sql = "SELECT * FROM tickets WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get all tickets created by a specific user.
     * SQL: SELECT * FROM tickets WHERE created_by=? ORDER BY created_at DESC
     */
    public List<Ticket> getTicketsByUser(int userId) {
        List<Ticket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM tickets WHERE created_by = ? ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                tickets.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    /**
     * Get all tickets assigned to a specific agent.
     * SQL: SELECT * FROM tickets WHERE assigned_to=? AND status!='CLOSED'
     */
    public List<Ticket> getTicketsByAgent(int agentId) {
        List<Ticket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM tickets WHERE assigned_to = ? AND status != 'CLOSED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, agentId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                tickets.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    /**
     * Get all tickets, optionally filtered by status.
     * SQL: SELECT * FROM tickets WHERE status=? ORDER BY sla_deadline ASC
     * If statusFilter is null or empty, returns all tickets.
     */
    public List<Ticket> getAllTickets(String statusFilter) {
        List<Ticket> tickets = new ArrayList<>();
        String sql;
        boolean hasFilter = (statusFilter != null && !statusFilter.isEmpty());

        if (hasFilter) {
            sql = "SELECT * FROM tickets WHERE status = ? ORDER BY sla_deadline ASC";
        } else {
            sql = "SELECT * FROM tickets ORDER BY sla_deadline ASC";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (hasFilter) {
                ps.setString(1, statusFilter);
            }
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                tickets.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    /**
     * Update ticket status.
     * SQL: UPDATE tickets SET status=? WHERE ticket_id=?
     */
    public boolean updateStatus(int id, String status) {
        String sql = "UPDATE tickets SET status = ? WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Assign a ticket to an agent.
     * SQL: UPDATE tickets SET assigned_to=? WHERE ticket_id=?
     */
    public boolean assignTicket(int id, int agentId) {
        String sql = "UPDATE tickets SET assigned_to = ? WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, agentId);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Resolve a ticket — set status to RESOLVED and resolved_at to NOW().
     * SQL: UPDATE tickets SET status='RESOLVED', resolved_at=NOW() WHERE ticket_id=?
     */
    public boolean resolveTicket(int id) {
        String sql = "UPDATE tickets SET status = 'RESOLVED', resolved_at = NOW() WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Flag all SLA-breached tickets.
     * SQL: UPDATE tickets SET status='SLA_BREACHED' WHERE sla_deadline < NOW()
     *      AND status NOT IN ('RESOLVED','CLOSED')
     * Returns the count of tickets flagged.
     */
    public int flagSlaBreaches() {
        String sql = "UPDATE tickets SET status = 'SLA_BREACHED' WHERE sla_deadline < NOW() " +
                     "AND status NOT IN ('RESOLVED', 'CLOSED')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            return ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * Get ticket counts grouped by priority.
     * SQL: SELECT priority, COUNT(*) FROM tickets GROUP BY priority
     */
    public Map<String, Integer> getTicketCountByPriority() {
        Map<String, Integer> counts = new HashMap<>();
        String sql = "SELECT priority, COUNT(*) AS cnt FROM tickets GROUP BY priority";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                counts.put(rs.getString("priority"), rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return counts;
    }

    /**
     * Get the count of open tickets.
     * SQL: SELECT COUNT(*) FROM tickets WHERE status='OPEN'
     */
    public int getOpenTicketCount() {
        String sql = "SELECT COUNT(*) AS cnt FROM tickets WHERE status = 'OPEN'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt("cnt");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get count of tickets by status.
     */
    public int getTicketCountByStatus(String status) {
        String sql = "SELECT COUNT(*) AS cnt FROM tickets WHERE status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("cnt");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get count of tickets resolved today.
     */
    public int getResolvedTodayCount() {
        String sql = "SELECT COUNT(*) AS cnt FROM tickets WHERE status = 'RESOLVED' " +
                     "AND resolved_at >= CURRENT_DATE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt("cnt");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get count of SLA-breached tickets.
     */
    public int getSlaBreachedCount() {
        String sql = "SELECT COUNT(*) AS cnt FROM tickets WHERE status = 'SLA_BREACHED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt("cnt");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
