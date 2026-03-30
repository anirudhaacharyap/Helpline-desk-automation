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


}
