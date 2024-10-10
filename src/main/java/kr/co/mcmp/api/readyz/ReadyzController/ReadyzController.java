package kr.co.mcmp.api.readyz.ReadyzController;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.mcmp.api.readyz.ReadyzDto.ReadyzResDto;
import kr.co.mcmp.api.readyz.ReadyzService.ReadyzService;
import kr.co.mcmp.api.response.ResponseCode;
import kr.co.mcmp.api.response.ResponseWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "readyz", description = "readyz")
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/readyz")
@RestController
public class ReadyzController {

    private final ReadyzService readyzService;

    @Operation(summary = "readyz", description = "readyz")
    @GetMapping
    public ResponseWrapper<ResponseCode> checkConnection() {
        ReadyzResDto readyzResDto = readyzService.checkConnection();
        return new ResponseWrapper<>(readyzResDto.getCode(), readyzResDto.getMessage(), null);
    }
}
