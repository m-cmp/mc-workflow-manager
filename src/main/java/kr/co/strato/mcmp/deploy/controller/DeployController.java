package kr.co.strato.mcmp.deploy.controller;

import java.io.IOException;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.strato.mcmp.api.response.ResponseCode;
import kr.co.strato.mcmp.api.response.ResponseWrapper;
import kr.co.strato.mcmp.deploy.model.Deploy;
import kr.co.strato.mcmp.deploy.service.DeployService;
import kr.co.strato.mcmp.jenkins.pipeline.model.Pipeline;

//@Tag(name = "Deploy", description = "워크플로우 배포 관리")
@RestController
public class DeployController {

//	@Autowired
//	private DeployService deployService;
//
//    @Operation(summary="워크플로우 배포 목록 조회")
//    @PostMapping("/deploy/list")
//	public ResponseWrapper<List<Deploy>> getDeployList(@RequestBody Deploy deploy) {
//		return new ResponseWrapper<>(deployService.getDeployList(deploy));
//	}
//
//    @Operation(summary="워크플로우 배포 상세 조회")
//    @GetMapping("/deploy/{deployId}")
//    public ResponseWrapper<Deploy> getDeploy(@PathVariable int deployId) {
//    	return new ResponseWrapper<>(deployService.getDeploy(deployId));
//    }
//
//    @Operation(summary="워크플로우 배포명 중복 체크", description="true : 중복 / false : 중복 아님")
//    @GetMapping("/deploy/name/duplicate")
//    public ResponseWrapper<Boolean> isDeployNameDuplicated(@RequestParam String deployName) {
//    	if ( StringUtils.isBlank(deployName) ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "deployName");
//    	}
//
//    	return new ResponseWrapper<>(deployService.isDeployNameDuplicated(deployName));
//    }
//
//    @Operation(summary="GitLab Clone URL 연결 체크", description="true : 중복 / false : 중복 아님")
//    @GetMapping("/deploy/gitlab/connection/check")
//    public ResponseWrapper<Boolean> checkGitlabProjectPathConnection(@RequestParam int gitlabId, @RequestParam String gitlabProjectPath) {
//    	if ( gitlabId == 0 ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "gitlabId");
//    	}
//    	else if ( StringUtils.isBlank(gitlabProjectPath) ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "gitlabProjectPath");
//    	}
//
//    	return new ResponseWrapper<>(deployService.checkgitlabProjectPathConnection(gitlabId, gitlabProjectPath));
//    }
//
//    @Operation(summary="파이프라인 생성 > Default 조회")
//    @GetMapping("/deploy/jenkins/pipeline/default")
//    public ResponseWrapper<List<Pipeline>> getDefaultPipeline(@RequestParam String deployName,
//													@RequestParam int gitlabId, @RequestParam String gitlabProjectPath, @RequestParam String branch, @RequestParam int k8sId) {
//
//    	if ( StringUtils.isBlank(deployName) ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "deployName");
//    	}
//    	else if ( gitlabId == 0 ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "gitlabId");
//    	}
//    	else if ( StringUtils.isBlank(gitlabProjectPath) ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "gitlabProjectPath");
//    	}
//    	else if ( StringUtils.isBlank(branch) ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "branch");
//    	}
//    	else if ( k8sId == 0 ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "k8sId");
//    	}
//
//    	return new ResponseWrapper<>(deployService.getDefaultPipeline(deployName, gitlabId, gitlabProjectPath, branch, k8sId));
//    }
//
//    @Operation(summary="파이프라인 구분 별 목록 조회")
//    @GetMapping("/deploy/jenkins/pipeline/{pipelineCd}")
//    public ResponseWrapper<List<Pipeline>> getPipelineList(@PathVariable String pipelineCd) {
//    	return new ResponseWrapper<>(deployService.getPipelineList(pipelineCd));
//    }
//
//    @Operation(summary="워크플로우 배포 등록")
//    @PostMapping("/deploy")
//	public ResponseWrapper<Integer> createDeploy(@RequestBody Deploy deploy) throws IOException {
//    	if ( StringUtils.isBlank(deploy.getWorkflowName()) ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "deployName");
//    	}
//    	else if ( deploy.getGitlabId() == null || deploy.getGitlabId() == 0 ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "gitlabId");
//    	}
//    	else if ( StringUtils.isBlank(deploy.getGitlabProjectPath()) ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "gitlabProjectPath");
//    	}
//    	else if ( StringUtils.isBlank(deploy.getBranch()) ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "branch");
//    	}
//    	else if ( StringUtils.isBlank(deploy.getWorkflowYaml()) ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "deployYaml");
//    	}
//    	else if ( deploy.getJenkinsId() == null || deploy.getJenkinsId() == 0 ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "jenkinsId");
//    	}
//    	else if ( StringUtils.isBlank(deploy.getPipelineScript()) ) {
//    		return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "pipelineScript");
//    	}
//
//    	deploy.setRegId("admin");
//    	deploy.setRegName("admin");
//
//		return new ResponseWrapper<>(deployService.createDeploy(deploy));
//	}
//
//    @Operation(summary="워크플로우 배포 수정")
//    @PutMapping("/deploy/{deployId}")
//    public ResponseWrapper<Boolean> updateDeploy(@PathVariable int deployId, @RequestBody Deploy deploy) throws IOException {
//    	if ( deploy.getWorkflowId() == null || deploy.getWorkflowId() == 0 ) {
//    		deploy.setWorkflowId(deployId);
//    	}
//
//    	deploy.setModId("admin");
//    	deploy.setModName("admin");
//
//    	return new ResponseWrapper<>(deployService.updateDeploy(deploy));
//    }
//
//    @Operation(summary="워크플로우 배포 삭제")
//    @DeleteMapping("/deploy/{deployId}")
//    public ResponseWrapper<Boolean> deleteDeploy(@PathVariable int deployId) {
//    	return new ResponseWrapper<>(deployService.deleteDeploy(deployId));
//    }
//
//    @Operation(summary="워크플로우 배포 실행")
//    @PostMapping("/deploy/{deployId}/run")
//    public ResponseWrapper<Object> runDeploy(HttpServletRequest request, @PathVariable int deployId) {
//    	return new ResponseWrapper<>(deployService.runDeploy(deployId));
//    }
}
