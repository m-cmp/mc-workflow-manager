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
@NoArgsConstructor // 기본 생성자 추가
public class WorkflowDto {
    private Long workflowIdx;
    private String workflowName;
    private String workflowPurpose;
    private Long ossIdx;
    private String script;
    private String status;
    private LocalDateTime runDate;
    private Integer latestBuildNumber;

    // from : 외부 (entity -> dto)
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

    // of : 내부 (dto -> dto)
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

    // toEntity : Entity 변환 (dto -> entity)
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

    // ofWithStatus : status 포함한 dto 생성
    public static WorkflowDto ofWithStatus(WorkflowDto workflowDto, String status) {
        return WorkflowDto.builder()
                .workflowIdx(workflowDto.getWorkflowIdx())
                .workflowName(workflowDto.getWorkflowName())
                .workflowPurpose(workflowDto.getWorkflowPurpose())
                .ossIdx(workflowDto.getOssIdx())
                .script(workflowDto.getScript())
                .status(status) // status 필드 포함
                .runDate(workflowDto.getRunDate())
                .latestBuildNumber(workflowDto.getLatestBuildNumber())
                .build();
    }

//    // registWorkflow : Workflow 등록 / 수정
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
//    // WorkflowStageMappingDto -> WorkflowDto 변환
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
