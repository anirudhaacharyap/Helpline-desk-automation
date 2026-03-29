package com.helpdesk.controller;

import com.helpdesk.dao.TicketDAO;
import com.helpdesk.model.Ticket;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/tickets")
public class TicketListServlet extends HttpServlet {

    // ── GET /tickets ─────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Security check
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int userId    = (int) session.getAttribute("userId");
        String role   = (String) session.getAttribute("userRole");
        String status = req.getParameter("status");

        TicketDAO ticketDAO = new TicketDAO();
        List<Ticket> tickets;

        if ("user".equals(role)) {
            tickets = ticketDAO.getTicketsByUser(userId);
        } else if ("agent".equals(role)) {
            tickets = ticketDAO.getTicketsByAgent(userId);
        } else {
            // admin sees all
            tickets = ticketDAO.getAllTickets(status);
        }

        req.setAttribute("tickets", tickets);
        req.setAttribute("userRole", role);
        req.setAttribute("currentFilter", status);
        req.getRequestDispatcher("/views/ticketList.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        doGet(req, res);
    }
}
