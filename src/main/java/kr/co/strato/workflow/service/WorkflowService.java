package kr.co.strato.workflow.service;

import kr.co.strato.workflow.dto.entityMappingDto.WorkflowDto;
import kr.co.strato.workflow.dto.entityMappingDto.WorkflowHistoryDto;
import kr.co.strato.workflow.dto.entityMappingDto.WorkflowParamDto;
import kr.co.strato.workflow.dto.reqDto.WorkflowReqDto;
import kr.co.strato.workflow.dto.resDto.WorkflowDetailResDto;
import kr.co.strato.workflow.dto.resDto.WorkflowStageTypeAndStageNameResDto;
import kr.co.strato.workflowStage.dto.WorkflowStageDto;

import java.util.List;

public interface WorkflowService {

    // Workflow 목록
    List<WorkflowDto> getWorkflowList();

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
    Boolean runWorkflow(Long workflowIdx);

    // Workflow 실행 (Workflow 정보)
    Boolean runWorkflow(WorkflowReqDto workflowReqDto);

    // Workflow 스테이지 목록
    List<WorkflowStageTypeAndStageNameResDto> getWorkflowStageList();

    // Workflow 기본 템플릿 조회
    List<WorkflowStageDto> getWorkflowTemplate(String workflowName);
    
    // Workflow History
    List<WorkflowHistoryDto> getWorkflowHistoryList(Long workflowIdx);

    // Workflow Param
    List<WorkflowParamDto> getWorkflowParamList();
}
