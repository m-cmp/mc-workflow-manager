package kr.co.mcmp.workflow.Entity;

import lombok.*;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(name = "workflow_history")
public class WorkflowHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "workflow_history_idx")
    private Long workflowHistoryIdx;

    @ManyToOne
    @JoinColumn(name = "workflow_idx", nullable = false)
    private Workflow workflow;

    @Column(name = "data_type")
    private String dataType;

    @Lob
    @Column(name = "data", columnDefinition = "CLOB")
    private String data;

    @Column(name = "user_id", nullable = false)
    private String userId;

    @Column(name = "date")
    private LocalDateTime date;
}