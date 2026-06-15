package kr.co.mcmp.workflow.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.mcmp.api.response.ResponseCode;
import kr.co.mcmp.api.response.ResponseWrapper;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowStageMappingDto;
import kr.co.mcmp.workflow.dto.reqDto.WorkflowReqDto;
import kr.co.mcmp.workflow.dto.resDto.*;
import kr.co.mcmp.workflow.service.WorkflowService;
import kr.co.mcmp.workflow.service.jenkins.model.JenkinsBuildDescribeLog;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.Objects;

@Tag(name = "Workflow", description = "Workflow deployment management")
@RequiredArgsConstructor
@RequestMapping("/workflow")
@RestController
public class WorkflowController {
    
    private final WorkflowService workflowService;

    @Operation(summary="List workflows")
    @GetMapping("/list")
    public ResponseWrapper<List<WorkflowListResDto>> getWorkflowList() {
        return new ResponseWrapper<>(workflowService.getWorkflowList());
    }

    @Operation(summary="Register workflow")
    @PostMapping
    public ResponseWrapper<Long> registWorkflow(@RequestBody WorkflowReqDto workflowReqDto) {

        if ( StringUtils.isBlank(workflowReqDto.getWorkflowInfo().getWorkflowName()) ) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "WorkflowName");
        }
        else if ( StringUtils.isBlank(workflowReqDto.getWorkflowInfo().getWorkflowPurpose()) ) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "WorkflowPurpose");
        }
        else if ( workflowReqDto.getWorkflowInfo().getOssIdx() == 0) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "OssIdx");
        }
        else if ( StringUtils.isBlank(workflowReqDto.getWorkflowInfo().getScript()) ) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "Script");
        }

        return new ResponseWrapper<>(workflowService.registWorkflow(workflowReqDto));
    }


    @Operation(summary="Update workflow")
    @PatchMapping("/{workflowIdx}")
    public ResponseWrapper<Boolean> updateWorkflow(@PathVariable Long workflowIdx, @RequestBody WorkflowReqDto workflowReqDto) {
        if (workflowIdx == null
                || workflowIdx == 0
                || workflowReqDto.getWorkflowInfo() == null
                || workflowReqDto.getWorkflowInfo().getWorkflowIdx() == null
                || workflowReqDto.getWorkflowInfo().getWorkflowIdx() == 0
                || !Objects.equals(workflowIdx, workflowReqDto.getWorkflowInfo().getWorkflowIdx())) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "WorkflowIdx");
        }

        return new ResponseWrapper<>(workflowService.updateWorkflow(workflowReqDto));
    }


    @Operation(summary="Delete workflow deployment")
    @DeleteMapping("/{workflowIdx}")
    public ResponseWrapper<Boolean> deleteWorkflow(@PathVariable Long workflowIdx) {
        return new ResponseWrapper<>(workflowService.deleteWorkflow(workflowIdx));
    }

    @Operation(summary="Check whether workflow has linked event listeners")
    @GetMapping("/existEventListener/{workflowIdx}")
    public ResponseWrapper<Boolean> existEventListener(@PathVariable Long workflowIdx) {
        return new ResponseWrapper<>(workflowService.existEventListener(workflowIdx));
    }

    @Operation(summary="Get workflow detail")
    @GetMapping("/{workflowIdx}")
    public ResponseWrapper<WorkflowDetailResDto> getWorkflow(@PathVariable Long workflowIdx) {
        return new ResponseWrapper<>(workflowService.getWorkflow(workflowIdx));
    }


    @Operation(summary="Check duplicate workflow name", description="true: duplicate / false: not duplicate")
    @GetMapping("/name/duplicate")
    public ResponseWrapper<Boolean> isWorkflowNameDuplicated(@RequestParam String workflowName) {
        if ( StringUtils.isBlank(workflowName) ) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "workflowName");
        }

        return new ResponseWrapper<>(workflowService.isWorkflowNameDuplicated(workflowName));
    }


    @Operation(summary="List stages by stage type")
    @GetMapping("/workflowStageList")
    public ResponseWrapper<List<WorkflowStageTypeAndStageNameResDto>> getWorkflowStageList() {
        return new ResponseWrapper<>(workflowService.getWorkflowStageList());
    }


    @Operation(summary="Get template")
    @GetMapping("/template/{workflowName}")
    public ResponseWrapper<List<WorkflowStageMappingDto>> getWorkflowTemplate(@PathVariable String workflowName) {
        if ( StringUtils.isBlank(workflowName) ) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "workflowName");
        }
        return new ResponseWrapper<>(workflowService.getWorkflowTemplate(workflowName));
    }


    @Operation(summary="Run workflow deployment")
    @GetMapping("/run/{workflowIdx}")
    public ResponseWrapper<Boolean> runWorkflowGet(@PathVariable Long workflowIdx) {
        return new ResponseWrapper<>(workflowService.runWorkflow(workflowIdx));
    }


    @Operation(summary="Run workflow deployment")
    @PostMapping("/run")
    public ResponseWrapper<Object> runWorkflowPost(@RequestBody WorkflowReqDto workflowReqDto) {
        return new ResponseWrapper<>(workflowService.runWorkflow(workflowReqDto));
    }

    @Operation(summary="Get workflow log")
    @GetMapping("/log/{workflowIdx}")
    public ResponseWrapper<List<WorkflowLogResDto>> getWorkflowLog(@PathVariable Long workflowIdx) {
        return new ResponseWrapper<>(workflowService.getWorkflowLog(workflowIdx));
    }

    @Operation(summary="Get workflow run history")
    @GetMapping("/runHistory/{workflowIdx}")
    public ResponseWrapper<List<WorkflowRunHistoryResDto>> getWorkflowRunHistoryList(@PathVariable Long workflowIdx) {
        return new ResponseWrapper<>(workflowService.getWorkflowRunHistoryList(workflowIdx));
    }

    @Operation(summary="Get workflow run history by stage")
    @GetMapping("/stageHistory/{workflowIdx}")
    public ResponseWrapper<JenkinsBuildDescribeLog> getWorkflowStageHistoryList(@PathVariable Long workflowIdx, @RequestParam int buildIdx, @RequestParam int nodeIdx) {
        return new ResponseWrapper<>(workflowService.getWorkflowStageHistoryList(workflowIdx, buildIdx, nodeIdx));
    }
}
