# 🎫 Helpdesk Support Ticket Automation System

![Java](https://img.shields.io/badge/Java-11%2B-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![JSP](https://img.shields.io/badge/JSP-Servlets-007396?style=for-the-badge&logo=java&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Tomcat](https://img.shields.io/badge/Apache%20Tomcat-9.0-F8DC75?style=for-the-badge&logo=apachetomcat&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-In%20Development-orange?style=for-the-badge)

> A full-stack web application for automating IT helpdesk operations — featuring intelligent ticket priority assignment, SLA-based routing, real-time knowledge base lookup via AJAX, and PDF reporting.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Database Schema](#-database-schema)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Team](#-team)
- [Screenshots](#-screenshots)
- [API Endpoints](#-api-endpoints)
- [Contributing](#-contributing)

---

## 🔍 Overview

The **Helpdesk Support Ticket Automation System** is a Java-based web application that digitises and automates the complete lifecycle of IT support requests. It replaces manual, email-based ticketing with a structured, SLA-aware workflow that automatically classifies tickets by urgency, routes them to the right agent, and surfaces relevant knowledge base solutions before a ticket is even submitted.

Built as a college mini project using a **custom MVC architecture** — no Spring Framework — to demonstrate deep understanding of Java web fundamentals: Servlets, JSP, JDBC, and DAO pattern.

---

## ✨ Features

### For End Users
- 📝 **Raise Support Tickets** — guided form with category selection and description
- 💡 **Live KB Suggestions** — AJAX-powered knowledge base lookup as you type; solutions appear before you even submit
- 📊 **Real-time Status Tracking** — see your ticket status update live (polls every 30 seconds)
- 💬 **Comment Thread** — add follow-up information to open tickets
- 📧 **Email Notifications** — get notified when your ticket status changes

### For Support Agents
- 📥 **Agent Queue** — personalised ticket queue sorted by SLA deadline (most urgent first)
- 🔄 **Status Management** — update tickets through OPEN → IN_PROGRESS → RESOLVED → CLOSED
- 🔍 **Ticket Search & Filter** — filter by status, priority, category
- 📖 **Knowledge Base** — add new solutions from resolved tickets

### For Administrators
- 🛡️ **Admin Dashboard** — live stats: open count, SLA breaches, agent workload
- 👥 **User Management** — create/deactivate user accounts, assign roles
- 📈 **PDF Reports** — generate ticket summary, agent performance, and SLA compliance reports
- ⚠️ **SLA Breach Alerts** — automatic flagging of tickets that breach their deadlines

### Core Automation (The Smart Parts)
- 🤖 **Auto Priority Assignment** — `PriorityEngine` scans ticket text for keywords and assigns CRITICAL / HIGH / MEDIUM / LOW automatically
- ⏱️ **SLA Deadline Calculation** — `SLAEngine` sets resolution deadlines based on priority (1hr / 4hr / 24hr / 72hr)
- 🔀 **Intelligent Agent Routing** — tickets auto-routed to the least-loaded available agent

---

## 🛠 Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | JSP + HTML5 + CSS3 + Bootstrap 5 | Dynamic page rendering |
| **AJAX** | Vanilla JavaScript `fetch()` API | Live KB lookup, status polling, dashboard refresh |
| **Backend** | Java 11 + Jakarta Servlets | Request handling, business logic |
| **Architecture** | Custom MVC + DAO Pattern | Separation of concerns |
| **Database** | MySQL 8.0 via JDBC | Persistent data storage |
| **Password Security** | jBCrypt | Password hashing |
| **PDF Reports** | iText 5.5.13 | Report generation |
| **Server** | Apache Tomcat 9 | Servlet container |
| **Version Control** | Git + GitHub | Source control & collaboration |

---

## 🏗 Architecture

This project implements a **custom 4-tier MVC architecture** without any framework:

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT BROWSER                        │
│         JSP + HTML + CSS + AJAX (fetch API)             │
└────────────────────────┬────────────────────────────────┘
                         │  HTTP Requests
┌────────────────────────▼────────────────────────────────┐
│              APACHE TOMCAT 9 (Servlet Container)         │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │         CONTROLLER LAYER (Java Servlets)        │    │
│  │  LoginServlet · TicketServlet · KBServlet       │    │
│  │  AdminServlet · ReportServlet · UpdateServlet   │    │
│  └──────────────────────┬──────────────────────────┘    │
│                         │                                │
│  ┌──────────────────────▼──────────────────────────┐    │
│  │       SERVICE / ENGINE LAYER (Java Classes)     │    │
│  │     PriorityEngine · SLAEngine · PasswordUtil   │    │
│  └──────────────────────┬──────────────────────────┘    │
│                         │                                │
│  ┌──────────────────────▼──────────────────────────┐    │
│  │           MODEL / DAO LAYER (JDBC)              │    │
│  │   UserDAO · TicketDAO · CommentDAO · KBDAO      │    │
│  └──────────────────────┬──────────────────────────┘    │
└───────────────────────── ┼ ────────────────────────────-┘
                           │  JDBC
┌──────────────────────────▼──────────────────────────────┐
│                    MySQL 8.0 DATABASE                    │
│    users · tickets · ticket_comments · knowledge_base    │
│              · sla_config · audit_log                    │
└──────────────────────────────────────────────────────────┘
```

---

## 🗃 Database Schema

Six tables power the application:

```sql
users              — accounts with role-based access (user / agent / admin)
tickets            — core entity with priority, status, SLA deadline
ticket_comments    — threaded comments per ticket
knowledge_base     — keyword → solution pairs for AJAX lookup
sla_config         — SLA hours per priority level (seeded data)
audit_log          — every user action logged for accountability
```

> Full SQL schema with CREATE TABLE statements and seed data is in [`/sql/schema.sql`](./sql/schema.sql)

---

## 📁 Project Structure

```
helpdesk/
├── src/
│   ├── com.helpdesk.model/          # POJO classes (Vibhas)
│   │   ├── User.java
│   │   ├── Ticket.java
│   │   ├── Comment.java
│   │   └── KnowledgeBase.java
│   │
│   ├── com.helpdesk.dao/            # Database access (Vibhas)
│   │   ├── DBConnection.java
│   │   ├── UserDAO.java
│   │   ├── TicketDAO.java
│   │   ├── CommentDAO.java
│   │   ├── KnowledgeBaseDAO.java
│   │   └── AuditDAO.java
│   │
│   ├── com.helpdesk.controller/     # Servlets (Anirudh)
│   │   ├── LoginServlet.java
│   │   ├── RegisterServlet.java
│   │   ├── TicketServlet.java
│   │   ├── TicketUpdateServlet.java
│   │   ├── TicketListServlet.java
│   │   ├── KBServlet.java
│   │   ├── AdminServlet.java
│   │   └── ReportServlet.java
│   │
│   ├── com.helpdesk.engine/         # Business logic (Pratyaksh)
│   │   ├── PriorityEngine.java
│   │   └── SLAEngine.java
│   │
│   └── com.helpdesk.util/           # Utilities (Pratyaksh)
│       ├── PasswordUtil.java
│       └── ReportGenerator.java
│
├── WebContent/
│   ├── views/                       # JSP pages (Udit J)
│   │   ├── login.jsp
│   │   ├── register.jsp
│   │   ├── dashboard.jsp
│   │   ├── raiseTicket.jsp
│   │   ├── ticketList.jsp
│   │   ├── ticketDetail.jsp
│   │   ├── adminDashboard.jsp
│   │   ├── reports.jsp
│   │   ├── knowledgeBase.jsp
│   │   └── userManagement.jsp
│   ├── css/
│   │   └── style.css
│   ├── js/
│   └── WEB-INF/
│       └── web.xml
│
├── sql/
│   └── schema.sql                   # Full DB schema + seed data
│
└── docs/
    ├── HLD.docx                     # High Level Design
    ├── LLD.docx                     # Low Level Design
    └── uml/                         # UML diagrams
        ├── use-case.png
        ├── class-diagram.png
        ├── sequence-diagram.png
        └── er-diagram.png
```

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

- [JDK 11+](https://adoptium.net/)
- [Apache Tomcat 9](https://tomcat.apache.org/download-90.cgi)
- [MySQL 8.0](https://dev.mysql.com/downloads/mysql/)
- [Eclipse IDE for Enterprise Java](https://www.eclipse.org/downloads/)

### Required JAR Files

Download and place these in `WebContent/WEB-INF/lib/`:

| JAR | Download |
|-----|----------|
| `mysql-connector-j-8.x.jar` | [MySQL Connector/J](https://dev.mysql.com/downloads/connector/j/) |
| `jbcrypt-0.4.jar` | [jBCrypt on MVN](https://mvnrepository.com/artifact/org.mindrot/jbcrypt/0.4) |
| `itextpdf-5.5.13.jar` | [iText on MVN](https://mvnrepository.com/artifact/com.itextpdf/itextpdf/5.5.13) |

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/anirudh/helpdesk-ticket-system.git
cd helpdesk-ticket-system
```

**2. Set up the database**
```bash
# Open MySQL and run the schema script
mysql -u root -p < sql/schema.sql
```

Or open the file in MySQL Workbench and execute it.

**3. Configure database credentials**

Edit `src/com/helpdesk/dao/DBConnection.java`:
```java
private static final String URL  = "jdbc:mysql://localhost:3306/helpdesk_db?useSSL=false&serverTimezone=UTC";
private static final String USER = "root";
private static final String PASS = "your_mysql_password";   // ← change this
```

**4. Import into Eclipse**
```
File → Import → Existing Projects into Workspace → Select root folder
```

**5. Add Tomcat Server**
```
Window → Preferences → Server → Runtime Environments → Add → Apache Tomcat v9.0
```

**6. Add JARs to Build Path**
```
Right-click each JAR in WEB-INF/lib → Build Path → Add to Build Path
```

**7. Run the project**
```
Right-click project → Run As → Run on Server → Select Tomcat 9 → Finish
```

**8. Open in browser**
```
http://localhost:8080/helpdesk/
```

### Default Login Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@helpdesk.com | admin123 |
| Agent | agent@helpdesk.com | agent123 |
| User | user@helpdesk.com | user123 |

> ⚠️ Change all default passwords immediately after first login.

---

## 👥 Team

| Member | Role | Responsibilities |
|--------|------|-----------------|
| **Anirudh** | Controller / Servlets + GitHub | All Java Servlets, URL routing, session management, GitHub repo |
| **Vibhas** | Model / DAO | POJO classes, DBConnection, all DAO CRUD operations |
| **Udit J** | View / JSP | All JSP pages, CSS styling, AJAX JavaScript |
| **Pratyaksh** | Integration / Testing | PriorityEngine, SLAEngine, PDF reports, UML diagrams, testing |

---

## 📸 Screenshots

> _Screenshots will be added after UI completion in Week 3._

| Page | Description |
|------|-------------|
| Login Page | Clean login form with error handling |
| Dashboard | Ticket summary cards with status overview |
| Raise Ticket | Form with live AJAX KB suggestion cards |
| Ticket List | Filterable, colour-coded priority table |
| Ticket Detail | Full info, comment thread, SLA countdown |
| Admin Dashboard | Live stats, breach alerts, agent workload |

---

## 🌐 API Endpoints (Servlet URL Mappings)

| Method | URL | Servlet | Description |
|--------|-----|---------|-------------|
| `GET` | `/login` | LoginServlet | Show login form |
| `POST` | `/login` | LoginServlet | Process login |
| `GET` | `/login?action=logout` | LoginServlet | Logout & clear session |
| `GET` | `/register` | RegisterServlet | Show register form |
| `POST` | `/register` | RegisterServlet | Create new account |
| `GET` | `/ticket?action=new` | TicketServlet | Show raise ticket form |
| `GET` | `/ticket?action=view&id={id}` | TicketServlet | View ticket detail |
| `POST` | `/ticket` | TicketServlet | Submit new ticket |
| `GET` | `/tickets` | TicketListServlet | List tickets (filtered) |
| `POST` | `/ticket/update` | TicketUpdateServlet | Update status / add comment |
| `GET` | `/kb/search?q={query}` | KBServlet | **AJAX** — KB keyword search |
| `GET` | `/admin` | AdminServlet | Admin dashboard |
| `GET` | `/admin/stats` | AdminServlet | **AJAX** — live dashboard stats |
| `GET` | `/report` | ReportServlet | Generate & download PDF |

---

## 🔐 Security

- Passwords hashed with **BCrypt** (cost factor 12) — never stored in plain text
- All DB queries use **PreparedStatement** — SQL injection protected
- **Session guard** on every Servlet — unauthenticated requests redirect to login
- **Role-based access control** — admin pages reject non-admin sessions
- **Session timeout** — 30 minutes of inactivity (configured in `web.xml`)
- Output rendered via JSP `<c:out>` — XSS protected

---

## 🤝 Contributing

This is a college project with a fixed team. For internal team contributions:

```bash
# 1. Pull latest from dev before starting work
git checkout dev
git pull origin dev

# 2. Work on your own branch
git checkout feat/your-name

# 3. Commit with a meaningful message
git add .
git commit -m "feat: add TicketDAO.insertTicket() method"

# 4. Push and notify Anirudh to merge
git push origin feat/your-name
```

**Commit message format:**
```
feat:     new feature added
fix:      bug fix
docs:     documentation changes
style:    CSS / UI changes
refactor: code restructure (no feature change)
test:     test cases added
```

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 📚 Documentation

Full design documents are available in the `/docs` folder:

- 📘 [High Level Design (HLD)](./docs/HLD.docx) — System architecture, component breakdown, data flow
- 📗 [Low Level Design (LLD)](./docs/LLD.docx) — Class designs, method signatures, SQL schema, AJAX flows
- 📙 [Team Task Guide](./docs/TeamGuide.docx) — Per-member instructions, tutorial links, code starters

---

<div align="center">

**Built with ☕ Java by Team Helpdesk**

Anirudh · Vibhas · Udit J · Pratyaksh

</div>
