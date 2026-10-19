package vn.mocsach.auth;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.*;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
@Service
public class OtpMailer {
 private final JavaMailSender sender; private final String from;
 public OtpMailer(JavaMailSender sender,@Value("${app.mail.from:}") String from){this.sender=sender;this.from=from;}
 public void send(String to,String code,String purpose) {
  if(from.isBlank()) throw new MailSendException("SMTP not configured");
  SimpleMailMessage mail=new SimpleMailMessage(); mail.setFrom(from);mail.setTo(to);
  mail.setSubject("Mộc Sách — Mã xác thực "+code);
  mail.setText("Xin chào,\n\nMã xác thực "+("REGISTER".equals(purpose)?"đăng ký":"EMAIL".equals(purpose)?"đổi email":"đặt lại mật khẩu")+" tại Mộc Sách của bạn là:\n\n"+code+"\n\nMã có hiệu lực trong 5 phút và chỉ sử dụng một lần. Không chia sẻ mã này với bất kỳ ai.\nNếu bạn không yêu cầu thao tác này, hãy bỏ qua email.\n\nMộc Sách\nCửa hàng bán sách cũ");
  sender.send(mail);
 }
}
