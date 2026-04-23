package com.shuttlemate.shuttle_mate.config;

import com.shuttlemate.shuttle_mate.common.interceptor.LoginCheckInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new LoginCheckInterceptor())
                .addPathPatterns("/club/create")    // 막을 url 경로
                .excludePathPatterns("/login", "/main", "/css/**", "/js/**");
    }
}
