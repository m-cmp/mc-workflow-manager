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
	 * @BeforeAll: runs before all tests in the class.
	 * @BeforeEach: runs before each @Test method.
	 * @AfterEach: runs after each @Test method.
	 * @AfterAll: runs after all test methods complete.
	 * @Test: marks a test method.
	 * @Disable: disables a test class or test method.
	 * @DisplayName: sets a custom display name.
	 * @RepeatedTest: marks a repeated test.
	 * @ParameterizedTest: marks a parameterized test.
	 * @TestMethodOrder: configures test method execution order.
	 * @Timeout: fails the test if it does not finish in the given time.
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
		
		// assertEquals: checks whether values are equal.
		int a = 1;
		int b = 1;
		assertEquals(a, b, "a and b are not equal");
		log.info("a and b are equal");
		/* Expected result *********************************************************************
		/* Success: a and b are equal
		/* Failure: org.opentest4j.AssertionFailedError: a and b are not equal
		***********************************************************************************/		

		// assertSame: checks whether objects are the same instance.
		String str1 = new String();
		String str2 = str1;
		assertSame(str1, str2, "str1 and str2 are not the same instance");
		log.info("str1 and str2 are the same instance");
		/* Expected result *********************************************************************
		/* Success: str1 and str2 are the same instance
		/* Failure: org.opentest4j.AssertionFailedError: str1 and str2 are not the same instance
		***********************************************************************************/		
		
		// assertTrue: checks whether the value is true.
		boolean result = true;
		assertTrue(result, "result is false");
		log.info("result is true");
		/* Expected result *********************************************************************
		/* Success: result is true
		/* Failure: org.opentest4j.AssertionFailedError: result is false
		***********************************************************************************/		
		
		// assertNotNull: checks whether the value is not null.
		Object data = new Object();
		assertNotNull(data, "data is null");
		log.info("data is not null");
		/* Expected result *********************************************************************
		/* Success: data is not null
		/* Failure: org.opentest4j.AssertionFailedError: data is null
		***********************************************************************************/		
	}
	
    @ParameterizedTest 
    @ValueSource(ints = { 1, 2, 3 }) 
    void testWithValueSource(int number) {
    	assertTrue(0 < number && 4 > number);
		log.info("{} is greater than 0 and less than 4", number);
		/* Expected result *********************************************************************
		/* 1 is greater than 0 and less than 4
		/* 2 is greater than 0 and less than 4
		/* 3 is greater than 0 and less than 4
		***********************************************************************************/		
    }
    
    @Test
    @EnabledOnOs(OS.LINUX)
    void onLinux() {
		log.info("Runs only on Linux");
    }

    @Test
    @EnabledOnOs(OS.WINDOWS)
    void OnWindow() {
		log.info("Runs only on Windows");
    }
    
    @Test
    @EnabledForJreRange(min = JRE.JAVA_8, max = JRE.JAVA_11)
    void forJava8to11() {
		log.info("Runs only on Java 8 through Java 11");
    }

}   
