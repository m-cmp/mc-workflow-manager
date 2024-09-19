package kr.co.mcmp.workflow.dto.entityMappingDto;

import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.workflow.Entity.WorkflowHistory;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Builder
@Getter
public class WorkflowHistoryDto {
    private Long workflowHistoryIdx;
    private Long workflowIdx;
    private String dataType;
    private String data;
    private String userId;
    private LocalDateTime date;

    // from : 외부 (entity -> dto)
    public static WorkflowHistoryDto from(WorkflowHistory workflowHistory) {
        return WorkflowHistoryDto.builder()
                .workflowHistoryIdx(workflowHistory.getWorkflowHistoryIdx())
                .workflowIdx(workflowHistory.getWorkflow().getWorkflowIdx())
                .dataType(workflowHistory.getDataType())
                .data(workflowHistory.getData())
                .userId(workflowHistory.getUserId())
                .date(workflowHistory.getDate())
                .build();
    }

    // of : 내부 (dto -> dto)
    public static WorkflowHistoryDto of(WorkflowHistoryDto workflowHistoryDto) {
        return WorkflowHistoryDto.builder()
                .workflowHistoryIdx(workflowHistoryDto.getWorkflowHistoryIdx())
                .workflowIdx(workflowHistoryDto.getWorkflowIdx())
                .dataType(workflowHistoryDto.getDataType())
                .data(workflowHistoryDto.getData())
                .userId(workflowHistoryDto.getUserId())
                .date(workflowHistoryDto.getDate())
                .build();
    }

    // toEntity : Entity 변환 (dto -> entity)
    public static WorkflowHistory toEntity(WorkflowHistoryDto workflowHistoryDto, WorkflowDto workflowDto, OssDto ossDto, OssTypeDto ossTypeDto) {
        return WorkflowHistory.builder()
                .workflowHistoryIdx(workflowHistoryDto.getWorkflowHistoryIdx())
                .workflow(WorkflowDto.toEntity(workflowDto, ossDto, ossTypeDto))
                .dataType(workflowHistoryDto.getDataType())
                .data(workflowHistoryDto.getData())
                .userId(workflowHistoryDto.getUserId())
                .date(workflowHistoryDto.getDate())
                .build();
    }

    //
    public static WorkflowHistory buildEntity(
                                                WorkflowDto workflowDto,
                                                OssDto ossDto,
                                                OssTypeDto ossTypeDto,
                                                String dataType,
                                                String data,
                                                String userId,
                                                LocalDateTime date) {
        return WorkflowHistory.builder()
                .workflow(WorkflowDto.toEntity(workflowDto, ossDto, ossTypeDto))
                .dataType(dataType)
                .data(data)
                .userId(userId)
                .date(date)
                .build();
    }
}
