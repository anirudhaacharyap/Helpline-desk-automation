-- ============================================================
--  HELPDESK DATABASE — helpdesk_db
--  PostgreSQL 15 Schema
--  Run this entire script to initialise the schema + seed data
-- ============================================================

-- ── USERS ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    user_id       SERIAL       PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role          VARCHAR(10)  NOT NULL DEFAULT 'user'
                  CHECK (role IN ('user', 'agent', 'admin')),
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    is_active     BOOLEAN      DEFAULT TRUE
);

-- ── TICKETS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tickets (
    ticket_id       SERIAL        PRIMARY KEY,
    title           VARCHAR(200)  NOT NULL,
    description     TEXT          NOT NULL,
    priority        VARCHAR(10)   NOT NULL
                    CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    status          VARCHAR(15)   DEFAULT 'OPEN'
                    CHECK (status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED',
                                      'CLOSED', 'SLA_BREACHED')),
    category        VARCHAR(100)  NOT NULL,
    created_by      INT           NOT NULL,
    assigned_to     INT,
    created_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    sla_deadline    TIMESTAMP     NOT NULL,
    resolved_at     TIMESTAMP     NULL,
    is_sla_breached BOOLEAN       DEFAULT FALSE,
    FOREIGN KEY (created_by)  REFERENCES users(user_id),
    FOREIGN KEY (assigned_to) REFERENCES users(user_id)
);

-- ── TICKET COMMENTS ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ticket_comments (
    comment_id   SERIAL    PRIMARY KEY,
    ticket_id    INT       NOT NULL,
    user_id      INT       NOT NULL,
    comment      TEXT      NOT NULL,
    commented_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)   REFERENCES users(user_id)
);

-- ── KNOWLEDGE BASE ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS knowledge_base (
    kb_id       SERIAL       PRIMARY KEY,
    keyword     VARCHAR(200) NOT NULL,
    solution    TEXT         NOT NULL,
    category    VARCHAR(100) NOT NULL,
    view_count  INT          DEFAULT 0,
    created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- ── SLA CONFIGURATION ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS sla_config (
    sla_id             SERIAL      PRIMARY KEY,
    priority_level     VARCHAR(10) UNIQUE NOT NULL
                       CHECK (priority_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    resolution_hours   INT         NOT NULL,
    escalation_hours   INT         NOT NULL
);

-- ── AUDIT LOG ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS audit_log (
    log_id      SERIAL       PRIMARY KEY,
    user_id     INT          NOT NULL,
    action      VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id   INT,
    log_time    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- ============================================================
--  SEED DATA
-- ============================================================

-- ── SLA Config Rows ────────────────────────────────────────
INSERT INTO sla_config (priority_level, resolution_hours, escalation_hours) VALUES
    ('CRITICAL', 1,  1),
    ('HIGH',     4,  2),
    ('MEDIUM',   24, 12),
    ('LOW',      72, 48)
ON CONFLICT (priority_level) DO NOTHING;

-- ── Default Users ──────────────────────────────────────────
-- Passwords: admin123, agent123, user123 (BCrypt hashed with cost 12)
INSERT INTO users (name, email, password_hash, role) VALUES
    ('Admin User',  'admin@helpdesk.com', '$2a$12$LJ3m4yst2ReHiNSKZGRYp.OzURMv6J5fVEHGn9beUf8MHphfK6XpO', 'admin'),
    ('Agent Smith',  'agent@helpdesk.com', '$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'agent'),
    ('John Doe',     'user@helpdesk.com',  '$2a$12$WApznUPhDubN0oeveSZHqeYBdVgnOfaLE03nHY7E5C0eEFf6Wzh2W', 'user')
ON CONFLICT (email) DO NOTHING;

-- ── Sample Knowledge Base Entries ──────────────────────────
INSERT INTO knowledge_base (keyword, solution, category) VALUES
    ('vpn not working',
     '1. Restart VPN client. 2. Check network connection. 3. Re-enter credentials. 4. Contact IT if issue persists.',
     'Network'),
    ('forgot password',
     'Visit the login page and click "Forgot Password". Enter your email to receive a reset link. Check spam folder if not received within 5 minutes.',
     'Access'),
    ('printer offline',
     '1. Check USB/network cable connection. 2. Restart the print spooler service. 3. Reinstall printer driver from manufacturer website.',
     'Hardware'),
    ('email not loading',
     'Clear browser cache and cookies. If using Outlook: File > Account Settings > Repair. For webmail: try incognito/private mode.',
     'Software'),
    ('slow computer',
     '1. Restart your computer. 2. Check available disk space (need >10% free). 3. Run a full antivirus scan. 4. Close unnecessary background applications.',
     'Hardware')
ON CONFLICT DO NOTHING;


-- ============================================================
--  END OF SCHEMA
-- ============================================================
