package com.helpdesk.dao;

import com.helpdesk.model.Comment;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CommentDAO {

    /**
     * Add a comment to a ticket.
     * SQL: INSERT INTO ticket_comments (ticket_id, user_id, comment) VALUES (?,?,?)
     */
    public boolean addComment(Comment c) {
        String sql = "INSERT INTO ticket_comments (ticket_id, user_id, comment) VALUES (?, ?, ?)";
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

    /**
     * Get all comments for a ticket, with user name joined.
     * SQL: SELECT c.*, u.name as user_name FROM ticket_comments c
     *      JOIN users u ON c.user_id=u.user_id
     *      WHERE c.ticket_id=? ORDER BY commented_at ASC
     */
    public List<Comment> getCommentsByTicket(int ticketId) {
        List<Comment> comments = new ArrayList<>();
        String sql = "SELECT c.*, u.name AS user_name FROM ticket_comments c " +
                     "JOIN users u ON c.user_id = u.user_id " +
                     "WHERE c.ticket_id = ? ORDER BY commented_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Comment comment = new Comment();
                comment.setCommentId(rs.getInt("comment_id"));
                comment.setTicketId(rs.getInt("ticket_id"));
                comment.setUserId(rs.getInt("user_id"));
                comment.setUserName(rs.getString("user_name"));
                comment.setComment(rs.getString("comment"));
                comment.setCommentedAt(rs.getTimestamp("commented_at"));
                comments.add(comment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return comments;
    }

    /**
     * Delete a comment by ID.
     * SQL: DELETE FROM ticket_comments WHERE comment_id=?
     */
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
}
