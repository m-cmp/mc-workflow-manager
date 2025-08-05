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

    // Workflow 목록
    List<WorkflowListResDto> getWorkflowList();

    // Workflow 등록
    Long registWorkflow(WorkflowReqDto workflowReqDto);

    // Workflow 수정
    Boolean updateWorkflow(WorkflowReqDto workflowReqDto);

    // Workflow 삭제
    Boolean deleteWorkflow(Long workflowIdx);

    // Workflow 상세
    WorkflowDetailResDto getWorkflow(Long workflowIdx);

    // Workflow 중복 체크
    Boolean isWorkflowNameDuplicated(String workflowName);

    // Workflow 실행 (Idx)
    Boolean runWorkflow(Long workflowIdx) throws IOException;

    // Workflow 실행 (Workflow 정보)
    Boolean runWorkflow(WorkflowReqDto workflowReqDto) throws IOException;

    // Workflow 스테이지 목록
    List<WorkflowStageTypeAndStageNameResDto> getWorkflowStageList();

    // Workflow 기본 템플릿 조회
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
