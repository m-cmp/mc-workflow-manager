package kr.co.strato.mcmp;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;


@SpringBootApplication
@EnableFeignClients // 여기
public class McmpBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(McmpBackendApplication.class, args);
	}

}
