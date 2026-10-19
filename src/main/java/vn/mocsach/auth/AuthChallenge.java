package vn.mocsach.auth;
import jakarta.persistence.*;
import org.hibernate.annotations.Nationalized;
import java.time.LocalDateTime;
@Entity @Table(name="AuthChallenges",schema="dbo")
public class AuthChallenge {
 @Column(name="VersionAtIssue") public Integer versionAtIssue;
 @Id @Column(name="ChallengeId",length=36) public String id;
 @Column(name="Purpose",length=16,nullable=false) public String purpose;
 @Nationalized @Column(name="Email",length=254,nullable=false) public String email;
 @Nationalized @Column(name="Username",length=50) public String username;
 @Nationalized @Column(name="FullName",length=150) public String fullName;
 @Column(name="PasswordHash",length=255) public String passwordHash;
 @Column(name="UserId") public Integer userId;
 @Column(name="CodeHash",length=64,nullable=false) public String codeHash;
 @Column(name="CreatedAt",nullable=false) public LocalDateTime createdAt;
 @Column(name="ExpiresAt",nullable=false) public LocalDateTime expiresAt;
 @Column(name="LastSentAt",nullable=false) public LocalDateTime lastSentAt;
 @Column(name="VerifiedAt") public LocalDateTime verifiedAt;
 @Column(name="UsedAt") public LocalDateTime usedAt;
 @Column(name="Attempts",nullable=false) public int attempts;
 @Column(name="SendCount",nullable=false) public int sendCount;
}
