package com.helpdesk.dao;

import com.helpdesk.model.KnowledgeBase;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class KnowledgeBaseDAO {

    /**
     * Search KB entries by keyword (matches keyword or solution fields).
     * SQL: SELECT * FROM knowledge_base WHERE keyword LIKE ? OR solution LIKE ? LIMIT 3
     */
    public List<KnowledgeBase> searchByKeyword(String term) {
        List<KnowledgeBase> results = new ArrayList<>();
        String sql = "SELECT * FROM knowledge_base WHERE keyword LIKE ? OR solution LIKE ? LIMIT 3";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String pattern = "%" + term + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                KnowledgeBase kb = new KnowledgeBase();
                kb.setKbId(rs.getInt("kb_id"));
                kb.setKeyword(rs.getString("keyword"));
                kb.setSolution(rs.getString("solution"));
                kb.setCategory(rs.getString("category"));
                kb.setViewCount(rs.getInt("view_count"));
                results.add(kb);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return results;
    }

    /**
     * Get all KB entries by category.
     * SQL: SELECT * FROM knowledge_base WHERE category=? ORDER BY view_count DESC
     */
    public List<KnowledgeBase> getAllByCategory(String category) {
        List<KnowledgeBase> results = new ArrayList<>();
        String sql = "SELECT * FROM knowledge_base WHERE category = ? ORDER BY view_count DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, category);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                KnowledgeBase kb = new KnowledgeBase();
                kb.setKbId(rs.getInt("kb_id"));
                kb.setKeyword(rs.getString("keyword"));
                kb.setSolution(rs.getString("solution"));
                kb.setCategory(rs.getString("category"));
                kb.setViewCount(rs.getInt("view_count"));
                results.add(kb);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return results;
    }

    /**
     * Get all KB entries.
     * SQL: SELECT * FROM knowledge_base ORDER BY view_count DESC
     */
    public List<KnowledgeBase> getAll() {
        List<KnowledgeBase> results = new ArrayList<>();
        String sql = "SELECT * FROM knowledge_base ORDER BY view_count DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                KnowledgeBase kb = new KnowledgeBase();
                kb.setKbId(rs.getInt("kb_id"));
                kb.setKeyword(rs.getString("keyword"));
                kb.setSolution(rs.getString("solution"));
                kb.setCategory(rs.getString("category"));
                kb.setViewCount(rs.getInt("view_count"));
                results.add(kb);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return results;
    }

    /**
     * Increment the view count for a KB entry.
     * SQL: UPDATE knowledge_base SET view_count = view_count + 1 WHERE kb_id=?
     */
    public void incrementViewCount(int kbId) {
        String sql = "UPDATE knowledge_base SET view_count = view_count + 1 WHERE kb_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, kbId);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Insert a new KB entry.
     * SQL: INSERT INTO knowledge_base (keyword,solution,category) VALUES (?,?,?)
     */
    public boolean insertEntry(KnowledgeBase kb) {
        String sql = "INSERT INTO knowledge_base (keyword, solution, category) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, kb.getKeyword());
            ps.setString(2, kb.getSolution());
            ps.setString(3, kb.getCategory());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
