<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.helpdesk.model.User" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String userRole = (String) session.getAttribute("userRole");
    String userName = (String) session.getAttribute("userName");
    if (!"admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<User> users = (List<User>) request.getAttribute("users");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management — Helpdesk</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet">
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container-fluid">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">🎫 Helpdesk</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/admin">Admin</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/admin?action=users">Users</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/report">Reports</a>
                    </li>
                </ul>
                <span class="navbar-text me-3">
                    Welcome, <strong><%= userName %></strong>
                </span>
                <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/login?action=logout">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <h2>User Management</h2>

        <div class="table-responsive">
            <table class="table table-striped table-hover">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Created</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (users != null && !users.isEmpty()) {
                        for (User u : users) {
                %>
                    <tr>
                        <td><%= u.getUserId() %></td>
                        <td><%= u.getName() %></td>
                        <td><%= u.getEmail() %></td>
                        <td>
                            <span class="badge bg-<%= "admin".equals(u.getRole()) ? "danger" :
                                                      "agent".equals(u.getRole()) ? "info" : "secondary" %>">
                                <%= u.getRole() %>
                            </span>
                        </td>
                        <td>
                            <span class="badge bg-<%= u.isActive() ? "success" : "dark" %>">
                                <%= u.isActive() ? "Active" : "Inactive" %>
                            </span>
                        </td>
                        <td><%= u.getCreatedAt() %></td>
                        <td>
                            <!-- Change Role -->
                            <form action="${pageContext.request.contextPath}/admin" method="post"
                                  class="d-inline">
                                <input type="hidden" name="action" value="updateRole">
                                <input type="hidden" name="targetUserId" value="<%= u.getUserId() %>">
                                <select name="newRole" class="form-select form-select-sm d-inline w-auto">
                                    <option value="user" <%= "user".equals(u.getRole()) ? "selected" : "" %>>user</option>
                                    <option value="agent" <%= "agent".equals(u.getRole()) ? "selected" : "" %>>agent</option>
                                    <option value="admin" <%= "admin".equals(u.getRole()) ? "selected" : "" %>>admin</option>
                                </select>
                                <button type="submit" class="btn btn-sm btn-outline-primary">Update</button>
                            </form>
                            <!-- Deactivate -->
                            <% if (u.isActive()) { %>
                            <form action="${pageContext.request.contextPath}/admin" method="post"
                                  class="d-inline ms-1">
                                <input type="hidden" name="action" value="deactivate">
                                <input type="hidden" name="targetUserId" value="<%= u.getUserId() %>">
                                <button type="submit" class="btn btn-sm btn-outline-danger"
                                        onclick="return confirm('Deactivate this user?')">Deactivate</button>
                            </form>
                            <% } %>
                        </td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="7" class="text-center text-muted">No users found.</td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
