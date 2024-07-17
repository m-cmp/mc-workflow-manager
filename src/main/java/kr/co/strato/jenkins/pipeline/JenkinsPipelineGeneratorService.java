package kr.co.strato.jenkins.pipeline;

import java.util.ArrayList;
import java.util.List;

import kr.co.strato.oss.dto.OssDto;
import kr.co.strato.oss.service.OssServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import kr.co.strato.jenkins.pipeline.model.Pipeline;
import kr.co.strato.util.JenkinsPipelineUtil;

@Service
public class JenkinsPipelineGeneratorService {
//
//	@Value("${gitlab.deploy.yaml.path}")
//	private String deployYamlPath;
//
//	@Value("${gitlab.deploy.yaml.filename}")
//	private String deployYamlFileName;
//
//	@Autowired
//	OssServiceImpl ossService;
//
//    /**
//     * 파이프라인 생성 > Default 조회
//     * @return
//     */
//    public List<Pipeline> getDefaultPipeline(String deployName, String gitlabCloneUrl, String branch, String gitlabCredentialId, String clusterCredentialId) {
//		// Checkout And Build 파이프라인(CHECKOUTBUILD)
//		Pipeline startPipeline = new Pipeline();
//		startPipeline.setPipelineCd("");
//		startPipeline.setPipelineScript(getStartPipeline(deployName, gitlabCloneUrl, branch, gitlabCredentialId, clusterCredentialId));
//
//		// Docker Image or WAR File Upload(FILEUPLOAD)
//		Pipeline endPipeline = new Pipeline();
//		endPipeline.setPipelineCd("");
//		endPipeline.setPipelineScript(getEndPipeline());
//
//		List<Pipeline> pipelines = new ArrayList<>();
//		pipelines.add(startPipeline);
//		pipelines.add(endPipeline);
//
//		return pipelines;
//    }
//	/**
//	 * Pipeline 시작 부분 생성
//	 */
//	private String getStartPipeline(String deployName, String gitlabCloneUrl, String branch, String gitlabCredentialId, String clusterCredentialId) {
//		StringBuffer sb = new StringBuffer();
//
//		JenkinsPipelineUtil.appendLine(sb, "//It was created by the Devops portal.");
//		JenkinsPipelineUtil.appendLine(sb, "pipeline {");
//		JenkinsPipelineUtil.appendLine(sb, "agent any", 1);
//		JenkinsPipelineUtil.appendLine(sb, "", 1);
//		JenkinsPipelineUtil.appendLine(sb, "environment {", 1);
//		JenkinsPipelineUtil.appendLine(sb, String.format("GIT_CLONE_URL = '%s'", gitlabCloneUrl), 2);
//		JenkinsPipelineUtil.appendLine(sb, String.format("BRANCH = '%s'", branch), 2);
//		JenkinsPipelineUtil.appendLine(sb, String.format("GIT_CREDENTIAL = '%s'", gitlabCredentialId), 2);
//		JenkinsPipelineUtil.appendLine(sb, String.format("DEPLOY_YAML_PATH = '%s/%s'", deployYamlPath, deployName), 2);
//		JenkinsPipelineUtil.appendLine(sb, String.format("DEPLOY_YAML_FILE = '%s'", deployYamlFileName), 2);
//		JenkinsPipelineUtil.appendLine(sb, String.format("CLUSTER_CREDENTIAL = '%s'", clusterCredentialId), 2);
//		JenkinsPipelineUtil.appendLine(sb, "}", 1);
//		JenkinsPipelineUtil.appendLine(sb, "", 1);
//		JenkinsPipelineUtil.appendLine(sb, "stages {", 1);
//
//		return sb.toString();
//	}
//
//
//	/**
//	 * 파이프라인 생성 > Default 조회f (Workflow)
//	 * @return
//	 */
//	public List<Pipeline> getDefaultPipelineWorkflow(String workflowName) {
//		// Checkout And Build 파이프라인(CHECKOUTBUILD)
//		Pipeline startPipeline = new Pipeline();
//		startPipeline.setPipelineCd("");
//		startPipeline.setPipelineScript(getStartPipelineWorkflow(workflowName));
//
//		// Docker Image or WAR File Upload(FILEUPLOAD)
//		Pipeline endPipeline = new Pipeline();
//		endPipeline.setPipelineCd("");
//		endPipeline.setPipelineScript(getEndPipeline());
//
//		List<Pipeline> pipelines = new ArrayList<>();
//		pipelines.add(startPipeline);
//		pipelines.add(endPipeline);
//
//		return pipelines;
//	}
//
//	/**
//	 * Pipeline 시작 부분 생성
//	 */
//	private String getStartPipelineWorkflow(String workflowName) {
//		StringBuffer sb = new StringBuffer();
//
//		OssDto ossDto =  ossService.getOssByOssCd("TUMBLEBUG");
//
//		JenkinsPipelineUtil.appendLine(sb, "import groovy.json.JsonOutput");
//		JenkinsPipelineUtil.appendLine(sb, "\n");
//		JenkinsPipelineUtil.appendLine(sb, "pipeline {");
//		JenkinsPipelineUtil.appendLine(sb, "agent any", 1);
//		JenkinsPipelineUtil.appendLine(sb, "", 1);
//		JenkinsPipelineUtil.appendLine(sb, "environment {", 1);
//
//		JenkinsPipelineUtil.appendLine(sb, "CB_TUMBLEBUG_SWAGGER_URI = "  + "'" + ossDto.getOssUrl() + "/tumblebug" + "'", 2);
//		JenkinsPipelineUtil.appendLine(sb, "USER = " + "'" + ossDto.getOssUsername() + "'", 2);
//		JenkinsPipelineUtil.appendLine(sb, "USER_PASSWORD = " + "'" + ossService.decryptAesString(ossDto.getOssPassword()) + "'", 2);
//
//		JenkinsPipelineUtil.appendLine(sb, "}", 1);
//		JenkinsPipelineUtil.appendLine(sb, "", 1);
//		JenkinsPipelineUtil.appendLine(sb, "stages {", 1);
//
//		return sb.toString();
//	}
//	/**
//	 * Pipeline 끝 부분 생성
//	 */
//	public String getEndPipeline() {
//		StringBuffer sb = new StringBuffer();
//
//		JenkinsPipelineUtil.appendLine(sb, "}", 1);
//		JenkinsPipelineUtil.appendLine(sb, "}");
//
//		return sb.toString();
//	}
}
