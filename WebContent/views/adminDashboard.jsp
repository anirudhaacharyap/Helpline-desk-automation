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
    if (!"admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Integer openCount       = (Integer) request.getAttribute("openCount");
    Integer inProgressCount = (Integer) request.getAttribute("inProgressCount");
    Integer resolvedToday   = (Integer) request.getAttribute("resolvedToday");
    Integer breachCount     = (Integer) request.getAttribute("breachCount");
    List<Ticket> breachedTickets = (List<Ticket>) request.getAttribute("breachedTickets");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Helpdesk</title>
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
                        <a class="nav-link" href="${pageContext.request.contextPath}/tickets">Tickets</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/admin">Admin</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/admin?action=users">Users</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/report">Reports</a>
                    </li>
                </ul>
                <span class="navbar-text me-3">
                    Welcome, <strong><%= userName %></strong> (Admin)
                </span>
                <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/login?action=logout">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <h2>Admin Dashboard</h2>

        <!-- Stat Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card text-white bg-primary">
                    <div class="card-body text-center">
                        <h5 class="card-title">Open</h5>
                        <h2 id="open-count"><%= openCount != null ? openCount : 0 %></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-white bg-warning">
                    <div class="card-body text-center">
                        <h5 class="card-title">In Progress</h5>
                        <h2 id="in-progress-count"><%= inProgressCount != null ? inProgressCount : 0 %></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-white bg-success">
                    <div class="card-body text-center">
                        <h5 class="card-title">Resolved Today</h5>
                        <h2 id="resolved-today"><%= resolvedToday != null ? resolvedToday : 0 %></h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-white bg-danger">
                    <div class="card-body text-center">
                        <h5 class="card-title">SLA Breached</h5>
                        <h2 id="breach-count"><%= breachCount != null ? breachCount : 0 %></h2>
                    </div>
                </div>
            </div>
        </div>

        <!-- SLA Breached Tickets -->
        <h4>SLA Breached Tickets</h4>
        <div class="table-responsive">
            <table class="table table-striped table-hover">
                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>Title</th>
                        <th>Priority</th>
                        <th>SLA Deadline</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (breachedTickets != null && !breachedTickets.isEmpty()) {
                        for (Ticket t : breachedTickets) {
                %>
                    <tr>
                        <td><%= t.getTicketId() %></td>
                        <td><%= t.getTitle() %></td>
                        <td><span class="badge badge-<%= t.getPriority().toLowerCase() %>">
                            <%= t.getPriority() %></span></td>
                        <td><%= t.getSlaDeadline() %></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/ticket?action=view&id=<%= t.getTicketId() %>"
                               class="btn btn-sm btn-outline-danger">View</a>
                        </td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="5" class="text-center text-muted">No SLA breaches — great work!</td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // AJAX Dashboard Stats Refresh — LLD Section 5.3
        function refreshDashboardStats() {
            fetch('${pageContext.request.contextPath}/admin?action=stats')
                .then(r => r.json())
                .then(stats => {
                    document.getElementById('open-count').textContent      = stats.openCount;
                    document.getElementById('in-progress-count').textContent = stats.inProgressCount;
                    document.getElementById('resolved-today').textContent  = stats.resolvedToday;
                    document.getElementById('breach-count').textContent    = stats.breachCount;
                })
                .catch(err => console.error('Stats refresh failed:', err));
        }

        setInterval(refreshDashboardStats, 60000); // refresh every 60 seconds
        refreshDashboardStats(); // call immediately on page load
    </script>
</body>
</html>
