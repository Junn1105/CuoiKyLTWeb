package vn.mocsach.auth;
import org.springframework.context.annotation.*;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.LoginUrlAuthenticationEntryPoint;
import jakarta.servlet.DispatcherType;
import java.time.Clock;
@Configuration
public class SecurityConfig {
 @Bean Clock clock(){return Clock.systemUTC();}
 @Bean PasswordEncoder passwordEncoder(){return new BCryptPasswordEncoder(12);}
 @Bean FilterRegistrationBean<JwtCookieFilter> jwtRegistration(JwtCookieFilter filter){var r=new FilterRegistrationBean<>(filter);r.setEnabled(false);return r;}
 @Bean SecurityFilterChain security(HttpSecurity http,JwtCookieFilter filter)throws Exception {
  return http.authorizeHttpRequests(a->a.dispatcherTypeMatchers(DispatcherType.FORWARD,DispatcherType.ERROR).permitAll()
   .requestMatchers("/admin/**").hasAnyRole("ADMIN","STAFF")
   .requestMatchers(org.springframework.http.HttpMethod.GET,"/books/*").permitAll()
   .requestMatchers("/","/home","/login","/register","/forgot-password","/verify-otp","/resend-otp","/reset-password","/auth/login","/error","/css/**","/js/**","/images/**","/webjars/**").permitAll().anyRequest().authenticated())
   .exceptionHandling(e->e.authenticationEntryPoint(new LoginUrlAuthenticationEntryPoint("/login")))
   .formLogin(f->f.disable()).httpBasic(b->b.disable()).logout(l->l.disable())
   .headers(h->h.contentSecurityPolicy(c->c.policyDirectives("default-src 'self'; img-src 'self' data:; style-src 'self'; script-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'")))
   .addFilterBefore(filter,UsernamePasswordAuthenticationFilter.class).build();
 }
}
