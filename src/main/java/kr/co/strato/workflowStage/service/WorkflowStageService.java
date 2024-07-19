package kr.co.strato.workflowStage.service;

import kr.co.strato.workflowStage.dto.WorkflowStageDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface WorkflowStageService {
    List<WorkflowStageDto> getWorkflowStageList();
    Long registWorkflowStage(WorkflowStageDto workflowStageDto);
    Long updateWorkflowStage(WorkflowStageDto workflowStageDto);
    void deleteWorkflowStage(Long workflowStageIdx);
    WorkflowStageDto detailWorkflowStage(Long workflowStageIdx);
    Boolean isWorkflowStageNameDuplicated(String workflowStageTypeName, String workflowStageName);
    List<WorkflowStageDto> getDefaultWorkflowStage(String workflowStageTypeName);
}
