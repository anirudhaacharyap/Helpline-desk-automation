-- ============================================================
--  HELPDESK DATABASE — Oracle XE
--  Run with F5 (Run Script) in SQL Developer
--  Connected as: helpdesk_user
-- ============================================================

-- ── CLEAN UP (safe to rerun) ────────────────────────────────
BEGIN EXECUTE IMMEDIATE 'DROP TABLE audit_log CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE ticket_comments CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE knowledge_base CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE sla_config CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE tickets CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE users CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE users_seq'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE tickets_seq'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE comments_seq'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE kb_seq'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE sla_seq'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE audit_seq'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- ── SEQUENCES ───────────────────────────────────────────────
CREATE SEQUENCE users_seq    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE tickets_seq  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE comments_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE kb_seq       START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE sla_seq      START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE audit_seq    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- ── USERS ───────────────────────────────────────────────────
CREATE TABLE users (
                       user_id       NUMBER        PRIMARY KEY,
                       name          VARCHAR2(100) NOT NULL,
                       email         VARCHAR2(150) NOT NULL UNIQUE,
                       password_hash VARCHAR2(255) NOT NULL,
                       role          VARCHAR2(10)  DEFAULT 'user' NOT NULL
                  CONSTRAINT chk_user_role CHECK (role IN ('user','agent','admin')),
                       created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
                       is_active     NUMBER(1)     DEFAULT 1
                  CONSTRAINT chk_user_active CHECK (is_active IN (0,1))
);
/

CREATE OR REPLACE TRIGGER users_bir
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    IF :NEW.user_id IS NULL THEN
SELECT users_seq.NEXTVAL INTO :NEW.user_id FROM dual;
END IF;
END;
/

-- ── TICKETS ─────────────────────────────────────────────────
CREATE TABLE tickets (
                         ticket_id       NUMBER        PRIMARY KEY,
                         title           VARCHAR2(200) NOT NULL,
                         description     CLOB          NOT NULL,
                         priority        VARCHAR2(10)  NOT NULL
                    CONSTRAINT chk_priority CHECK (priority IN ('LOW','MEDIUM','HIGH','CRITICAL')),
                         status          VARCHAR2(15)  DEFAULT 'OPEN'
                    CONSTRAINT chk_status CHECK (status IN ('OPEN','IN_PROGRESS','RESOLVED','CLOSED','SLA_BREACHED')),
                         category        VARCHAR2(100) NOT NULL,
                         created_by      NUMBER        NOT NULL,
                         assigned_to     NUMBER,
                         created_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
                         sla_deadline    TIMESTAMP     NOT NULL,
                         resolved_at     TIMESTAMP,
                         is_sla_breached NUMBER(1)     DEFAULT 0
                    CONSTRAINT chk_sla_breached CHECK (is_sla_breached IN (0,1)),
                         CONSTRAINT fk_ticket_user  FOREIGN KEY (created_by)  REFERENCES users(user_id),
                         CONSTRAINT fk_ticket_agent FOREIGN KEY (assigned_to) REFERENCES users(user_id)
);
/

CREATE OR REPLACE TRIGGER tickets_bir
BEFORE INSERT ON tickets
FOR EACH ROW
BEGIN
    IF :NEW.ticket_id IS NULL THEN
SELECT tickets_seq.NEXTVAL INTO :NEW.ticket_id FROM dual;
END IF;
END;
/

-- ── TICKET COMMENTS ─────────────────────────────────────────
-- NOTE: "comment" is reserved in Oracle — column renamed to comment_text
CREATE TABLE ticket_comments (
                                 comment_id   NUMBER        PRIMARY KEY,
                                 ticket_id    NUMBER        NOT NULL,
                                 user_id      NUMBER        NOT NULL,
                                 comment_text CLOB          NOT NULL,
                                 commented_at TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
                                 CONSTRAINT fk_comment_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id) ON DELETE CASCADE,
                                 CONSTRAINT fk_comment_user   FOREIGN KEY (user_id)   REFERENCES users(user_id)
);
/

CREATE OR REPLACE TRIGGER comments_bir
BEFORE INSERT ON ticket_comments
FOR EACH ROW
BEGIN
    IF :NEW.comment_id IS NULL THEN
SELECT comments_seq.NEXTVAL INTO :NEW.comment_id FROM dual;
END IF;
END;
/

-- ── KNOWLEDGE BASE ───────────────────────────────────────────
CREATE TABLE knowledge_base (
                                kb_id      NUMBER        PRIMARY KEY,
                                keyword    VARCHAR2(200) NOT NULL,
                                solution   CLOB          NOT NULL,
                                category   VARCHAR2(100) NOT NULL,
                                view_count NUMBER        DEFAULT 0,
                                created_at TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);
/

CREATE OR REPLACE TRIGGER kb_bir
BEFORE INSERT ON knowledge_base
FOR EACH ROW
BEGIN
    IF :NEW.kb_id IS NULL THEN
SELECT kb_seq.NEXTVAL INTO :NEW.kb_id FROM dual;
END IF;
END;
/

-- ── SLA CONFIG ───────────────────────────────────────────────
CREATE TABLE sla_config (
                            sla_id           NUMBER       PRIMARY KEY,
                            priority_level   VARCHAR2(10) UNIQUE NOT NULL
                     CONSTRAINT chk_sla_priority CHECK (priority_level IN ('LOW','MEDIUM','HIGH','CRITICAL')),
                            resolution_hours NUMBER       NOT NULL,
                            escalation_hours NUMBER       NOT NULL
);
/

CREATE OR REPLACE TRIGGER sla_bir
BEFORE INSERT ON sla_config
FOR EACH ROW
BEGIN
    IF :NEW.sla_id IS NULL THEN
SELECT sla_seq.NEXTVAL INTO :NEW.sla_id FROM dual;
END IF;
END;
/

-- ── AUDIT LOG ────────────────────────────────────────────────
CREATE TABLE audit_log (
                           log_id      NUMBER        PRIMARY KEY,
                           user_id     NUMBER        NOT NULL,
                           action      VARCHAR2(100) NOT NULL,
                           entity_type VARCHAR2(50),
                           entity_id   NUMBER,
                           log_time    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
                           CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);
/

CREATE OR REPLACE TRIGGER audit_bir
BEFORE INSERT ON audit_log
FOR EACH ROW
BEGIN
    IF :NEW.log_id IS NULL THEN
SELECT audit_seq.NEXTVAL INTO :NEW.log_id FROM dual;
END IF;
END;
/

-- ============================================================
--  SEED DATA
-- ============================================================

-- ── SLA Config ───────────────────────────────────────────────
INSERT INTO sla_config (priority_level, resolution_hours, escalation_hours) VALUES ('CRITICAL', 1,  1);
INSERT INTO sla_config (priority_level, resolution_hours, escalation_hours) VALUES ('HIGH',     4,  2);
INSERT INTO sla_config (priority_level, resolution_hours, escalation_hours) VALUES ('MEDIUM',   24, 12);
INSERT INTO sla_config (priority_level, resolution_hours, escalation_hours) VALUES ('LOW',      72, 48);

-- ── Default Users (BCrypt hashed — admin123 / agent123 / user123) ─────────
INSERT INTO users (name, email, password_hash, role) VALUES
    ('Admin User',  'admin@helpdesk.com', '$2a$12$LJ3m4yst2ReHiNSKZGRYp.OzURMv6J5fVEHGn9beUf8MHphfK6XpO', 'admin');
INSERT INTO users (name, email, password_hash, role) VALUES
    ('Agent Smith', 'agent@helpdesk.com', '$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'agent');
INSERT INTO users (name, email, password_hash, role) VALUES
    ('John Doe',    'user@helpdesk.com',  '$2a$12$WApznUPhDubN0oeveSZHqeYBdVgnOfaLE03nHY7E5C0eEFf6Wzh2W', 'user');

-- ── Knowledge Base ───────────────────────────────────────────
INSERT INTO knowledge_base (keyword, solution, category) VALUES
    ('vpn not working',
     '1. Restart VPN client. 2. Check network connection. 3. Re-enter credentials. 4. Contact IT if issue persists.',
     'Network');
INSERT INTO knowledge_base (keyword, solution, category) VALUES
    ('forgot password',
     'Visit the login page and click Forgot Password. Enter your email to receive a reset link. Check spam folder if not received within 5 minutes.',
     'Access');
INSERT INTO knowledge_base (keyword, solution, category) VALUES
    ('printer offline',
     '1. Check USB/network cable. 2. Restart the print spooler service. 3. Reinstall printer driver from manufacturer website.',
     'Hardware');
INSERT INTO knowledge_base (keyword, solution, category) VALUES
    ('email not loading',
     'Clear browser cache and cookies. If using Outlook: File > Account Settings > Repair. For webmail try incognito mode.',
     'Software');
INSERT INTO knowledge_base (keyword, solution, category) VALUES
    ('slow computer',
     '1. Restart your computer. 2. Check available disk space (need more than 10% free). 3. Run a full antivirus scan. 4. Close unnecessary background applications.',
     'Hardware');

UPDATE users SET password_hash = '$2a$12$jjuLHvbHyHGqOagsE5JhHuOOKoHzEhwjsRQ2yEz5EL8Q45MnVPXB6' WHERE email = 'admin@helpdesk.com';
UPDATE users SET password_hash = '$2a$12$SiLNCHkv6.eZ7MlyjhV3LetRR/HKvJuqEeHDUbq21rZDUgQhAGeH2' WHERE email = 'agent@helpdesk.com';
UPDATE users SET password_hash = '$2a$12$QunjLjS/wByur0keGhECWu2qvt4qtMlZp87OAutlw.yfxHU7BQlw6' WHERE email = 'user@helpdesk.com';


COMMIT;