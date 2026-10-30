package com.bookstore.security;

import com.bookstore.entity.auth.RoleCode;
import com.bookstore.entity.auth.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
public class JwtTokenProvider {

    private static final Logger log = LoggerFactory.getLogger(JwtTokenProvider.class);

    private final SecretKey signingKey;
    private final long expirationMs;

    public JwtTokenProvider(
            @Value("${app.jwt.secret:mocsach-used-bookstore-default-dev-secret-key-must-be-at-least-256-bits-long-2026}") String secret,
            @Value("${app.jwt.expiration-ms:86400000}") long expirationMs) {
        // Ensure secret has at least 256 bits (32 bytes)
        byte[] keyBytes = secret.getBytes(StandardCharsets.UTF_8);
        if (keyBytes.length < 32) {
            String padded = String.format("%-32s", secret).replace(' ', 'x');
            keyBytes = padded.getBytes(StandardCharsets.UTF_8);
        }
        this.signingKey = Keys.hmacShaKeyFor(keyBytes);
        this.expirationMs = expirationMs;
    }

    public String generateToken(User user) {
        long now = System.currentTimeMillis();
        Long branchId = user.getBranch() != null ? user.getBranch().getId() : null;
        String branchCode = user.getBranch() != null ? user.getBranch().getCode() : null;
        String roleStr = user.getRole() != null ? user.getRole().getCode().name() : RoleCode.ROLE_CUSTOMER.name();

        return Jwts.builder()
                .subject(user.getId().toString())
                .claim("email", user.getEmail())
                .claim("fullName", user.getFullName())
                .claim("role", roleStr)
                .claim("branchId", branchId)
                .claim("branchCode", branchCode)
                .issuedAt(new Date(now))
                .expiration(new Date(now + expirationMs))
                .signWith(signingKey)
                .compact();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser().verifyWith(signingKey).build().parseSignedClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            log.warn("Invalid JWT token: {}", e.getMessage());
            return false;
        }
    }

    public Claims getClaims(String token) {
        return Jwts.parser().verifyWith(signingKey).build().parseSignedClaims(token).getPayload();
    }

    public CustomUserDetails getUserDetailsFromToken(String token) {
        Claims claims = getClaims(token);
        Long userId = Long.valueOf(claims.getSubject());
        String email = claims.get("email", String.class);
        String fullName = claims.get("fullName", String.class);
        String roleStr = claims.get("role", String.class);
        RoleCode roleCode = roleStr != null ? RoleCode.valueOf(roleStr) : RoleCode.ROLE_CUSTOMER;

        Number branchIdNum = claims.get("branchId", Number.class);
        Long branchId = branchIdNum != null ? branchIdNum.longValue() : null;
        String branchCode = claims.get("branchCode", String.class);

        return new CustomUserDetails(userId, email, fullName, "", roleCode, branchId, branchCode, true);
    }
}
