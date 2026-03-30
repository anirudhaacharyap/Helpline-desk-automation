package com.helpdesk.dao;

import com.helpdesk.model.Comment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CommentDAO {

    private static final String COMMENT_COLUMN = "comment_text";

    // ── ADD COMMENT ──────────────────────────────────────────
    public boolean addComment(Comment c) {
        String sql = "INSERT INTO ticket_comments (ticket_id, user_id, " + COMMENT_COLUMN + ") VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, c.getTicketId());
            ps.setInt(2, c.getUserId());
            ps.setString(3, c.getComment());
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── GET BY TICKET ────────────────────────────────────────
    public List<Comment> getCommentsByTicket(int ticketId) {
        List<Comment> comments = new ArrayList<>();
        String sql = "SELECT c.comment_id, c.ticket_id, c.user_id, c." + COMMENT_COLUMN + ", " +
                "c.commented_at, u.name AS user_name FROM ticket_comments c " +
                "JOIN users u ON c.user_id = u.user_id " +
                "WHERE c.ticket_id = ? ORDER BY commented_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) comments.add(mapRow(rs));

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return comments;
    }

    // ── DELETE ────────────────────────────────────────────────
    public boolean deleteComment(int commentId) {
        String sql = "DELETE FROM ticket_comments WHERE comment_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, commentId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── PRIVATE: map ResultSet row → Comment object ──────────
    private Comment mapRow(ResultSet rs) throws SQLException {
        Comment c = new Comment();
        c.setCommentId(rs.getInt("comment_id"));
        c.setTicketId(rs.getInt("ticket_id"));
        c.setUserId(rs.getInt("user_id"));
        c.setUserName(rs.getString("user_name"));
        c.setComment(rs.getString(COMMENT_COLUMN));
        c.setCommentedAt(rs.getTimestamp("commented_at"));
        return c;
    }

    // ── QUICK TEST ───────────────────────────────────────────
    public static void main(String[] args) {
        CommentDAO dao = new CommentDAO();
        System.out.println("Comments for ticket 1: " + dao.getCommentsByTicket(1).size());
    }
}
