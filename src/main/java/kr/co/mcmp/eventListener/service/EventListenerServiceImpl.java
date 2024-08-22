package kr.co.mcmp.eventListener.service;

import kr.co.mcmp.eventListener.dto.reqDto.RequestEventListenerDto;
import kr.co.mcmp.eventListener.dto.resDto.ResponseEventListenerDto;
import kr.co.mcmp.eventListener.entity.EventListener;
import kr.co.mcmp.eventListener.repository.EventListenerRepository;
import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.oss.entity.Oss;
import kr.co.mcmp.oss.entity.OssType;
import kr.co.mcmp.oss.repository.OssRepository;
import kr.co.mcmp.oss.repository.OssTypeRepository;
import kr.co.mcmp.workflow.Entity.Workflow;
import kr.co.mcmp.workflow.Entity.WorkflowParam;
import kr.co.mcmp.workflow.Entity.WorkflowStageMapping;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowParamDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowStageMappingDto;
import kr.co.mcmp.workflow.dto.reqDto.WorkflowReqDto;
import kr.co.mcmp.workflow.dto.resDto.WorkflowDetailResDto;
import kr.co.mcmp.workflow.dto.resDto.WorkflowListResDto;
import kr.co.mcmp.workflow.repository.WorkflowParamRepository;
import kr.co.mcmp.workflow.repository.WorkflowRepository;
import kr.co.mcmp.workflow.repository.WorkflowStageMappingRepository;
import kr.co.mcmp.workflow.service.WorkflowService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Log4j2
@RequiredArgsConstructor
@Service
public class EventListenerServiceImpl implements EventListenerService {

    private final EventListenerRepository eventListenerRepository;

    private final WorkflowRepository workflowRepository;

    private final OssRepository ossRepository;

    private final OssTypeRepository ossTypeRepository;

    private final WorkflowParamRepository workflowParamRepository;

    private final WorkflowService workflowService;
    private final WorkflowStageMappingRepository workflowStageMappingRepository;

    @Override
    public List<ResponseEventListenerDto> getEventListenerList() {
        return eventListenerRepository.findAll()
                .stream()
                .map(ResponseEventListenerDto::from)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public Long registEventListner(RequestEventListenerDto requestEventListenerDto) {
        try {
            Long workflowIdx = requestEventListenerDto.getWorkflowIdx();

            Workflow workflowEntity = workflowRepository.findByWorkflowIdx(workflowIdx);
            WorkflowDto workflowDto = WorkflowDto.from(workflowEntity);

            Oss ossEntity = ossRepository.findByOssIdx(workflowDto.getOssIdx());
            OssDto ossDto = OssDto.from(ossEntity);

            OssType ossTypeEntity = ossTypeRepository.findByOssTypeIdx(ossDto.getOssTypeIdx());
            OssTypeDto ossTypeDto = OssTypeDto.from(ossTypeEntity);

            EventListener eventListenerEntity = RequestEventListenerDto.toEntity(requestEventListenerDto, workflowDto, ossDto, ossTypeDto);
            eventListenerEntity = eventListenerRepository.save(eventListenerEntity);

            for(WorkflowParamDto param : requestEventListenerDto.getWorkflowParams()) {
                workflowParamRepository.save(WorkflowParamDto.toEntity(param, workflowDto, ossDto, ossTypeDto));
            }

            return eventListenerEntity.getEventListenerIdx();
        } catch (Exception e) {
            log.error(e.getMessage());
            return null;
        }
    }

    @Override
    @Transactional
    public Boolean updateEventListener(RequestEventListenerDto requestEventListenerDto) {
        Boolean result = false;
        try {
            EventListener eventListenerEntity = eventListenerRepository.findByEventListenerIdx(requestEventListenerDto.getEventListenerIdx());
            RequestEventListenerDto newRequestEventListenerDto = RequestEventListenerDto.from(eventListenerEntity);

            Long workflowIdx = requestEventListenerDto.getWorkflowIdx();

            Workflow workflowEntity = workflowRepository.findByWorkflowIdx(workflowIdx);
            WorkflowDto workflowDto = WorkflowDto.from(workflowEntity);

            Oss ossEntity = ossRepository.findByOssIdx(workflowDto.getOssIdx());
            OssDto ossDto = OssDto.from(ossEntity);

            OssType ossType = ossTypeRepository.findByOssTypeIdx(ossDto.getOssTypeIdx());
            OssTypeDto ossTypeDto = OssTypeDto.from(ossType);

            eventListenerRepository.save(RequestEventListenerDto.toUpdate(newRequestEventListenerDto.getEventListenerIdx(), requestEventListenerDto, workflowDto, ossDto, ossTypeDto));

            for(WorkflowParamDto param : requestEventListenerDto.getWorkflowParams()) {
                workflowParamRepository.save(WorkflowParamDto.toEntity(param, workflowDto, ossDto, ossTypeDto));
            }
            result = true;
        } catch (Exception e) {
            log.error(e.getMessage());
        }
        return result;
    }

    @Override
    @Transactional
    public Boolean deleteEventListener(Long eventListenerIdx) {
        Boolean result = false;
        try {
            eventListenerRepository.deleteByEventListenerIdx(eventListenerIdx);
            result = true;
        } catch (Exception e) {
            log.error(e.getMessage());
        }
        return result;
    }

    @Override
    public ResponseEventListenerDto detailEventListener(Long eventListenerIdx) {
        try {
            EventListener eventListenerEntity = eventListenerRepository.findByEventListenerIdx(eventListenerIdx);
            return ResponseEventListenerDto.from(eventListenerEntity);
        } catch (Exception e) {
            log.error(e.getMessage());
            return null;
        }
    }

    /**
     * 배포 조회
     * @param eventListenerYn
     * @return
     */
    @Override
    public List<WorkflowListResDto> getWorkflowList(String eventListenerYn) {
        List<WorkflowDto> workflowList = workflowRepository.findAll()
                .stream()
                .map(WorkflowDto::from)
                .collect(Collectors.toList());

        List<WorkflowListResDto> list = new ArrayList<>();
        for(WorkflowDto workflow : workflowList) {
            Workflow workflowEntity = workflowRepository.findByWorkflowIdx(workflow.getWorkflowIdx());
            WorkflowDto workflowDto = WorkflowDto.from(workflowEntity);

            List<WorkflowParamDto> paramList =
                    workflowParamRepository.findByWorkflow_WorkflowIdxAndEventListenerYn(workflow.getWorkflowIdx(), eventListenerYn)
                            .stream()
                            .map(WorkflowParamDto::from)
                            .collect(Collectors.toList());

            List<WorkflowStageMappingDto> stageList =
                    workflowStageMappingRepository.findByWorkflow_WorkflowIdx(workflow.getWorkflowIdx())
                            .stream()
                            .map(WorkflowStageMappingDto::from)
                            .collect(Collectors.toList());

            WorkflowListResDto workflowListData = WorkflowListResDto.of(workflowDto, paramList, stageList);

            list.add(workflowListData);
        }
        return list;
    }

    /**
     * 배포 조회
     * @param workflowIdx
     * @return
     */
    @Override
    public WorkflowDetailResDto getWorkflowDetail(Long workflowIdx, String eventListenerYn) {
        try {
            Workflow workflowEntity = workflowRepository.findByWorkflowIdx(workflowIdx);
            WorkflowDto workflowDto = WorkflowDto.from(workflowEntity);

            List<WorkflowParamDto> paramList = workflowParamRepository.findByWorkflow_WorkflowIdxAndEventListenerYn(workflowIdx, eventListenerYn)
                    .stream()
                    .map(WorkflowParamDto::from)
                    .collect(Collectors.toList());

            List<WorkflowStageMappingDto> stageList = workflowStageMappingRepository.findByWorkflow_WorkflowIdx(workflowIdx)
                    .stream()
                    .map(WorkflowStageMappingDto::from)
                    .collect(Collectors.toList());

            WorkflowDetailResDto workflowDetail = WorkflowDetailResDto.of(workflowDto, paramList, stageList);

            return workflowDetail;
        } catch (Exception e) {
            log.error(e.getMessage());
            return null;
        }
    }

    @Override
    public Boolean runEventListener(Long eventListenerIdx) {
        Boolean result = false;

        try {
            EventListener eventListenerEntity = eventListenerRepository.findByEventListenerIdx(eventListenerIdx);
            Long workflowIdx = eventListenerEntity.getWorkflow().getWorkflowIdx();

            Workflow workflowEntity = workflowRepository.findByWorkflowIdx(workflowIdx);

            List<WorkflowParam> params = workflowParamRepository.findByWorkflow_WorkflowIdxAndEventListenerYn(workflowIdx, "Y");

            List<WorkflowStageMapping> stages = workflowStageMappingRepository.findByWorkflow_WorkflowIdx(workflowIdx);

            WorkflowReqDto workflowReqDto = WorkflowReqDto.from(workflowEntity, params, stages);

            result = workflowService.runWorkflow(workflowReqDto);
        } catch (Exception e) {
            log.error(e.getMessage());
        }
        return result;
    }
}
