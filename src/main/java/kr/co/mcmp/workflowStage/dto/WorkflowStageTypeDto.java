package kr.co.mcmp.workflowStage.dto;

import kr.co.mcmp.workflowStage.Entity.WorkflowStageType;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class WorkflowStageTypeDto {
    private Long workflowStageTypeIdx;
    private String workflowStageTypeName;
    private String workflowStageTypeDesc;

    // Comment translated to English.
    public static WorkflowStageTypeDto from(WorkflowStageType workflowStageType) {
        return WorkflowStageTypeDto.builder()
                .workflowStageTypeIdx(workflowStageType.getWorkflowStageTypeIdx())
                .workflowStageTypeName(workflowStageType.getWorkflowStageTypeName())
                .workflowStageTypeDesc(workflowStageType.getWorkflowStageTypeDesc())
                .build();
    }

    // Comment translated to English.
    public static WorkflowStageTypeDto of(WorkflowStageTypeDto workflowStageTypeDto) {
        return WorkflowStageTypeDto.builder()
                .workflowStageTypeIdx(workflowStageTypeDto.getWorkflowStageTypeIdx())
                .workflowStageTypeName(workflowStageTypeDto.getWorkflowStageTypeName())
                .workflowStageTypeDesc(workflowStageTypeDto.getWorkflowStageTypeDesc())
                .build();
    }

    // Comment translated to English.
    public static WorkflowStageType toEntity(WorkflowStageTypeDto workflowStageTypeDto) {
        return WorkflowStageType.builder()
                .workflowStageTypeIdx(workflowStageTypeDto.getWorkflowStageTypeIdx())
                .workflowStageTypeName(workflowStageTypeDto.getWorkflowStageTypeName())
                .workflowStageTypeDesc(workflowStageTypeDto.getWorkflowStageTypeDesc())
                .build();
    }

    // Comment translated to English.
    public static WorkflowStageType saveWorkflowStageType(String workflowStageTypeName, String workflowStageTypeDesc) {
        return WorkflowStageType.builder()
                .workflowStageTypeName(workflowStageTypeName)
                .workflowStageTypeDesc(workflowStageTypeDesc)
                .build();
    }
}
