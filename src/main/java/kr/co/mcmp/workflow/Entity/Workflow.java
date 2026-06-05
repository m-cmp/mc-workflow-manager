package kr.co.mcmp.workflow.Entity;

import kr.co.mcmp.oss.entity.Oss;
import lombok.*;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(
        name = "workflow",
        uniqueConstraints = @UniqueConstraint(name = "uk_workflow_name", columnNames = "workflow_name")
)
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

    @Lob
    @Column(name = "script", columnDefinition = "CLOB")
    private String script;

    @Column(name = "run_date")
    private LocalDateTime runDate;

    @Column(name = "run_status")
    private String runStatus;

    @Column(name = "latest_build_number")
    private Integer latestBuildNumber;

    public void updateRunDate(LocalDateTime runDate) {
        this.runDate = runDate;
    }

    public void updateRunStatus(String runStatus, Integer latestBuildNumber) {
        this.runStatus = runStatus;
        this.latestBuildNumber = latestBuildNumber;
    }
}
