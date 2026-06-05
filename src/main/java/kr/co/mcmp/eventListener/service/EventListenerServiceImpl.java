package kr.co.mcmp.eventListener.service;

import kr.co.mcmp.eventListener.dto.reqDto.RequestEventListenerDto;
import kr.co.mcmp.eventListener.dto.resDto.ResponseEventListenerDto;
import kr.co.mcmp.eventListener.entity.EventListener;
import kr.co.mcmp.eventListener.entity.EventListenerParam;
import kr.co.mcmp.eventListener.repository.EventListenerParamRepository;
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
import kr.co.mcmp.workflow.dto.resDto.WorkflowLogResDto;
import kr.co.mcmp.workflow.repository.WorkflowParamRepository;
import kr.co.mcmp.workflow.repository.WorkflowRepository;
import kr.co.mcmp.workflow.repository.WorkflowStageMappingRepository;
import kr.co.mcmp.workflow.service.WorkflowService;
import kr.co.mcmp.workflow.service.jenkins.service.JenkinsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Log4j2
@RequiredArgsConstructor
@Service
public class EventListenerServiceImpl implements EventListenerService {

    private final EventListenerRepository eventListenerRepository;

    private final EventListenerParamRepository eventListenerParamRepository;

    private final WorkflowRepository workflowRepository;

    private final OssRepository ossRepository;

    private final OssTypeRepository ossTypeRepository;

    private final WorkflowParamRepository workflowParamRepository;

    private final WorkflowService workflowService;

    private final WorkflowStageMappingRepository workflowStageMappingRepository;

    private final JenkinsService jenkinsService;

    @Override
    public List<ResponseEventListenerDto> getEventListenerList() {
        return eventListenerRepository.findAll()
                .stream()
                .map(ResponseEventListenerDto::fromGetList)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public Long registEventListner(RequestEventListenerDto requestEventListenerDto) {
        try {
            if (eventListenerRepository.existsByEventListenerName(requestEventListenerDto.getEventListenerName())) {
                log.warn("Event Listener name already exists: {}", requestEventListenerDto.getEventListenerName());
                return null;
            }

            Long workflowIdx = requestEventListenerDto.getWorkflowIdx();

            WorkflowDto workflowDto = getWorkflowDto(workflowIdx);

            OssDto ossDto = getOssDto(workflowDto.getOssIdx());

            OssTypeDto ossTypeDto = getOssTypeDto(ossDto.getOssTypeIdx());

            EventListener eventListenerEntity = RequestEventListenerDto.toEntity(requestEventListenerDto, workflowDto, ossDto, ossTypeDto);
            eventListenerEntity = eventListenerRepository.save(eventListenerEntity);

            saveEventListenerParams(eventListenerEntity, requestEventListenerDto.getWorkflowParams());

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
            if (!eventListenerEntity.getEventListenerName().equals(requestEventListenerDto.getEventListenerName())
                    && eventListenerRepository.existsByEventListenerName(requestEventListenerDto.getEventListenerName())) {
                log.warn("Event Listener name already exists: {}", requestEventListenerDto.getEventListenerName());
                return false;
            }

            Long workflowIdx = requestEventListenerDto.getWorkflowIdx();

            WorkflowDto workflowDto = getWorkflowDto(workflowIdx);

            OssDto ossDto = getOssDto(workflowDto.getOssIdx());

            OssTypeDto ossTypeDto = getOssTypeDto(ossDto.getOssTypeIdx());

            EventListener updatedEventListener =
                    eventListenerRepository.save(RequestEventListenerDto.toUpdate(newRequestEventListenerDto.getEventListenerIdx(), requestEventListenerDto, workflowDto, ossDto, ossTypeDto));

            eventListenerParamRepository.deleteByEventListener_EventListenerIdx(updatedEventListener.getEventListenerIdx());
            saveEventListenerParams(updatedEventListener, requestEventListenerDto.getWorkflowParams());
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
            eventListenerParamRepository.deleteByEventListener_EventListenerIdx(eventListenerIdx);
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
            List<WorkflowParamDto> paramList = getEventListenerParamDtos(
                    eventListenerEntity.getEventListenerIdx(),
                    eventListenerEntity.getWorkflow().getWorkflowIdx());

            return ResponseEventListenerDto.from(eventListenerEntity, paramList);
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
            String status = StringUtils.hasText(workflowDto.getStatus()) ? workflowDto.getStatus() : "-";
            workflowDto = WorkflowDto.ofWithStatus(workflowDto, status);

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
    public Boolean isEventListenerDuplicated(String eventlistenerName) {
        Boolean result = false;
        try {
            result = eventListenerRepository.existsByEventListenerName(eventlistenerName);
        } catch (Exception e) {
            log.error(e.getMessage());
        }
        return result;
    }

    @Override
    public Boolean runEventListener(Long eventListenerIdx, Map<String, String> params) {
        return runEventListenerWithMergedParams(eventListenerIdx, params);
    }


    @Override
    public Boolean runEventListenerPost(Long eventListenerIdx, Map<String, String> params) {
        return runEventListenerWithMergedParams(eventListenerIdx, params);
    }


    @Override
    public Boolean runEventListenerPut(Long eventListenerIdx, Map<String, String> params) {
        return runEventListenerWithMergedParams(eventListenerIdx, params);
    }




    private Boolean runEventListenerWithMergedParams(Long eventListenerIdx, Map<String, String> params) {
        try {
            EventListener eventListenerEntity = eventListenerRepository.findByEventListenerIdx(eventListenerIdx);
            Long workflowIdx = eventListenerEntity.getWorkflow().getWorkflowIdx();
            Workflow workflowEntity = workflowRepository.findByWorkflowIdx(workflowIdx);

            List<WorkflowParam> workflowParams = mergeRunParams(workflowEntity, eventListenerIdx, params);
            List<WorkflowStageMapping> stages = workflowStageMappingRepository.findByWorkflow_WorkflowIdx(workflowIdx);
            WorkflowReqDto workflowReqDto = WorkflowReqDto.from(workflowEntity, workflowParams, stages);

            return workflowService.runWorkflow(workflowReqDto);
        } catch (Exception e) {
            log.error("runEventListener error: {}", e.getMessage(), e);
            return false;
        }
    }

    private List<WorkflowParam> mergeRunParams(Workflow workflowEntity, Long eventListenerIdx, Map<String, String> requestParams) {
        Map<String, String> paramsByKey = new LinkedHashMap<>();
        Long workflowIdx = workflowEntity.getWorkflowIdx();

        workflowParamRepository.findByWorkflow_WorkflowIdxAndEventListenerYn(workflowIdx, "N")
                .forEach(param -> putParam(paramsByKey, param.getParamKey(), param.getParamValue()));

        List<EventListenerParam> eventListenerParams = eventListenerParamRepository.findByEventListener_EventListenerIdx(eventListenerIdx);
        if (CollectionUtils.isEmpty(eventListenerParams)) {
            workflowParamRepository.findByWorkflow_WorkflowIdxAndEventListenerYn(workflowIdx, "Y")
                    .forEach(param -> putParam(paramsByKey, param.getParamKey(), param.getParamValue()));
        } else {
            eventListenerParams.forEach(param -> putParam(paramsByKey, param.getParamKey(), param.getParamValue()));
        }

        if (requestParams != null) {
            requestParams.forEach((key, value) -> putParam(paramsByKey, key, value));
        }

        return paramsByKey.entrySet()
                .stream()
                .map(entry -> WorkflowParam.builder()
                        .workflow(workflowEntity)
                        .paramKey(entry.getKey())
                        .paramValue(entry.getValue())
                        .eventListenerYn("N")
                        .build())
                .collect(Collectors.toList());
    }

    private void saveEventListenerParams(EventListener eventListener, List<WorkflowParamDto> workflowParams) {
        if (CollectionUtils.isEmpty(workflowParams)) {
            return;
        }

        Map<String, String> paramsByKey = new LinkedHashMap<>();
        workflowParams.forEach(param -> putParam(paramsByKey, param.getParamKey(), param.getParamValue()));

        paramsByKey.forEach((key, value) ->
                eventListenerParamRepository.save(EventListenerParam.builder()
                        .eventListener(eventListener)
                        .paramKey(key)
                        .paramValue(value)
                        .build()));
    }

    private List<WorkflowParamDto> getEventListenerParamDtos(Long eventListenerIdx, Long workflowIdx) {
        List<EventListenerParam> eventListenerParams = eventListenerParamRepository.findByEventListener_EventListenerIdx(eventListenerIdx);
        if (CollectionUtils.isEmpty(eventListenerParams)) {
            return workflowParamRepository.findByWorkflow_WorkflowIdxAndEventListenerYn(workflowIdx, "Y")
                    .stream()
                    .map(WorkflowParamDto::from)
                    .collect(Collectors.toList());
        }

        return eventListenerParams.stream()
                .map(param -> WorkflowParamDto.builder()
                        .workflowIdx(workflowIdx)
                        .paramKey(param.getParamKey())
                        .paramValue(param.getParamValue())
                        .eventListenerYn("Y")
                        .build())
                .collect(Collectors.toList());
    }

    private void putParam(Map<String, String> paramsByKey, String key, String value) {
        if (!StringUtils.hasText(key)) {
            return;
        }

        paramsByKey.put(key.trim().toUpperCase(), value == null ? "" : value);
    }

    public WorkflowDto getWorkflowDto(Long workflowIdx) {
        Workflow workflowEntity = workflowRepository.findByWorkflowIdx(workflowIdx);
        return WorkflowDto.from(workflowEntity);
    }

    public OssDto getOssDto(Long ossIdx) {
        Oss ossEntity = ossRepository.findByOssIdx(ossIdx);
        return OssDto.from(ossEntity);
    }

    public OssTypeDto getOssTypeDto(Long ossTypeIdx) {
        OssType ossTypeEntity = ossTypeRepository.findByOssTypeIdx(ossTypeIdx);
        return OssTypeDto.from(ossTypeEntity);
    }

    /**
     * WorkflowStageMappingDto 정보 조회
     * @param workflowIdx
     * @return
     */
    public String getWorkflowRunHistoryStatus(Long workflowIdx) {

        // jenkins job Name 조회
        WorkflowDto workflowDto = getWorkflowDto(workflowIdx);

        // oss 조회
        OssDto ossDto = getOssDto(workflowDto.getOssIdx());

        List<WorkflowLogResDto> buildList = WorkflowLogResDto.createList();

        int buildNumber = 1;

        while (true) {
            try {
                String log = jenkinsService.getJenkinsLog(
                        ossDto.getOssUrl(),
                        ossDto.getOssUsername(),
                        ossDto.getOssPassword(),
                        workflowDto.getWorkflowName(),
                        buildNumber
                );
                buildList = WorkflowLogResDto.addToList(buildList, buildNumber, log);

                buildNumber++;
            } catch (Exception e) {
                break; // 더 이상 빌드가 없으면 루프 종료
            }
        }

        buildNumber -= 1;
        if (buildNumber > 0)
            return jenkinsService.getJenkinsBuildStage(ossDto, workflowDto.getWorkflowName(), buildNumber).getStatus();
        else
            return "-";
    }
}
