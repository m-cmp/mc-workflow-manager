package kr.co.strato.workflow.Entity;

import kr.co.strato.oss.entity.Oss;
import lombok.AccessLevel;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;

@Data
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Table(name = "workflow")
public class Workflow {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "workflow_idx")
    private Long workflowIdx;

    @Column(name = "workflow_name", nullable = false)
    private String workflowName;

    @Column(name = "workflow_purpose", nullable = false)
    private String workflowPurpose;

    @ManyToOne
    @JoinColumn(name = "oss_idx", nullable = false)
    private Oss oss;

    @Column(name = "script")
    private String script;
}