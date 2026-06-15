package kr.co.mcmp.workflow.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.mcmp.api.response.ResponseWrapper;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowHistoryDto;
import kr.co.mcmp.workflow.service.WorkflowService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Workflow History", description = "Workflow history management")
@RequiredArgsConstructor
@RequestMapping("/workflow/history")
@RestController
public class WorkflowHistoryController {

    private final WorkflowService workflowService;

    @Operation(summary="Get workflow history")
    @GetMapping("/{workflowIdx}")
    public ResponseWrapper<List<WorkflowHistoryDto>> getWorkflowHistoryList(@PathVariable Long workflowIdx, @RequestParam String dataType) {
        return new ResponseWrapper<>(workflowService.getWorkflowHistoryList(workflowIdx, dataType));
    }
}
