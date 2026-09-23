package kr.co.mcmp.eventListener.repository;


import kr.co.mcmp.eventListener.entity.EventListener;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EventListenerRepository extends JpaRepository<EventListener, Long> {
    List<EventListener> findAll();
    List<EventListener> findAllByWorkspaceIdAndProjectId(String workspaceId, String projectId);
    EventListener save(EventListener eventListener);
    void deleteByEventListenerIdx(Long eventListenerIdx);
    EventListener findByEventListenerIdx(Long eventListenerIdx);
    EventListener findByEventListenerIdxAndWorkspaceIdAndProjectId(Long eventListenerIdx, String workspaceId, String projectId);
    Boolean existsByEventListenerName(String eventlistenerName);
    Boolean existsByWorkflow_WorkflowIdx(Long workflowIdx);

    @Modifying(clearAutomatically = true)
    @Query("update EventListener e set e.workspaceId = :workspaceId, e.projectId = :projectId where e.eventListenerIdx in (1, 2) and e.workspaceId is null and e.projectId is null")
    void assignLegacyListeners(@Param("workspaceId") String workspaceId, @Param("projectId") String projectId);
}
