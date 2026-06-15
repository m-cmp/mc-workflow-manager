package kr.co.mcmp.workflow.dto.resDto;

import kr.co.mcmp.workflowStage.dto.WorkflowStageDto;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Builder
@Getter
public class WorkflowStageTypeAndStageNameResDto {
    private String title;
    private String label;
    private List<WorkflowStageDto> list;

    // Comment translated to English.
    public static WorkflowStageTypeAndStageNameResDto of(String title, List<WorkflowStageDto> list) {
        return WorkflowStageTypeAndStageNameResDto.builder()
                .title(title)
                .label(toDisplayLabel(title))
                .list(list)
                .build();
    }

    private static String toDisplayLabel(String title) {
        if (title == null) {
            return "";
        }

        return switch (title) {
            case "infra" -> "Infra";
            case "k8s" -> "K8s";
            case "app", "app-deploy" -> "App";
            case "database", "db-backup-restore" -> "Database";
            case "utility", "common-util" -> "Utility";
            default -> title;
        };
    }
}
