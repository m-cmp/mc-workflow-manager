package kr.co.strato.mcmp.jenkins.jenkinsLog.service;

import com.cdancy.jenkins.rest.domain.common.RequestStatus;
import com.cdancy.jenkins.rest.domain.job.PipelineNode;
import kr.co.strato.mcmp.jenkins.api.JenkinsRestApi;
import kr.co.strato.mcmp.jenkins.model.JenkinsBuildDescribeLog;
import kr.co.strato.mcmp.jenkins.model.JenkinsBuildDetailLog;
import kr.co.strato.mcmp.jenkins.model.JenkinsWorkflow;
import kr.co.strato.mcmp.oss.mapper.OssMapper;
import kr.co.strato.mcmp.oss.model.Oss;
import kr.co.strato.mcmp.workflow.mapper.WorkflowMapper;
import kr.co.strato.mcmp.workflow.model.Workflow;
import kr.co.strato.mcmp.workflow.model.WorkflowHistory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class JenkinsLogService {
    @Autowired
    private JenkinsRestApi api;
    @Autowired
    private OssMapper ossMapper;

    @Autowired
    private WorkflowMapper workflowMapper;

    public List<WorkflowHistory> getLogs(Integer workflowId) {
        // 1. 정보 Get
        Workflow workflow = workflowMapper.selectWorkflow(workflowId);
        Oss jenkins = ossMapper.selectOss(workflow.getJenkinsId());

        // 2. history에서 jenkins build ID 가져오기
        List<WorkflowHistory> workflowHistoryList = workflowMapper.selectWorkflowHistoryList(workflowId);
        try {
            for(WorkflowHistory workflowHistory: workflowHistoryList) {
                String log = api.getJenkinsBuildConsoleLog(
                        jenkins.getOssUrl(),
                        jenkins.getOssUsername(),
                        jenkins.getOssPassword(),
                        workflow.getJenkinsJobName(),
                        workflowHistory.getBuildNumber()
                );
                workflowHistory.setLog(log);
            }
        } catch (Exception e) {
            System.err.println(e);
        }
        return workflowHistoryList;
    }
}
