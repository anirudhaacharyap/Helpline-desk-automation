/**
 * Helpdesk Support Ticket Automation — Main JavaScript
 * Common utility functions used across JSP pages.
 */

/**
 * Show a temporary alert banner at the top of the page.
 * @param {string} message - Alert message
 * @param {string} type - Bootstrap alert type: 'success', 'danger', 'warning', 'info'
 */
function showAlert(message, type) {
    const container = document.querySelector('.container');
    if (!container) return;

    const alert = document.createElement('div');
    alert.className = 'alert alert-' + type + ' alert-dismissible fade show mt-3';
    alert.role = 'alert';
    alert.innerHTML = message +
        '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>';

    container.insertBefore(alert, container.firstChild.nextSibling);

    // Auto-dismiss after 5 seconds
    setTimeout(() => {
        alert.classList.remove('show');
        setTimeout(() => alert.remove(), 150);
    }, 5000);
}

/**
 * Show an error banner for AJAX failures.
 * @param {string} message - Error message to display
 */
function showErrorBanner(message) {
    showAlert(message, 'danger');
}

/**
 * Confirm a destructive action before submitting.
 * @param {string} message - Confirmation message
 * @returns {boolean} true if confirmed
 */
function confirmAction(message) {
    return confirm(message || 'Are you sure?');
}

/**
 * Format a timestamp for display.
 * @param {string} timestamp - ISO timestamp string
 * @returns {string} formatted date/time
 */
function formatTimestamp(timestamp) {
    if (!timestamp) return 'N/A';
    const date = new Date(timestamp);
    return date.toLocaleString();
}

// Parse URL params for success/error messages on page load
document.addEventListener('DOMContentLoaded', function() {
    const params = new URLSearchParams(window.location.search);
    if (params.has('success')) {
        showAlert(decodeURIComponent(params.get('success')), 'success');
    }
    if (params.has('error')) {
        showAlert(decodeURIComponent(params.get('error')), 'danger');
    }
});
