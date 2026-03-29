package com.helpdesk.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * PasswordUtil — Wraps jBCrypt for password hashing and verification.
 * Requires jbcrypt-0.4.jar in WEB-INF/lib.
 */
public class PasswordUtil {

    /**
     * Hash a plain password before storing.
     *
     * @param plainPassword The plain text password
     * @return BCrypt hash string
     */
    public static String hash(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
    }

    /**
     * Verify a plain password against a stored BCrypt hash.
     *
     * @param plain      The plain text password to verify
     * @param storedHash The stored BCrypt hash
     * @return true if the password matches, false otherwise
     */
    public static boolean verify(String plain, String storedHash) {
        return BCrypt.checkpw(plain, storedHash);
    }

    // ── QUICK TEST ───────────────────────────────────────────
    public static void main(String[] args) {
        // 1. Hash a password
        String hashed = hash("hello123");
        System.out.println("Hash of 'hello123' : " + hashed);

        // 2. Verify correct password
        System.out.println("Verify 'hello123'  : " + verify("hello123", hashed));

        // 3. Verify wrong password
        System.out.println("Verify 'wrong'     : " + verify("wrong", hashed));

        // 4. Generate fresh hashes for schema.sql seed data
        System.out.println("\n=== Paste these into schema.sql ===");
        String adminHash = hash("admin123");
        String agentHash = hash("agent123");
        String userHash  = hash("user123");
        System.out.println("admin123 : " + adminHash);
        System.out.println("agent123 : " + agentHash);
        System.out.println("user123  : " + userHash);

        // 5. Verify them immediately
        System.out.println("\n=== Verify seed hashes ===");
        System.out.println("admin123 valid : " + verify("admin123", adminHash));
        System.out.println("agent123 valid : " + verify("agent123", agentHash));
        System.out.println("user123  valid : " + verify("user123", userHash));
    }
}
