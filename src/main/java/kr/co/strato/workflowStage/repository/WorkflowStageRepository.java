package kr.co.strato.workflowStage.repository;

import kr.co.strato.workflowStage.Entity.WorkflowStage;
import kr.co.strato.workflowStage.Entity.WorkflowStageType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorkflowStageRepository extends JpaRepository<WorkflowStage, Long> {
    List<WorkflowStage> findAll();
    void deleteById(Long workflowStageIdx);
    WorkflowStage findByWorkflowStageIdx(Long workflowStageIdx);
    Boolean existsByWorkflowStageTypeAndWorkflowStageName(WorkflowStageType workflowStageType, String workflowStageName);

    List<WorkflowStage> findByWorkflowStageType(WorkflowStageType workflowStageType);
}
