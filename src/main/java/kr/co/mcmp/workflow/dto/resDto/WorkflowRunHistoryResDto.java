package kr.co.mcmp.workflow.dto.resDto;

import kr.co.mcmp.workflow.service.jenkins.model.JenkinsStage;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.util.ArrayList;
import java.util.List;

@SuperBuilder
@Getter
@NoArgsConstructor // 기본 생성자 추가
public class WorkflowRunHistoryResDto {
    private String name;
    private String status;
    private long startTimeMillis;
    private long durationTimeMillis;
    private List<JenkinsStage> stages;

    public static List<WorkflowRunHistoryResDto> createList() {
        List<WorkflowRunHistoryResDto> list = new ArrayList<>();
        return list;
    }

    public static List<WorkflowRunHistoryResDto> addToList(List<WorkflowRunHistoryResDto> list,WorkflowRunHistoryResDto statusResDto) {
        WorkflowRunHistoryResDto workflowRunHistoryResDto = WorkflowRunHistoryResDto.builder()
                .name(statusResDto.getName())
                .status(statusResDto.getStatus())
                .startTimeMillis(statusResDto.getStartTimeMillis())
                .durationTimeMillis(statusResDto.getDurationTimeMillis())
                .stages(statusResDto.getStages())
                .build();

        list.add(workflowRunHistoryResDto);
        return list;
    }
}
