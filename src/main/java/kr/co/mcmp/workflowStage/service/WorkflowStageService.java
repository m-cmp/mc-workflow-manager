package kr.co.mcmp.workflowStage.service;

import kr.co.mcmp.workflowStage.dto.WorkflowStageDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface WorkflowStageService {
    List<WorkflowStageDto> getWorkflowStageList();
    Long registWorkflowStage(WorkflowStageDto workflowStageDto);
    Boolean updateWorkflowStage(WorkflowStageDto workflowStageDto);
    Boolean deleteWorkflowStage(Long workflowStageIdx);
    WorkflowStageDto detailWorkflowStage(Long workflowStageIdx);
    Boolean isWorkflowStageNameDuplicated(String workflowStageTypeName, String workflowStageName);
    List<WorkflowStageDto> getDefaultWorkflowStage(String workflowStageTypeName);
}
