<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.helpdesk.model.Ticket" %>
<%@ page import="com.helpdesk.model.Comment" %>
<%@ page import="com.helpdesk.model.User" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String userRole = (String) session.getAttribute("userRole");
    String userName = (String) session.getAttribute("userName");
    int currentUserId = (int) session.getAttribute("userId");

    Ticket ticket = (Ticket) request.getAttribute("ticket");
    List<Comment> comments = (List<Comment>) request.getAttribute("comments");
    List<User> agents = (List<User>) request.getAttribute("agents");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ticket #<%= ticket.getTicketId() %> — Helpdesk</title>
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
                        <a class="nav-link" href="${pageContext.request.contextPath}/tickets">Ticket List</a>
                    </li>
                </ul>
                <span class="navbar-text me-3">
                    Welcome, <strong><%= userName %></strong> (<%= userRole %>)
                </span>
                <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/login?action=logout">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <!-- Ticket Info Card -->
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h4 class="mb-0">Ticket #<%= ticket.getTicketId() %>: <%= ticket.getTitle() %></h4>
                <span id="status-badge" class="badge badge-<%= ticket.getStatus().toLowerCase() %>">
                    <%= ticket.getStatus() %>
                </span>
            </div>
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-md-3"><strong>Priority:</strong>
                        <span class="badge badge-<%= ticket.getPriority().toLowerCase() %>">
                            <%= ticket.getPriority() %></span>
                    </div>
                    <div class="col-md-3"><strong>Category:</strong> <%= ticket.getCategory() %></div>
                    <div class="col-md-3"><strong>Created:</strong> <%= ticket.getCreatedAt() %></div>
                    <div class="col-md-3"><strong>SLA Deadline:</strong> <%= ticket.getSlaDeadline() %></div>
                </div>
                <div class="mb-3">
                    <strong>Description:</strong>
                    <p class="mt-1"><%= ticket.getDescription() %></p>
                </div>
                <% if (ticket.getResolvedAt() != null) { %>
                <div class="mb-3">
                    <strong>Resolved At:</strong> <%= ticket.getResolvedAt() %>
                </div>
                <% } %>
            </div>
        </div>

        <input type="hidden" id="ticket-id" value="<%= ticket.getTicketId() %>">

        <div class="row">
            <!-- Left: Comments -->
            <div class="col-md-8">
                <h5>Comments (<%= comments != null ? comments.size() : 0 %>)</h5>
                <div class="mb-3">
                <%
                    if (comments != null && !comments.isEmpty()) {
                        for (Comment c : comments) {
                %>
                    <div class="card mb-2">
                        <div class="card-body py-2 px-3">
                            <strong><%= c.getUserName() %></strong>
                            <small class="text-muted ms-2"><%= c.getCommentedAt() %></small>
                            <p class="mb-0 mt-1"><%= c.getComment() %></p>
                        </div>
                    </div>
                <%
                        }
                    } else {
                %>
                    <p class="text-muted">No comments yet.</p>
                <%
                    }
                %>
                </div>

                <!-- Add Comment Form -->
                <form action="${pageContext.request.contextPath}/ticket/update" method="post">
                    <input type="hidden" name="ticketId" value="<%= ticket.getTicketId() %>">
                    <input type="hidden" name="action" value="addComment">
                    <div class="mb-3">
                        <textarea class="form-control" name="comment" rows="3"
                                  placeholder="Add a comment..." required></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary btn-sm">Post Comment</button>
                </form>
            </div>

            <!-- Right: Actions (Agent / Admin) -->
            <div class="col-md-4">
                <% if ("agent".equals(userRole) || "admin".equals(userRole)) { %>
                <div class="card">
                    <div class="card-header"><strong>Ticket Actions</strong></div>
                    <div class="card-body">
                        <!-- Change Status -->
                        <form action="${pageContext.request.contextPath}/ticket/update" method="post" class="mb-3">
                            <input type="hidden" name="ticketId" value="<%= ticket.getTicketId() %>">
                            <input type="hidden" name="action" value="changeStatus">
                            <label class="form-label">Update Status</label>
                            <select name="newStatus" class="form-select mb-2">
                                <option value="OPEN" <%= "OPEN".equals(ticket.getStatus()) ? "selected" : "" %>>OPEN</option>
                                <option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(ticket.getStatus()) ? "selected" : "" %>>IN_PROGRESS</option>
                                <option value="RESOLVED" <%= "RESOLVED".equals(ticket.getStatus()) ? "selected" : "" %>>RESOLVED</option>
                                <option value="CLOSED" <%= "CLOSED".equals(ticket.getStatus()) ? "selected" : "" %>>CLOSED</option>
                            </select>
                            <button type="submit" class="btn btn-warning btn-sm w-100">Update Status</button>
                        </form>

                        <% if ("admin".equals(userRole) && agents != null) { %>
                        <!-- Assign to Agent (Admin only) -->
                        <form action="${pageContext.request.contextPath}/ticket/update" method="post">
                            <input type="hidden" name="ticketId" value="<%= ticket.getTicketId() %>">
                            <input type="hidden" name="action" value="assign">
                            <label class="form-label">Assign to Agent</label>
                            <select name="agentId" class="form-select mb-2">
                                <% for (User agent : agents) { %>
                                <option value="<%= agent.getUserId() %>"
                                    <%= (agent.getUserId() == ticket.getAssignedTo()) ? "selected" : "" %>>
                                    <%= agent.getName() %>
                                </option>
                                <% } %>
                            </select>
                            <button type="submit" class="btn btn-info btn-sm w-100">Assign Agent</button>
                        </form>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // AJAX Status Polling — poll every 30s for status updates (LLD Section 5.2)
        function pollTicketStatus(ticketId) {
            fetch('${pageContext.request.contextPath}/admin?action=stats')
                .then(r => r.json())
                .then(data => {
                    // Reload the page to get latest status — simpler approach
                })
                .catch(err => console.error('Status poll failed:', err));
        }

        // Custom polling: check ticket status every 30 seconds
        const pollingInterval = setInterval(() => {
            const ticketId = document.getElementById('ticket-id').value;
            // For now, just refresh the page data
            fetch('${pageContext.request.contextPath}/ticket?action=view&id=' + ticketId, {
                headers: { 'X-Requested-With': 'XMLHttpRequest' }
            }).then(r => {
                if (r.ok) {
                    // Could parse and update DOM; for simplicity, we note status changes
                }
            }).catch(err => console.error('Polling error:', err));
        }, 30000);
    </script>
</body>
</html>
