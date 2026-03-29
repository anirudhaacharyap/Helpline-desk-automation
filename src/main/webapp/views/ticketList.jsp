<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.helpdesk.model.Ticket, java.util.List, java.sql.Timestamp" %>
<%
    request.setAttribute("pageTitle", "All Tickets");
    String ctxPath = request.getContextPath();
    List<Ticket> tickets = (List<Ticket>) request.getAttribute("tickets");
    String userRole = (String) session.getAttribute("userRole");
    String currentFilter = (String) request.getAttribute("currentFilter");
    if (currentFilter == null) currentFilter = "";
    int totalCount = tickets != null ? tickets.size() : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tickets — Helpdesk</title>
    <link rel="stylesheet" href="<%= ctxPath %>/css/style.css">
</head>
<body>
<div class="app-layout">
    <jsp:include page="/views/includes/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="/views/includes/topbar.jsp" />
        <div class="page-body">

            <!-- Header + Filters -->
            <div class="flex-between mb-24">
                <div>
                    <span style="font-size:18px;font-weight:700;color:#1B3A6B;">All Tickets</span>
                    <span class="badge badge-open" style="margin-left:8px;"><%= totalCount %></span>
                </div>
                <div class="filter-bar">
                    <select id="filterStatus" onchange="applyFilters()">
                        <option value="">All Status</option>
                        <option value="OPEN" <%= "OPEN".equals(currentFilter) ? "selected" : "" %>>Open</option>
                        <option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(currentFilter) ? "selected" : "" %>>In Progress</option>
                        <option value="RESOLVED" <%= "RESOLVED".equals(currentFilter) ? "selected" : "" %>>Resolved</option>
                        <option value="CLOSED" <%= "CLOSED".equals(currentFilter) ? "selected" : "" %>>Closed</option>
                        <option value="SLA_BREACHED" <%= "SLA_BREACHED".equals(currentFilter) ? "selected" : "" %>>SLA Breached</option>
                    </select>
                    <input type="text" id="searchBox" placeholder="Search title..." oninput="filterTable()">
                </div>
            </div>

            <!-- Table -->
            <div class="card">
                <div class="card-body" style="padding:0;">
<% if (tickets == null || tickets.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-icon">&#128203;</div>
                        <div class="empty-text">No tickets found</div>
                    </div>
<% } else { %>
                    <div class="table-container">
                        <table class="data-table" id="ticketTable">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Title</th>
                                    <th>Category</th>
                                    <th>Priority</th>
                                    <th>Status</th>
                                    <th>Assigned To</th>
                                    <th>Created</th>
                                    <th>SLA Deadline</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
<%
    long now = System.currentTimeMillis();
    long twoHours = 2 * 3600 * 1000L;
    for (Ticket t : tickets) {
        String pClass = "badge-" + t.getPriority().toLowerCase();
        String sClass = "badge-" + t.getStatus().toLowerCase();
        boolean isResolved = "RESOLVED".equals(t.getStatus()) || "CLOSED".equals(t.getStatus());
        boolean breached = t.getSlaDeadline() != null && !isResolved && now > t.getSlaDeadline().getTime();
        boolean warning = !breached && t.getSlaDeadline() != null && !isResolved
                          && (t.getSlaDeadline().getTime() - now) < twoHours;
        String slaClass = breached ? "sla-breached" : warning ? "sla-warning" : "";
%>
                                <tr class="clickable" onclick="location.href='<%= ctxPath %>/ticket?action=view&id=<%= t.getTicketId() %>'">
                                    <td><%= t.getTicketId() %></td>
                                    <td><%= t.getTitle() %></td>
                                    <td><%= t.getCategory() %></td>
                                    <td><span class="badge <%= pClass %>"><%= t.getPriority() %></span></td>
                                    <td><span class="badge <%= sClass %>"><%= t.getStatus() %></span></td>
                                    <td><%= t.getAssignedTo() > 0 ? "Agent #" + t.getAssignedTo() : "-" %></td>
                                    <td><%= t.getCreatedAt() != null ? t.getCreatedAt().toString().substring(0,16) : "-" %></td>
                                    <td class="<%= slaClass %>">
                                        <%= breached ? "&#9888; " : "" %><%= t.getSlaDeadline() != null ? t.getSlaDeadline().toString().substring(0,16) : "-" %>
                                    </td>
                                    <td><a href="<%= ctxPath %>/ticket?action=view&id=<%= t.getTicketId() %>" class="btn btn-outline btn-sm">View</a></td>
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

<script>
function applyFilters() {
    var status = document.getElementById('filterStatus').value;
    var url = '<%= ctxPath %>/tickets';
    if (status) url += '?status=' + status;
    location.href = url;
}

function filterTable() {
    var q = document.getElementById('searchBox').value.toLowerCase();
    var rows = document.querySelectorAll('#ticketTable tbody tr');
    rows.forEach(function(row) {
        var title = row.cells[1].textContent.toLowerCase();
        row.style.display = title.indexOf(q) >= 0 ? '' : 'none';
    });
}
</script>
</body>
</html>
