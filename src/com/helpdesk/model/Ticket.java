package com.helpdesk.model;

import java.sql.Timestamp;

public class Ticket {

    private int ticketId;
    private String title;
    private String description;
    private String priority;        // 'CRITICAL','HIGH','MEDIUM','LOW'
    private String status;          // 'OPEN','IN_PROGRESS','RESOLVED','CLOSED','SLA_BREACHED'
    private String category;        // 'Hardware','Software','Network','Access','Other'
    private int createdBy;          // FK → users.user_id
    private int assignedTo;         // FK → users.user_id
    private Timestamp createdAt;
    private Timestamp slaDeadline;
    private Timestamp resolvedAt;
    private boolean isSlaBreached;

    // No-arg constructor
    public Ticket() {}

    // Full parameterised constructor
    public Ticket(int ticketId, String title, String description,
                  String priority, String status, String category,
                  int createdBy, int assignedTo,
                  Timestamp createdAt, Timestamp slaDeadline,
                  Timestamp resolvedAt, boolean isSlaBreached) {
        this.ticketId = ticketId;
        this.title = title;
        this.description = description;
        this.priority = priority;
        this.status = status;
        this.category = category;
        this.createdBy = createdBy;
        this.assignedTo = assignedTo;
        this.createdAt = createdAt;
        this.slaDeadline = slaDeadline;
        this.resolvedAt = resolvedAt;
        this.isSlaBreached = isSlaBreached;
    }

    // Getters and Setters
    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public int getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(int assignedTo) {
        this.assignedTo = assignedTo;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getSlaDeadline() {
        return slaDeadline;
    }

    public void setSlaDeadline(Timestamp slaDeadline) {
        this.slaDeadline = slaDeadline;
    }

    public Timestamp getResolvedAt() {
        return resolvedAt;
    }

    public void setResolvedAt(Timestamp resolvedAt) {
        this.resolvedAt = resolvedAt;
    }

    public boolean isSlaBreached() {
        return isSlaBreached;
    }

    public void setSlaBreached(boolean slaBreached) {
        isSlaBreached = slaBreached;
    }

    @Override
    public String toString() {
        return "Ticket{" +
                "ticketId=" + ticketId +
                ", title='" + title + '\'' +
                ", priority='" + priority + '\'' +
                ", status='" + status + '\'' +
                ", category='" + category + '\'' +
                ", createdBy=" + createdBy +
                ", assignedTo=" + assignedTo +
                ", createdAt=" + createdAt +
                ", slaDeadline=" + slaDeadline +
                ", resolvedAt=" + resolvedAt +
                ", isSlaBreached=" + isSlaBreached +
                '}';
    }
}
