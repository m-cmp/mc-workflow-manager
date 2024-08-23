package kr.co.mcmp.eventListener.dto.reqDto;

import kr.co.mcmp.eventListener.entity.EventListener;
import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowParamDto;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class RequestEventListenerDto {

    private Long eventListenerIdx;
    private String eventListenerName;
    private String eventListenerDesc;
    private String eventListenerUrl;
    private Long workflowIdx;
    private List<WorkflowParamDto> workflowParams;

    // from : 외부 (entity -> dto)
    public static RequestEventListenerDto from(EventListener eventListener) {
        return RequestEventListenerDto.builder()
                .eventListenerIdx(eventListener.getEventListenerIdx())
                .eventListenerName(eventListener.getEventListenerName())
                .eventListenerDesc(eventListener.getEventListenerDesc())
//                .eventListenerUrl(eventListener.getEventListenerUrl())
                .workflowIdx(eventListener.getWorkflow().getWorkflowIdx())
                .build();
    }

    // of : 내부 (dto -> dto)
    public static RequestEventListenerDto of(RequestEventListenerDto eventListenerDto) {
        return RequestEventListenerDto.builder()
                .eventListenerIdx(eventListenerDto.getEventListenerIdx())
                .eventListenerName(eventListenerDto.getEventListenerName())
                .eventListenerDesc(eventListenerDto.getEventListenerDesc())
//                .eventListenerUrl(eventListenerDto.getEventListenerUrl())
                .workflowIdx(eventListenerDto.getWorkflowIdx())
                .build();
    }

    // toEntity : Entity 변환 (dto -> entity)
    public static EventListener toEntity(RequestEventListenerDto eventListenerDto, WorkflowDto workflowDto, OssDto ossDto, OssTypeDto ossTypeDto) {
        return EventListener.builder()
                .eventListenerIdx(eventListenerDto.getEventListenerIdx())
                .eventListenerName(eventListenerDto.getEventListenerName())
                .eventListenerDesc(eventListenerDto.getEventListenerDesc())
//                .eventListenerUrl(eventListenerDto.getEventListenerUrl())
                .workflow(WorkflowDto.toEntity(workflowDto, ossDto, ossTypeDto))
                .build();
    }

    // toEntity : Entity 변환 (dto -> entity)
    public static EventListener toUpdate(Long eventListenerIdx, RequestEventListenerDto eventListenerDto, WorkflowDto workflowDto, OssDto ossDto, OssTypeDto ossTypeDto) {
        return EventListener.builder()
                .eventListenerIdx(eventListenerIdx)
                .eventListenerName(eventListenerDto.getEventListenerName())
                .eventListenerDesc(eventListenerDto.getEventListenerDesc())
//                .eventListenerUrl(eventListenerDto.getEventListenerUrl())
                .workflow(WorkflowDto.toEntity(workflowDto, ossDto, ossTypeDto))
                .build();
    }
}
