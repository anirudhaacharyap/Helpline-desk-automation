package com.helpdesk.controller;

import com.helpdesk.dao.UserDAO;
import com.helpdesk.model.User;
import com.helpdesk.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    /**
     * GET /login → show the login form.
     * Also handles logout via ?action=logout.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        // Handle logout
        if ("logout".equals(action)) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        req.getRequestDispatcher("/views/login.jsp").forward(req, res);
    }

    /**
     * POST /login → process the login form.
     * Read email + password → UserDAO.getUserByEmail() → PasswordUtil.verify()
     * → if valid: create session, redirect based on role
     * → if invalid: forward to login.jsp with error message
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String email    = req.getParameter("email");
        String password = req.getParameter("password");

        // Basic validation
        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Email is required");
            req.getRequestDispatcher("/views/login.jsp").forward(req, res);
            return;
        }

        if (password == null || password.isEmpty()) {
            req.setAttribute("error", "Password is required");
            req.getRequestDispatcher("/views/login.jsp").forward(req, res);
            return;
        }

        // Look up user by email
        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByEmail(email.trim());

        // Verify password using BCrypt
        if (user != null && PasswordUtil.verify(password, user.getPasswordHash())) {
            // Valid login — create session
            HttpSession session = req.getSession(true);
            session.setAttribute("userId",   user.getUserId());
            session.setAttribute("userName", user.getName());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("userEmail", user.getEmail());

            // Redirect based on role
            if ("admin".equals(user.getRole())) {
                res.sendRedirect(req.getContextPath() + "/admin");
            } else if ("agent".equals(user.getRole())) {
                res.sendRedirect(req.getContextPath() + "/tickets");
            } else {
                res.sendRedirect(req.getContextPath() + "/dashboard");
            }
        } else {
            // Invalid credentials
            req.setAttribute("error", "Invalid email or password");
            req.getRequestDispatcher("/views/login.jsp").forward(req, res);
        }
    }
}
