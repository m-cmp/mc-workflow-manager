package kr.co.mcmp.workflowStage.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.mcmp.api.response.ResponseCode;
import kr.co.mcmp.api.response.ResponseWrapper;
import kr.co.mcmp.workflowStage.dto.WorkflowStageTypeDto;
import kr.co.mcmp.workflowStage.service.WorkflowStageTypeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Workflow Stage Type", description = "워크플로우 스테이지 타입 관리")
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/workflowStageType")
@RestController
public class WorkflowStageTypeController {

    private final WorkflowStageTypeService workflowStageTypeService;

    @Operation(summary="워크플로우 스테이지 타입 목록")
    @GetMapping("/list")
    public ResponseWrapper<List<WorkflowStageTypeDto>> getWorkflowStageList() {
        return new ResponseWrapper<>(workflowStageTypeService.getWorkflowStageTypeList());
    }

    @Operation(summary="워크플로우 스테이지 타입 등록")
    @PostMapping
    public ResponseWrapper<Long> registWorkflowStage(@RequestBody WorkflowStageTypeDto workflowStageTypeDto) {
        return new ResponseWrapper<>(workflowStageTypeService.registWorkflowStage(workflowStageTypeDto));
    }

    @Operation(summary="워크플로우 스테이지 타입 수정")
    @PatchMapping("/{workflowStageTypeIdx}")
    public ResponseWrapper<Long> updateWorkflowStageType(@PathVariable Long workflowStageTypeIdx, @RequestBody WorkflowStageTypeDto workflowStageTypeDto) {
        if ( workflowStageTypeIdx != 0 || workflowStageTypeDto.getWorkflowStageTypeIdx() != 0 ) {
            return new ResponseWrapper<>(workflowStageTypeService.updateWorkflowStageType(workflowStageTypeDto));
        }
        return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "workflowStageTypeIdx");
    }

    @Operation(summary="워크플로우 스테이지 타입 삭제")
    @DeleteMapping("{workflowStageTypeIdx}")
    public ResponseWrapper<Void> deleteWorkflowStageType(@PathVariable Long workflowStageTypeIdx) {
        workflowStageTypeService.deleteWorkflowStageType(workflowStageTypeIdx);
        return new ResponseWrapper<>();
    }

    @Operation(summary="워크플로우 스테이지 타입 상세")
    @GetMapping("/{workflowStageTypeIdx}")
    public ResponseWrapper<WorkflowStageTypeDto> detailWorkflowStageType(@PathVariable Long workflowStageTypeIdx) {
        return new ResponseWrapper<>(workflowStageTypeService.detailWorkflowStageType(workflowStageTypeIdx));
    }
}
