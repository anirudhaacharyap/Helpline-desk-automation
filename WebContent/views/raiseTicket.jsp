<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    <title>Raise Ticket — Helpdesk</title>
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
                        <a class="nav-link active" href="${pageContext.request.contextPath}/ticket?action=new">Raise Ticket</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/tickets">Ticket List</a>
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
        <h2>Raise a Support Ticket</h2>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger" role="alert">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/ticket" method="post">
            <div class="mb-3">
                <label for="title" class="form-label">Title</label>
                <input type="text" class="form-control" id="title" name="title"
                       placeholder="Brief summary of the issue" required maxlength="200">
            </div>

            <div class="mb-3">
                <label for="category" class="form-label">Category</label>
                <select class="form-select" id="category" name="category" required>
                    <option value="" disabled selected>Select a category</option>
                    <option value="Hardware">Hardware</option>
                    <option value="Software">Software</option>
                    <option value="Network">Network</option>
                    <option value="Access">Access</option>
                    <option value="Other">Other</option>
                </select>
            </div>

            <div class="mb-3">
                <label for="description" class="form-label">Description</label>
                <textarea class="form-control" id="description" name="description"
                          rows="5" placeholder="Describe your issue in detail..." required></textarea>
            </div>

            <!-- AJAX KB Suggestion Area -->
            <div id="kb-suggestions" class="mb-3"></div>

            <button type="submit" class="btn btn-primary">Submit Ticket</button>
            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-secondary ms-2">Cancel</a>
        </form>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // AJAX KB Suggestion — debounced search from LLD Section 5.1
        let debounceTimer;

        document.getElementById('description').addEventListener('input', function() {
            clearTimeout(debounceTimer);
            const query = this.value.trim();

            if (query.length < 3) {
                document.getElementById('kb-suggestions').innerHTML = '';
                return;
            }

            debounceTimer = setTimeout(() => {
                fetch('${pageContext.request.contextPath}/kb/search?q=' + encodeURIComponent(query))
                    .then(response => response.json())
                    .then(data => renderSuggestions(data))
                    .catch(err => console.error('KB lookup failed:', err));
            }, 500);   // wait 500ms after user stops typing
        });

        function renderSuggestions(results) {
            const container = document.getElementById('kb-suggestions');
            container.innerHTML = '';

            if (results.length === 0) return;

            const header = document.createElement('p');
            header.innerHTML = '<strong>💡 Possible Solutions Found:</strong>';
            container.appendChild(header);

            results.forEach(kb => {
                const card = document.createElement('div');
                card.className = 'kb-card';
                card.innerHTML = `
                    <h5>${kb.keyword}</h5>
                    <p>${kb.solution}</p>
                    <small class="text-muted">Category: ${kb.category}</small>
                    <button type="button" class="btn btn-sm btn-outline-success ms-2"
                            onclick="dismissKB(${kb.kbId}, this.parentElement)">
                        This solved my issue — dismiss
                    </button>`;
                container.appendChild(card);
            });
        }

        function dismissKB(kbId, card) {
            // Increment view count asynchronously
            fetch('${pageContext.request.contextPath}/kb/search?action=view&id=' + kbId, { method: 'POST' });
            card.remove();
        }
    </script>
</body>
</html>
