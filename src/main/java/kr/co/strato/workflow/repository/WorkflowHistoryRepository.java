package kr.co.strato.workflow.repository;

import kr.co.strato.workflow.Entity.WorkflowHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorkflowHistoryRepository extends JpaRepository<WorkflowHistory, Long> {
    List<WorkflowHistory> findByWorkflow_WorkflowIdx(Long workflowIdx);
}
