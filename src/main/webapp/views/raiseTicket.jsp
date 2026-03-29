<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%
    request.setAttribute("pageTitle", "Raise a Ticket");
    String ctxPath = request.getContextPath();
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Raise Ticket — Helpdesk</title>
    <link rel="stylesheet" href="<%= ctxPath %>/css/style.css">
</head>
<body>
<div class="app-layout">
    <jsp:include page="/views/includes/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="/views/includes/topbar.jsp" />
        <div class="page-body" style="display:flex; justify-content:center;">

            <div class="card" style="width:700px; max-width:100%;">
                <div class="card-header">Raise a Support Ticket</div>
                <div class="card-body">

<% if (error != null) { %>
                    <div class="alert alert-error"><%= error %></div>
<% } %>

                    <form method="POST" action="<%= ctxPath %>/ticket">
                        <div class="form-group">
                            <label for="title">Title</label>
                            <input type="text" id="title" name="title" class="form-control"
                                   placeholder="Brief summary of your issue" required>
                        </div>

                        <div class="form-group">
                            <label for="category">Category</label>
                            <select id="category" name="category" class="form-control" required>
                                <option value="">Select a category</option>
                                <option value="Hardware">Hardware</option>
                                <option value="Software">Software</option>
                                <option value="Network">Network</option>
                                <option value="Access">Access</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="description">Description</label>
                            <textarea id="description" name="description" class="form-control"
                                      rows="6" placeholder="Describe your issue in detail..." required></textarea>
                        </div>

                        <!-- KB Suggestions -->
                        <div id="kb-suggestions" class="mb-16"></div>

                        <button type="submit" class="btn btn-primary btn-block">Submit Ticket</button>
                    </form>

                    <div class="alert alert-info" style="margin-top:16px;">
                        &#8505;&#65039; Priority and SLA deadline are assigned automatically based on your description.
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
(function() {
    var timer = null;
    var descEl = document.getElementById('description');
    var sugBox = document.getElementById('kb-suggestions');
    var ctx = '<%= ctxPath %>';

    descEl.addEventListener('keyup', function() {
        clearTimeout(timer);
        var q = descEl.value.trim();
        if (q.length < 3) { sugBox.innerHTML = ''; return; }
        timer = setTimeout(function() {
            fetch(ctx + '/kb/search?q=' + encodeURIComponent(q))
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (!data.length) { sugBox.innerHTML = ''; return; }
                    var html = '<div style="font-size:12px;font-weight:600;color:#64748b;margin-bottom:8px;">&#128161; Possible solutions from Knowledge Base:</div>';
                    data.forEach(function(kb) {
                        html += '<div class="kb-suggestion">'
                            + '<div class="kb-title">' + kb.keyword + ' <span class="badge badge-open">' + kb.category + '</span></div>'
                            + '<div class="kb-body">' + kb.solution + '</div>'
                            + '</div>';
                    });
                    sugBox.innerHTML = html;
                })
                .catch(function() { sugBox.innerHTML = ''; });
        }, 500);
    });
})();
</script>
</body>
</html>
