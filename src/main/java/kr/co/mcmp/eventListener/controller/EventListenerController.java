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
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Objects;

@Tag(name = "event Listener", description = "Event listener management")
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/eventlistener")
@RestController
public class EventListenerController {

    private final EventListenerService eventListenerService;

    @Operation(summary = "List event listeners", description = "List all event listeners" )
    @GetMapping("/list")
    public ResponseWrapper<List<ResponseEventListenerDto>> getEventListenerList() {
        return new ResponseWrapper<>(eventListenerService.getEventListenerList());
    }

    @Operation(summary="Register event listener")
    @PostMapping
    public ResponseWrapper<Long> registEventListner(@RequestBody RequestEventListenerDto requestEventListenerDto) {
        ResponseWrapper<Long> invalidResponse = validateEventListenerRequest(requestEventListenerDto);
        if (invalidResponse != null) {
            return invalidResponse;
        }

        return new ResponseWrapper<>(eventListenerService.registEventListner(requestEventListenerDto));
    }

    @Operation(summary = "Update event listener", description = "Update event listener")
    @PatchMapping("/{eventListenerIdx}")
    public ResponseWrapper<Boolean> updateEventListner(@PathVariable Long eventListenerIdx, @RequestBody RequestEventListenerDto requestEventListenerDto) {
        if (eventListenerIdx == null
                || eventListenerIdx == 0
                || requestEventListenerDto.getEventListenerIdx() == null
                || requestEventListenerDto.getEventListenerIdx() == 0
                || !Objects.equals(eventListenerIdx, requestEventListenerDto.getEventListenerIdx())) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "EventListnerIdx");
        }
        ResponseWrapper<Boolean> invalidResponse = validateEventListenerRequest(requestEventListenerDto);
        if (invalidResponse != null) {
            return invalidResponse;
        }

        return new ResponseWrapper<>(eventListenerService.updateEventListener(requestEventListenerDto));
    }

    @Operation(summary = "Delete event listener", description = "Delete event listener")
    @DeleteMapping("/{eventListenerIdx}")
    public ResponseWrapper<Boolean> deleteEventListner(@PathVariable Long eventListenerIdx) {
        return new ResponseWrapper<>(eventListenerService.deleteEventListener(eventListenerIdx));
    }

    @Operation(summary = "Get event listener detail", description = "Get event listener detail" )
    @GetMapping("/{eventListenerIdx}")
    public ResponseWrapper<ResponseEventListenerDto> detailEventListener(@PathVariable Long eventListenerIdx) {
        return new ResponseWrapper<>(eventListenerService.detailEventListener(eventListenerIdx));
    }

    @Operation(summary = "Run event listener", description = "Run event listener")
    @GetMapping("/run/{eventListenerIdx}")
    public ResponseWrapper<Boolean> runEventListener(
            @PathVariable Long eventListenerIdx,
            @RequestParam Map<String, String> params) {
        return new ResponseWrapper<>(eventListenerService.runEventListener(eventListenerIdx, params));
    }

    @Operation(summary = "Run event listener", description = "Run event listener")
    @PostMapping("/run/{eventListenerIdx}")
    public ResponseWrapper<Boolean> runEventListenerPost(@PathVariable Long eventListenerIdx, @RequestBody Map<String, String> params) {
        return new ResponseWrapper<>(eventListenerService.runEventListenerPost(eventListenerIdx, params));
    }

    @Operation(summary = "Run event listener", description = "Run event listener")
    @PutMapping("/run/{eventListenerIdx}")
    public ResponseWrapper<Boolean> runEventListenerPut(@PathVariable Long eventListenerIdx, @RequestBody Map<String, String> params) {
        return new ResponseWrapper<>(eventListenerService.runEventListenerPut(eventListenerIdx, params));
    }

    @Operation(summary = "List event listener workflows", description = "List event listener workflows")
    @GetMapping("/workflowList/{eventListenerYn}")
    public ResponseWrapper<List<WorkflowListResDto>> getWorkflowList(@PathVariable String eventListenerYn) {
        return new ResponseWrapper<>(eventListenerService.getWorkflowList(eventListenerYn));
    }

    @Operation(summary="Check duplicate event listener")
    @GetMapping("/duplicate")
    public ResponseWrapper<Boolean> isEventListenerDuplicated(@RequestParam String eventlistenerName) {
        return new ResponseWrapper<>(eventListenerService.isEventListenerDuplicated(eventlistenerName));
    }

    @Operation(summary="Get workflow detail")
    @GetMapping("/workflowDetail/{workflowIdx}/{evnetListenerYn}")
    public ResponseWrapper<WorkflowDetailResDto> getWorkflowDetail(@PathVariable Long workflowIdx, @PathVariable String evnetListenerYn) {
        return new ResponseWrapper<>(eventListenerService.getWorkflowDetail(workflowIdx, evnetListenerYn));
    }

    private <T> ResponseWrapper<T> validateEventListenerRequest(RequestEventListenerDto requestEventListenerDto) {
        if (requestEventListenerDto == null || StringUtils.isBlank(requestEventListenerDto.getEventListenerName())) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "EventListenerName");
        }
        if (StringUtils.isBlank(requestEventListenerDto.getEventListenerDesc())) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "EventListenerDesc");
        }
        if (requestEventListenerDto.getWorkflowIdx() == null || requestEventListenerDto.getWorkflowIdx() == 0) {
            return new ResponseWrapper<>(ResponseCode.BAD_REQUEST, "WorkflowIdx");
        }

        return null;
    }

}
