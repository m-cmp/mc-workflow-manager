package kr.co.strato.workflowStage.service;

import kr.co.strato.util.JenkinsPipelineUtil;
import kr.co.strato.workflowStage.Entity.WorkflowStageType;
import kr.co.strato.workflowStage.dto.WorkflowStageDto;
import kr.co.strato.workflowStage.dto.WorkflowStageTypeDto;
import kr.co.strato.workflowStage.repository.WorkflowStageRepository;
import kr.co.strato.workflowStage.repository.WorkflowStageTypeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;

import java.util.List;
import java.util.stream.Collectors;

@Log4j2
@RequiredArgsConstructor
@Service
public class WorkflowStageServiceImpl implements WorkflowStageService {

    private final WorkflowStageRepository workflowStageRepository;
    private final WorkflowStageTypeRepository workflowStageTypeRepository;

    @Override
    public List<WorkflowStageDto> getWorkflowStageList() {
        List<WorkflowStageDto> workflowStageDtoList = workflowStageRepository.findAll()
                .stream()
                .map(WorkflowStageDto::from)
                .collect(Collectors.toList());
        return workflowStageDtoList;
    }

    @Override
    public Long registWorkflowStage(WorkflowStageDto workflowStageDto) {
        WorkflowStageTypeDto workflowStageTypeDto =
                WorkflowStageTypeDto.from(workflowStageTypeRepository.findByWorkflowStageTypeIdx(workflowStageDto.getWorkflowStageTypeIdx()));
        WorkflowStageDto result =
                WorkflowStageDto.from(workflowStageRepository.save(WorkflowStageDto.toEntity(workflowStageDto, workflowStageTypeDto)));
        return result.getWorkflowStageIdx();
    }

    @Override
    public Long updateWorkflowStage(WorkflowStageDto workflowStageDto) {
        WorkflowStageTypeDto workflowStageTypeDto =
                WorkflowStageTypeDto.from(workflowStageTypeRepository.findByWorkflowStageTypeIdx(workflowStageDto.getWorkflowStageTypeIdx()));
        WorkflowStageDto result =
                WorkflowStageDto.from(workflowStageRepository.save(WorkflowStageDto.toEntity(workflowStageDto, workflowStageTypeDto)));
        return result.getWorkflowStageIdx();
    }

    @Override
    public void deleteWorkflowStage(Long workflowStageIdx) {
        workflowStageRepository.deleteById(workflowStageIdx);
    }

    @Override
    public WorkflowStageDto detailWorkflowStage(Long workflowStageIdx) {
        return WorkflowStageDto.from(workflowStageRepository.findByWorkflowStageIdx(workflowStageIdx));
    }

    @Override
    @Transactional
    public Boolean isWorkflowStageNameDuplicated(String workflowStageTypeName, String workflowStageName) {
        WorkflowStageType workflowStageType = workflowStageTypeRepository.findByWorkflowStageTypeName(workflowStageTypeName);
        return workflowStageRepository.existsByWorkflowStageTypeAndWorkflowStageName(workflowStageType, workflowStageName);
    }

    @Override
    public List<WorkflowStageDto> getDefaultWorkflowStage(String workflowStageTypeName) {
        // 1. 타입 Dto 조회
        WorkflowStageTypeDto workflowStageTypeDto =
                WorkflowStageTypeDto.from(workflowStageTypeRepository.findByWorkflowStageTypeName(workflowStageTypeName));
        // 2. 스테이지 Dto 조회
        List<WorkflowStageDto> workflowStageDtoList =
                workflowStageRepository.findByWorkflowStageType(WorkflowStageTypeDto.toEntity(workflowStageTypeDto))
                        .stream()
                        .map(WorkflowStageDto::from)
                        .collect(Collectors.toList());

        // 3. 없을경우 default 스크립트 만들어서 set
        if ( CollectionUtils.isEmpty(workflowStageDtoList) ) {
            StringBuffer sb = new StringBuffer();

            JenkinsPipelineUtil.appendLine(sb, "stage('" + workflowStageTypeName.toLowerCase().replaceAll("_", " ") + "') {", 2);
            JenkinsPipelineUtil.appendLine(sb, "steps {", 3);
            JenkinsPipelineUtil.appendLine(sb, "echo '>>>>>STAGE: " + workflowStageTypeName + "'", 4);
            JenkinsPipelineUtil.appendLine(sb, "", 1);
            JenkinsPipelineUtil.appendLine(sb, "// 스크립트를 작성해주세요.", 4);
            JenkinsPipelineUtil.appendLine(sb, "}", 3);
            JenkinsPipelineUtil.appendLine(sb, "}", 2);
            JenkinsPipelineUtil.appendLine(sb, "", 1);

            // 스테이지 Dto에 타입Idx, 스크립트만 넣어서 리스트에 넣어준다.
            WorkflowStageDto workflowStageDto =
                    WorkflowStageDto.setWorkflowStageDefaultScript(workflowStageTypeDto.getWorkflowStageTypeIdx(), sb.toString());
            workflowStageDtoList.add(workflowStageDto);
        }

        return workflowStageDtoList;
    }
}
