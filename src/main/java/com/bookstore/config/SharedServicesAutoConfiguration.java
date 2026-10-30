package com.bookstore.config;

import com.bookstore.service.shared.CloudinaryService;
import com.bookstore.service.shared.MockCloudinaryServiceImpl;
import com.bookstore.service.shared.MockWebSocketNotificationServiceImpl;
import com.bookstore.service.shared.WebSocketNotificationService;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SharedServicesAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean(WebSocketNotificationService.class)
    public WebSocketNotificationService webSocketNotificationService() {
        return new MockWebSocketNotificationServiceImpl();
    }

    @Bean
    @ConditionalOnMissingBean(CloudinaryService.class)
    public CloudinaryService cloudinaryService() {
        return new MockCloudinaryServiceImpl();
    }
}
