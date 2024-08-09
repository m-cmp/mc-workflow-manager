package kr.co.strato.workflow.repository;

import kr.co.strato.workflow.Entity.Workflow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorkflowRepository extends JpaRepository<Workflow, Long> {
    List<Workflow> findAll();
    Workflow findByWorkflowIdx(Long workflowIdx);
    Workflow findByWorkflowName(String workflowName);
    void deleteByWorkflowIdx(Long workflowIdx);
}
