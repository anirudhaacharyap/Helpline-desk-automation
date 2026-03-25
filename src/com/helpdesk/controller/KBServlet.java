package com.helpdesk.controller;

import com.helpdesk.dao.KnowledgeBaseDAO;
import com.helpdesk.model.KnowledgeBase;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/kb/search")
public class KBServlet extends HttpServlet {

    /**
     * GET /kb/search?q={query} → AJAX endpoint that returns JSON array of KB suggestions.
     * Per LLD Section 4.3.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");

        String query = req.getParameter("q");

        if (query == null || query.trim().length() < 3) {
            res.getWriter().write("[]"); // too short — return empty
            return;
        }

        List<KnowledgeBase> results =
            new KnowledgeBaseDAO().searchByKeyword(query.trim());

        // Build JSON manually (no external library needed)
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < results.size(); i++) {
            KnowledgeBase kb = results.get(i);
            json.append("{")
               .append("\"kbId\":").append(kb.getKbId()).append(",")
               .append("\"keyword\":\"").append(escape(kb.getKeyword())).append("\",")
               .append("\"solution\":\"").append(escape(kb.getSolution())).append("\",")
               .append("\"category\":\"").append(escape(kb.getCategory())).append("\"")
               .append("}");
            if (i < results.size() - 1) json.append(",");
        }
        json.append("]");

        res.getWriter().write(json.toString());
    }

    /**
     * POST /kb/search → handles view count increment (AJAX).
     * Called as POST /kb/search?action=view&id={kbId}
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");

        String idParam = req.getParameter("id");
        if (idParam != null) {
            try {
                int kbId = Integer.parseInt(idParam);
                new KnowledgeBaseDAO().incrementViewCount(kbId);
                res.getWriter().write("{\"status\":\"ok\"}");
            } catch (NumberFormatException e) {
                res.getWriter().write("{\"status\":\"error\"}");
            }
        } else {
            res.getWriter().write("{\"status\":\"error\"}");
        }
    }

    /**
     * Escape special characters for JSON strings.
     */
    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "")
                .replace("\t", "\\t");
    }
}
