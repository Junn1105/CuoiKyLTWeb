package vn.mocsach.auth;
import org.springframework.stereotype.Component;
import java.time.*;
import java.util.*;
@Component
public class RequestLimiter {
 private final Map<String,Deque<Instant>> buckets=new HashMap<>();
 private final Clock clock;
 public RequestLimiter(Clock clock) { this.clock=clock; }
 public synchronized void check(String key,int limit,Duration window) {
  Instant now=clock.instant();
  buckets.values().forEach(q->{ while(!q.isEmpty() && q.peekFirst().isBefore(now.minus(Duration.ofHours(1)))) q.removeFirst(); });
  buckets.entrySet().removeIf(e->e.getValue().isEmpty());
  if(buckets.size()>10000 && !buckets.containsKey(key)) throw new AuthProblem("Hệ thống đang bận. Vui lòng thử lại sau.");
  Deque<Instant> q=buckets.computeIfAbsent(key,k->new ArrayDeque<>());
  while(!q.isEmpty() && !q.peekFirst().isAfter(now.minus(window))) q.removeFirst();
  if(q.size()>=limit) throw new AuthProblem("Bạn thao tác quá nhanh. Vui lòng đợi một lát rồi thử lại.");
  q.addLast(now);
 }
}
