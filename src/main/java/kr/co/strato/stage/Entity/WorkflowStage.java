package kr.co.strato.stage.Entity;

import lombok.*;

import javax.persistence.*;

@Entity
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(name = "workflow_stage")
public class WorkflowStage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "stage_idx")
    private Long stageIdx;

    @ManyToOne
    @JoinColumn(name = "workflow_stage_type_idx", nullable = false)
    private WorkflowStageType workflowStageType;

    @Column(name = "stage_order")
    private Integer stageOrder;

    @Column(name = "stage_name", nullable = false)
    private String stageName;

    @Column(name = "stage_desc")
    private String stageDesc;

    @Column(name = "stage", nullable = false)
    private String stageContent;
}