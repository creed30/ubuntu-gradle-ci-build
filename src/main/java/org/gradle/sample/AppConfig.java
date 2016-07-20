package org.gradle.sample;

import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.boot.SpringApplication;

@SpringBootApplication
@EnableAutoConfiguration
public class AppConfig implements ApplicationContextAware {

    private static ApplicationContext context;

    public static void main(String[] args) {
	ApplicationContext appContext = SpringApplication.run(AppConfig.class);
        context = appContext;
    }

    public static ApplicationContext getApplicationContext(){
    	return context;
    }

    @Override
    public void setApplicationContext(ApplicationContext ctx) {
        context = ctx;
    }
}
