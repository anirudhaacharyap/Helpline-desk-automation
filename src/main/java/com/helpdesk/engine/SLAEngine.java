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

    // ── QUICK TEST ───────────────────────────────────────────
    public static void main(String[] args) {
        System.out.println("=== SLAEngine Test ===");

        // 1. Deadline calculation
        System.out.println("CRITICAL deadline : " + getDeadline("CRITICAL"));
        System.out.println("HIGH deadline     : " + getDeadline("HIGH"));
        System.out.println("MEDIUM deadline   : " + getDeadline("MEDIUM"));
        System.out.println("LOW deadline      : " + getDeadline("LOW"));

        // 2. SLA breach check — deadline in the past → breached
        Timestamp pastDeadline = new Timestamp(System.currentTimeMillis() - 3_600_000L);
        System.out.println("Past deadline + OPEN     : breached = " + isBreached(pastDeadline, "OPEN"));
        System.out.println("Past deadline + RESOLVED : breached = " + isBreached(pastDeadline, "RESOLVED"));

        // 3. SLA breach check — deadline in the future → not breached
        Timestamp futureDeadline = new Timestamp(System.currentTimeMillis() + 3_600_000L);
        System.out.println("Future deadline + OPEN   : breached = " + isBreached(futureDeadline, "OPEN"));

        // 4. Route to agent (mock data, no DB)
        User a1 = new User(); a1.setUserId(10); a1.setName("Agent A");
        User a2 = new User(); a2.setUserId(20); a2.setName("Agent B");
        List<User> agents = List.of(a1, a2);
        Map<Integer, Integer> counts = new HashMap<>();
        counts.put(10, 5);  // Agent A has 5 tickets
        counts.put(20, 2);  // Agent B has 2 tickets
        int chosen = routeToAgent("HIGH", agents, counts);
        System.out.println("Route HIGH ticket → agent ID " + chosen + " (should be 20)");
    }
}
