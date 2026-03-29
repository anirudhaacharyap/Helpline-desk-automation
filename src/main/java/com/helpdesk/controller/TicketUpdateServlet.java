package com.helpdesk.controller;

import com.helpdesk.dao.AuditDAO;
import com.helpdesk.dao.CommentDAO;
import com.helpdesk.dao.TicketDAO;
import com.helpdesk.model.Comment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/ticket/update")
public class TicketUpdateServlet extends HttpServlet {

    /**
     * GET — not used, redirect to ticket list.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        res.sendRedirect(req.getContextPath() + "/tickets");
    }

    /**
     * POST /ticket/update → handle ticket updates.
     * Params: ticketId, action (addComment | changeStatus | assign)
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Security guard
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String userRole = (String) session.getAttribute("userRole");

        String action = req.getParameter("action");
        int ticketId;

        try {
            ticketId = Integer.parseInt(req.getParameter("ticketId"));
        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/tickets?error=Invalid+ticket+ID");
            return;
        }

        TicketDAO ticketDAO = new TicketDAO();
        AuditDAO auditDAO = new AuditDAO();

        if ("addComment".equals(action)) {
            // Add a comment
            String commentText = req.getParameter("comment");
            if (commentText != null && !commentText.trim().isEmpty()) {
                Comment comment = new Comment();
                comment.setTicketId(ticketId);
                comment.setUserId(userId);
                comment.setComment(commentText.trim());

                new CommentDAO().addComment(comment);
                auditDAO.log(userId, "COMMENT_ADDED", "ticket", ticketId);
            }

        } else if ("changeStatus".equals(action)) {
            // Change ticket status — only agents and admins
            if (!"agent".equals(userRole) && !"admin".equals(userRole)) {
                res.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            String newStatus = req.getParameter("newStatus");
            if (newStatus != null && !newStatus.trim().isEmpty()) {
                if ("RESOLVED".equals(newStatus)) {
                    ticketDAO.resolveTicket(ticketId);
                } else {
                    ticketDAO.updateStatus(ticketId, newStatus);
                }
                auditDAO.log(userId, "STATUS_CHANGED", "ticket", ticketId);
            }

        } else if ("assign".equals(action)) {
            // Assign ticket to agent — admin only
            if (!"admin".equals(userRole)) {
                res.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            try {
                int agentId = Integer.parseInt(req.getParameter("agentId"));
                ticketDAO.assignTicket(ticketId, agentId);
                auditDAO.log(userId, "TICKET_ASSIGNED", "ticket", ticketId);
            } catch (NumberFormatException e) {
                // ignore invalid agent ID
            }
        }

        // Redirect back to ticket detail
        res.sendRedirect(req.getContextPath() + "/ticket?action=view&id=" + ticketId);
    }
}
