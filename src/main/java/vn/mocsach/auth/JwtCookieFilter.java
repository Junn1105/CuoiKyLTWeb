package vn.mocsach.auth;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;
import java.util.*;
@Component
public class JwtCookieFilter extends OncePerRequestFilter {
 private final JwtTokens tokens;private final UserRepository users;private final JdbcTemplate jdbc;
 public JwtCookieFilter(JwtTokens tokens,UserRepository users,JdbcTemplate jdbc){this.tokens=tokens;this.users=users;this.jdbc=jdbc;}
 @Override protected void doFilterInternal(HttpServletRequest request,HttpServletResponse response,FilterChain chain)throws ServletException,IOException {
  if(request.getCookies()!=null) for(Cookie cookie:request.getCookies()) if("mocsach_auth".equals(cookie.getName())) {
   try {
    var jwt=tokens.decode(cookie.getValue());var user=users.findById(Integer.valueOf(jwt.getSubject())).orElse(null);
    Number version=jwt.getClaim("version");
    if(user!=null&&"ACTIVE".equals(user.status)&&version!=null&&version.intValue()==user.authVersion) {
     var roles=new HashSet<SimpleGrantedAuthority>();
     try { jdbc.query("SELECT r.RoleCode FROM dbo.Roles r JOIN dbo.UserRoles ur ON ur.RoleId=r.RoleId WHERE ur.UserId=?",(rs,n)->roles.add(new SimpleGrantedAuthority("ROLE_"+rs.getString(1))),user.id); } catch(DataAccessException ignored) {}
     try { jdbc.query("SELECT DISTINCT StoreRole FROM dbo.StaffStoreAssignments WHERE UserId=? AND Status='ACTIVE'",(rs,n)->roles.add(new SimpleGrantedAuthority("ROLE_"+rs.getString(1))),user.id); } catch(DataAccessException ignored) {}
     SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(user.username,null,roles));
    }
   } catch(JwtException|IllegalArgumentException ignored) { SecurityContextHolder.clearContext(); }
   break;
  }
  chain.doFilter(request,response);
 }
}
