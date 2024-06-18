package kr.co.strato.mcmp.util;

import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableFeignClients(basePackages = "com.isntyet.java.practice")
public class FeignConfig {

}
