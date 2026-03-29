<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.helpdesk.model.Ticket, com.helpdesk.model.Comment, com.helpdesk.model.User, java.util.List, java.sql.Timestamp" %>
<%
    Ticket ticket = (Ticket) request.getAttribute("ticket");
    List<Comment> comments = (List<Comment>) request.getAttribute("comments");
    List<User> agents = (List<User>) request.getAttribute("agents");
    String ctxPath = request.getContextPath();
    String userRole = (String) session.getAttribute("userRole");
    int userId = (int) session.getAttribute("userId");
    request.setAttribute("pageTitle", "Ticket #" + ticket.getTicketId());

    String pClass = "badge-" + ticket.getPriority().toLowerCase();
    String sClass = "badge-" + ticket.getStatus().toLowerCase();
    String status = ticket.getStatus();

    long now = System.currentTimeMillis();
    long deadline = ticket.getSlaDeadline() != null ? ticket.getSlaDeadline().getTime() : 0;
    long remaining = deadline - now;
    boolean breached = remaining < 0 && !"RESOLVED".equals(status) && !"CLOSED".equals(status);
    String timeLeft = "";
    if (deadline > 0 && !breached) {
        long hrs = remaining / 3600000;
        long mins = (remaining % 3600000) / 60000;
        timeLeft = hrs + "h " + mins + "m remaining";
    } else if (breached) {
        long overMs = -remaining;
        long hrs = overMs / 3600000;
        long mins = (overMs % 3600000) / 60000;
        timeLeft = hrs + "h " + mins + "m overdue";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ticket #<%= ticket.getTicketId() %> — Helpdesk</title>
    <link rel="stylesheet" href="<%= ctxPath %>/css/style.css">
</head>
<body>
<div class="app-layout">
    <jsp:include page="/views/includes/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="/views/includes/topbar.jsp" />
        <div class="page-body">

            <div class="detail-layout">
                <!-- LEFT COLUMN: Info + Comments -->
                <div>
                    <h2 style="color:#1B3A6B; margin-bottom:16px;"><%= ticket.getTitle() %></h2>

                    <div class="card mb-24">
                        <div class="card-header">Description</div>
                        <div class="card-body">
                            <p style="line-height:1.7; white-space:pre-wrap;"><%= ticket.getDescription() %></p>
                        </div>
                    </div>

                    <!-- Comments -->
                    <div class="card">
                        <div class="card-header">Comments &amp; Updates (<%= comments != null ? comments.size() : 0 %>)</div>
                        <div class="card-body">
<% if (comments == null || comments.isEmpty()) { %>
                            <div class="empty-state" style="padding:24px 0;">
                                <div class="empty-text">No comments yet</div>
                            </div>
<% } else { %>
<%     for (Comment c : comments) {
           String cInitial = c.getUserName() != null && c.getUserName().length() > 0
                             ? c.getUserName().substring(0,1).toUpperCase() : "?";
           boolean isAgent = c.getUserId() != userId;
%>
                            <div class="comment-item <%= isAgent ? "agent-comment" : "" %>">
                                <div class="comment-avatar"><%= cInitial %></div>
                                <div>
                                    <div class="comment-meta">
                                        <strong><%= c.getUserName() %></strong>
                                        &middot; <%= c.getCommentedAt() != null ? c.getCommentedAt().toString().substring(0,16) : "" %>
                                    </div>
                                    <div class="comment-text"><%= c.getComment() %></div>
                                </div>
                            </div>
<%     } %>
<% } %>

                            <!-- Add Comment Form -->
                            <form method="POST" action="<%= ctxPath %>/ticket/update" style="margin-top:16px;">
                                <input type="hidden" name="ticketId" value="<%= ticket.getTicketId() %>">
                                <input type="hidden" name="action" value="addComment">
                                <div class="form-group mb-8">
                                    <textarea name="comment" class="form-control" rows="3"
                                              placeholder="Write a comment..." required></textarea>
                                </div>
                                <button type="submit" class="btn btn-primary btn-sm">Post Comment</button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- RIGHT COLUMN: Metadata + Actions -->
                <div>
                    <div class="card mb-24">
                        <div class="card-header">Ticket Details</div>
                        <div class="card-body">
                            <table style="width:100%; font-size:13px;">
                                <tr><td style="padding:6px 0;color:#64748b;">Ticket ID</td><td style="padding:6px 0;font-weight:600;">#<%= ticket.getTicketId() %></td></tr>
                                <tr><td style="padding:6px 0;color:#64748b;">Status</td><td style="padding:6px 0;"><span class="badge <%= sClass %>" style="font-size:13px;"><%= status %></span></td></tr>
                                <tr><td style="padding:6px 0;color:#64748b;">Priority</td><td style="padding:6px 0;"><span class="badge <%= pClass %>" style="font-size:13px;"><%= ticket.getPriority() %></span></td></tr>
                                <tr><td style="padding:6px 0;color:#64748b;">Category</td><td style="padding:6px 0;"><%= ticket.getCategory() %></td></tr>
                                <tr><td style="padding:6px 0;color:#64748b;">Created By</td><td style="padding:6px 0;">User #<%= ticket.getCreatedBy() %></td></tr>
                                <tr><td style="padding:6px 0;color:#64748b;">Assigned To</td><td style="padding:6px 0;"><%= ticket.getAssignedTo() > 0 ? "Agent #" + ticket.getAssignedTo() : "Unassigned" %></td></tr>
                                <tr><td style="padding:6px 0;color:#64748b;">Created At</td><td style="padding:6px 0;"><%= ticket.getCreatedAt() != null ? ticket.getCreatedAt().toString().substring(0,16) : "-" %></td></tr>
                                <tr>
                                    <td style="padding:6px 0;color:#64748b;">SLA Deadline</td>
                                    <td style="padding:6px 0;" class="<%= breached ? "sla-breached" : "" %>">
                                        <%= ticket.getSlaDeadline() != null ? ticket.getSlaDeadline().toString().substring(0,16) : "-" %>
                                        <br><span style="font-size:11px;"><%= timeLeft %></span>
                                    </td>
                                </tr>
                                <% if (ticket.getResolvedAt() != null) { %>
                                <tr><td style="padding:6px 0;color:#64748b;">Resolved At</td><td style="padding:6px 0;"><%= ticket.getResolvedAt().toString().substring(0,16) %></td></tr>
                                <% } %>
                            </table>
                        </div>
                    </div>

                    <!-- Status Update — agent / admin only -->
<% if ("agent".equals(userRole) || "admin".equals(userRole)) { %>
                    <div class="card mb-24">
                        <div class="card-header">Update Status</div>
                        <div class="card-body">
                            <form method="POST" action="<%= ctxPath %>/ticket/update">
                                <input type="hidden" name="ticketId" value="<%= ticket.getTicketId() %>">
                                <input type="hidden" name="action" value="changeStatus">
                                <div class="form-group">
                                    <select name="newStatus" class="form-control">
<% if ("OPEN".equals(status)) { %>
                                        <option value="IN_PROGRESS">In Progress</option>
<% } %>
<% if ("IN_PROGRESS".equals(status) || "OPEN".equals(status)) { %>
                                        <option value="RESOLVED">Resolved</option>
<% } %>
<% if ("RESOLVED".equals(status)) { %>
                                        <option value="CLOSED">Closed</option>
<% } %>
<% if ("SLA_BREACHED".equals(status)) { %>
                                        <option value="IN_PROGRESS">In Progress</option>
                                        <option value="RESOLVED">Resolved</option>
<% } %>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-accent btn-sm btn-block">Update</button>
                            </form>
                        </div>
                    </div>
<% } %>

                    <!-- Reassign — admin only -->
<% if ("admin".equals(userRole) && agents != null && !agents.isEmpty()) { %>
                    <div class="card">
                        <div class="card-header">Reassign Agent</div>
                        <div class="card-body">
                            <form method="POST" action="<%= ctxPath %>/ticket/update">
                                <input type="hidden" name="ticketId" value="<%= ticket.getTicketId() %>">
                                <input type="hidden" name="action" value="assign">
                                <div class="form-group">
                                    <select name="agentId" class="form-control">
<%     for (User a : agents) { %>
                                        <option value="<%= a.getUserId() %>" <%= a.getUserId() == ticket.getAssignedTo() ? "selected" : "" %>>
                                            <%= a.getName() %> (#<%= a.getUserId() %>)
                                        </option>
<%     } %>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-outline btn-sm btn-block">Reassign</button>
                            </form>
                        </div>
                    </div>
<% } %>
                </div>
            </div>

        </div>
    </div>
</div>
</body>
</html>
