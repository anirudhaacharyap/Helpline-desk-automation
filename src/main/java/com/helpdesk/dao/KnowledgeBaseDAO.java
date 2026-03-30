package com.helpdesk.dao;

import com.helpdesk.model.KnowledgeBase;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class KnowledgeBaseDAO {

    // ── SEARCH BY KEYWORD ────────────────────────────────────
    public List<KnowledgeBase> searchByKeyword(String term) {
        List<KnowledgeBase> results = new ArrayList<>();
        String sql = "SELECT * FROM (SELECT * FROM knowledge_base WHERE keyword LIKE ? OR solution LIKE ?) " +
                "WHERE ROWNUM <= 3";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String pattern = "%" + term + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) results.add(mapRow(rs));

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return results;
    }

    // ── GET ALL BY CATEGORY ──────────────────────────────────
    public List<KnowledgeBase> getAllByCategory(String category) {
        List<KnowledgeBase> results = new ArrayList<>();
        String sql = "SELECT * FROM knowledge_base WHERE category = ? ORDER BY view_count DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, category);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) results.add(mapRow(rs));

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return results;
    }

    // ── GET ALL ──────────────────────────────────────────────
    public List<KnowledgeBase> getAll() {
        List<KnowledgeBase> results = new ArrayList<>();
        String sql = "SELECT * FROM knowledge_base ORDER BY view_count DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) results.add(mapRow(rs));

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return results;
    }

    // ── INCREMENT VIEW COUNT ─────────────────────────────────
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

    // ── INSERT ───────────────────────────────────────────────
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

    // ── PRIVATE: map ResultSet row → KnowledgeBase object ────
    private KnowledgeBase mapRow(ResultSet rs) throws SQLException {
        KnowledgeBase kb = new KnowledgeBase();
        kb.setKbId(rs.getInt("kb_id"));
        kb.setKeyword(rs.getString("keyword"));
        kb.setSolution(rs.getString("solution"));
        kb.setCategory(rs.getString("category"));
        kb.setViewCount(rs.getInt("view_count"));
        return kb;
    }



}
