package com.helpdesk.engine;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import java.sql.Timestamp;

public class SLAEngineTest {

    @Test
    public void testIsBreached_ResolvedStatus() {
        Timestamp pastDeadline = new Timestamp(System.currentTimeMillis() - 10000);
        assertFalse(SLAEngine.isBreached(pastDeadline, "RESOLVED"), "Resolved tickets should never be breached");
    }

    @Test
    public void testIsBreached_ClosedStatus() {
        Timestamp pastDeadline = new Timestamp(System.currentTimeMillis() - 10000);
        assertFalse(SLAEngine.isBreached(pastDeadline, "CLOSED"), "Closed tickets should never be breached");
    }

    @Test
    public void testIsBreached_OpenStatus_PastDeadline() {
        Timestamp pastDeadline = new Timestamp(System.currentTimeMillis() - 10000);
        assertTrue(SLAEngine.isBreached(pastDeadline, "OPEN"), "Open tickets with past deadlines should be breached");
    }

    @Test
    public void testIsBreached_InProgressStatus_PastDeadline() {
        Timestamp pastDeadline = new Timestamp(System.currentTimeMillis() - 10000);
        assertTrue(SLAEngine.isBreached(pastDeadline, "IN_PROGRESS"), "In Progress tickets with past deadlines should be breached");
    }

    @Test
    public void testIsBreached_OpenStatus_FutureDeadline() {
        Timestamp futureDeadline = new Timestamp(System.currentTimeMillis() + 10000);
        assertFalse(SLAEngine.isBreached(futureDeadline, "OPEN"), "Open tickets with future deadlines should not be breached");
    }

    @Test
    public void testIsBreached_InProgressStatus_FutureDeadline() {
        Timestamp futureDeadline = new Timestamp(System.currentTimeMillis() + 10000);
        assertFalse(SLAEngine.isBreached(futureDeadline, "IN_PROGRESS"), "In Progress tickets with future deadlines should not be breached");
    }

    @Test
    public void testIsBreached_NullStatus() {
        Timestamp pastDeadline = new Timestamp(System.currentTimeMillis() - 10000);
        assertTrue(SLAEngine.isBreached(pastDeadline, null), "Null status with past deadline should be breached");
    }
}
