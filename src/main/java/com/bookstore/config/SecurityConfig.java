package com.bookstore.config;

import com.bookstore.security.CustomAccessDeniedHandler;
import com.bookstore.security.JwtAuthenticationFilter;
import jakarta.servlet.DispatcherType;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.LoginUrlAuthenticationEntryPoint;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import vn.mocsach.auth.JwtCookieFilter;

import java.time.Clock;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final JwtCookieFilter legacyJwtCookieFilter;
    private final CustomAccessDeniedHandler accessDeniedHandler;

    public SecurityConfig(
            JwtAuthenticationFilter jwtAuthenticationFilter,
            JwtCookieFilter legacyJwtCookieFilter,
            CustomAccessDeniedHandler accessDeniedHandler) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
        this.legacyJwtCookieFilter = legacyJwtCookieFilter;
        this.accessDeniedHandler = accessDeniedHandler;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(csrf -> csrf.ignoringRequestMatchers("/api/**"))
            .authorizeHttpRequests(auth -> auth
                .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR).permitAll()

                // 1. Static resources
                .requestMatchers("/css/**", "/js/**", "/images/**", "/webjars/**", "/favicon.ico").permitAll()

                // 2. Public web views & Authentication
                .requestMatchers("/", "/home", "/stores", "/books/**", "/login", "/register",
                        "/forgot-password", "/verify-otp", "/resend-otp", "/reset-password",
                        "/auth/login", "/auth/logout", "/error").permitAll()

                // 3. REST API public endpoints
                .requestMatchers(HttpMethod.POST, "/api/auth/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/catalog/**", "/api/branches/public/**").permitAll()

                // 4. RESTRICTED: Super Admin ONLY endpoints (Global System & Chain Settings)
                .requestMatchers("/admin/branches/**").hasAnyRole("SUPER_ADMIN", "ADMIN")
                .requestMatchers("/admin/users/**").hasAnyRole("SUPER_ADMIN", "ADMIN")
                .requestMatchers("/admin/dashboard", "/admin").hasAnyRole("SUPER_ADMIN", "ADMIN")
                .requestMatchers("/admin/transfers/approve/**", "/admin/transfers/*/approve").hasAnyRole("SUPER_ADMIN", "ADMIN")

                // 4b. RESTRICTED: Management & Analytics (Admin + Branch Manager ONLY, NOT Staff)
                .requestMatchers("/admin/stores/**").hasAnyRole("SUPER_ADMIN", "ADMIN", "BRANCH_MANAGER", "MANAGER")
                .requestMatchers("/admin/reports/**").hasAnyRole("SUPER_ADMIN", "ADMIN", "BRANCH_MANAGER", "MANAGER")

                // 5. RESTRICTED: Branch Operations (Super Admin + Branch Manager + Staff)
                .requestMatchers("/admin/my-store/**").hasAnyRole("SUPER_ADMIN", "BRANCH_MANAGER", "STAFF", "ADMIN", "MANAGER")
                .requestMatchers("/admin/buybacks/**").hasAnyRole("SUPER_ADMIN", "BRANCH_MANAGER", "STAFF", "ADMIN", "MANAGER")
                .requestMatchers("/admin/transfers/**").hasAnyRole("SUPER_ADMIN", "BRANCH_MANAGER", "STAFF", "ADMIN", "MANAGER")
                .requestMatchers("/api/pricing/**").hasAnyRole("SUPER_ADMIN", "BRANCH_MANAGER", "STAFF", "ADMIN", "MANAGER")
                .requestMatchers("/admin/**").hasAnyRole("SUPER_ADMIN", "BRANCH_MANAGER", "STAFF", "ADMIN", "MANAGER")

                // 6. Customer & Authenticated Member actions
                .requestMatchers("/buybacks/my-requests/**", "/cart/**", "/checkout/**", "/account/**").authenticated()

                // Default: any other route requires authentication
                .anyRequest().authenticated()
            )
            .exceptionHandling(e -> e
                .authenticationEntryPoint(new LoginUrlAuthenticationEntryPoint("/login"))
                .accessDeniedHandler(accessDeniedHandler)
            )
            .formLogin(f -> f.disable())
            .httpBasic(b -> b.disable())
            .logout(l -> l.disable())
            .headers(h -> h.contentSecurityPolicy(c -> c.policyDirectives(
                "default-src 'self'; img-src 'self' data: https://res.cloudinary.com; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'"
            )))
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
            .addFilterBefore(legacyJwtCookieFilter, UsernamePasswordAuthenticationFilter.class)
            .build();
    }
}
