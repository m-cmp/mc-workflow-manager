package kr.co.strato.oss.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.strato.api.response.ResponseWrapper;
import kr.co.strato.oss.dto.OssTypeDto;
import kr.co.strato.oss.service.OssTypeService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@Tag(name = "oss 타입", description = "JENKINS / GITLAB / TUMBLEBUG / Etc...")
@RequestMapping("/ossType")
@RestController
public class OssTypeController {

    @Autowired
    private OssTypeService ossTypeService;

    @Operation(summary = "OSS 타입 목록 조회", description = "oss Type 목록조회" )
    @GetMapping("/list")
    public ResponseWrapper<List<OssTypeDto>> getOssTypeList() {
        return new ResponseWrapper<>(ossTypeService.getAllOssTypeList());
    }

    @Operation(summary = "OSS 타입 등록", description = "oss Type 등록")
    @PostMapping("/regist")
    public ResponseWrapper<Long> registOssType(@RequestBody OssTypeDto ossTypeDto) {
        return new ResponseWrapper<>(ossTypeService.registOssType(ossTypeDto));
    }

    @Operation(summary = "OSS 타입 수정", description = "oss Type 수정")
    @PutMapping("/modify/{ossTypeIdx}")
    public ResponseWrapper<Long> updateOssType(@PathVariable Long ossTypeIdx, @RequestBody OssTypeDto ossTypeDto) {
        if ( ossTypeIdx != 0 || ossTypeDto.getOssTypeIdx() != 0 ) {
            return new ResponseWrapper<>(ossTypeService.updateOssType(ossTypeDto));
        }
        return new ResponseWrapper<>(null);
    }

    @Operation(summary = "OSS 타입 삭제", description = "oss Type 삭제")
    @DeleteMapping("/delete/{ossTypeIdx}")
    public ResponseWrapper<Void> deleteOssType(@PathVariable Long ossTypeIdx) {
        ossTypeService.deleteOssType(ossTypeIdx);
        return new ResponseWrapper<>();
    }

    @Operation(summary = "OSS 타입 상세", description = "oss Type 상세정보")
    @GetMapping("/detail/{ossTypeIdx}")
    public ResponseWrapper<OssTypeDto> detailOssType(@PathVariable Long ossTypeIdx) {
        return new ResponseWrapper<>(ossTypeService.detailOssType(ossTypeIdx));
    }
}
