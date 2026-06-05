package kr.co.mcmp.workflowStage.repository;

import kr.co.mcmp.workflowStage.Entity.WorkflowStage;
import kr.co.mcmp.workflowStage.Entity.WorkflowStageType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorkflowStageRepository extends JpaRepository<WorkflowStage, Long> {
    List<WorkflowStage> findAll();

    @Query("select stage from WorkflowStage stage order by stage.workflowStageType.workflowStageTypeIdx asc, stage.workflowStageOrder asc, stage.workflowStageIdx asc")
    List<WorkflowStage> findAllOrderByStageTypeAndStageOrder();

    void deleteByWorkflowStageIdx(Long workflowStageIdx);
    WorkflowStage findByWorkflowStageIdx(Long workflowStageIdx);
    Boolean existsByWorkflowStageTypeAndWorkflowStageName(WorkflowStageType workflowStageType, String workflowStageName);

    List<WorkflowStage> findByWorkflowStageType(WorkflowStageType workflowStageType);

    @Query("select stage from WorkflowStage stage where stage.workflowStageType = :workflowStageType order by stage.workflowStageOrder asc, stage.workflowStageIdx asc")
    List<WorkflowStage> findByWorkflowStageTypeOrderByStageOrder(@Param("workflowStageType") WorkflowStageType workflowStageType);

    Boolean existsByWorkflowStageType(WorkflowStageType workflowStageType);
}
