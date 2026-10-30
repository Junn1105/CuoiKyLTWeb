package com.bookstore.config;

import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EntityScan(basePackages = {"com.bookstore.entity", "vn.mocsach"})
@EnableJpaRepositories(basePackages = {"com.bookstore.repository", "vn.mocsach"})
public class JpaConfig {
}
