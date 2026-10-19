package vn.mocsach.auth;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
public interface UserRepository extends JpaRepository<UserAccount,Integer> {
 @Lock(LockModeType.PESSIMISTIC_WRITE) @Query("select u from UserAccount u where u.id=:id")
 Optional<UserAccount> locked(@Param("id") Integer id);
 Optional<UserAccount> findByUsernameIgnoreCaseOrEmailIgnoreCase(String username,String email);
 Optional<UserAccount> findByEmailIgnoreCase(String email);
 boolean existsByUsernameIgnoreCase(String username);
 boolean existsByEmailIgnoreCase(String email);
}
