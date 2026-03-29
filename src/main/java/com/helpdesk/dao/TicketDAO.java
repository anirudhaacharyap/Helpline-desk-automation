package com.helpdesk.dao;

import com.helpdesk.model.Ticket;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TicketDAO {

    // ── INSERT ───────────────────────────────────────────────
    public int insertTicket(Ticket t) {
        String sql = "INSERT INTO tickets (title, description, priority, status, category, " +
                "created_by, assigned_to, sla_deadline) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        String[] returnCols = {"ticket_id"};
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, returnCols)) {

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
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    // ── GET BY ID ────────────────────────────────────────────
    public Ticket getTicketById(int id) {
        String sql = "SELECT * FROM tickets WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ── GET BY USER ──────────────────────────────────────────
    public List<Ticket> getTicketsByUser(int userId) {
        List<Ticket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM tickets WHERE created_by = ? ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) tickets.add(mapRow(rs));

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    // ── GET BY AGENT ─────────────────────────────────────────
    public List<Ticket> getTicketsByAgent(int agentId) {
        List<Ticket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM tickets WHERE assigned_to = ? AND status != 'CLOSED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, agentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) tickets.add(mapRow(rs));

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    // ── GET ALL (optional status filter) ─────────────────────
    public List<Ticket> getAllTickets(String statusFilter) {
        List<Ticket> tickets = new ArrayList<>();
        boolean hasFilter = (statusFilter != null && !statusFilter.isEmpty());
        String sql = hasFilter
                ? "SELECT * FROM tickets WHERE status = ? ORDER BY sla_deadline ASC"
                : "SELECT * FROM tickets ORDER BY sla_deadline ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (hasFilter) ps.setString(1, statusFilter);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) tickets.add(mapRow(rs));

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    // ── UPDATE STATUS ────────────────────────────────────────
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

    // ── ASSIGN ───────────────────────────────────────────────
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

    // ── RESOLVE ──────────────────────────────────────────────
    public boolean resolveTicket(int id) {
        String sql = "UPDATE tickets SET status = 'RESOLVED', resolved_at = SYSDATE WHERE ticket_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── FLAG SLA BREACHES ────────────────────────────────────
    public int flagSlaBreaches() {
        String sql = "UPDATE tickets SET status = 'SLA_BREACHED' WHERE sla_deadline < SYSDATE " +
                "AND status NOT IN ('RESOLVED', 'CLOSED')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            return ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ── COUNT BY PRIORITY ────────────────────────────────────
    public Map<String, Integer> getTicketCountByPriority() {
        Map<String, Integer> counts = new HashMap<>();
        String sql = "SELECT priority, COUNT(*) AS cnt FROM tickets GROUP BY priority";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) counts.put(rs.getString("priority"), rs.getInt("cnt"));

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return counts;
    }

    // ── OPEN COUNT ───────────────────────────────────────────
    public int getOpenTicketCount() {
        return getTicketCountByStatus("OPEN");
    }

    // ── COUNT BY STATUS ──────────────────────────────────────
    public int getTicketCountByStatus(String status) {
        String sql = "SELECT COUNT(*) AS cnt FROM tickets WHERE status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("cnt");

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ── RESOLVED TODAY ───────────────────────────────────────
    public int getResolvedTodayCount() {
        String sql = "SELECT COUNT(*) AS cnt FROM tickets WHERE status = 'RESOLVED' " +
                "AND resolved_at >= TRUNC(SYSDATE)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getInt("cnt");

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ── SLA BREACHED COUNT ───────────────────────────────────
    public int getSlaBreachedCount() {
        return getTicketCountByStatus("SLA_BREACHED");
    }

    // ── PRIVATE: map ResultSet row → Ticket object ───────────
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
        t.setSlaBreached(rs.getInt("is_sla_breached") == 1);
        return t;
    }

    // ── QUICK TEST ───────────────────────────────────────────
    public static void main(String[] args) {
        TicketDAO dao = new TicketDAO();
        System.out.println("All tickets : " + dao.getAllTickets(null).size());
        System.out.println("Open count  : " + dao.getOpenTicketCount());
        System.out.println("By priority : " + dao.getTicketCountByPriority());
        System.out.println("SLA breached: " + dao.getSlaBreachedCount());
    }
}
