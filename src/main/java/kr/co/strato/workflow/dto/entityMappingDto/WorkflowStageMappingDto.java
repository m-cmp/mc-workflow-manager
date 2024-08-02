package kr.co.strato.workflow.dto.entityMappingDto;

import kr.co.strato.oss.dto.OssDto;
import kr.co.strato.oss.dto.OssTypeDto;
import kr.co.strato.workflow.Entity.WorkflowStageMapping;
import kr.co.strato.workflowStage.dto.WorkflowStageDto;
import lombok.Builder;
import lombok.Getter;

@Builder
@Getter
public class WorkflowStageMappingDto {
    private Long mappingIdx;
    private Long workflowIdx;
    private Integer stageOrder;
    private Long workflowStageTypeIdx;
    private String stageContent;

    // from : 외부 (entity -> dto)
    public static WorkflowStageMappingDto from(WorkflowStageMapping workflowStageMapping) {
        return WorkflowStageMappingDto.builder()
                .mappingIdx(workflowStageMapping.getMappingIdx())
                .workflowIdx(workflowStageMapping.getWorkflow().getWorkflowIdx())
                .stageOrder(workflowStageMapping.getStageOrder())
                .workflowStageTypeIdx(workflowStageMapping.getWorkflowStageTypeIdx())
                .stageContent(workflowStageMapping.getStageContent())
                .build();
    }

    // of : 내부 (dto -> dto)
    public static WorkflowStageMappingDto of(WorkflowStageMappingDto workflowStageMappingDto) {
        return WorkflowStageMappingDto.builder()
                .mappingIdx(workflowStageMappingDto.getMappingIdx())
                .workflowIdx(workflowStageMappingDto.getWorkflowIdx())
                .stageOrder(workflowStageMappingDto.getStageOrder())
                .workflowStageTypeIdx(workflowStageMappingDto.getWorkflowStageTypeIdx())
                .stageContent(workflowStageMappingDto.getStageContent())
                .build();
    }

    // toEntity : Entity 변환 (dto -> entity)
    public static WorkflowStageMapping toEntity(WorkflowStageMappingDto workflowStageMappingBaseData, WorkflowDto workflowDto, OssDto ossDto, OssTypeDto ossTypeDto) {
        return WorkflowStageMapping.builder()
                .mappingIdx(workflowStageMappingBaseData.getMappingIdx())
                .workflow(WorkflowDto.toEntity(workflowDto, ossDto, ossTypeDto))
                .stageOrder(workflowStageMappingBaseData.getStageOrder())
                .workflowStageTypeIdx(workflowStageMappingBaseData.getWorkflowStageTypeIdx())
                .stageContent(workflowStageMappingBaseData.getStageContent())
                .build();
    }

    // default Script Set
    public static WorkflowStageMappingDto setWorkflowTemplate(String workflowStageContent) {
        return WorkflowStageMappingDto.builder()
                .stageContent(workflowStageContent)
                .build();
    }
}
