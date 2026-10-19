package vn.mocsach.auth;
import jakarta.persistence.*;
import org.hibernate.annotations.Nationalized;
import java.time.LocalDateTime;
@Entity @Table(name="Users",schema="dbo")
public class UserAccount {
 @Column(name="Phone",length=20) public String phone;
 @Column(name="AvatarPath",length=100) public String avatarPath;
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="UserId") public Integer id;
 @Nationalized @Column(name="Username",length=50,nullable=false) public String username;
 @Nationalized @Column(name="Email",length=254,nullable=false) public String email;
 @Nationalized @Column(name="FullName",length=150,nullable=false) public String fullName;
 @Column(name="PasswordHash",length=255,nullable=false) public String passwordHash;
 @Column(name="Status",length=20,nullable=false) public String status;
 @Column(name="AuthVersion",nullable=false) public int authVersion;
 @Column(name="CreatedAt",nullable=false) public LocalDateTime createdAt;
 @Column(name="UpdatedAt",nullable=false) public LocalDateTime updatedAt;
}
