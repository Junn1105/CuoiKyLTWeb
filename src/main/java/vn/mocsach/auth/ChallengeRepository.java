package vn.mocsach.auth;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
import java.util.Optional;
public interface ChallengeRepository extends JpaRepository<AuthChallenge,String> {
 @Lock(LockModeType.PESSIMISTIC_WRITE) @Query("select c from AuthChallenge c where c.id=:id")
 Optional<AuthChallenge> locked(@Param("id") String id);
 long countByEmailAndCreatedAtAfter(String email,LocalDateTime after);
 Optional<AuthChallenge> findFirstByEmailOrderByLastSentAtDesc(String email);
}
