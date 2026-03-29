# Helpdesk Support Ticket Automation

A web-based IT helpdesk system built with Java Servlets, JSP, and Oracle Database XE. Handles ticket lifecycle from creation to resolution with automated priority assignment and SLA tracking.

## What it does

- Users raise support tickets describing their issue
- System auto-assigns priority (Critical/High/Medium/Low) by scanning keywords in the description
- SLA deadlines are calculated per priority level and tracked in real time
- Tickets get routed to agents; admins can reassign, manage users, and pull PDF reports
- Knowledge base provides instant suggestions while users type their issue

## Tech stack

| Layer | Tech |
|---|---|
| Backend | Java 17, Jakarta Servlets, JSP (scriptlets) |
| Database | Oracle XE (JDBC, no ORM) |
| Auth | BCrypt (jbcrypt-0.4) |
| PDF | iText 5.5.13 |
| Frontend | Vanilla HTML/CSS/JS, Inter font |
| Server | Apache Tomcat 10 |

No frameworks. No Spring. No JSTL. Just servlets and SQL.

## Project structure

```
helpdesk/
├── src/com/helpdesk/
│   ├── model/         # POJOs — User, Ticket, Comment, KnowledgeBase
│   ├── dao/           # JDBC data access (Oracle-specific SQL)
│   ├── engine/        # PriorityEngine (keyword scoring), SLAEngine (deadlines)
│   ├── controller/    # 9 servlets handling all routes
│   └── util/          # PasswordUtil (BCrypt), ReportGenerator (PDF)
├── WebContent/
│   ├── css/style.css  # Design system — navy palette, Inter font
│   └── views/         # 12 JSP pages + 2 shared includes
├── sql/schema.sql     # Oracle DDL + sequences + seed data
└── .gitignore
```

## Setup

1. **Database** — Run `sql/schema.sql` in SQL*Plus or SQL Developer against your Oracle XE instance. Creates tables, sequences, and 3 seed users.

2. **JDBC config** — Edit `src/com/helpdesk/dao/DBConnection.java`:
   ```java
   JDBC_URL  = "jdbc:oracle:thin:@localhost:1521:XE";
   USER      = "your_oracle_user";
   PASSWORD  = "your_password";
   ```

3. **Dependencies** — Drop these JARs into `WebContent/WEB-INF/lib/`:
   - `ojdbc8.jar` (Oracle JDBC driver)
   - `jbcrypt-0.4.jar`
   - `itextpdf-5.5.13.jar`

4. **Deploy** — Add to Tomcat 10 in IntelliJ (Artifact → Web Application: Exploded) and run.

## Default logins

| Role | Email | Password |
|---|---|---|
| Admin | admin@helpdesk.com | admin123 |
| Agent | agent@helpdesk.com | agent123 |
| User | user@helpdesk.com | user123 |

## Routes

| Path | Servlet | Access |
|---|---|---|
| `/login` | LoginServlet | Public |
| `/register` | RegisterServlet | Public |
| `/dashboard` | DashboardServlet | All roles |
| `/tickets` | TicketListServlet | All roles |
| `/ticket` | TicketServlet | All roles |
| `/ticket/update` | TicketUpdateServlet | All roles |
| `/kb/search` | KBServlet (JSON) | Public (AJAX) |
| `/admin` | AdminServlet | Admin only |
| `/report` | ReportServlet (PDF) | Admin only |

## How the engines work

**PriorityEngine** — Scans title + description for weighted keywords. "server down" = 12 pts, "slow" = 4 pts. Score ≥10 = CRITICAL, ≥6 = HIGH, ≥3 = MEDIUM, else LOW.

**SLAEngine** — Maps priority to hours: CRITICAL=1h, HIGH=4h, MEDIUM=24h, LOW=72h. Deadline = now + hours. Tickets past deadline get flagged SLA_BREACHED on view.

## License

Academic project. Not licensed for production use.
