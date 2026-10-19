package vn.mocsach;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
@SpringBootApplication
public class MocSachApplication extends SpringBootServletInitializer {
 public static void main(String[] args) { SpringApplication.run(MocSachApplication.class,args); }
 @Override protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) { return builder.sources(MocSachApplication.class); }
}
