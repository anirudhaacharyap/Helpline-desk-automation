package com.helpdesk.controller;

import com.helpdesk.dao.TicketDAO;
import com.helpdesk.model.Ticket;
import com.helpdesk.util.ReportGenerator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/report")
public class ReportServlet extends HttpServlet {

    /**
     * GET /report → show the reports page.
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
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        req.getRequestDispatcher("/views/reports.jsp").forward(req, res);
    }

    /**
     * POST /report → generate and download a PDF report.
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
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Get all tickets for the report
        TicketDAO ticketDAO = new TicketDAO();
        String statusFilter = req.getParameter("status");
        List<Ticket> tickets = ticketDAO.getAllTickets(statusFilter);

        // Set response headers for PDF download
        res.setContentType("application/pdf");
        res.setHeader("Content-Disposition", "attachment; filename=helpdesk_report.pdf");

        try {
            ReportGenerator.generateTicketReport(tickets, res.getOutputStream());
        } catch (Exception e) {
            e.printStackTrace();
            res.sendRedirect(req.getContextPath() + "/report?error=PDF+generation+failed");
        }
    }
}
