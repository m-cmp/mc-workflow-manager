package kr.co.mcmp.eventListener.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.mcmp.api.response.ResponseCode;
import kr.co.mcmp.api.response.ResponseWrapper;
import kr.co.mcmp.eventListener.dto.reqDto.RequestEventListenerDto;
import kr.co.mcmp.eventListener.dto.resDto.ResponseEventListenerDto;
import kr.co.mcmp.eventListener.service.EventListenerService;
import kr.co.mcmp.workflow.dto.resDto.WorkflowDetailResDto;
import kr.co.mcmp.workflow.dto.resDto.WorkflowListResDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "event Listener", description = "이벤트 리스너 관리")
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/eventlistener")
@RestController
public class EventListenerController {

    private final EventListenerService eventListenerService;

    @Operation(summary = "Event Listener 목록 조회", description = "Event Listener  모든 목록조회" )
    @GetMapping("/list")
    public ResponseWrapper<List<ResponseEventListenerDto>> getEventListenerList() {
        return new ResponseWrapper<>(eventListenerService.getEventListenerList());
    }

    @Operation(summary="Event Listener 등록")
    @PostMapping
    public ResponseWrapper<Long> registEventListner(@RequestBody RequestEventListenerDto requestEventListenerDto) {
        return new ResponseWrapper<>(eventListenerService.registEventListner(requestEventListenerDto));
    }

    @Operation(summary = "Event Listener 수정", description = "Event Listener 수정")
    @PatchMapping("/{eventListenerIdx}")
    public ResponseWrapper<Boolean> updateEventListner(@PathVariable Long eventListenerIdx, @RequestBody RequestEventListenerDto requestEventListenerDto) {
        if ( eventListenerIdx != 0 || requestEventListenerDto.getEventListenerIdx() != 0 ) {
            return new ResponseWrapper<>(eventListenerService.updateEventListener(requestEventListenerDto));
        }
        return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "EventListnerIdx");
    }

    @Operation(summary = "Event Listener 삭제", description = "Event Listener 삭제")
    @DeleteMapping("/{eventListenerIdx}")
    public ResponseWrapper<Boolean> deleteEventListner(@PathVariable Long eventListenerIdx) {
        return new ResponseWrapper<>(eventListenerService.deleteEventListener(eventListenerIdx));
    }

    @Operation(summary = "Event Listener 상세 조회", description = "Event Listener 상세조회" )
    @GetMapping("/{eventListenerIdx}")
    public ResponseWrapper<ResponseEventListenerDto> detailEventListener(@PathVariable Long eventListenerIdx) {
        return new ResponseWrapper<>(eventListenerService.detailEventListener(eventListenerIdx));
    }

    @Operation(summary = "Event Listener 실행", description = "Event Listener 실행")
    @GetMapping("/run/{eventListenerIdx}")
    public ResponseWrapper<Boolean> runEventListener(@PathVariable Long eventListenerIdx) {
        return new ResponseWrapper<>(eventListenerService.runEventListener(eventListenerIdx));
    }

    @Operation(summary = "Event Listener Workflow 목록", description = "Event Listener Workflow 목록")
    @GetMapping("/workflowList/{eventListenerYn}")
    public ResponseWrapper<List<WorkflowListResDto>> getWorkflowList(@PathVariable String eventListenerYn) {
        return new ResponseWrapper<>(eventListenerService.getWorkflowList(eventListenerYn));
    }

    @Operation(summary="워크플로우 상세 조회")
    @GetMapping("/workflowDetail/{workflowIdx}/{evnetListenerYn}")
    public ResponseWrapper<WorkflowDetailResDto> getWorkflowDetail(@PathVariable Long workflowIdx, @PathVariable String evnetListenerYn) {
        return new ResponseWrapper<>(eventListenerService.getWorkflowDetail(workflowIdx, evnetListenerYn));
    }
}
