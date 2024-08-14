package kr.co.mcmp.mcmp;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledForJreRange;
import org.junit.jupiter.api.condition.EnabledOnOs;
import org.junit.jupiter.api.condition.JRE;
import org.junit.jupiter.api.condition.OS;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.test.context.SpringBootTest;


@SpringBootTest
class McmpBackendApplicationTests {

	/**
	 * 
	 * @BeforeAll 	: 테스트 실행 전에 실행되는 메소드입니다.
	 * @BeforeEach 	: 테스트(@Test) 메소드 실행 전에 실행되는 메소드입니다.
	 * @AfterEach 	: 테스트(@Test) 메소드 실행이 끝나면 실행되는 메소드입니다.
	 * @AfterAll 	: 모든 테스트 메소드 실행이 끝나면 실행되는 메소드입니다. 
	 * @Test 		: 테스트 메서드임을 나타냅니다.
	 * @Disable 	: 테스트 클래스나 테스트 메소드를 사용하지 않도록 할 때 사용됩니다.(not be executed)
	 * @DisplayName : 테스트 클래스 또는 테스트 메서드에 대한 사용자 지정 표시 이름을 설정합니다.(custom display name)
	 * @RepeatedTest : 반복 테스트를 위한 메소드임을 나타냅니다.
	 * @ParameterizedTest : 매개 변수가 있는 테스트임을 나타냅니다.
	 * @TestMethodOrder : 테스트 메소드 실행 순서를 구성하는데 사용됩니다.
	 * @Timeout 	: 주어진 시간안에 실행을 못할 경우 실패하도록 하는데 사용됩니다.
	 * 
	 */
	
	private static Logger log = LoggerFactory.getLogger(McmpBackendApplicationTests.class);

	@Test
	void contextLoads() {
	}
	
	@BeforeAll
    static void beforeAllTest() {
		log.info("@BeforeAll executed before all tests in the current test class.");
    }

    @BeforeEach
    void beforeEaschTest() {
    	log.info("@BeforeEach executed before each @Test method in the current test class.");
    }

    @AfterEach
    void afterEachTest() {
    	log.info("@AfterEach executed after each @Test method in the current test class.");
    }

    @AfterAll
    static void afterAllTest() {
    	log.info("@AfterAll executed after all tests in the current test class.");
    }

	@Test
	void testAssert() {
		
		//assertEquals : 같은 값인가? 
		int a = 1;
		int b = 1;
		assertEquals(a, b, "a와 b는 같지 않다");
		log.info("a와 b는 같다");
		/* 예상 결과값 ************************************************************************
		/* 성공 : a와 b는 같다
		/* 실패 : org.opentest4j.AssertionFailedError: a와 b는 같지 않다
		***********************************************************************************/		

		//assertSame : 같은 객체인가?		
		String str1 = new String();
		String str2 = str1;
		assertSame(str1, str2, "str1과 str2s는 같지 않다");
		log.info("str1과 str2는 같다");
		/* 예상 결과값 ************************************************************************
		/* 성공 : str1과 str2는 같다
		/* 실패 : org.opentest4j.AssertionFailedError: str1과 str2s는 같지 않다
		***********************************************************************************/		
		
		//assertTrue(a): a가 참인가?
		boolean result = true;
		assertTrue(result, "result는 false 이다");
		log.info("result는 true 이다");
		/* 예상 결과값 ************************************************************************
		/* 성공 : result는 true 이다
		/* 실패 : org.opentest4j.AssertionFailedError: result는 false 이다
		***********************************************************************************/		
		
		//assertNotNull(a): a가 null이 아닌가?
		Object data = new Object();
		assertNotNull(data, "data는 null 이다");
		log.info("data는 null이 아니다");
		/* 예상 결과값 ************************************************************************
		/* 성공 : data는 null이 아니다
		/* 실패 : org.opentest4j.AssertionFailedError: data는 null 이다
		***********************************************************************************/		
	}
	
    @ParameterizedTest 
    @ValueSource(ints = { 1, 2, 3 }) 
    void testWithValueSource(int number) {
    	assertTrue(0 < number && 4 > number);
    	log.info("{}는 0보다 크고 4보다 작다", number);
		/* 예상 결과값 ************************************************************************
		/* 1는 0보다 크고 4보다 작다
		/* 2는 0보다 크고 4보다 작다
		/* 3는 0보다 크고 4보다 작다		 
		***********************************************************************************/		
    }
    
    @Test
    @EnabledOnOs(OS.LINUX)
    void onLinux() {
    	log.info("os.LINUX인 경우에만 실행");
    }

    @Test
    @EnabledOnOs(OS.WINDOWS)
    void OnWindow() {
		log.info("os.WINDOWS인 경우만 실행");
    }
    
    @Test
    @EnabledForJreRange(min = JRE.JAVA_8, max = JRE.JAVA_11)
    void forJava8to11() {
    	log.info("Java8에서 11인 경우만 실행");
    }

}   
