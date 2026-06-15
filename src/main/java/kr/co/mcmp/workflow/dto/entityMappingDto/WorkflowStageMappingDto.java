package kr.co.mcmp.workflow.dto.entityMappingDto;

import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.workflow.Entity.WorkflowStageMapping;
import kr.co.mcmp.workflowStage.Entity.WorkflowStage;
import kr.co.mcmp.workflowStage.dto.WorkflowStageDto;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Builder
@Getter
public class WorkflowStageMappingDto {
    private Long mappingIdx;
    private Long workflowIdx;
    private Integer stageOrder;
    private Long workflowStageIdx;
    private String workflowStageName;
    private String workflowStageTypeName;
    private String stageContent;
    private List<WorkflowParamDto> defaultParams;

    // Comment translated to English.
    public static WorkflowStageMappingDto from(WorkflowStageMapping workflowStageMapping) {
        return WorkflowStageMappingDto.builder()
                .mappingIdx(workflowStageMapping.getMappingIdx())
                .workflowIdx(workflowStageMapping.getWorkflow().getWorkflowIdx())
                .stageOrder(workflowStageMapping.getStageOrder())
                .workflowStageIdx(workflowStageMapping.getWorkflowStageIdx())
                .stageContent(workflowStageMapping.getStageContent())
                .build();
    }

    public static WorkflowStageMappingDto from(WorkflowStageMapping workflowStageMapping, WorkflowStage workflowStage) {
        WorkflowStageMappingDtoBuilder builder = WorkflowStageMappingDto.builder()
                .mappingIdx(workflowStageMapping.getMappingIdx())
                .workflowIdx(workflowStageMapping.getWorkflow().getWorkflowIdx())
                .stageOrder(workflowStageMapping.getStageOrder())
                .workflowStageIdx(workflowStageMapping.getWorkflowStageIdx())
                .stageContent(workflowStageMapping.getStageContent());

        if (workflowStage != null) {
            WorkflowStageDto workflowStageDto = WorkflowStageDto.from(workflowStage);
            builder.workflowStageName(workflowStageDto.getWorkflowStageName())
                    .workflowStageTypeName(workflowStageDto.getWorkflowStageTypeName())
                    .defaultParams(workflowStageDto.getDefaultParams());
        }

        return builder.build();
    }

    // Comment translated to English.
    public static WorkflowStageMappingDto of(WorkflowStageMappingDto workflowStageMappingDto) {
        return WorkflowStageMappingDto.builder()
                .mappingIdx(workflowStageMappingDto.getMappingIdx())
                .workflowIdx(workflowStageMappingDto.getWorkflowIdx())
                .stageOrder(workflowStageMappingDto.getStageOrder())
                .workflowStageIdx(workflowStageMappingDto.getWorkflowStageIdx())
                .workflowStageName(workflowStageMappingDto.getWorkflowStageName())
                .workflowStageTypeName(workflowStageMappingDto.getWorkflowStageTypeName())
                .stageContent(workflowStageMappingDto.getStageContent())
                .defaultParams(workflowStageMappingDto.getDefaultParams())
                .build();
    }

    // Comment translated to English.
    public static WorkflowStageMapping toEntity(WorkflowStageMappingDto workflowStageMappingBaseData, WorkflowDto workflowDto, OssDto ossDto, OssTypeDto ossTypeDto) {
        return WorkflowStageMapping.builder()
                .mappingIdx(workflowStageMappingBaseData.getMappingIdx())
                .workflow(WorkflowDto.toEntity(workflowDto, ossDto, ossTypeDto))
                .stageOrder(workflowStageMappingBaseData.getStageOrder())
                .workflowStageIdx(workflowStageMappingBaseData.getWorkflowStageIdx())
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
