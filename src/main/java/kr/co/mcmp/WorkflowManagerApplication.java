package kr.co.mcmp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;

@SpringBootApplication
public class WorkflowManagerApplication {
    public static void main(String[] args) throws GeneralSecurityException, UnsupportedEncodingException {
        System.out.println("========= boot start test string console =========");
        SpringApplication.run(WorkflowManagerApplication.class, args);
        System.out.println("========= boot start test string console =========");
    }
}
