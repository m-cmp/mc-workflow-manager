package kr.co.strato.workflow.dto.resDto;

import kr.co.strato.workflowStage.dto.WorkflowStageDto;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Builder
@Getter
public class WorkflowStageTypeAndStageNameResDto {
    private String title;
    private List<WorkflowStageDto> list;

    // from : 외부 (entity -> dto)
    public static WorkflowStageTypeAndStageNameResDto of(String title, List<WorkflowStageDto> list) {
        return WorkflowStageTypeAndStageNameResDto.builder()
                .title(title)
                .list(list)
                .build();
    }
}
