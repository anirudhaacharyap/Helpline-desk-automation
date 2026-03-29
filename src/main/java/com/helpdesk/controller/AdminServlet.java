package com.helpdesk.controller;

import com.helpdesk.dao.TicketDAO;
import com.helpdesk.dao.UserDAO;
import com.helpdesk.model.Ticket;
import com.helpdesk.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    /**
     * GET /admin → show admin dashboard with stats.
     * Also handles AJAX stats endpoint: GET /admin?action=stats
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

        // Admin-only check
        String userRole = (String) session.getAttribute("userRole");
        if (!"admin".equals(userRole)) {
            res.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        String action = req.getParameter("action");

        if ("stats".equals(action)) {
            // AJAX endpoint — return JSON stats
            res.setContentType("application/json");
            res.setCharacterEncoding("UTF-8");

            TicketDAO ticketDAO = new TicketDAO();

            int openCount      = ticketDAO.getOpenTicketCount();
            int inProgressCount = ticketDAO.getTicketCountByStatus("IN_PROGRESS");
            int resolvedToday  = ticketDAO.getResolvedTodayCount();
            int breachCount    = ticketDAO.getSlaBreachedCount();

            // Flag SLA breaches
            ticketDAO.flagSlaBreaches();

            String json = String.format(
                    "{\"openCount\":%d,\"inProgressCount\":%d,\"resolvedToday\":%d,\"breachCount\":%d}",
                    openCount, inProgressCount, resolvedToday, breachCount
            );
            res.getWriter().write(json);
            return;

        } else if ("users".equals(action)) {
            // Show user management page
            UserDAO userDAO = new UserDAO();
            List<User> users = userDAO.getAllUsers();
            req.setAttribute("users", users);
            req.getRequestDispatcher("/views/userManagement.jsp").forward(req, res);
            return;
        }

        // Default: admin dashboard
        TicketDAO ticketDAO = new TicketDAO();

        // Flag SLA breaches
        ticketDAO.flagSlaBreaches();

        int openCount       = ticketDAO.getOpenTicketCount();
        int inProgressCount = ticketDAO.getTicketCountByStatus("IN_PROGRESS");
        int resolvedToday   = ticketDAO.getResolvedTodayCount();
        int breachCount     = ticketDAO.getSlaBreachedCount();

        List<Ticket> allTickets      = ticketDAO.getAllTickets(null);
        List<Ticket> breachedTickets = ticketDAO.getAllTickets("SLA_BREACHED");

        // Agents list for assignment
        UserDAO userDAO = new UserDAO();
        List<User> agents = userDAO.getAllAgents();

        req.setAttribute("openCount", openCount);
        req.setAttribute("inProgressCount", inProgressCount);
        req.setAttribute("resolvedToday", resolvedToday);
        req.setAttribute("breachCount", breachCount);
        req.setAttribute("allTickets", allTickets);
        req.setAttribute("breachedTickets", breachedTickets);
        req.setAttribute("agents", agents);

        req.getRequestDispatcher("/views/adminDashboard.jsp").forward(req, res);
    }

    /**
     * POST /admin → handle admin actions (user management).
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

        String userRole = (String) session.getAttribute("userRole");
        if (!"admin".equals(userRole)) {
            res.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        String action = req.getParameter("action");
        UserDAO userDAO = new UserDAO();

        if ("updateRole".equals(action)) {
            try {
                int targetUserId = Integer.parseInt(req.getParameter("targetUserId"));
                String newRole = req.getParameter("newRole");
                userDAO.updateUserRole(targetUserId, newRole);
            } catch (NumberFormatException e) {
                // ignore
            }
        } else if ("deactivate".equals(action)) {
            try {
                int targetUserId = Integer.parseInt(req.getParameter("targetUserId"));
                userDAO.deactivateUser(targetUserId);
            } catch (NumberFormatException e) {
                // ignore
            }
        }

        res.sendRedirect(req.getContextPath() + "/admin?action=users");
    }
}
