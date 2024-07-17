package kr.co.strato.workflow.Entity;

import lombok.*;

import javax.persistence.*;

@Entity
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(name = "workflow_stage_mapping")
public class WorkflowStageMapping {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "mapping_idx")
    private Long mappingIdx;

    @ManyToOne
    @JoinColumn(name = "workflow_idx", nullable = false)
    private Workflow workflow;

    @Column(name = "stage_order")
    private Byte stageOrder;

    @Column(name = "workflow_stage_type_idx")
    private Long workflowStageTypeIdx;

    @Column(name = "stage")
    private String stageContent;
}