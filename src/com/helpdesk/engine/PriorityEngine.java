package com.helpdesk.engine;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * PriorityEngine — Analyses ticket title and description to auto-assign priority.
 * Uses keyword scoring: each keyword has a weight, total score determines priority tier.
 * Implementation per LLD Section 3.1.
 */
public class PriorityEngine {

    private static final Map<String, Integer> KEYWORD_SCORES = new LinkedHashMap<>();

    static {
        // CRITICAL tier (score >= 10)
        KEYWORD_SCORES.put("server down", 12);
        KEYWORD_SCORES.put("data loss", 12);
        KEYWORD_SCORES.put("production down", 12);
        KEYWORD_SCORES.put("security breach", 11);
        KEYWORD_SCORES.put("system failure", 10);
        KEYWORD_SCORES.put("cannot access", 10);
        // HIGH tier (score 6-9)
        KEYWORD_SCORES.put("urgent", 8);
        KEYWORD_SCORES.put("not working", 7);
        KEYWORD_SCORES.put("error 500", 7);
        KEYWORD_SCORES.put("login failed", 6);
        KEYWORD_SCORES.put("blocked", 6);
        // MEDIUM tier (score 3-5)
        KEYWORD_SCORES.put("slow", 4);
        KEYWORD_SCORES.put("intermittent", 4);
        KEYWORD_SCORES.put("performance", 3);
        KEYWORD_SCORES.put("warning", 3);
        // LOW tier (score 0-2) = default
    }

    /**
     * Analyses ticket text and returns priority string.
     *
     * @param title       Ticket title
     * @param description Ticket description
     * @return "CRITICAL" | "HIGH" | "MEDIUM" | "LOW"
     */
    public static String assignPriority(String title, String description) {
        String combined = (title + " " + description).toLowerCase();
        int totalScore = 0;

        for (Map.Entry<String, Integer> entry : KEYWORD_SCORES.entrySet()) {
            if (combined.contains(entry.getKey())) {
                totalScore += entry.getValue();
            }
        }

        if (totalScore >= 10) return "CRITICAL";
        if (totalScore >= 6)  return "HIGH";
        if (totalScore >= 3)  return "MEDIUM";
        return "LOW";
    }
}
