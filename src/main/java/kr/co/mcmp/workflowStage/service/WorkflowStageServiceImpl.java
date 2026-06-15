package kr.co.mcmp.workflowStage.service;

import kr.co.mcmp.util.JenkinsPipelineUtil;
import kr.co.mcmp.workflow.repository.WorkflowStageMappingRepository;
import kr.co.mcmp.workflowStage.Entity.WorkflowStage;
import kr.co.mcmp.workflowStage.Entity.WorkflowStageType;
import kr.co.mcmp.workflowStage.dto.WorkflowStageDto;
import kr.co.mcmp.workflowStage.dto.WorkflowStageTypeDto;
import kr.co.mcmp.workflowStage.repository.WorkflowStageRepository;
import kr.co.mcmp.workflowStage.repository.WorkflowStageTypeRepository;
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

    private final WorkflowStageMappingRepository workflowStageMappingRepository;

    @Override
    public List<WorkflowStageDto> getWorkflowStageList() {
        try {
            List<WorkflowStageDto> workflowStageDtoList = workflowStageRepository
                    .findAllOrderByStageTypeAndStageOrder()
                    .stream()
                    .map(WorkflowStageDto::from)
                    .collect(Collectors.toList());
            return workflowStageDtoList;
        } catch (Exception e) {
            log.error(e.getMessage());
            return null;
        }
    }

    @Override
    public Long registWorkflowStage(WorkflowStageDto workflowStageDto) {
        try {

            Boolean existsWorkflowType = workflowStageTypeRepository.existsByWorkflowStageTypeName(workflowStageDto.getWorkflowStageTypeName());
            if(!existsWorkflowType) {
                workflowStageTypeRepository.save(WorkflowStageTypeDto.saveWorkflowStageType(workflowStageDto.getWorkflowStageTypeName(), ""));
            }

            WorkflowStageType workflowStageTypeEntity = workflowStageTypeRepository.findByWorkflowStageTypeName(workflowStageDto.getWorkflowStageTypeName());
            WorkflowStageTypeDto workflowStageTypeDto = WorkflowStageTypeDto.from(workflowStageTypeEntity);

            WorkflowStage workflowStageEntity =  workflowStageRepository.save(WorkflowStageDto.toEntity(workflowStageDto, workflowStageTypeDto));
            WorkflowStageDto result = WorkflowStageDto.from(workflowStageEntity);

            return result.getWorkflowStageIdx();
        } catch (Exception e) {
            log.error(e.getMessage());
            return null;
        }
    }

    @Override
    public Boolean updateWorkflowStage(WorkflowStageDto workflowStageDto) {
        Boolean result = false;
        try {
            WorkflowStageType workflowStageType = workflowStageTypeRepository.findByWorkflowStageTypeIdx(workflowStageDto.getWorkflowStageTypeIdx());
            WorkflowStageTypeDto workflowStageTypeDto = WorkflowStageTypeDto.from(workflowStageType);

            workflowStageRepository.save(WorkflowStageDto.toEntity(workflowStageDto, workflowStageTypeDto));

            result = true;
        } catch (Exception e) {
            log.error(e.getMessage());
        }
        return result;
    }

    @Override
    @Transactional
    public Boolean deleteWorkflowStage(Long workflowStageIdx) {
        Boolean result = false;
        try {
            if(!workflowStageMappingRepository.existsByWorkflowStageIdx(workflowStageIdx)) {
                workflowStageRepository.deleteByWorkflowStageIdx(workflowStageIdx);
                result = true;
            }
        } catch (Exception e) {
            log.error(e.getMessage());
        }
        return result;
    }

    @Override
    public WorkflowStageDto detailWorkflowStage(Long workflowStageIdx) {
        try {
            return WorkflowStageDto.from(workflowStageRepository.findByWorkflowStageIdx(workflowStageIdx));
        } catch (Exception e) {
            log.error(e.getMessage());
            return null;
        }
    }

    @Override
    @Transactional
    public Boolean isWorkflowStageNameDuplicated(String workflowStageTypeName, String workflowStageName) {
        try {
            WorkflowStageType workflowStageType = workflowStageTypeRepository.findByWorkflowStageTypeName(workflowStageTypeName);
            return workflowStageRepository.existsByWorkflowStageTypeAndWorkflowStageName(workflowStageType, workflowStageName);
        } catch (Exception e) {
            log.error(e.getMessage());
            return false;
        }
    }

    @Override
    public List<WorkflowStageDto> getDefaultWorkflowStage(String workflowStageTypeName) {
        try {

            Boolean existsWorkflowType = workflowStageTypeRepository.existsByWorkflowStageTypeName(workflowStageTypeName);

            if(existsWorkflowType) {
                // Comment translated to English.
                WorkflowStageTypeDto workflowStageTypeDto =
                        WorkflowStageTypeDto.from(workflowStageTypeRepository.findByWorkflowStageTypeName(workflowStageTypeName));
                // Comment translated to English.
                List<WorkflowStageDto> workflowStageDtoList =
                        workflowStageRepository.findByWorkflowStageTypeOrderByStageOrder(WorkflowStageTypeDto.toEntity(workflowStageTypeDto))
                                .stream()
                                .map(WorkflowStageDto::from)
                                .collect(Collectors.toList());

                // Comment translated to English.
                if ( CollectionUtils.isEmpty(workflowStageDtoList) ) {
                    StringBuffer sb = new StringBuffer();

                    JenkinsPipelineUtil.appendLine(sb, "stage('" + workflowStageTypeName.toLowerCase().replaceAll("_", " ") + "') {", 2);
                    JenkinsPipelineUtil.appendLine(sb, "steps {", 3);
                    JenkinsPipelineUtil.appendLine(sb, "echo '>>>>>STAGE: " + workflowStageTypeName + "'", 4);
                    JenkinsPipelineUtil.appendLine(sb, "", 1);
                    JenkinsPipelineUtil.appendLine(sb, "// Write the script here.", 4);
                    JenkinsPipelineUtil.appendLine(sb, "}", 3);
                    JenkinsPipelineUtil.appendLine(sb, "}", 2);
                    JenkinsPipelineUtil.appendLine(sb, "", 1);

                    // Comment translated to English.
                    WorkflowStageDto workflowStageDto =
                            WorkflowStageDto.setWorkflowStageDefaultScript(workflowStageTypeDto.getWorkflowStageTypeIdx(), sb.toString());
                    workflowStageDtoList.add(workflowStageDto);
                }
                return workflowStageDtoList;
            }
            else {
                StringBuffer sb = new StringBuffer();

                JenkinsPipelineUtil.appendLine(sb, "stage('" + workflowStageTypeName.toLowerCase().replaceAll("_", " ") + "') {", 2);
                JenkinsPipelineUtil.appendLine(sb, "steps {", 3);
                JenkinsPipelineUtil.appendLine(sb, "echo '>>>>>STAGE: " + workflowStageTypeName + "'", 4);
                JenkinsPipelineUtil.appendLine(sb, "", 1);
                JenkinsPipelineUtil.appendLine(sb, "// Write the script here.", 4);
                JenkinsPipelineUtil.appendLine(sb, "}", 3);
                JenkinsPipelineUtil.appendLine(sb, "}", 2);
                JenkinsPipelineUtil.appendLine(sb, "", 1);

                // Comment translated to English.
                List<WorkflowStageDto> workflowStageDtoList =
                        WorkflowStageDto.setWorkflowStageDefaultScriptList(0L, sb.toString());
                return workflowStageDtoList;
            }
        } catch (Exception e) {
            log.error(e.getMessage());
            return null;
        }
    }
}
