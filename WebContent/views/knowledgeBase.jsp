<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.helpdesk.model.KnowledgeBase" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String userRole = (String) session.getAttribute("userRole");
    String userName = (String) session.getAttribute("userName");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Knowledge Base — Helpdesk</title>
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
                        <a class="nav-link" href="${pageContext.request.contextPath}/tickets">Tickets</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/kb">Knowledge Base</a>
                    </li>
                </ul>
                <span class="navbar-text me-3">
                    Welcome, <strong><%= userName %></strong>
                </span>
                <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/login?action=logout">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <h2>Knowledge Base</h2>

        <!-- Search -->
        <div class="mb-3">
            <input type="text" class="form-control" id="kb-search"
                   placeholder="Search knowledge base articles...">
        </div>

        <div id="kb-results">
            <!-- KB articles will be loaded here -->
            <p class="text-muted">Start typing to search for solutions...</p>
        </div>

        <!-- Category tabs -->
        <div class="mt-4">
            <h5>Browse by Category</h5>
            <div class="btn-group mb-3">
                <button class="btn btn-outline-primary kb-cat-btn" data-category="Hardware">Hardware</button>
                <button class="btn btn-outline-primary kb-cat-btn" data-category="Software">Software</button>
                <button class="btn btn-outline-primary kb-cat-btn" data-category="Network">Network</button>
                <button class="btn btn-outline-primary kb-cat-btn" data-category="Access">Access</button>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let searchTimer;
        document.getElementById('kb-search').addEventListener('input', function() {
            clearTimeout(searchTimer);
            const query = this.value.trim();
            if (query.length < 3) {
                document.getElementById('kb-results').innerHTML =
                    '<p class="text-muted">Type at least 3 characters to search...</p>';
                return;
            }
            searchTimer = setTimeout(() => {
                fetch('${pageContext.request.contextPath}/kb/search?q=' + encodeURIComponent(query))
                    .then(r => r.json())
                    .then(data => {
                        const container = document.getElementById('kb-results');
                        if (data.length === 0) {
                            container.innerHTML = '<p class="text-muted">No articles found.</p>';
                            return;
                        }
                        container.innerHTML = '';
                        data.forEach(kb => {
                            const card = document.createElement('div');
                            card.className = 'card mb-2';
                            card.innerHTML = '<div class="card-body">' +
                                '<h5 class="card-title">' + kb.keyword + '</h5>' +
                                '<p class="card-text">' + kb.solution + '</p>' +
                                '<small class="text-muted">Category: ' + kb.category + '</small>' +
                                '</div>';
                            container.appendChild(card);
                        });
                    })
                    .catch(err => console.error('KB search failed:', err));
            }, 500);
        });
    </script>
</body>
</html>
