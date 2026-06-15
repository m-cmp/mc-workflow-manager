package kr.co.mcmp.eventListener.dto.resDto;

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
public class ResponseEventListenerDto {

    private Long eventListenerIdx;
    private String eventListenerName;
    private String eventListenerDesc;
    private Long workflowIdx;
    private String workflowName;
    private String eventListenerCallUrl;
    private List<WorkflowParamDto> workflowParams;

    // Comment translated to English.
    public static ResponseEventListenerDto from(EventListener eventListener, List<WorkflowParamDto> workflowParams) {
        return ResponseEventListenerDto.builder()
                .eventListenerIdx(eventListener.getEventListenerIdx())
                .eventListenerName(eventListener.getEventListenerName())
                .eventListenerDesc(eventListener.getEventListenerDesc())
                .workflowIdx(eventListener.getWorkflow().getWorkflowIdx())
                .workflowName(eventListener.getWorkflow().getWorkflowName())
                .eventListenerCallUrl("/eventlistener/run/"+eventListener.getEventListenerIdx())
                .workflowParams(workflowParams)
                .build();
    }

    // Comment translated to English.
    public static ResponseEventListenerDto of(ResponseEventListenerDto eventListenerDto) {
        return ResponseEventListenerDto.builder()
                .eventListenerIdx(eventListenerDto.getEventListenerIdx())
                .eventListenerName(eventListenerDto.getEventListenerName())
                .eventListenerDesc(eventListenerDto.getEventListenerDesc())
                .workflowIdx(eventListenerDto.getWorkflowIdx())
                .build();
    }

    // Comment translated to English.
    public static EventListener toEntity(ResponseEventListenerDto eventListenerDto, WorkflowDto workflowDto, OssDto ossDto, OssTypeDto ossTypeDto) {
        return EventListener.builder()
                .eventListenerIdx(eventListenerDto.getEventListenerIdx())
                .eventListenerName(eventListenerDto.getEventListenerName())
                .eventListenerDesc(eventListenerDto.getEventListenerDesc())
                .workflow(WorkflowDto.toEntity(workflowDto, ossDto, ossTypeDto))
                .build();
    }

    // Comment translated to English.
    public static ResponseEventListenerDto fromGetList(EventListener eventListener) {
        return ResponseEventListenerDto.builder()
                .eventListenerIdx(eventListener.getEventListenerIdx())
                .eventListenerName(eventListener.getEventListenerName())
                .eventListenerDesc(eventListener.getEventListenerDesc())
                .workflowIdx(eventListener.getWorkflow().getWorkflowIdx())
                .workflowName(eventListener.getWorkflow().getWorkflowName())
                .eventListenerCallUrl("/eventlistener/run/"+eventListener.getEventListenerIdx())
                .build();
    }
}
