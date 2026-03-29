<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%
    String tbUserName = (String) session.getAttribute("userName");
    String tbUserRole = (String) session.getAttribute("userRole");
    String tbCtx = request.getContextPath();

    String roleBadgeClass = "badge-user";
    if ("admin".equals(tbUserRole)) roleBadgeClass = "badge-admin";
    else if ("agent".equals(tbUserRole)) roleBadgeClass = "badge-agent";
%>
<header class="topbar">
    <div class="topbar-title"><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "Dashboard" %></div>
    <div class="topbar-right">
        <span class="topbar-user"><%= tbUserName != null ? tbUserName : "Guest" %></span>
        <span class="badge <%= roleBadgeClass %>"><%= tbUserRole != null ? tbUserRole : "" %></span>
        <a href="<%= tbCtx %>/login?action=logout" class="btn btn-outline btn-sm">Logout</a>
    </div>
</header>
