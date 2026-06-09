package kr.co.mcmp.exception;

import kr.co.mcmp.api.response.ResponseWrapper;
//import kr.co.strato.argocd.exception.ArgocdException;
//import kr.co.strato.gitlab.exception.McmpGitLabException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.resource.NoResourceFoundException;


@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final String CHROME_DEVTOOLS_PROBE_PATH = ".well-known/appspecific/com.chrome.devtools.json";

    @ExceptionHandler(NoResourceFoundException.class)
    protected ResponseEntity<Void> handleNoResourceFoundException(NoResourceFoundException e) {
        String resourcePath = e.getResourcePath();
        if (CHROME_DEVTOOLS_PROBE_PATH.equals(resourcePath)) {
            log.debug("Ignoring Chrome DevTools probe request: {}", resourcePath);
        } else {
            log.warn("Static resource not found: {}", resourcePath);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    }
    
    /**
     * Exception 발생시
     */
    @ExceptionHandler(Exception.class)
    protected ResponseWrapper<String> handleException(Exception e) {
        log.error("Exception", e);
        
        McmpException de = new McmpException(e);
        return new ResponseWrapper<>(de.getResponseCode(), de.getDetail());
        
    }

//    /**
//     * RestClientResponseException 발생시
//     */
//    @ExceptionHandler(RestClientResponseException.class)
//    @ResponseStatus(HttpStatus.OK)
//    protected ResponseStatus handleRestClientResponseException(RestClientResponseException e) {
//        return new ResponseStatus(ResponseCode.API_REQUEST_ERROR);
//    }
    
    /*ResponseCode 로 Exception 발생시 */
    @ExceptionHandler(value = {McmpException.class})
    protected ResponseWrapper<String> handleGeneralException(McmpException de) {
    	return new ResponseWrapper<>(de.getResponseCode(), de.getDetail());
    }

    /*ResponseCode 로 Exception 발생시 */
    @ExceptionHandler(value = {AlreadyExistsException.class})
    protected ResponseWrapper<String> handleGeneralException(AlreadyExistsException de) {
    	return new ResponseWrapper<>(de.getResponseCode(), de.getDetail());
    }

//    @ExceptionHandler(value = {ArgocdException.class})
//    protected ResponseWrapper<String> handleGeneralException(ArgocdException e) {
//    	return new ResponseWrapper<>(e.getCode(), e.getMessag(), e.getDetail());
//    }
//
//    @ExceptionHandler(value = {McmpGitLabException.class})
//    protected ResponseWrapper<String> handleGeneralException(McmpGitLabException e) {
//    	return new ResponseWrapper<>(e.getCode(), e.getMessag(), e.getDetail());
//    }
}
