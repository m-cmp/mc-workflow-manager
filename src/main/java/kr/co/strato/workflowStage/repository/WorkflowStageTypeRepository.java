package kr.co.strato.workflowStage.repository;

import kr.co.strato.workflowStage.Entity.WorkflowStage;
import kr.co.strato.workflowStage.Entity.WorkflowStageType;
import kr.co.strato.workflowStage.dto.WorkflowStageTypeDto;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorkflowStageTypeRepository extends JpaRepository<WorkflowStageType, Long> {
    List<WorkflowStageType> findAll();
    WorkflowStageType save(WorkflowStageType workflowStageType);
    void deleteById(Long workflowStageTypeIdx);
    WorkflowStageType findByWorkflowStageTypeIdx(Long workflowStageTypeIdx);
}
