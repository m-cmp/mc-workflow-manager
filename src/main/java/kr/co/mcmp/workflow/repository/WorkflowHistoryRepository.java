package kr.co.mcmp.workflow.repository;

import kr.co.mcmp.workflow.Entity.WorkflowHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorkflowHistoryRepository extends JpaRepository<WorkflowHistory, Long> {
    List<WorkflowHistory> findByWorkflow_WorkflowIdx(Long workflowIdx);
}
