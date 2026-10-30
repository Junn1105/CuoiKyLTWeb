package vn.mocsach.auth;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Legacy security registration placeholder.
 * Primary security configuration is handled in com.bookstore.config.SecurityConfig.
 */
@Configuration("legacySecurityConfig")
public class SecurityConfig {

    @Bean
    public FilterRegistrationBean<JwtCookieFilter> jwtRegistration(JwtCookieFilter filter) {
        var r = new FilterRegistrationBean<>(filter);
        r.setEnabled(false); // Managed explicitly in SecurityConfig
        return r;
    }
}
