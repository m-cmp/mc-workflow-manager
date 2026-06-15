package kr.co.mcmp.workflowStage.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.mcmp.api.response.ResponseCode;
import kr.co.mcmp.api.response.ResponseWrapper;
import kr.co.mcmp.workflowStage.dto.WorkflowStageDto;
import kr.co.mcmp.workflowStage.service.WorkflowStageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Workflow Stage", description = "Workflow stage management")
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/workflowStage")
@RestController
public class WorkflowStageController {

    private final WorkflowStageService workflowStageService;

    @Operation(summary="List workflow stages")
    @GetMapping("/list")
    public ResponseWrapper<List<WorkflowStageDto>> getWorkflowStageList() {
        return new ResponseWrapper<>(workflowStageService.getWorkflowStageList());
    }

    @Operation(summary="Register workflow stage")
    @PostMapping
    public ResponseWrapper<Long> registWorkflowStage(@RequestBody WorkflowStageDto workflowStageDto) {
        return new ResponseWrapper<>(workflowStageService.registWorkflowStage(workflowStageDto));
    }

    @Operation(summary="Update workflow stage")
    @PatchMapping("/{workflowStageIdx}")
    public ResponseWrapper<Boolean> updateWorkflowStage(@PathVariable Long workflowStageIdx, @RequestBody WorkflowStageDto workflowStageDto) {
        if ( workflowStageIdx != 0 || workflowStageDto.getWorkflowStageIdx() != 0 ) {
            return new ResponseWrapper<>(workflowStageService.updateWorkflowStage(workflowStageDto));
        }
        return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "workflowStageIdx");
    }

    @Operation(summary="Delete workflow stage")
    @DeleteMapping("/{workflowStageIdx}")
    public ResponseWrapper<Boolean> deleteWorkflowStage(@PathVariable Long workflowStageIdx) {
        return new ResponseWrapper<>(workflowStageService.deleteWorkflowStage(workflowStageIdx));
    }

    @Operation(summary="Get workflow stage detail")
    @GetMapping("/{workflowStageIdx}")
    public ResponseWrapper<WorkflowStageDto> detailWorkflowStage(@PathVariable Long workflowStageIdx) {
        return new ResponseWrapper<>(workflowStageService.detailWorkflowStage(workflowStageIdx));
    }

    @Operation(summary="Check duplicate workflow stage name", description="true: duplicate / false: not duplicate")
    @GetMapping("/duplicate")
    public ResponseWrapper<Boolean> isWorkflowStageNameDuplicated(@RequestParam String workflowStageTypeName, @RequestParam String workflowStageName) {
        if ( StringUtils.isBlank(workflowStageTypeName) ) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "workflowStageTypeName");
        }
        else if ( StringUtils.isBlank(workflowStageName) ) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "workflowStageName");
        }

        return new ResponseWrapper<>(workflowStageService.isWorkflowStageNameDuplicated(workflowStageTypeName, workflowStageName));
    }

    @Operation(summary="Get default script when creating workflow stage")
    @GetMapping("/default/script/{workflowStageTypeName}")
    public ResponseWrapper<List<WorkflowStageDto>> getDefaultWorkflowStage(@PathVariable String workflowStageTypeName) {
        return new ResponseWrapper<>(workflowStageService.getDefaultWorkflowStage(workflowStageTypeName));
    }
}
