package kr.co.strato.mcmp.workflow.controller;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import kr.co.strato.mcmp.workflow.model.Workflow;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.strato.mcmp.api.response.ResponseWrapper;
import kr.co.strato.mcmp.workflow.service.WorkflowService;
import org.apache.commons.lang3.StringUtils;
import kr.co.strato.mcmp.api.response.ResponseCode;
import kr.co.strato.mcmp.jenkins.pipeline.model.Pipeline;

import javax.servlet.http.HttpServletRequest;

@Tag(name = "Workflow", description = "워크플로우 배포 관리")
@RequestMapping("/workflow")
@RestController
public class WorkflowController {

    @Autowired
    private WorkflowService workflowService;

    @Operation(summary="워크플로우 목록 조회")
    @GetMapping("/list")
    public ResponseWrapper<List<Workflow>> getWorkflowList() {
        return new ResponseWrapper<>(workflowService.getWorkflowList(null));
    }

    @Operation(summary="워크플로우 등록")
    @PostMapping("")
    public ResponseWrapper<Integer> createWorkflow(@RequestBody Workflow workflow) throws IOException {
        if ( StringUtils.isBlank(workflow.getWorkflowName()) ) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "workflowName");
        }
        else if ( StringUtils.isBlank(workflow.getWorkflowPurpose()) ) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "workflowPurpose");
        }
        else if ( workflow.getJenkinsId() == null || workflow.getJenkinsId() == 0 ) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "jenkinsId");
        }
        else if ( StringUtils.isBlank(workflow.getPipelineScript()) ) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "pipelineScript");
        }

        workflow.setRegId("admin");
        workflow.setRegName("admin");

        return new ResponseWrapper<>(workflowService.createWorkflow(workflow));
    }

    @Operation(summary="워크플로우 상세 조회")
    @GetMapping("/{workflowId}")
    public ResponseWrapper<Workflow> getWorkflow(@PathVariable int workflowId) {
        return new ResponseWrapper<>(workflowService.getWorkflow(workflowId));
    }

    @Operation(summary="워크플로우 수정")
    @PutMapping("/{workflowId}")
    public ResponseWrapper<Boolean> updateWorkflow(@PathVariable int workflowId, @RequestBody Workflow workflow) throws IOException {
        if ( workflow.getWorkflowId() == null || workflow.getWorkflowId() == 0 ) {
            workflow.setWorkflowId(workflowId);
        }

        workflow.setModId("admin");
        workflow.setModName("admin");

        return new ResponseWrapper<>(workflowService.updateWorkflow(workflow));
    }

    @Operation(summary="파이프라인 생성 > Default 조회")
    @PostMapping("/jenkins/pipeline/default")
    public ResponseWrapper<List<Pipeline>> getDefaultPipeline(@RequestBody Workflow workflow) {
// TODO 추후 추가작업
//        if ( StringUtils.isBlank(workflow.getWorkflowName()) ) {
//            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "workflowName");
//        }
//        else if ( workflow.getJenkinsId() == 0 ) {
//            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "getJenkinsId");
//        }

        return new ResponseWrapper<>(workflowService.getDefaultPipeline(workflow));
    }

    @Operation(summary="워크플로우 명 중복 체크", description="true : 중복 / false : 중복 아님")
    @GetMapping("/name/duplicate")
    public ResponseWrapper<Boolean> isWorkflowNameDuplicated(@RequestParam String workflowName) {
        if ( StringUtils.isBlank(workflowName) ) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "workflowName");
        }

        return new ResponseWrapper<>(workflowService.isWorkflowNameDuplicated(workflowName));
    }

    @Operation(summary="파이프라인 구분 별 목록 조회")
    @GetMapping("/jenkins/pipeline")
    public ResponseWrapper<Map<String, List<Pipeline>>> getPipelineList() {
        return new ResponseWrapper<>(workflowService.getPipelineList());
    }

    @Operation(summary="워크플로우 배포 실행")
    @GetMapping("/{workflowId}/run")
    public ResponseWrapper<Object> runWorkflowGet(HttpServletRequest request, @PathVariable int workflowId) {
        Workflow workflow = new Workflow();
        workflow.setWorkflowId(workflowId);
        return new ResponseWrapper<>(workflowService.runWorkflow(workflow));
    }

    @Operation(summary="워크플로우 배포 실행")
    @PostMapping("/run")
    public ResponseWrapper<Object> runWorkflowPost(HttpServletRequest request, @RequestBody Workflow workflow) {
        return new ResponseWrapper<>(workflowService.runWorkflow(workflow));
    }

    @Operation(summary="워크플로우 배포 삭제")
    @DeleteMapping("/{workflowId}")
    public ResponseWrapper<Boolean> deleteWorkflow(@PathVariable int workflowId) {
        return new ResponseWrapper<>(workflowService.deleteWorkflow(workflowId));
    }
}
