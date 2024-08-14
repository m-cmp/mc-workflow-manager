package kr.co.mcmp.workflowStage.service;

import kr.co.mcmp.workflowStage.dto.WorkflowStageTypeDto;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface WorkflowStageTypeService {
    List<WorkflowStageTypeDto> getWorkflowStageTypeList();

    Long registWorkflowStage(WorkflowStageTypeDto workflowStageTypeDto);

    Long updateWorkflowStageType(WorkflowStageTypeDto workflowStageTypeDto);

    void deleteWorkflowStageType(Long workflowStageTypeIdx);

    WorkflowStageTypeDto detailWorkflowStageType(Long workflowStageTypeIdx);
}
