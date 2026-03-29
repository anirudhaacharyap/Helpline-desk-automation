package com.helpdesk.controller;

import com.helpdesk.dao.UserDAO;
import com.helpdesk.model.User;
import com.helpdesk.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    /**
     * GET /register → show the registration form.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.getRequestDispatcher("/views/register.jsp").forward(req, res);
    }

    /**
     * POST /register → process the registration form.
     * Read name, email, password, confirmPassword → validate → hash password → insert user.
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String name            = req.getParameter("name");
        String email           = req.getParameter("email");
        String password        = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // Validation
        if (name == null || name.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.isEmpty()) {
            req.setAttribute("error", "All fields are required");
            req.getRequestDispatcher("/views/register.jsp").forward(req, res);
            return;
        }

        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Passwords do not match");
            req.getRequestDispatcher("/views/register.jsp").forward(req, res);
            return;
        }

        if (password.length() < 6) {
            req.setAttribute("error", "Password must be at least 6 characters");
            req.getRequestDispatcher("/views/register.jsp").forward(req, res);
            return;
        }

        // Check if email already exists
        UserDAO userDAO = new UserDAO();
        if (userDAO.getUserByEmail(email.trim()) != null) {
            req.setAttribute("error", "An account with this email already exists");
            req.getRequestDispatcher("/views/register.jsp").forward(req, res);
            return;
        }

        // Create user
        User user = new User();
        user.setName(name.trim());
        user.setEmail(email.trim());
        user.setPasswordHash(PasswordUtil.hash(password));
        user.setRole("user");

        boolean success = userDAO.insertUser(user);

        if (success) {
            res.sendRedirect(req.getContextPath() + "/login?success=registered");
            return;
        } else {
            req.setAttribute("error", "Registration failed. Please try again.");
            req.getRequestDispatcher("/views/register.jsp").forward(req, res);
        }
    }
}
