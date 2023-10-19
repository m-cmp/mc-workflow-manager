package m.cmp.wfManager._defaultconfig;

import io.swagger.v3.oas.models.OpenAPI;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Swagger Configuration 명세서 기본 정의
 */

@Configuration
public class SwaggerConfig {
        @Bean
        public OpenAPI openApiInfo(){
                return new OpenAPI().info(
                        new io.swagger.v3.oas.models.info.Info()
                                .title("mc-workflow-manager Api 명세서")
                                .description("mc-workflow-manager API 명세서")
                                .version("V1")
                );
        }
}
