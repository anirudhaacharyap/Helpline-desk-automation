<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.helpdesk.model.Ticket, com.helpdesk.model.User, java.util.List" %>
<%
    request.setAttribute("pageTitle", "Admin Dashboard");
    String ctxPath = request.getContextPath();

    Integer openCount = (Integer) request.getAttribute("openCount");
    Integer inProgressCount = (Integer) request.getAttribute("inProgressCount");
    Integer resolvedToday = (Integer) request.getAttribute("resolvedToday");
    Integer breachCount = (Integer) request.getAttribute("breachCount");
    List<Ticket> allTickets = (List<Ticket>) request.getAttribute("allTickets");
    List<Ticket> breachedTickets = (List<Ticket>) request.getAttribute("breachedTickets");
    List<User> agents = (List<User>) request.getAttribute("agents");

    if (openCount == null) openCount = 0;
    if (inProgressCount == null) inProgressCount = 0;
    if (resolvedToday == null) resolvedToday = 0;
    if (breachCount == null) breachCount = 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin — Helpdesk</title>
    <link rel="stylesheet" href="<%= ctxPath %>/css/style.css">
</head>
<body>
<div class="app-layout">
    <jsp:include page="/views/includes/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="/views/includes/topbar.jsp" />
        <div class="page-body">

            <!-- Stat Cards -->
            <div class="stats-grid" id="statCards">
                <div class="stat-card">
                    <div class="stat-label">Total Open</div>
                    <div class="stat-value" id="statOpen"><%= openCount %></div>
                </div>
<%
    String breachCardClass = breachCount > 0 ? "stat-card danger" : "stat-card";
%>
                <div class="<%= breachCardClass %>">
                    <div class="stat-label">SLA Breached</div>
                    <div class="stat-value" id="statBreach"><%= breachCount %></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Resolved Today</div>
                    <div class="stat-value" id="statResolved"><%= resolvedToday %></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Total Agents</div>
                    <div class="stat-value"><%= agents != null ? agents.size() : 0 %></div>
                </div>
            </div>

            <!-- Two-panel row -->
            <div style="display:grid; grid-template-columns:60% 40%; gap:20px; margin-bottom:24px;">

                <!-- SLA Breached Tickets -->
                <div class="card">
                    <div class="card-header">&#9888; SLA Breached Tickets</div>
                    <div class="card-body" style="padding:0;">
<% if (breachedTickets == null || breachedTickets.isEmpty()) { %>
                        <div class="empty-state" style="padding:32px;">
                            <div class="empty-text">&#9989; No SLA breaches — all good!</div>
                        </div>
<% } else { %>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr><th>#</th><th>Title</th><th>Priority</th><th>Agent</th><th>Deadline</th><th>Overdue By</th></tr>
                                </thead>
                                <tbody>
<%     long nowMs = System.currentTimeMillis();
       for (Ticket t : breachedTickets) {
           long overMs = t.getSlaDeadline() != null ? (nowMs - t.getSlaDeadline().getTime()) : 0;
           long overHrs = overMs / 3600000;
           long overMins = (overMs % 3600000) / 60000;
           String pClass = "badge-" + t.getPriority().toLowerCase();
%>
                                    <tr style="background:#fef2f2;">
                                        <td><%= t.getTicketId() %></td>
                                        <td><a href="<%= ctxPath %>/ticket?action=view&id=<%= t.getTicketId() %>"><%= t.getTitle() %></a></td>
                                        <td><span class="badge <%= pClass %>"><%= t.getPriority() %></span></td>
                                        <td>Agent #<%= t.getAssignedTo() %></td>
                                        <td class="sla-breached"><%= t.getSlaDeadline() != null ? t.getSlaDeadline().toString().substring(0,16) : "-" %></td>
                                        <td class="sla-breached"><%= overHrs %>h <%= overMins %>m</td>
                                    </tr>
<%     } %>
                                </tbody>
                            </table>
                        </div>
<% } %>
                    </div>
                </div>

                <!-- Agent Workload -->
                <div class="card">
                    <div class="card-header">Agent Workload</div>
                    <div class="card-body">
<% if (agents == null || agents.isEmpty()) { %>
                        <p style="color:#94a3b8;">No agents found</p>
<% } else {
       int maxLoad = 1;
       for (User a : agents) {
           int cnt = 0;
           if (allTickets != null) {
               for (Ticket t : allTickets) {
                   if (t.getAssignedTo() == a.getUserId()
                       && !"RESOLVED".equals(t.getStatus())
                       && !"CLOSED".equals(t.getStatus())) cnt++;
               }
           }
           if (cnt > maxLoad) maxLoad = cnt;
       }
       for (User a : agents) {
           int cnt = 0;
           if (allTickets != null) {
               for (Ticket t : allTickets) {
                   if (t.getAssignedTo() == a.getUserId()
                       && !"RESOLVED".equals(t.getStatus())
                       && !"CLOSED".equals(t.getStatus())) cnt++;
               }
           }
           int pct = (cnt * 100) / maxLoad;
%>
                        <div style="margin-bottom:14px;">
                            <div class="flex-between" style="font-size:13px;">
                                <span style="font-weight:500;"><%= a.getName() %></span>
                                <span style="color:#64748b;"><%= cnt %> open</span>
                            </div>
                            <div class="workload-bar-bg">
                                <div class="workload-bar-fill" style="width:<%= pct %>%;"></div>
                            </div>
                        </div>
<%     }
   } %>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
// AJAX refresh stats every 60s
setInterval(function() {
    fetch('<%= ctxPath %>/admin?action=stats')
        .then(function(r) { return r.json(); })
        .then(function(d) {
            document.getElementById('statOpen').textContent = d.openCount;
            document.getElementById('statBreach').textContent = d.breachCount;
            document.getElementById('statResolved').textContent = d.resolvedToday;
        })
        .catch(function() {});
}, 60000);
</script>
</body>
</html>
