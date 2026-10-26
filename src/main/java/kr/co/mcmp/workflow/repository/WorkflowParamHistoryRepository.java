package kr.co.mcmp.workflow.repository;

import kr.co.mcmp.workflow.Entity.WorkflowParamHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WorkflowParamHistoryRepository extends JpaRepository<WorkflowParamHistory, Long> {
    void deleteByWorkflow_WorkflowIdx(Long workflowIdx);
}
