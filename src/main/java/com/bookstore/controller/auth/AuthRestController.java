package com.bookstore.controller.auth;

import com.bookstore.entity.auth.User;
import com.bookstore.security.CustomUserDetails;
import com.bookstore.security.SecurityUtils;
import com.bookstore.service.auth.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthRestController {

    private final AuthService authService;

    public AuthRestController(AuthService authService) {
        this.authService = authService;
    }

    public record LoginRequest(String email, String password) {}

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request, HttpServletRequest httpRequest, HttpServletResponse httpResponse) {
        if (request == null || request.email() == null || request.password() == null) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Vui lòng nhập đầy đủ email và mật khẩu."));
        }

        try {
            User user = authService.authenticate(request.email().trim(), request.password());
            String token = authService.generateToken(user);

            // Set HttpOnly ACCESS_TOKEN cookie for web navigation
            ResponseCookie cookie = ResponseCookie.from("ACCESS_TOKEN", token)
                    .httpOnly(true)
                    .secure(httpRequest.isSecure())
                    .path("/")
                    .maxAge(86400) // 24 hours
                    .sameSite("Lax")
                    .build();
            httpResponse.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());

            Map<String, Object> data = new HashMap<>();
            data.put("id", user.getId());
            data.put("email", user.getEmail());
            data.put("fullName", user.getFullName());
            data.put("role", user.getRole().getCode().name());
            data.put("branchId", user.getBranch() != null ? user.getBranch().getId() : null);
            data.put("branchCode", user.getBranch() != null ? user.getBranch().getCode() : null);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "token", token,
                    "user", data,
                    "message", "Đăng nhập thành công"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }

    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser() {
        return SecurityUtils.getCurrentUser()
                .map(u -> ResponseEntity.ok((Object) Map.of(
                        "success", true,
                        "userId", u.getUserId(),
                        "email", u.getEmail(),
                        "fullName", u.getFullName(),
                        "role", u.getRoleCode().name(),
                        "branchId", u.getBranchId() != null ? u.getBranchId() : "",
                        "branchCode", u.getBranchCode() != null ? u.getBranchCode() : "",
                        "isSuperAdmin", u.isSuperAdmin(),
                        "isBranchManager", u.isBranchManager(),
                        "isStaff", u.isStaff()
                )))
                .orElseGet(() -> ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                        "success", false,
                        "message", "Chưa đăng nhập"
                )));
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpServletResponse response) {
        ResponseCookie cookie = ResponseCookie.from("ACCESS_TOKEN", "")
                .httpOnly(true)
                .path("/")
                .maxAge(0)
                .sameSite("Lax")
                .build();
        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
        return ResponseEntity.ok(Map.of("success", true, "message", "Đăng xuất thành công"));
    }
}
