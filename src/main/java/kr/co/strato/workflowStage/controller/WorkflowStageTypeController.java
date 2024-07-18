package kr.co.strato.workflowStage.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.strato.api.response.ResponseWrapper;
import kr.co.strato.workflowStage.dto.WorkflowStageTypeDto;
import kr.co.strato.workflowStage.service.WorkflowStageTypeService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@Tag(name = "Workflow Stage Type", description = "워크플로우 스테이지 타입 관리")
@RequestMapping("/workflowStageType")
@RestController
public class WorkflowStageTypeController {

    @Autowired
    private WorkflowStageTypeService workflowStageTypeService;

    @Operation(summary="워크플로우 스테이지 목록")
    @GetMapping("/list")
    public ResponseWrapper<List<WorkflowStageTypeDto>> getWorkflowStageList() {
        return new ResponseWrapper<>(workflowStageTypeService.getWorkflowStageTypeList());
    }

    @Operation(summary="워크플로우 스테이지 등록")
    @PostMapping("/regist")
    public ResponseWrapper<Long> registWorkflowStage(@RequestBody WorkflowStageTypeDto workflowStageTypeDto) {
        return new ResponseWrapper<>(workflowStageTypeService.registWorkflowStage(workflowStageTypeDto));
    }

    @Operation(summary="워크플로우 스테이지 수정")
    @PutMapping("/modify/{workflowStageTypeIdx}")
    public ResponseWrapper<Long> updateWorkflowStageType(@PathVariable Long workflowStageTypeIdx, @RequestBody WorkflowStageTypeDto workflowStageTypeDto) {
        if ( workflowStageTypeIdx != 0 || workflowStageTypeDto.getWorkflowStageTypeIdx() != 0 ) {
            return new ResponseWrapper<>(workflowStageTypeService.updateWorkflowStageType(workflowStageTypeDto));
        }
        return new ResponseWrapper<>(null);
    }

    @Operation(summary="워크플로우 스테이지 삭제")
    @DeleteMapping("/delete/{workflowStageTypeIdx}")
    public ResponseWrapper<Void> deleteWorkflowStageType(@PathVariable Long workflowStageTypeIdx) {
        workflowStageTypeService.deleteWorkflowStageType(workflowStageTypeIdx);
        return new ResponseWrapper<>();
    }

    @Operation(summary="워크플로우 스테이지 상세")
    @GetMapping("/detail/{workflowStageTypeIdx}")
    public ResponseWrapper<WorkflowStageTypeDto> detailWorkflowStageType(@PathVariable Long workflowStageTypeIdx) {
        return new ResponseWrapper<>(workflowStageTypeService.detailWorkflowStageType(workflowStageTypeIdx));
    }
}
