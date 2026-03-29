<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%
    String ctxPath = request.getContextPath();
    String userName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");
    String currentURI = request.getRequestURI();
    String initial = (userName != null && userName.length() > 0)
            ? userName.substring(0, 1).toUpperCase() : "?";
%>
<aside class="sidebar">
    <div class="sidebar-brand">&#127915; Helpdesk</div>

    <nav class="sidebar-nav">
        <div class="sidebar-section">Main</div>
        <a href="<%= ctxPath %>/dashboard"
           class="<%= currentURI.contains("/dashboard") ? "active" : "" %>">
            &#128202; Dashboard
        </a>
        <a href="<%= ctxPath %>/tickets"
           class="<%= currentURI.contains("/tickets") ? "active" : "" %>">
            &#127991; My Tickets
        </a>
        <a href="<%= ctxPath %>/kb"
           class="<%= currentURI.contains("/kb") ? "active" : "" %>">
            &#128218; Knowledge Base
        </a>

        <% if ("agent".equals(userRole) || "admin".equals(userRole)) { %>
        <div class="sidebar-section">Agent</div>
        <a href="<%= ctxPath %>/tickets?status=OPEN"
           class="">
            &#128203; All Tickets
        </a>
        <% } %>

        <% if ("admin".equals(userRole)) { %>
        <div class="sidebar-section">Admin</div>
        <a href="<%= ctxPath %>/admin"
           class="<%= currentURI.contains("/admin") && !currentURI.contains("users") ? "active" : "" %>">
            &#128736; Admin Panel
        </a>
        <a href="<%= ctxPath %>/report"
           class="<%= currentURI.contains("/report") ? "active" : "" %>">
            &#128196; Reports
        </a>
        <a href="<%= ctxPath %>/admin?action=users"
           class="<%= currentURI.contains("users") ? "active" : "" %>">
            &#128101; User Management
        </a>
        <% } %>
    </nav>

    <div class="sidebar-footer">
        <div class="sidebar-avatar"><%= initial %></div>
        <div class="sidebar-user-info">
            <div class="sidebar-user-name"><%= userName != null ? userName : "Guest" %></div>
            <div class="sidebar-user-role"><%= userRole != null ? userRole : "" %></div>
        </div>
        <a href="<%= ctxPath %>/login?action=logout" class="sidebar-logout" title="Logout">&#9211;</a>
    </div>
</aside>
