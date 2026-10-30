package vn.mocsach;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication(scanBasePackages = {"com.bookstore", "vn.mocsach"})
@EnableScheduling
public class MocSachApplication extends SpringBootServletInitializer {
	public static void main(String[] args) {
		SpringApplication.run(MocSachApplication.class, args);
	}

	@Override
	protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
		return builder.sources(MocSachApplication.class);
	}
}
