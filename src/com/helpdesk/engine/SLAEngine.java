package com.helpdesk.engine;

import java.sql.Timestamp;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.helpdesk.model.User;

/**
 * SLAEngine — Calculates SLA deadlines and checks for breaches.
 * Implementation per LLD Section 3.2.
 */
public class SLAEngine {

    // SLA hours per priority — matches sla_config table
    private static final Map<String, Integer> SLA_HOURS = new HashMap<>();
    static {
        SLA_HOURS.put("CRITICAL", 1);
        SLA_HOURS.put("HIGH",     4);
        SLA_HOURS.put("MEDIUM",  24);
        SLA_HOURS.put("LOW",     72);
    }

    /**
     * Calculates the SLA deadline timestamp.
     *
     * @param priority Priority string from PriorityEngine
     * @return Timestamp = NOW + SLA hours
     */
    public static Timestamp getDeadline(String priority) {
        int hours = SLA_HOURS.getOrDefault(priority, 72);
        long millis = System.currentTimeMillis() + (hours * 3_600_000L);
        return new Timestamp(millis);
    }

    /**
     * Routes ticket to an agent based on priority.
     * Simple round-robin: picks agent with fewest open tickets.
     *
     * @param priority     Priority string
     * @param agentList    List of available agents from UserDAO
     * @param ticketCounts Map of agentId -> open ticket count
     * @return user_id of chosen agent
     */
    public static int routeToAgent(String priority,
                                   List<User> agentList,
                                   Map<Integer, Integer> ticketCounts) {
        return agentList.stream()
            .min(Comparator.comparingInt(
                a -> ticketCounts.getOrDefault(a.getUserId(), 0)))
            .map(User::getUserId)
            .orElse(1);  // fallback to admin
    }

    /**
     * Checks if a ticket has breached its SLA.
     *
     * @param slaDeadline The SLA deadline timestamp
     * @param status      Current ticket status
     * @return true if breached (deadline passed and not resolved/closed)
     */
    public static boolean isBreached(Timestamp slaDeadline, String status) {
        if ("RESOLVED".equals(status) || "CLOSED".equals(status)) return false;
        return new Timestamp(System.currentTimeMillis()).after(slaDeadline);
    }
}
