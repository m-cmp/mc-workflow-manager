package kr.co.strato.workflow.Entity;

import lombok.AccessLevel;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Table(name = "workflow_param_history")
public class WorkflowParamHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "workflow_param_history_idx")
    private Long workflowParamHistoryIdx;

    @ManyToOne
    @JoinColumn(name = "workflow_idx", nullable = false)
    private Workflow workflow;

    @Column(name = "run_user_id", nullable = false)
    private String runUserId;

    @Column(name = "run_date")
    private LocalDateTime runDate;
}