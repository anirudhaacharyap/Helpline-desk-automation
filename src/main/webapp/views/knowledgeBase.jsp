<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.helpdesk.model.KnowledgeBase" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Knowledge Base");
    String ctxPath = request.getContextPath();
    String userRole = (String) session.getAttribute("userRole");
    boolean canAdd = "agent".equals(userRole) || "admin".equals(userRole);
    List<KnowledgeBase> kbEntries = (List<KnowledgeBase>) request.getAttribute("kbEntries");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Knowledge Base — Helpdesk</title>
    <link rel="stylesheet" href="<%= ctxPath %>/css/style.css">
</head>
<body>
<div class="app-layout">
    <jsp:include page="/views/includes/sidebar.jsp" />
    <div class="main-content">
        <jsp:include page="/views/includes/topbar.jsp" />
        <div class="page-body">
<% if ("1".equals(request.getParameter("added"))) { %>
            <div class="alert alert-success mb-16">Knowledge base entry saved.</div>
<% } else if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger mb-16">Unable to save the knowledge base entry.</div>
<% } %>

            <!-- Search Bar -->
            <div class="flex-between mb-16">
                <div style="flex:1; max-width:500px;">
                    <input type="text" id="kbSearch" class="form-control"
                           placeholder="&#128269; Search knowledge base..." style="font-size:15px; padding:12px 16px;">
                </div>
<% if (canAdd) { %>
                <button class="btn btn-primary btn-sm" onclick="document.getElementById('addKBModal').classList.add('active')">+ Add Entry</button>
<% } %>
            </div>

            <!-- Category Tabs -->
            <div class="tabs" id="categoryTabs">
                <button class="tab active" data-cat="All" onclick="filterCategory('All', this)">All</button>
                <button class="tab" data-cat="Hardware" onclick="filterCategory('Hardware', this)">Hardware</button>
                <button class="tab" data-cat="Software" onclick="filterCategory('Software', this)">Software</button>
                <button class="tab" data-cat="Network" onclick="filterCategory('Network', this)">Network</button>
                <button class="tab" data-cat="Access" onclick="filterCategory('Access', this)">Access</button>
                <button class="tab" data-cat="Other" onclick="filterCategory('Other', this)">Other</button>
            </div>

            <!-- KB Cards Grid -->
            <div class="kb-grid" id="kbGrid">
                <div class="empty-state" style="grid-column:1/-1;">
                    <div class="empty-icon">&#128218;</div>
                    <div class="empty-text">Start typing to search the knowledge base</div>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- Add KB Entry Modal -->
<% if (canAdd) { %>
<div id="addKBModal" class="modal-overlay">
    <div class="modal-box">
        <h3>Add KB Entry</h3>
        <form id="addKBForm" method="post" action="<%= ctxPath %>/kb">
            <div class="form-group">
                <label>Keyword / Title</label>
                <input type="text" id="kbKeyword" name="keyword" class="form-control" required>
            </div>
            <div class="form-group">
                <label>Solution</label>
                <textarea id="kbSolution" name="solution" class="form-control" rows="4" required></textarea>
            </div>
            <div class="form-group">
                <label>Category</label>
                <select id="kbCategory" name="category" class="form-control">
                    <option value="Hardware">Hardware</option>
                    <option value="Software">Software</option>
                    <option value="Network">Network</option>
                    <option value="Access">Access</option>
                    <option value="Other">Other</option>
                </select>
            </div>
            <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:20px;">
                <button type="button" class="btn btn-outline btn-sm" onclick="document.getElementById('addKBModal').classList.remove('active')">Cancel</button>
                <button type="submit" class="btn btn-primary btn-sm">Save Entry</button>
            </div>
        </form>
    </div>
</div>
<% } %>

<script>
var ctx = '<%= ctxPath %>';
var allResults = [
<%
    if (kbEntries != null) {
        for (int i = 0; i < kbEntries.size(); i++) {
            KnowledgeBase kb = kbEntries.get(i);
%>
    {
        kbId: <%= kb.getKbId() %>,
        keyword: "<%= kb.getKeyword() == null ? "" : kb.getKeyword().replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", "\\n") %>",
        solution: "<%= kb.getSolution() == null ? "" : kb.getSolution().replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", "\\n") %>",
        category: "<%= kb.getCategory() == null ? "" : kb.getCategory().replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", "\\n") %>"
    }<%= i < kbEntries.size() - 1 ? "," : "" %>
<%
        }
    }
%>
];
var activeCategory = 'All';
var searchTimer = null;

renderCards();

document.getElementById('kbSearch').addEventListener('keyup', function() {
    clearTimeout(searchTimer);
    var q = this.value.trim();
    if (q.length < 3) {
        allResults = [
<%
    if (kbEntries != null) {
        for (int i = 0; i < kbEntries.size(); i++) {
            KnowledgeBase kb = kbEntries.get(i);
%>
        {
            kbId: <%= kb.getKbId() %>,
            keyword: "<%= kb.getKeyword() == null ? "" : kb.getKeyword().replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", "\\n") %>",
            solution: "<%= kb.getSolution() == null ? "" : kb.getSolution().replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", "\\n") %>",
            category: "<%= kb.getCategory() == null ? "" : kb.getCategory().replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", "\\n") %>"
        }<%= i < kbEntries.size() - 1 ? "," : "" %>
<%
        }
    }
%>
        ];
        renderCards();
        return;
    }
    searchTimer = setTimeout(function() {
        fetch(ctx + '/kb/search?q=' + encodeURIComponent(q))
            .then(function(r) { return r.json(); })
            .then(function(data) {
                allResults = data;
                renderCards();
            })
            .catch(function() {
                allResults = [];
                renderCards();
            });
    }, 400);
});

function filterCategory(cat, btn) {
    activeCategory = cat;
    document.querySelectorAll('.tab').forEach(function(t) { t.classList.remove('active'); });
    btn.classList.add('active');
    renderCards();
}

function renderCards() {
    var grid = document.getElementById('kbGrid');
    var filtered = allResults;
    if (activeCategory !== 'All') {
        filtered = allResults.filter(function(kb) { return kb.category === activeCategory; });
    }
    if (!filtered.length) {
        grid.innerHTML = '<div class="empty-state" style="grid-column:1/-1;"><div class="empty-text">No results found</div></div>';
        return;
    }
    var html = '';
    filtered.forEach(function(kb) {
        var catClass = 'badge-open';
        html += '<div class="card">'
            + '<div class="card-body">'
            + '<div style="font-weight:600; color:#1B3A6B; margin-bottom:8px;">' + escapeHtml(kb.keyword) + '</div>'
            + '<p style="font-size:13px; color:#475569; line-height:1.6; margin-bottom:12px;">' + escapeHtml(kb.solution) + '</p>'
            + '<div class="flex-between">'
            + '<span class="badge ' + catClass + '">' + escapeHtml(kb.category) + '</span>'
            + '</div>'
            + '</div></div>';
    });
    grid.innerHTML = html;
}

function escapeHtml(s) {
    if (!s) return '';
    var div = document.createElement('div');
    div.textContent = s;
    return div.innerHTML;
}
</script>
</body>
</html>
