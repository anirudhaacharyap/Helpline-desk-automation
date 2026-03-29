<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%
    request.setAttribute("pageTitle", "Reports");
    String ctxPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports — Helpdesk</title>
    <link rel="stylesheet" href="<%= ctxPath %>/css/style.css">
</head>
<body>
<div class="app-layout">
    <jsp:include page="/views/includes/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="/views/includes/topbar.jsp" />
        <div class="page-body">

            <!-- Report Generator -->
            <div class="card mb-24" style="max-width:600px;">
                <div class="card-header">Generate Report</div>
                <div class="card-body">
                    <form id="reportForm" onsubmit="generateReport(event)">
                        <div class="form-group">
                            <label for="reportType">Report Type</label>
                            <select id="reportType" class="form-control">
                                <option value="ticket_summary">Ticket Summary</option>
                                <option value="agent_performance">Agent Performance</option>
                                <option value="sla_compliance">SLA Compliance</option>
                            </select>
                        </div>
                        <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
                            <div class="form-group">
                                <label for="dateFrom">Date From</label>
                                <input type="date" id="dateFrom" class="form-control">
                            </div>
                            <div class="form-group">
                                <label for="dateTo">Date To</label>
                                <input type="date" id="dateTo" class="form-control">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">&#128196; Generate PDF</button>
                    </form>
                </div>
            </div>

            <!-- Quick Stats -->
            <div class="card">
                <div class="card-header">Quick Stats</div>
                <div class="card-body">
                    <div style="display:grid; grid-template-columns:1fr 1fr 1fr; gap:20px;">
                        <!-- By Priority -->
                        <div>
                            <h4 style="font-size:13px; font-weight:600; color:#1B3A6B; margin-bottom:10px;">By Priority</h4>
                            <table class="data-table">
                                <thead><tr><th>Priority</th><th>Count</th></tr></thead>
                                <tbody>
                                    <tr><td><span class="badge badge-critical">Critical</span></td><td id="qCritical">—</td></tr>
                                    <tr><td><span class="badge badge-high">High</span></td><td id="qHigh">—</td></tr>
                                    <tr><td><span class="badge badge-medium">Medium</span></td><td id="qMedium">—</td></tr>
                                    <tr><td><span class="badge badge-low">Low</span></td><td id="qLow">—</td></tr>
                                </tbody>
                            </table>
                        </div>
                        <!-- By Status -->
                        <div>
                            <h4 style="font-size:13px; font-weight:600; color:#1B3A6B; margin-bottom:10px;">By Status</h4>
                            <table class="data-table">
                                <thead><tr><th>Status</th><th>Count</th></tr></thead>
                                <tbody>
                                    <tr><td><span class="badge badge-open">Open</span></td><td id="qOpen">—</td></tr>
                                    <tr><td><span class="badge badge-in_progress">In Progress</span></td><td id="qInProg">—</td></tr>
                                    <tr><td><span class="badge badge-resolved">Resolved</span></td><td id="qResolved">—</td></tr>
                                    <tr><td><span class="badge badge-closed">Closed</span></td><td id="qClosed">—</td></tr>
                                </tbody>
                            </table>
                        </div>
                        <!-- By Category -->
                        <div>
                            <h4 style="font-size:13px; font-weight:600; color:#1B3A6B; margin-bottom:10px;">By Category</h4>
                            <table class="data-table">
                                <thead><tr><th>Category</th><th>Count</th></tr></thead>
                                <tbody id="qCatBody">
                                    <tr><td colspan="2" style="color:#94a3b8;">Loading...</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
function generateReport(e) {
    e.preventDefault();
    var url = '<%= ctxPath %>/report';
    var params = [];
    var df = document.getElementById('dateFrom').value;
    var dt = document.getElementById('dateTo').value;
    if (df) params.push('dateFrom=' + df);
    if (dt) params.push('dateTo=' + dt);
    if (params.length) url += '?' + params.join('&');
    window.open(url, '_blank');
}

// Load quick stats via AJAX
fetch('<%= ctxPath %>/admin?action=stats')
    .then(function(r) { return r.json(); })
    .then(function(d) {
        if (d.openCount !== undefined) document.getElementById('qOpen').textContent = d.openCount;
        if (d.resolvedToday !== undefined) document.getElementById('qResolved').textContent = d.resolvedToday;
        if (d.breachCount !== undefined) document.getElementById('qInProg').textContent = d.inProgressCount || 0;
    })
    .catch(function() {});
</script>
</body>
</html>
