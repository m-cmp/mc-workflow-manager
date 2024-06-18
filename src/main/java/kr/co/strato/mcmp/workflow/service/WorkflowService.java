package kr.co.strato.mcmp.workflow.service;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.*;

import kr.co.strato.mcmp.common.model.CommonCode;
import kr.co.strato.mcmp.common.service.CommonService;
import kr.co.strato.mcmp.workflow.model.Workflow;
import lombok.Getter;
import lombok.Setter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;

import com.cdancy.jenkins.rest.domain.job.BuildInfo;

import kr.co.strato.mcmp.workflow.mapper.WorkflowMapper;
import kr.co.strato.mcmp.workflow.model.Workflow;
import kr.co.strato.mcmp.workflow.model.WorkflowHistory;
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
public class WorkflowService {

    @Autowired
    private JenkinsService jenkinsService;

    @Autowired
    private JenkinsPipelineGeneratorService pipelineService;

    @Autowired
    private WorkflowMapper workflowMapper;

    @Autowired
    private OssMapper ossMapper;

    @Autowired
    private JenkinsPipelineMapper pipelineMapper;

    @Autowired
    private CommonService commonService;

    /**
     * 워크플로우 목록 조회
     * @param workflow
     * @return
     */
    public List<Workflow> getWorkflowList(Workflow workflow) {
        return workflowMapper.selectWorkflowList(workflow);
    }

    /**
     * 워크플로우 생성
     * @param workflow
     * @return
     * @throws IOException
     */
    @Transactional(rollbackFor = { RuntimeException.class })
    public int createWorkflow(Workflow workflow) throws IOException {

        // jenkins 정보 조회
        Oss jenkins = ossMapper.selectOss(workflow.getJenkinsId());

        // jenkins > job 생성
        String jobName = createJobName(jenkins, workflow.getWorkflowName());
        workflow.setJenkinsJobName(jobName);

        boolean isCreate = jenkinsService.createJenkinsJob_v2(jenkins, workflow.getJenkinsJobName(), workflow.getPipelineScript(), workflow.getPipelineParam());
        if ( isCreate ) {
            workflowMapper.insertWorkflow(workflow);

            Workflow checkWorkflow = workflowMapper.selectWorkflowForName(workflow.getWorkflowName());
            workflow.setWorkflowId(checkWorkflow.getWorkflowId());
            workflowMapper.insertWorkflowParams(workflow);

            // workflow_jenkins_pipeline_mapping
            if ( !CollectionUtils.isEmpty(workflow.getPipelines()) ) {
                workflowMapper.insertWorkflowPipeline(workflow);
            }
        }

        return workflow.getWorkflowId();
    }

    /**
     * 배포 조회
     * @param workflowId
     * @return
     */
    public Workflow getWorkflow(int workflowId) {
        Workflow workflow = workflowMapper.selectWorkflow(workflowId);
        if ( workflow != null ) {
            workflow.setPipelines(workflowMapper.selectWorkflowPipelineList(workflowId));
            workflow.setPipelineParam(workflowMapper.selectWorkflowParamList(workflowId));
        }

        return workflow;
    }

    /**
     * 배포 정보 수정
     */
    @Transactional(rollbackFor = { RuntimeException.class })
    public boolean updateWorkflow(Workflow updateWorkflow) throws UnsupportedEncodingException {
        boolean result = false;

        Workflow workflow = workflowMapper.selectWorkflow(updateWorkflow.getWorkflowId());

        // jenkins에 job 수정
        Oss jenkins = ossMapper.selectOss(workflow.getJenkinsId());

        boolean isUpdate = jenkinsService.updateJenkinsJobPipeline_v2(jenkins, workflow.getJenkinsJobName(), updateWorkflow.getPipelineScript(), updateWorkflow.getPipelineParam());
        if ( isUpdate ) {
            workflowMapper.updateWorkflow(updateWorkflow);

            // workflow_jenkins_pipeline_mapping
            if ( !CollectionUtils.isEmpty(updateWorkflow.getPipelines()) ) {
                workflowMapper.deleteWorkflowPipeline(updateWorkflow.getWorkflowId());

                updateWorkflow.setRegId(updateWorkflow.getModId());
                updateWorkflow.setRegName(updateWorkflow.getModName());
                workflowMapper.insertWorkflowPipeline(updateWorkflow);
            }

            result = true;
        }

        return result;
    }

    /**
     * 기본 스크립트 생성
     * @param workflow
     * @return
     */
    public List<Pipeline> getDefaultPipeline(Workflow workflow) {
        return pipelineService.getDefaultPipelineWorkflow(workflow.getWorkflowName());

    }

    /**
     * 워크플로우명 중복 체크
     * @param workflowName
     * @return
     */
    public boolean isWorkflowNameDuplicated(String workflowName) {
        return workflowMapper.isWorkflowNameDuplicated(workflowName);
    }

    /**
     * 젠킨스 파이프라인 목록 (빌드 시 사용할 파이프라인 목록)
     * @return
     */
    public Map<String, List<Pipeline>> getPipelineList() {

        List<CommonCode> titleList = commonService.getCommonCodeList("Pipeline");

        Map<String, List<Pipeline>> map = new HashMap<>();

        if(!titleList.isEmpty()) {
            titleList.forEach(title -> {
                List<Pipeline> pipelineList = new ArrayList<>();

                Pipeline pipeline = pipelineMapper.selectJenkinsPipelineDetail(title.getCommonCd());
                pipelineList.add(pipeline);

                map.put(title.getCommonCd(), pipelineList);
            });

        }

        return map;
    }

    /**
     * 배포 실행
     * @param workflow
     * @return
     */
    @Async
    public int runWorkflow(Workflow workflow) {
        // 배포 실행 관련 사용자 이력 정보 수정
        Workflow workflowInfo = workflowMapper.selectWorkflow(workflow.getWorkflowId());

        Map<String, List<String>> jenkinsJobParams = null;
        if(workflow.getPipelineParam().size() > 0) {
            Map<String, List<String>> finalJenkinsJobParams = new HashMap<>();
            workflow.getPipelineParam().forEach(param-> {
                List<String> valueList = new ArrayList<>();
                valueList.add(param.getParamValue());
                finalJenkinsJobParams.put(param.getParamKey(), valueList);
            });
            jenkinsJobParams = finalJenkinsJobParams;
        }

        // OSS 접속 정보 조회
        Oss jenkins = ossMapper.selectOss(workflowInfo.getJenkinsId());

        // Jenkins Job 실행
        int jenkinsBuildId = jenkinsService.buildJenkinsJob(jenkins, workflowInfo.getJenkinsJobName(), jenkinsJobParams);
        int buildNumber = jenkinsService.getQueueExecutableNumber(jenkins, jenkinsBuildId);

        // 배포 이력 정보 등록
        WorkflowHistory history = new WorkflowHistory();
        history.setWorkflowId(workflowInfo.getWorkflowId());
        history.setJenkinsBuildId(jenkinsBuildId);
        history.setPipelineScript(workflowInfo.getPipelineScript());
        history.setRunResult("BUILDING");
        history.setBuildNumber(buildNumber);
        history.setRunUserId("admin");
        history.setRunUserName("admin");
        workflowMapper.insertWorkflowHistory(history);

        // Jenkins Job 실행 대기
        BuildInfo buildInfo = jenkinsService.waitJenkinsBuild(jenkins, workflowInfo.getJenkinsJobName(), jenkinsBuildId, buildNumber);

        // Jenkin Job 실행 결과 등록
        history.setRunResult(buildInfo.result());
        history.setRunMessage(buildInfo.toString());
        workflowMapper.updateWorkflowHistory(history);
//
        return history.getWorkflowHistoryId();
    }

    /**
     * 배포 정보 삭제
     * @param workflowId
     * @return
     */
    public boolean deleteWorkflow(int workflowId) {
        boolean result = false;

        Workflow workflow = workflowMapper.selectWorkflow(workflowId);

        Oss jenkins = ossMapper.selectOss(workflow.getJenkinsId());

        boolean isDelete = jenkinsService.deleteJenkinsJob(jenkins, workflow.getJenkinsJobName());
        if ( isDelete ) {
            // workflow_jenkins_pipeline_mapping 테이블 데이터 삭제
            workflowMapper.deleteWorkflowPipeline(workflowId);

            workflowMapper.deleteWorkflowParam(workflowId);

            // workflow_history 테이블 데이터 삭제
            workflowMapper.deleteWorkflowHistory(workflowId);

            // workflow 테이블 데이터 삭제
            workflowMapper.deleteWorkflow(workflowId);

            result = true;
        }

        return result;
    }

    /**
     * Jenkins Job 이름 생성
     * @param jenkins
     * @param buildName
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
}
