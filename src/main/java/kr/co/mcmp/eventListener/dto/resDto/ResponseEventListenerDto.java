package kr.co.mcmp.eventListener.dto.resDto;

import kr.co.mcmp.eventListener.entity.EventListener;
import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowDto;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class ResponseEventListenerDto {

    private Long eventListenerIdx;
    private String eventListenerName;
    private String eventListenerDesc;
    private String eventListenerUrl;
    private Long workflowIdx;
    private String eventListenerCallUrl;

    // from : 외부 (entity -> dto)
    public static ResponseEventListenerDto from(EventListener eventListener) {
        return ResponseEventListenerDto.builder()
                .eventListenerIdx(eventListener.getEventListenerIdx())
                .eventListenerName(eventListener.getEventListenerName())
                .eventListenerDesc(eventListener.getEventListenerDesc())
                .eventListenerUrl(eventListener.getEventListenerUrl())
                .workflowIdx(eventListener.getWorkflow().getWorkflowIdx())
                .eventListenerCallUrl(eventListener.getEventListenerUrl()+"/"+eventListener.getEventListenerIdx())
                .build();
    }

    // of : 내부 (dto -> dto)
    public static ResponseEventListenerDto of(ResponseEventListenerDto eventListenerDto) {
        return ResponseEventListenerDto.builder()
                .eventListenerIdx(eventListenerDto.getEventListenerIdx())
                .eventListenerName(eventListenerDto.getEventListenerName())
                .eventListenerDesc(eventListenerDto.getEventListenerDesc())
                .eventListenerUrl(eventListenerDto.getEventListenerUrl())
                .workflowIdx(eventListenerDto.getWorkflowIdx())
                .build();
    }

    // toEntity : Entity 변환 (dto -> entity)
    public static EventListener toEntity(ResponseEventListenerDto eventListenerDto, WorkflowDto workflowDto, OssDto ossDto, OssTypeDto ossTypeDto) {
        return EventListener.builder()
                .eventListenerIdx(eventListenerDto.getEventListenerIdx())
                .eventListenerName(eventListenerDto.getEventListenerName())
                .eventListenerDesc(eventListenerDto.getEventListenerDesc())
                .eventListenerUrl(eventListenerDto.getEventListenerUrl())
                .workflow(WorkflowDto.toEntity(workflowDto, ossDto, ossTypeDto))
                .build();
    }
}
