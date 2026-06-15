package kr.co.mcmp.workflow.dto.resDto;

import kr.co.mcmp.workflow.Entity.Workflow;
import kr.co.mcmp.workflow.Entity.WorkflowParam;
import kr.co.mcmp.workflow.Entity.WorkflowStageMapping;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowParamDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowStageMappingDto;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@SuperBuilder
@Getter
@NoArgsConstructor // Comment translated to English.
public class WorkflowListResDto {
    private WorkflowDto workflowInfo;
    private List<WorkflowParamDto> workflowParams;
    private List<WorkflowStageMappingDto> workflowStageMappings;
    private LocalDateTime runDate;

    // Comment translated to English.
    public static WorkflowListResDto from(Workflow workflow, List<WorkflowParam> workflowParams, List<WorkflowStageMapping> workflowStageMappings) {
        return WorkflowListResDto.builder()
                .workflowInfo            (WorkflowDto.from(workflow))
                .workflowParams         (workflowParams.stream().map(WorkflowParamDto::from).collect(Collectors.toList()))
                .workflowStageMappings  (workflowStageMappings.stream().map(WorkflowStageMappingDto::from).collect(Collectors.toList()))
                .runDate                (workflow.getRunDate())
                .build();
    }

    // Comment translated to English.
    public static WorkflowListResDto of(WorkflowDto workflowDto, List<WorkflowParamDto> workflowParams, List<WorkflowStageMappingDto> workflowStageMappings) {
        return WorkflowListResDto.builder()
                .workflowInfo(workflowDto)
                .workflowParams(workflowParams)
                .workflowStageMappings(workflowStageMappings)
                .runDate(workflowDto.getRunDate())
                .build();
    }
}
