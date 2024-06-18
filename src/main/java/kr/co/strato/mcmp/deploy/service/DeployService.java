package kr.co.strato.mcmp.deploy.service;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.List;
import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;

import com.cdancy.jenkins.rest.domain.job.BuildInfo;

import kr.co.strato.mcmp.deploy.mapper.DeployMapper;
import kr.co.strato.mcmp.deploy.model.Deploy;
import kr.co.strato.mcmp.deploy.model.DeployHistory;
import kr.co.strato.mcmp.gitlab.model.GitlabConfig;
import kr.co.strato.mcmp.gitlab.service.GitLabService;
import kr.co.strato.mcmp.jenkins.model.JenkinsCredential;
import kr.co.strato.mcmp.jenkins.pipeline.JenkinsPipelineGeneratorService;
import kr.co.strato.mcmp.jenkins.pipeline.mapper.JenkinsPipelineMapper;
import kr.co.strato.mcmp.jenkins.pipeline.model.Pipeline;
import kr.co.strato.mcmp.jenkins.service.JenkinsService;
import kr.co.strato.mcmp.k8s.mapper.K8SMapper;
import kr.co.strato.mcmp.k8s.model.K8SConfig;
import kr.co.strato.mcmp.oss.mapper.OssMapper;
import kr.co.strato.mcmp.oss.model.Oss;
import kr.co.strato.mcmp.util.NamingUtils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class DeployService {
	
	@Value("${gitlab.deploy.yaml.path}")
	private String gitlabDeployYamlPath; 
		
	@Value("${gitlab.deploy.yaml.filename}")
	private String gitlabDeployYamlFilename; 
	
	@Autowired
	private GitLabService gitlabService;
	
	@Autowired
	private JenkinsService jenkinsService;
	
	@Autowired
	private JenkinsPipelineGeneratorService pipelineService;

	@Autowired
	private DeployMapper deployMapper;
	
	@Autowired
	private OssMapper ossMapper; 
	
	@Autowired
	private K8SMapper k8sMapper;
	
	@Autowired
	private JenkinsPipelineMapper pipelineMapper;
	
	/**
	 * 배포 목록 조회
	 * @param deploy
	 * @return
	 */
	public List<Deploy> getDeployList(Deploy deploy) {
		return deployMapper.selectDeployList(deploy);
	}
	 
	/**
	 * 배포 상세 조회
	 * @param deployId
	 * @return
	 */
	public Deploy getDeploy(int deployId) {
		Deploy deploy = deployMapper.selectDeploy(deployId);
		if ( deploy != null ) {
			deploy.setPipelines(deployMapper.selectDeployPipelineList(deployId));
		}
		
		return deploy;
	}
	
	/**
	 * 배포명 중복 체크
	 * @param deployName
	 * @return
	 */
	public boolean isDeployNameDuplicated(String deployName) {
		return deployMapper.isDeployNameDuplicated(deployName);
	}
	
	/**
	 * GitLab Clone URL 연결 체크
	 * @param gitlabId
	 * @param gitlabProjectPath
	 * @return
	 */
	public boolean checkgitlabProjectPathConnection(int gitlabId, String gitlabProjectPath) {
		Oss gitlab = ossMapper.selectOss(gitlabId);
		
		return gitlabService.checkConnection(gitlab, getGitlabCloneFullUrl(gitlab.getOssUrl(), gitlabProjectPath));
	}
	
	/**
	 * GitLab 프로젝트 Clone URL
	 * @param gitlabUrl
	 * @param gitlabProjectPath
	 * @return
	 */
	private String getGitlabCloneFullUrl(String gitlabUrl, String gitlabProjectPath) {
		return String.format("%s/%s", gitlabUrl, gitlabProjectPath);
	}
	
	/**
	 * 기본 스크립트 생성
	 * @param gitlabId
	 * @param gitlabProjectPath
	 * @param branch
	 * @return
	 */
	public List<Pipeline> getDefaultPipeline(String deployName, int gitlabId, String gitlabProjectPath, String branch, int k8sId) {
		Oss gitlab = ossMapper.selectOss(gitlabId);
		String gitlabCloneUrl = getGitlabCloneFullUrl(gitlab.getOssUrl(), gitlabProjectPath);

		K8SConfig k8s = k8sMapper.selectK8S(k8sId);

		return pipelineService.getDefaultPipeline(deployName, gitlabCloneUrl, branch
												,NamingUtils.getCredentialName(gitlab.getOssId(), gitlab.getOssName())
												,NamingUtils.getCredentialName(k8s.getK8sId(), k8s.getK8sName()));
	}
	
	/**
	 * 젠킨스 파이프라인 목록 (빌드 시 사용할 파이프라인 목록)
	 * @param pipelineCd
	 * @param projectId
	 * @return
	 */
	public List<Pipeline> getPipelineList(String pipelineCd) {
		Pipeline pipeline = new Pipeline();
		pipeline.setPipelineCd(pipelineCd);

		return pipelineMapper.selectJenkinsPipelineList(pipeline);
	}
	
	/**
	 * 배포 생성
	 * @param deploy
	 * @return
	 * @throws IOException 
	 */
	@Transactional(rollbackFor = { RuntimeException.class })
	public int createDeploy(Deploy deploy) throws IOException {
		// GitLab 정보 조회
		Oss gitlab = ossMapper.selectOss(deploy.getGitlabId());
		GitlabConfig gitlabConfig = gitlabService.parsingGitLabURL(getGitlabCloneFullUrl(gitlab.getOssUrl(), deploy.getGitlabProjectPath()));
		if ( gitlabConfig != null ) {
			deploy.setGroupName(gitlabConfig.getGroupName());
			deploy.setProjectName(gitlabConfig.getProjectName());
		}
		
		// deploy.yaml 파일을 gitlab에 upload
		gitlabService.createOrUpdateFile(deploy.getGitlabId(), deploy.getGroupName(), deploy.getProjectName(), 
								getDeployYamlFileFullPath(deploy.getWorkflowName()), deploy.getBranch(), deploy.getWorkflowYaml());

		// jenkins 정보 조회
		Oss jenkins = ossMapper.selectOss(deploy.getJenkinsId());
		
		// jenkins >  gitlab 접속 credentials 등록
		String gitlabCredentialId = jenkinsService.createCredential(jenkins, gitlab, null, JenkinsCredential.getCredentialTypeByOss(gitlab.getOssCd()));
		log.info("[GitLab] Credential ID : {}", gitlabCredentialId);
		
		// jenkins >  클러스터 접속 credentials 등록
		K8SConfig k8s = k8sMapper.selectK8S(deploy.getK8sId());
		String k8sCredentialId = jenkinsService.createCredential(jenkins, null, k8s, JenkinsCredential.getCredentialTypeByOss("CLUSTER"));
		log.info("[K8S] Credential ID : {}", k8sCredentialId);
		
		// jenkins > job 생성
		String jobName = createJobName(jenkins, deploy.getWorkflowName());
		deploy.setJenkinsJobName(jobName);
		
		boolean isCreate = jenkinsService.createJenkinsJob(jenkins, deploy.getJenkinsJobName(), deploy.getPipelineScript());
    	if ( isCreate ) {
    		deployMapper.insertDeploy(deploy);
    		
    		// deploy_jenkins_pipeline_mapping
    		if ( !CollectionUtils.isEmpty(deploy.getPipelines()) ) {    			
    			deployMapper.insertDeployPipeline(deploy);
    		}
    	}
		
		return deploy.getWorkflowId();
	}
	
	/**
	 * yaml 파일 업로드 경로 
	 * @param deployName
	 * @return
	 */
	private String getDeployYamlFileFullPath(String deployName) {
		return String.format("%s/%s/%s", gitlabDeployYamlPath, deployName, gitlabDeployYamlFilename).replace("//", "/");
	}
    
    /**
     * Jenkins Job 이름 생성 
     * @param name
     * @return
     */
	public String createJobName(Oss jenkins, String buildName) {
		int min = 10000;
		int max = 99999;
		int v = new Random().nextInt((max - min) + 1) + min;
		
		String jobName = null;
		boolean isExist = true;

		while(isExist) {
			jobName = String.format("%s-%d", buildName, v);
			isExist = jenkinsService.isExistJobName(jenkins, jobName);
		}
		
		return jobName;
	}

	/**
	 * 배포 정보 수정
	 */
	@Transactional(rollbackFor = { RuntimeException.class })
	public boolean updateDeploy(Deploy updateDeploy) throws UnsupportedEncodingException {
		boolean result = false;
		
		Deploy deploy = deployMapper.selectDeploy(updateDeploy.getWorkflowId());
		
		// deploy.yaml 파일을 gitlab에 upload
		gitlabService.createOrUpdateFile(deploy.getGitlabId(), deploy.getGroupName(), deploy.getProjectName(), 
								getDeployYamlFileFullPath(deploy.getWorkflowName()), deploy.getBranch(), updateDeploy.getWorkflowYaml());
		
		// jenkins에 job 수정
		Oss jenkins = ossMapper.selectOss(deploy.getJenkinsId());
		
		boolean isUpdate = jenkinsService.updateJenkinsJobPipeline(jenkins, deploy.getJenkinsJobName(), updateDeploy.getPipelineScript());
    	if ( isUpdate ) {
    		deployMapper.updateDeploy(updateDeploy);
    		
    		// deploy_jenkins_pipeline_mapping 
    		if ( !CollectionUtils.isEmpty(updateDeploy.getPipelines()) ) {
    			deployMapper.deleteDeployPipeline(updateDeploy.getWorkflowId());
    			
    			updateDeploy.setRegId(updateDeploy.getModId());
    			updateDeploy.setRegName(updateDeploy.getModName());
    			deployMapper.insertDeployPipeline(updateDeploy);
    		}

			result = true;
    	}
		
		return result;
	}
	
	/**
	 * 배포 정보 삭제
	 * @param deployId
	 * @return
	 */
	public boolean deleteDeploy(int workflowId) {
		boolean result = false;
		
		Deploy deploy = deployMapper.selectDeploy(workflowId);

		Oss jenkins = ossMapper.selectOss(deploy.getJenkinsId());
		
		boolean isDelete = jenkinsService.deleteJenkinsJob(jenkins, deploy.getJenkinsJobName());
		if ( isDelete ) {
			// deploy_jenkins_pipeline_mapping 테이블 데이터 삭제
			deployMapper.deleteDeployPipeline(workflowId);
			
			// deploy_history 테이블 데이터 삭제
			deployMapper.deleteDeployHistory(workflowId);
			
			// deploy 테이블 데이터 삭제
			deployMapper.deleteDeploy(workflowId);
			
			result = true;
		}
		
		return result;
	}
	
	/**
	 * 배포 실행
	 * @param deployId
	 * @return
	 */
	@Async
	public int runDeploy(int deployId) {
		// 배포 실행 관련 사용자 이력 정보 수정
		Deploy deploy = deployMapper.selectDeploy(deployId);

		// OSS 접속 정보 조회
		Oss jenkins = ossMapper.selectOss(deploy.getJenkinsId());
		
		// Jenkins Job 실행 		
		int jenkinsBuildId = jenkinsService.buildJenkinsJob(jenkins, deploy.getJenkinsJobName(), null);
		int buildNumber = jenkinsService.getQueueExecutableNumber(jenkins, jenkinsBuildId);
		
		// 배포 이력 정보 등록 
		DeployHistory history = new DeployHistory();
		history.setWorkflowId(deployId);
		history.setJenkinsBuildId(jenkinsBuildId);
		history.setPipelineScript(deploy.getPipelineScript());
		history.setRunResult("BUILDING");
		history.setBuildNumber(buildNumber);
		history.setRunUserId("admin");
		history.setRunUserName("admin");
		deployMapper.insertDeployHistory(history);

		// Jenkins Job 실행 대기
		BuildInfo buildInfo = jenkinsService.waitJenkinsBuild(jenkins, deploy.getJenkinsJobName(), jenkinsBuildId, buildNumber);

		// Jenkin Job 실행 결과 등록
		history.setRunResult(buildInfo.result());
		history.setRunMessage(buildInfo.toString());
		deployMapper.updateDeployHistory(history);
		
		return history.getWorkflowHistoryId();
	}
}
