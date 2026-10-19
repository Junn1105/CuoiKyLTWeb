package vn.mocsach.catalog;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.sql.Timestamp;
import java.time.*;
import java.util.*;

@Service
public class NotificationService {
 private final JdbcTemplate jdbc;
 public NotificationService(JdbcTemplate jdbc){this.jdbc=jdbc;}

 public int unreadCount(int userId){
  try{
   Integer c=jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Notifications WHERE UserId=? AND ReadAt IS NULL",Integer.class,userId);
   return c==null?0:c;
  }catch(DataAccessException ex){return 0;}
 }

 public List<Map<String,Object>> list(int userId,int limit){
  try{
   Instant now=Instant.now();
   var rows=jdbc.query("""
    SELECT NotificationId,Type,Title,Content,TargetUrl,CreatedAt,ReadAt
    FROM dbo.Notifications
    WHERE UserId=?
    ORDER BY CreatedAt DESC,NotificationId DESC
    """,(rs,i)->{
     var row=new LinkedHashMap<String,Object>();
     long id=rs.getLong("NotificationId");
     String type=Objects.toString(rs.getString("Type"),"");
     String targetUrl=Objects.toString(rs.getString("TargetUrl"),"");
     Timestamp createdAt=rs.getTimestamp("CreatedAt");
     Timestamp readAt=rs.getTimestamp("ReadAt");
     boolean unread=readAt==null;
     row.put("id",id);
     row.put("type",type);
     row.put("title",rs.getString("Title"));
     row.put("content",rs.getString("Content"));
     row.put("targetUrl",targetUrl);
     row.put("createdAt",createdAt);
     row.put("readAt",readAt);
     row.put("unread",unread);
     row.put("icon",iconFor(type));
     row.put("timeLabel",relativeTime(createdAt,now));
     row.put("safeUrl",safeTargetUrl(targetUrl));
     return (Map<String,Object>)row;
    },userId);
   return rows.size()>limit?rows.subList(0,limit):rows;
  }catch(DataAccessException ex){return List.of();}
 }

 @Transactional
 public String openAndMarkRead(int userId,long notificationId){
  var urls=jdbc.query("SELECT TargetUrl FROM dbo.Notifications WHERE NotificationId=? AND UserId=?",
   (rs,i)->rs.getString("TargetUrl"),notificationId,userId);
  if(urls.isEmpty())return "/notifications";
  jdbc.update("UPDATE dbo.Notifications SET ReadAt=CASE WHEN CreatedAt>CURRENT_TIMESTAMP THEN CreatedAt ELSE CURRENT_TIMESTAMP END WHERE NotificationId=? AND UserId=? AND ReadAt IS NULL",notificationId,userId);
  return safeTargetUrl(urls.get(0));
 }

 @Transactional
 public void markAllRead(int userId){
  jdbc.update("UPDATE dbo.Notifications SET ReadAt=CASE WHEN CreatedAt>CURRENT_TIMESTAMP THEN CreatedAt ELSE CURRENT_TIMESTAMP END WHERE UserId=? AND ReadAt IS NULL",userId);
 }

 @Transactional
 public void create(int userId,String type,String title,String content,String targetUrl){
  try{
   jdbc.update("INSERT INTO dbo.Notifications(UserId,StoreId,Type,Title,Content,TargetUrl,CreatedAt,ReadAt) VALUES(?,NULL,?,?,?,?,CURRENT_TIMESTAMP,NULL)",
    userId,type,title,content,safeTargetUrl(targetUrl));
  }catch(DataAccessException ignored){}
 }

 static String iconFor(String type){
  return switch(type.toUpperCase(Locale.ROOT)){
   case "CART" -> "🛒";
   case "ORDER","PAYMENT","RETURN","TRANSFER" -> "📦";
   case "REVIEW" -> "★";
   case "RECOMMEND" -> "📚";
   case "SECURITY" -> "🛡";
   default -> "🔔";
  };
 }

 static String relativeTime(Object raw,Instant now){
  Instant created= switch(raw){
   case Timestamp ts -> ts.toInstant();
   case LocalDateTime ldt -> ldt.toInstant(ZoneOffset.UTC);
   case OffsetDateTime odt -> odt.toInstant();
   case Instant inst -> inst;
   case null, default -> now;
  };
  long minutes=Math.max(0,Duration.between(created,now).toMinutes());
  if(minutes<1)return "Vừa xong";
  if(minutes<60)return minutes+" phút trước";
  long hours=minutes/60;
  if(hours<24)return hours+" giờ trước";
  long days=hours/24;
  if(days<7)return days+" ngày trước";
  long weeks=days/7;
  if(weeks<5)return weeks+" tuần trước";
  return (days/30)+" tháng trước";
 }

 static String safeTargetUrl(String url){
  String s=url==null?"":url.strip();
  if(s.startsWith("/account/notifications"))return "/notifications";
  if(!s.isEmpty()&&s.startsWith("/")&&!s.startsWith("//")
   &&(s.equals("/")||s.startsWith("/home")||s.startsWith("/books/")||s.startsWith("/cart")||s.startsWith("/account")||s.startsWith("/notifications")||s.startsWith("/orders")||s.startsWith("/checkout")))
   return s;
  return "/notifications";
 }
}
