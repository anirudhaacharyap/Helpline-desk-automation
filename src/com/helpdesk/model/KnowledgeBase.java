package com.helpdesk.model;

public class KnowledgeBase {

    private int kbId;
    private String keyword;
    private String solution;
    private String category;
    private int viewCount;

    // No-arg constructor
    public KnowledgeBase() {}

    // Full parameterised constructor
    public KnowledgeBase(int kbId, String keyword, String solution,
                         String category, int viewCount) {
        this.kbId = kbId;
        this.keyword = keyword;
        this.solution = solution;
        this.category = category;
        this.viewCount = viewCount;
    }

    // Getters and Setters
    public int getKbId() {
        return kbId;
    }

    public void setKbId(int kbId) {
        this.kbId = kbId;
    }

    public String getKeyword() {
        return keyword;
    }

    public void setKeyword(String keyword) {
        this.keyword = keyword;
    }

    public String getSolution() {
        return solution;
    }

    public void setSolution(String solution) {
        this.solution = solution;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public int getViewCount() {
        return viewCount;
    }

    public void setViewCount(int viewCount) {
        this.viewCount = viewCount;
    }

    @Override
    public String toString() {
        return "KnowledgeBase{" +
                "kbId=" + kbId +
                ", keyword='" + keyword + '\'' +
                ", solution='" + solution + '\'' +
                ", category='" + category + '\'' +
                ", viewCount=" + viewCount +
                '}';
    }
}
