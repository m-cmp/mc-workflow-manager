package kr.co.strato.stage.Entity;

import lombok.AccessLevel;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;

@Data
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Table(name = "workflow_stage_type")
public class WorkflowStageType {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "workflow_stage_type_idx")
    private Long workflowStageTypeIdx;

    @Column(name = "workflow_stage_type_name", nullable = false)
    private String workflowStageTypeName;

    @Column(name = "workflow_stage_type_desc")
    private String workflowStageTypeDesc;
}
