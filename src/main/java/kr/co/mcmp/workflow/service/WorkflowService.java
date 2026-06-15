package kr.co.mcmp.workflow.service;

import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowHistoryDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowParamDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowStageMappingDto;
import kr.co.mcmp.workflow.dto.reqDto.WorkflowReqDto;
import kr.co.mcmp.workflow.dto.resDto.*;
import kr.co.mcmp.workflow.service.jenkins.model.JenkinsBuildDescribeLog;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.IOException;
import java.util.List;

public interface WorkflowService {

    // Comment translated to English.
    List<WorkflowListResDto> getWorkflowList();

    // Comment translated to English.
    Long registWorkflow(WorkflowReqDto workflowReqDto);

    // Comment translated to English.
    Boolean updateWorkflow(WorkflowReqDto workflowReqDto);

    // Comment translated to English.
    Boolean deleteWorkflow(Long workflowIdx);

    // Comment translated to English.
    Boolean existEventListener(Long workflowIdx);

    // Comment translated to English.
    WorkflowDetailResDto getWorkflow(Long workflowIdx);

    // Comment translated to English.
    Boolean isWorkflowNameDuplicated(String workflowName);

    // Comment translated to English.
    Boolean runWorkflow(Long workflowIdx);

    // Comment translated to English.
    Boolean runWorkflow(WorkflowReqDto workflowReqDto);

    // Comment translated to English.
    List<WorkflowStageTypeAndStageNameResDto> getWorkflowStageList();

    // Comment translated to English.
    List<WorkflowStageMappingDto> getWorkflowTemplate(String workflowName);
    
    // Workflow History
    List<WorkflowHistoryDto> getWorkflowHistoryList(Long workflowIdx, String dataType);

    // Workflow Param
    List<WorkflowParamDto> getWorkflowParamList();

    // workflow log List
    List<WorkflowLogResDto> getWorkflowLog(Long workflowIdx);

    List<WorkflowRunHistoryResDto> getWorkflowRunHistoryList(Long workflowIdx);

    JenkinsBuildDescribeLog getWorkflowStageHistoryList(Long workflowIdx, int buildIdx, int nodeIdx);
}
