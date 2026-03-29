package com.helpdesk.model;

import java.sql.Timestamp;

public class Comment {

    private int commentId;
    private int ticketId;
    private int userId;
    private String userName;        // Denormalised for display
    private String comment;
    private Timestamp commentedAt;

    // No-arg constructor
    public Comment() {}

    // Full parameterised constructor
    public Comment(int commentId, int ticketId, int userId,
                   String userName, String comment, Timestamp commentedAt) {
        this.commentId = commentId;
        this.ticketId = ticketId;
        this.userId = userId;
        this.userName = userName;
        this.comment = comment;
        this.commentedAt = commentedAt;
    }

    // Getters and Setters
    public int getCommentId() {
        return commentId;
    }

    public void setCommentId(int commentId) {
        this.commentId = commentId;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Timestamp getCommentedAt() {
        return commentedAt;
    }

    public void setCommentedAt(Timestamp commentedAt) {
        this.commentedAt = commentedAt;
    }

    @Override
    public String toString() {
        return "Comment{" +
                "commentId=" + commentId +
                ", ticketId=" + ticketId +
                ", userId=" + userId +
                ", userName='" + userName + '\'' +
                ", comment='" + comment + '\'' +
                ", commentedAt=" + commentedAt +
                '}';
    }
}
