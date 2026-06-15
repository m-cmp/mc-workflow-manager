package kr.co.mcmp.workflow.dto.entityMappingDto;

import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.workflow.Entity.Workflow;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

@SuperBuilder
@Getter
@NoArgsConstructor // Comment translated to English.
public class WorkflowDto {
    private Long workflowIdx;
    private String workflowName;
    private String workflowPurpose;
    private Long ossIdx;
    private String script;
    private String status;
    private LocalDateTime runDate;
    private Integer latestBuildNumber;

    // Comment translated to English.
    public static WorkflowDto from(Workflow workflow) {
        return WorkflowDto.builder()
                .workflowIdx(workflow.getWorkflowIdx())
                .workflowName(workflow.getWorkflowName())
                .workflowPurpose(workflow.getWorkflowPurpose())
                .ossIdx(workflow.getOss().getOssIdx())
                .script(workflow.getScript())
                .status(workflow.getRunStatus())
                .runDate(workflow.getRunDate())
                .latestBuildNumber(workflow.getLatestBuildNumber())
                .build();
    }

    // Comment translated to English.
    public static WorkflowDto of(WorkflowDto workflowDto) {
        return WorkflowDto.builder()
                .workflowIdx(workflowDto.getWorkflowIdx())
                .workflowName(workflowDto.getWorkflowName())
                .workflowPurpose(workflowDto.getWorkflowPurpose())
                .ossIdx(workflowDto.getOssIdx())
                .script(workflowDto.getScript())
                .status(workflowDto.getStatus())
                .runDate(workflowDto.getRunDate())
                .latestBuildNumber(workflowDto.getLatestBuildNumber())
                .build();
    }

    // Comment translated to English.
    public static Workflow toEntity(WorkflowDto workflowDto, OssDto ossDto, OssTypeDto ossTypeDto) {
        return Workflow.builder()
                .workflowIdx(workflowDto.getWorkflowIdx())
                .workflowName(workflowDto.getWorkflowName())
                .workflowPurpose(workflowDto.getWorkflowPurpose())
                .oss(OssDto.toEntity(ossDto, ossTypeDto))
                .script(workflowDto.getScript())
                .runDate(workflowDto.getRunDate())
                .runStatus(workflowDto.getStatus())
                .latestBuildNumber(workflowDto.getLatestBuildNumber())
                .build();
    }

    // Comment translated to English.
    public static WorkflowDto ofWithStatus(WorkflowDto workflowDto, String status) {
        return WorkflowDto.builder()
                .workflowIdx(workflowDto.getWorkflowIdx())
                .workflowName(workflowDto.getWorkflowName())
                .workflowPurpose(workflowDto.getWorkflowPurpose())
                .ossIdx(workflowDto.getOssIdx())
                .script(workflowDto.getScript())
                .status(status) // Comment translated to English.
                .runDate(workflowDto.getRunDate())
                .latestBuildNumber(workflowDto.getLatestBuildNumber())
                .build();
    }

// Comment translated to English.
//    public static Workflow saveWorkflow(WorkflowParamDto.WorkflowParamList workflowDto, OssDto ossDto, OssTypeDto ossTypeDto) {
//        return Workflow.builder()
//                .workflowIdx(workflowDto.getWorkflowIdx())
//                .workflowName(workflowDto.getWorkflowName())
//                .workflowPurpose(workflowDto.getWorkflowPurpose())
//                .oss(OssDto.toEntity(ossDto, ossTypeDto))
//                .script(workflowDto.getScript())
//                .build();
//    }
//
// Comment translated to English.
//    public static WorkflowDto workflowStageToWorkflowDto(WorkflowStageMappingDto.WorkflowStageMappingList workflowStageMappingList) {
//        return WorkflowDto.builder()
//                .workflowIdx(workflowStageMappingList.getWorkflowIdx())
//                .workflowName(workflowStageMappingList.getWorkflowName())
//                .workflowPurpose(workflowStageMappingList.getWorkflowPurpose())
//                .ossIdx(workflowStageMappingList.getOssIdx())
//                .script(workflowStageMappingList.getScript())
//                .build();
//    }

}
