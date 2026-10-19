package vn.mocsach.auth;
import com.nimbusds.jose.jwk.source.ImmutableSecret;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.*;
import org.springframework.stereotype.Component;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.*;
@Component
public class JwtTokens {
 private final JwtEncoder encoder;private final JwtDecoder decoder;private final Clock clock;
 public JwtTokens(@Value("${app.auth.secret}") String secret,Clock clock) {
  byte[] bytes=secret.getBytes(StandardCharsets.UTF_8);if(bytes.length<32)throw new IllegalStateException("Authentication secret is missing");
  var key=new SecretKeySpec(bytes,"HmacSHA256");this.clock=clock;
  encoder=new NimbusJwtEncoder(new ImmutableSecret<>(key));
  var d=NimbusJwtDecoder.withSecretKey(key).macAlgorithm(MacAlgorithm.HS256).build();
  d.setJwtValidator(JwtValidators.createDefaultWithIssuer("moc-sach"));decoder=d;
 }
 public String issue(UserAccount user) {
  Instant now=clock.instant();
  var claims=JwtClaimsSet.builder().issuer("moc-sach").subject(user.id.toString()).issuedAt(now).expiresAt(now.plusSeconds(7200)).claim("version",user.authVersion).build();
  return encoder.encode(JwtEncoderParameters.from(JwsHeader.with(MacAlgorithm.HS256).build(),claims)).getTokenValue();
 }
 public Jwt decode(String token) {return decoder.decode(token);}
}
