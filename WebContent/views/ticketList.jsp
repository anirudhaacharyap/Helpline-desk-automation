<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.helpdesk.model.Ticket" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String userRole = (String) session.getAttribute("userRole");
    String userName = (String) session.getAttribute("userName");
    String currentFilter = (String) request.getAttribute("currentFilter");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ticket List — Helpdesk</title>
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
                        <a class="nav-link" href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/ticket?action=new">Raise Ticket</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/tickets">Ticket List</a>
                    </li>
                    <% if ("admin".equals(userRole)) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/admin">Admin</a>
                    </li>
                    <% } %>
                </ul>
                <span class="navbar-text me-3">
                    Welcome, <strong><%= userName %></strong> (<%= userRole %>)
                </span>
                <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/login?action=logout">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <h2>Tickets</h2>

        <!-- Status Filter -->
        <div class="mb-3">
            <span class="me-2">Filter by status:</span>
            <a href="${pageContext.request.contextPath}/tickets"
               class="btn btn-sm <%= (currentFilter == null) ? "btn-dark" : "btn-outline-dark" %>">All</a>
            <a href="${pageContext.request.contextPath}/tickets?status=OPEN"
               class="btn btn-sm <%= "OPEN".equals(currentFilter) ? "btn-primary" : "btn-outline-primary" %>">Open</a>
            <a href="${pageContext.request.contextPath}/tickets?status=IN_PROGRESS"
               class="btn btn-sm <%= "IN_PROGRESS".equals(currentFilter) ? "btn-warning" : "btn-outline-warning" %>">In Progress</a>
            <a href="${pageContext.request.contextPath}/tickets?status=RESOLVED"
               class="btn btn-sm <%= "RESOLVED".equals(currentFilter) ? "btn-success" : "btn-outline-success" %>">Resolved</a>
            <a href="${pageContext.request.contextPath}/tickets?status=CLOSED"
               class="btn btn-sm <%= "CLOSED".equals(currentFilter) ? "btn-secondary" : "btn-outline-secondary" %>">Closed</a>
            <a href="${pageContext.request.contextPath}/tickets?status=SLA_BREACHED"
               class="btn btn-sm <%= "SLA_BREACHED".equals(currentFilter) ? "btn-danger" : "btn-outline-danger" %>">SLA Breached</a>
        </div>

        <!-- Tickets Table -->
        <div class="table-responsive">
            <table class="table table-striped table-hover">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>Title</th>
                        <th>Category</th>
                        <th>Priority</th>
                        <th>Status</th>
                        <th>SLA Deadline</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    List<Ticket> tickets = (List<Ticket>) request.getAttribute("tickets");
                    if (tickets != null && !tickets.isEmpty()) {
                        for (Ticket t : tickets) {
                %>
                    <tr>
                        <td><%= t.getTicketId() %></td>
                        <td><%= t.getTitle() %></td>
                        <td><%= t.getCategory() %></td>
                        <td><span class="badge badge-<%= t.getPriority().toLowerCase() %>">
                            <%= t.getPriority() %></span></td>
                        <td><span class="badge badge-<%= t.getStatus().toLowerCase() %>">
                            <%= t.getStatus() %></span></td>
                        <td><%= t.getSlaDeadline() %></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/ticket?action=view&id=<%= t.getTicketId() %>"
                               class="btn btn-sm btn-outline-primary">View</a>
                        </td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="7" class="text-center text-muted">No tickets found.</td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
