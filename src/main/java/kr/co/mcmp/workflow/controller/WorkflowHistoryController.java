package kr.co.mcmp.workflow.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.mcmp.api.response.ResponseWrapper;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowHistoryDto;
import kr.co.mcmp.workflow.service.WorkflowService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Workflow History", description = "워크플로우 이력 관리")
@RequiredArgsConstructor
@RequestMapping("/workflow/history")
@RestController
public class WorkflowHistoryController {

    private final WorkflowService workflowService;

    @Operation(summary="워크플로우 이력 조회")
    @GetMapping("/{workflowIdx}")
    public ResponseWrapper<List<WorkflowHistoryDto>> getWorkflowHistoryList(@PathVariable Long workflowIdx, @RequestParam String dataType) {
        return new ResponseWrapper<>(workflowService.getWorkflowHistoryList(workflowIdx, dataType));
    }
}
