<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.helpdesk.model.User, java.util.List" %>
<%
    request.setAttribute("pageTitle", "User Management");
    String ctxPath = request.getContextPath();
    List<User> users = (List<User>) request.getAttribute("users");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management — Helpdesk</title>
    <link rel="stylesheet" href="<%= ctxPath %>/css/style.css">
</head>
<body>
<div class="app-layout">
    <jsp:include page="/views/includes/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="/views/includes/topbar.jsp" />
        <div class="page-body">

            <div class="flex-between mb-24">
                <span style="font-size:18px;font-weight:700;color:#1B3A6B;">User Management</span>
                <button class="btn btn-primary btn-sm" onclick="document.getElementById('addUserModal').classList.add('active')">+ Add New User</button>
            </div>

            <div class="card">
                <div class="card-body" style="padding:0;">
<% if (users == null || users.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">&#128101;</div>
                        <div class="empty-text">No users found</div>
                    </div>
<% } else { %>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Role</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
<%     for (User u : users) {
           String rClass = "badge-" + u.getRole();
%>
                                <tr>
                                    <td><%= u.getUserId() %></td>
                                    <td><%= u.getName() %></td>
                                    <td><%= u.getEmail() %></td>
                                    <td><span class="badge <%= rClass %>"><%= u.getRole() %></span></td>
                                    <td>
                                        <span class="badge <%= u.isActive() ? "badge-resolved" : "badge-closed" %>">
                                            <%= u.isActive() ? "Active" : "Inactive" %>
                                        </span>
                                    </td>
                                    <td>
                                        <form method="POST" action="<%= ctxPath %>/admin" style="display:inline-flex; gap:6px; align-items:center;">
                                            <input type="hidden" name="action" value="updateRole">
                                            <input type="hidden" name="targetUserId" value="<%= u.getUserId() %>">
                                            <select name="newRole" style="padding:4px 8px; font-size:12px; border-radius:4px; border:1px solid #d1d5db;">
                                                <option value="user" <%= "user".equals(u.getRole()) ? "selected" : "" %>>user</option>
                                                <option value="agent" <%= "agent".equals(u.getRole()) ? "selected" : "" %>>agent</option>
                                                <option value="admin" <%= "admin".equals(u.getRole()) ? "selected" : "" %>>admin</option>
                                            </select>
                                            <button type="submit" class="btn btn-accent btn-sm" style="padding:4px 10px;">Save</button>
                                        </form>
<% if (u.isActive()) { %>
                                        <form method="POST" action="<%= ctxPath %>/admin" style="display:inline; margin-left:4px;"
                                              onsubmit="return confirm('Deactivate this user?');">
                                            <input type="hidden" name="action" value="deactivate">
                                            <input type="hidden" name="targetUserId" value="<%= u.getUserId() %>">
                                            <button type="submit" class="btn btn-danger btn-sm" style="padding:4px 10px;">Deactivate</button>
                                        </form>
<% } %>
                                    </td>
                                </tr>
<%     } %>
                            </tbody>
                        </table>
                    </div>
<% } %>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- Add User Modal -->
<div id="addUserModal" class="modal-overlay">
    <div class="modal-box">
        <h3>Add New User</h3>
        <form method="POST" action="<%= ctxPath %>/register">
            <div class="form-group">
                <label for="newName">Full Name</label>
                <input type="text" id="newName" name="name" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="newEmail">Email</label>
                <input type="email" id="newEmail" name="email" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="newPassword">Password</label>
                <input type="password" id="newPassword" name="password" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="newConfirm">Confirm Password</label>
                <input type="password" id="newConfirm" name="confirmPassword" class="form-control" required>
            </div>
            <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:20px;">
                <button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById('addUserModal').classList.remove('active')">Cancel</button>
                <button type="submit" class="btn btn-primary btn-sm">Create User</button>
            </div>
        </form>
    </div>
</div>
</body>
</html>
