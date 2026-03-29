<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.helpdesk.model.Ticket, java.util.List, java.sql.Timestamp" %>
<%
    request.setAttribute("pageTitle", "Dashboard");
    List<Ticket> tickets = (List<Ticket>) request.getAttribute("tickets");
    String ctxPath = request.getContextPath();
    String userRole = (String) session.getAttribute("userRole");

    int openCount = 0, inProgressCount = 0, resolvedCount = 0, breachedCount = 0;
    if (tickets != null) {
        for (Ticket t : tickets) {
            String s = t.getStatus();
            if ("OPEN".equals(s)) openCount++;
            else if ("IN_PROGRESS".equals(s)) inProgressCount++;
            else if ("RESOLVED".equals(s)) resolvedCount++;
            else if ("SLA_BREACHED".equals(s)) breachedCount++;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — Helpdesk</title>
    <link rel="stylesheet" href="<%= ctxPath %>/css/style.css">
</head>
<body>
<div class="app-layout">
    <jsp:include page="/views/includes/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="/views/includes/topbar.jsp" />
        <div class="page-body">

            <!-- Stat Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-label">Open Tickets</div>
                    <div class="stat-value"><%= openCount %></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">In Progress</div>
                    <div class="stat-value"><%= inProgressCount %></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Resolved</div>
                    <div class="stat-value"><%= resolvedCount %></div>
                </div>
                <div class="stat-card <%= breachedCount > 0 ? "danger" : "" %>">
                    <div class="stat-label">SLA Breached</div>
                    <div class="stat-value"><%= breachedCount %></div>
                </div>
            </div>

            <!-- Recent Tickets -->
            <div class="card">
                <div class="card-header flex-between">
                    <span>My Recent Tickets</span>
                    <a href="<%= ctxPath %>/ticket?action=new" class="btn btn-primary btn-sm">+ Raise New Ticket</a>
                </div>
                <div class="card-body" style="padding:0;">
<% if (tickets == null || tickets.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">&#128203;</div>
                        <div class="empty-text">No tickets yet — raise your first ticket</div>
                        <a href="<%= ctxPath %>/ticket?action=new" class="btn btn-accent btn-sm">Raise a Ticket</a>
                    </div>
<% } else { %>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Title</th>
                                    <th>Category</th>
                                    <th>Priority</th>
                                    <th>Status</th>
                                    <th>Created</th>
                                    <th>SLA Deadline</th>
                                </tr>
                            </thead>
                            <tbody>
<%
    int limit = Math.min(tickets.size(), 5);
    for (int i = 0; i < limit; i++) {
        Ticket t = tickets.get(i);
        String pClass = "badge-" + t.getPriority().toLowerCase();
        String sClass = "badge-" + t.getStatus().toLowerCase();
        boolean breached = t.getSlaDeadline() != null
                && new Timestamp(System.currentTimeMillis()).after(t.getSlaDeadline())
                && !"RESOLVED".equals(t.getStatus()) && !"CLOSED".equals(t.getStatus());
%>
                                <tr class="clickable" onclick="location.href='<%= ctxPath %>/ticket?action=view&id=<%= t.getTicketId() %>'">
                                    <td><%= t.getTicketId() %></td>
                                    <td><%= t.getTitle() %></td>
                                    <td><%= t.getCategory() %></td>
                                    <td><span class="badge <%= pClass %>"><%= t.getPriority() %></span></td>
                                    <td><span class="badge <%= sClass %>"><%= t.getStatus() %></span></td>
                                    <td><%= t.getCreatedAt() != null ? t.getCreatedAt().toString().substring(0,16) : "-" %></td>
                                    <td class="<%= breached ? "sla-breached" : "" %>">
                                        <%= breached ? "&#9888; " : "" %><%= t.getSlaDeadline() != null ? t.getSlaDeadline().toString().substring(0,16) : "-" %>
                                    </td>
                                </tr>
<% } %>
                            </tbody>
                        </table>
                    </div>
<% } %>
                </div>
            </div>

        </div>
    </div>
</div>
</body>
</html>
