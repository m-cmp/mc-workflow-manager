package m.cmp.wfManager.exception;

import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import lombok.extern.slf4j.Slf4j;
import m.cmp.wfManager.api.response.ResponseWrapper;


@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    /**
     * Exception 발생시
     */
    @ExceptionHandler(Exception.class)
    protected ResponseWrapper<String> handleException(Exception e) {
        log.error("Exception", e);
        
        McmpException de = new McmpException(e);
        return new ResponseWrapper<>(de.getResponseCode(), de.getDetail());
        
    }

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
}
