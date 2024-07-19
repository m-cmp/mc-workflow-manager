package kr.co.strato.workflowStage.dto;

import kr.co.strato.workflowStage.Entity.WorkflowStageType;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class WorkflowStageTypeDto {
    private Long workflowStageTypeIdx;
    private String workflowStageTypeName;
    private String workflowStageTypeDesc;

    // from : 외부 (entity -> dto)
    public static WorkflowStageTypeDto from(WorkflowStageType workflowStageType) {
        return WorkflowStageTypeDto.builder()
                .workflowStageTypeIdx(workflowStageType.getWorkflowStageTypeIdx())
                .workflowStageTypeName(workflowStageType.getWorkflowStageTypeName())
                .workflowStageTypeDesc(workflowStageType.getWorkflowStageTypeDesc())
                .build();
    }

    // of : 내부 (dto -> dto)
    public static WorkflowStageTypeDto of(WorkflowStageTypeDto workflowStageTypeDto) {
        return WorkflowStageTypeDto.builder()
                .workflowStageTypeIdx(workflowStageTypeDto.getWorkflowStageTypeIdx())
                .workflowStageTypeName(workflowStageTypeDto.getWorkflowStageTypeName())
                .workflowStageTypeDesc(workflowStageTypeDto.getWorkflowStageTypeDesc())
                .build();
    }

    // toEntity : Entity 변환 (dto -> entity)
    public static WorkflowStageType toEntity(WorkflowStageTypeDto workflowStageTypeDto) {
        return WorkflowStageType.builder()
                .workflowStageTypeIdx(workflowStageTypeDto.getWorkflowStageTypeIdx())
                .workflowStageTypeName(workflowStageTypeDto.getWorkflowStageTypeName())
                .workflowStageTypeDesc(workflowStageTypeDto.getWorkflowStageTypeDesc())
                .build();
    }
}
