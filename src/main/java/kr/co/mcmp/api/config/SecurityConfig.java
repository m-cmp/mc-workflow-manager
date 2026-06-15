//package kr.co.strato.api.config;
//
//import org.springframework.context.annotation.Bean;
//import org.springframework.core.annotation.Order;
//import org.springframework.security.config.annotation.web.builders.HttpSecurity;
//import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
//import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
//import org.springframework.security.config.annotation.web.configurers.RequestCacheConfigurer;
//import org.springframework.security.web.SecurityFilterChain;
//import org.springframework.web.cors.CorsConfiguration;
//import org.springframework.web.cors.CorsConfigurationSource;
//import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
//
//import java.util.Collections;
//
//@EnableWebSecurity
//public class SecurityConfig {
//
// Comment translated to English.
//	@Bean
//	@Order(0)
//	public SecurityFilterChain resources(HttpSecurity http) throws Exception {
//	    return http.cors().configurationSource(corsConfigurationSource())
//	    			.and()
// Comment translated to English.
//	    			.requestMatchers(matchers -> matchers.antMatchers("/**"))
//			        .requestCache(RequestCacheConfigurer::disable)
//			        .securityContext(AbstractHttpConfigurer::disable)
//			        .sessionManagement(AbstractHttpConfigurer::disable)
//			        .build();
//	}
//
// Comment translated to English.
//	public CorsConfigurationSource corsConfigurationSource() {
//		CorsConfiguration configuration = new CorsConfiguration();
//
//		configuration.setAllowedOriginPatterns(Collections.singletonList("*"));
//		configuration.addAllowedHeader("*");
//		configuration.addAllowedMethod("POST");
//		configuration.addAllowedMethod("PUT");
//		configuration.addAllowedMethod("DELETE");
//		configuration.addAllowedMethod("GET");
//
//		configuration.setAllowCredentials(true);
//
//		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
//		source.registerCorsConfiguration("/**", configuration);
//		return source;
//	}
//}
