<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — Helpdesk</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<div class="auth-wrapper">
    <div class="auth-card">
        <div class="auth-brand">&#127915; Helpdesk</div>
        <div class="auth-subtitle">Sign in to your account</div>

        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
            <div class="alert alert-error"><%= error %></div>
        <% } %>

        <% String success = request.getParameter("success"); %>
        <% if ("registered".equals(success)) { %>
            <div class="alert alert-success">Registration successful! Please login.</div>
        <% } %>

        <form method="POST" action="<%= request.getContextPath() %>/login">
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" class="form-control"
                       placeholder="you@company.com" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" class="form-control"
                       placeholder="Enter your password" required>
            </div>
            <button type="submit" class="btn btn-primary btn-block">Sign In</button>
        </form>

        <p style="text-align:center; margin-top:16px; font-size:13px; color:#94a3b8;">
            Don't have an account?
            <a href="<%= request.getContextPath() %>/register">Register here</a>
        </p>
    </div>
</div>
</body>
</html>
