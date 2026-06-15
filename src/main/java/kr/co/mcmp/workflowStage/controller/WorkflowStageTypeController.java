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

@Tag(name = "Workflow Stage Type", description = "Workflow stage type management")
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/workflowStageType")
@RestController
public class WorkflowStageTypeController {

    private final WorkflowStageTypeService workflowStageTypeService;

    @Operation(summary="List workflow stage types")
    @GetMapping("/list")
    public ResponseWrapper<List<WorkflowStageTypeDto>> getWorkflowStageList() {
        return new ResponseWrapper<>(workflowStageTypeService.getWorkflowStageTypeList());
    }

    @Operation(summary="Register workflow stage type")
    @PostMapping
    public ResponseWrapper<Long> registWorkflowStage(@RequestBody WorkflowStageTypeDto workflowStageTypeDto) {
        return new ResponseWrapper<>(workflowStageTypeService.registWorkflowStage(workflowStageTypeDto));
    }

    @Operation(summary="Update workflow stage type")
    @PatchMapping("/{workflowStageTypeIdx}")
    public ResponseWrapper<Boolean> updateWorkflowStageType(@PathVariable Long workflowStageTypeIdx, @RequestBody WorkflowStageTypeDto workflowStageTypeDto) {
        if ( workflowStageTypeIdx != 0 || workflowStageTypeDto.getWorkflowStageTypeIdx() != 0 ) {
            return new ResponseWrapper<>(workflowStageTypeService.updateWorkflowStageType(workflowStageTypeDto));
        }
        return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "workflowStageTypeIdx");
    }

    @Operation(summary="Delete workflow stage type")
    @DeleteMapping("{workflowStageTypeIdx}")
    public ResponseWrapper<Boolean> deleteWorkflowStageType(@PathVariable Long workflowStageTypeIdx) {
        return new ResponseWrapper<>(workflowStageTypeService.deleteWorkflowStageType(workflowStageTypeIdx));
    }

    @Operation(summary="Get workflow stage type detail")
    @GetMapping("/{workflowStageTypeIdx}")
    public ResponseWrapper<WorkflowStageTypeDto> detailWorkflowStageType(@PathVariable Long workflowStageTypeIdx) {
        return new ResponseWrapper<>(workflowStageTypeService.detailWorkflowStageType(workflowStageTypeIdx));
    }
}
