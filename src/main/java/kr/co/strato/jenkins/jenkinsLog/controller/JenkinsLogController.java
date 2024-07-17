package kr.co.strato.jenkins.jenkinsLog.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.strato.jenkins.jenkinsLog.service.JenkinsLogService;
import kr.co.strato.api.response.ResponseWrapper;
//import kr.co.strato.jenkins.jenkinsLog.service.JenkinsLogService;
//import kr.co.strato.workflow.model.WorkflowHistory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "jenkinsLog", description ="젠킨스 로그")
@RequestMapping("/jenkins")
@RestController
public class JenkinsLogController {
//    @Autowired
//    private JenkinsLogService jenkinsLogService;
//
//    @Operation(summary="로그 조회")
//    @GetMapping("/logs/{workflowId}")
//    public ResponseWrapper<List<WorkflowHistory>> getLog(@PathVariable Integer workflowId) {
//        return new ResponseWrapper<>(jenkinsLogService.getLogs(workflowId));
//    }
}
