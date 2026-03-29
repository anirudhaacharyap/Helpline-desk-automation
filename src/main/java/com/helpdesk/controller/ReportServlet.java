package com.helpdesk.controller;

import com.helpdesk.dao.TicketDAO;
import com.helpdesk.model.Ticket;
import com.helpdesk.util.ReportGenerator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/report")
public class ReportServlet extends HttpServlet {

    // ── GET /report → generate and stream PDF directly ───────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Security check
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

        // Get all tickets
        TicketDAO ticketDAO = new TicketDAO();
        List<Ticket> tickets = ticketDAO.getAllTickets(null);

        // Stream PDF directly to browser
        res.setContentType("application/pdf");
        res.setHeader("Content-Disposition", "attachment; filename=report.pdf");

        try {
            ReportGenerator.generateTicketReport(tickets, res.getOutputStream());
        } catch (Exception e) {
            e.printStackTrace();
            // Cannot redirect after getOutputStream() — just log the error
        }
    }
}
