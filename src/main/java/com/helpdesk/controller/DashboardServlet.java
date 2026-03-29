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

/**
 * DashboardServlet — loads user's tickets and forwards to dashboard.jsp.
 * This servlet is the landing page after login for regular users and agents.
 */
@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

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

        TicketDAO ticketDAO = new TicketDAO();
        List<Ticket> tickets;

        if ("agent".equals(userRole)) {
            tickets = ticketDAO.getTicketsByAgent(userId);
        } else if ("admin".equals(userRole)) {
            tickets = ticketDAO.getAllTickets(null);
        } else {
            tickets = ticketDAO.getTicketsByUser(userId);
        }

        req.setAttribute("tickets", tickets);
        req.getRequestDispatcher("/views/dashboard.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        doGet(req, res);
    }
}
