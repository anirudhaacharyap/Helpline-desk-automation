package com.helpdesk.controller;

import com.helpdesk.dao.TicketDAO;
import com.helpdesk.model.Ticket;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/tickets")
public class TicketListServlet extends HttpServlet {

    /**
     * GET /tickets → show list of tickets.
     * Agents/admins see all tickets (with optional status filter).
     * Regular users see only their own tickets.
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

        int userId = (int) session.getAttribute("userId");
        String userRole = (String) session.getAttribute("userRole");
        String statusFilter = req.getParameter("status");

        TicketDAO ticketDAO = new TicketDAO();
        List<Ticket> tickets;

        if ("admin".equals(userRole) || "agent".equals(userRole)) {
            // Agents and admins see all tickets
            tickets = ticketDAO.getAllTickets(statusFilter);
        } else {
            // Regular users see only their own tickets
            tickets = ticketDAO.getTicketsByUser(userId);
        }

        req.setAttribute("tickets", tickets);
        req.setAttribute("currentFilter", statusFilter);
        req.getRequestDispatcher("/views/ticketList.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        doGet(req, res);
    }
}
