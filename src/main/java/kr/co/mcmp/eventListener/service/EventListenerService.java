package kr.co.mcmp.eventListener.service;

import kr.co.mcmp.eventListener.dto.reqDto.RequestEventListenerDto;
import kr.co.mcmp.eventListener.dto.resDto.ResponseEventListenerDto;
import kr.co.mcmp.workflow.dto.resDto.WorkflowDetailResDto;
import kr.co.mcmp.workflow.dto.resDto.WorkflowListResDto;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public interface EventListenerService {
    List<ResponseEventListenerDto> getEventListenerList();
    Long registEventListner(RequestEventListenerDto requestEventListenerDto);
    Boolean updateEventListener(RequestEventListenerDto requestEventListenerDto);
    Boolean deleteEventListener(Long eventListenerIdx);
    ResponseEventListenerDto detailEventListener(Long eventListenerIdx);
    List<WorkflowListResDto> getWorkflowList(String eventListenerYn);
    WorkflowDetailResDto getWorkflowDetail(Long workflowIdx, String eventListenerYn);
    Boolean isEventListenerDuplicated(String eventlistenerName);
    Boolean runEventListener(Long eventListenerIdx, Map<String, String> params);
    Boolean runEventListenerPost(Long workflowIdx, Map<String, String> params);
    Boolean runEventListenerPut(Long workflowIdx, Map<String, String> params);
}
