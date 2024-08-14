package kr.co.mcmp.workflowStage.service;

import kr.co.mcmp.workflowStage.dto.WorkflowStageTypeDto;
import kr.co.mcmp.workflowStage.repository.WorkflowStageTypeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Log4j2
@RequiredArgsConstructor
@Service
public class WorkflowStageTypeServiceImpl implements WorkflowStageTypeService {

    private final WorkflowStageTypeRepository workflowStageTypeRepository;

    /**
     * Workflow Stage Type 생성
     * @return
     */
    @Override
    public List<WorkflowStageTypeDto> getWorkflowStageTypeList() {
        List<WorkflowStageTypeDto> workflowStageTypeDtoList =
                workflowStageTypeRepository.findAll()
                .stream()
                .map(WorkflowStageTypeDto::from)
                .collect(Collectors.toList());;
        return workflowStageTypeDtoList;
    }

    /**
     * Workflow Stage Type 등록
     * @param workflowStageTypeDto
     * @return
     */
    @Override
    public Long registWorkflowStage(WorkflowStageTypeDto workflowStageTypeDto) {
        WorkflowStageTypeDto result = WorkflowStageTypeDto.from(workflowStageTypeRepository.save(WorkflowStageTypeDto.toEntity(workflowStageTypeDto)));
        return result.getWorkflowStageTypeIdx();
    }

    /**
     * Workflow Stage Type 수정
     * @param workflowStageTypeDto
     * @return
     */
    @Override
    public Long updateWorkflowStageType(WorkflowStageTypeDto workflowStageTypeDto) {
        WorkflowStageTypeDto result = WorkflowStageTypeDto.from(workflowStageTypeRepository.save(WorkflowStageTypeDto.toEntity(workflowStageTypeDto)));
        return result.getWorkflowStageTypeIdx();
    }

    /**
     * Workflow Stage Type 삭제
     * @param workflowStageTypeIdx
     * @return
     */
    @Override
    public void deleteWorkflowStageType(Long workflowStageTypeIdx) {
        workflowStageTypeRepository.deleteById(workflowStageTypeIdx);
    }

    /**
     * Workflow Stage Type 상세
     * @param workflowStageTypeIdx
     * @return
     */
    @Override
    public WorkflowStageTypeDto detailWorkflowStageType(Long workflowStageTypeIdx) {
        return WorkflowStageTypeDto.from(workflowStageTypeRepository.findByWorkflowStageTypeIdx(workflowStageTypeIdx));
    }
}
