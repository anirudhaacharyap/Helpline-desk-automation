package com.helpdesk.controller;

import com.helpdesk.dao.AuditDAO;
import com.helpdesk.dao.CommentDAO;
import com.helpdesk.dao.TicketDAO;
import com.helpdesk.dao.UserDAO;
import com.helpdesk.engine.PriorityEngine;
import com.helpdesk.engine.SLAEngine;
import com.helpdesk.model.Comment;
import com.helpdesk.model.Ticket;
import com.helpdesk.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/ticket")
public class TicketServlet extends HttpServlet {

    /**
     * GET /ticket?action=view&id=5  → show ticket detail
     * GET /ticket?action=new        → show raise ticket form
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Security guard
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        if ("view".equals(action)) {
            try {
                int ticketId = Integer.parseInt(req.getParameter("id"));
                TicketDAO ticketDAO = new TicketDAO();
                CommentDAO commentDAO = new CommentDAO();

                Ticket ticket = ticketDAO.getTicketById(ticketId);

                if (ticket == null) {
                    res.sendRedirect(req.getContextPath() + "/tickets");
                    return;
                }

                List<Comment> comments = commentDAO.getCommentsByTicket(ticketId);

                // SLA breach check
                if (SLAEngine.isBreached(ticket.getSlaDeadline(), ticket.getStatus())
                        && !"SLA_BREACHED".equals(ticket.getStatus())) {
                    ticketDAO.updateStatus(ticketId, "SLA_BREACHED");
                    ticket.setStatus("SLA_BREACHED");
                }

                // Get list of agents for assignment dropdown (admin/agent view)
                UserDAO userDAO = new UserDAO();
                List<User> agents = userDAO.getAllAgents();

                req.setAttribute("ticket", ticket);
                req.setAttribute("comments", comments);
                req.setAttribute("agents", agents);
                req.getRequestDispatcher("/views/ticketDetail.jsp").forward(req, res);

            } catch (NumberFormatException e) {
                res.sendRedirect(req.getContextPath() + "/tickets?error=Invalid+ticket+ID");
            }
        } else {
            // action=new → show raise ticket form
            req.getRequestDispatcher("/views/raiseTicket.jsp").forward(req, res);
        }
    }

    /**
     * POST /ticket → create new ticket.
     * Reads form params, auto-assigns priority via PriorityEngine,
     * calculates SLA deadline via SLAEngine, routes to least-loaded agent.
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

        // 1. Read form params
        String title       = req.getParameter("title");
        String description = req.getParameter("description");
        String category    = req.getParameter("category");

        // 2. Validate
        if (title == null || title.trim().isEmpty() ||
                description == null || description.trim().isEmpty()) {
            req.setAttribute("error", "Title and description are required");
            req.getRequestDispatcher("/views/raiseTicket.jsp").forward(req, res);
            return;
        }

        title = title.trim();
        description = description.trim();

        // 3. Auto-assign priority
        String priority = PriorityEngine.assignPriority(title, description);

        // 4. Calculate SLA deadline
        Timestamp slaDeadline = SLAEngine.getDeadline(priority);

        // 5. Route to agent (least-loaded)
        UserDAO userDAO = new UserDAO();
        TicketDAO ticketDAO = new TicketDAO();
        List<User> agents = userDAO.getAllAgents();

        // Build ticket counts map for agent routing
        Map<Integer, Integer> ticketCounts = new HashMap<>();
        for (User agent : agents) {
            int count = ticketDAO.getTicketsByAgent(agent.getUserId()).size();
            ticketCounts.put(agent.getUserId(), count);
        }

        int agentId = agents.isEmpty() ? 1 : SLAEngine.routeToAgent(priority, agents, ticketCounts);

        // 6. Build ticket object and insert
        Ticket ticket = new Ticket();
        ticket.setTitle(title);
        ticket.setDescription(description);
        ticket.setCategory(category);
        ticket.setPriority(priority);
        ticket.setStatus("OPEN");
        ticket.setCreatedBy(userId);
        ticket.setAssignedTo(agentId);
        ticket.setSlaDeadline(slaDeadline);

        int newId = ticketDAO.insertTicket(ticket);

        // 7. Log audit
        new AuditDAO().log(userId, "TICKET_CREATED", "ticket", newId);

        // 8. Redirect to dashboard with success message
        res.sendRedirect(req.getContextPath() + "/dashboard?success=Ticket+%23" + newId + "+created");
    }
}
