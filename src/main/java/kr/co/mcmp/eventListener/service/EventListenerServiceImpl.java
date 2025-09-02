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

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
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
            Long workflowIdx = requestEventListenerDto.getWorkflowIdx();

            WorkflowDto workflowDto = getWorkflowDto(workflowIdx);

            OssDto ossDto = getOssDto(workflowDto.getOssIdx());

            OssTypeDto ossTypeDto = getOssTypeDto(ossDto.getOssTypeIdx());

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

            WorkflowDto workflowDto = getWorkflowDto(workflowIdx);

            OssDto ossDto = getOssDto(workflowDto.getOssIdx());

            OssTypeDto ossTypeDto = getOssTypeDto(ossDto.getOssTypeIdx());

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
            List<WorkflowParamDto> paramList =
                    workflowParamRepository.findByWorkflow_WorkflowIdxAndEventListenerYn(eventListenerEntity.getWorkflow().getWorkflowIdx(), "Y")
                            .stream()
                            .map(WorkflowParamDto::from)
                            .collect(Collectors.toList());

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
            String status = getWorkflowRunHistoryStatus(workflowDto.getWorkflowIdx());
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

    /**
     * 이벤트 리스너 실행
     * @param eventListenerIdx
     * @return
     */
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

    @Override
    public Boolean runEventListenerPost(Long eventListenerIdx, Map<String, String> params) {
        Boolean result = false;

        try {
            // 1. 이벤트 리스너 조회
            EventListener eventListenerEntity = eventListenerRepository.findByEventListenerIdx(eventListenerIdx);
            Long workflowIdx = eventListenerEntity.getWorkflow().getWorkflowIdx();

            // 2. 워크플로우 조회
            Workflow workflowEntity = workflowRepository.findByWorkflowIdx(workflowIdx);

            // 3. Map<String, String> → List<WorkflowParam>
            List<WorkflowParam> workflowParams = new ArrayList<>();
            if (params != null && !params.isEmpty()) {
                for (Map.Entry<String, String> entry : params.entrySet()) {
                    WorkflowParam wp = WorkflowParam.builder()
                            .workflow(workflowEntity)
                            .paramKey(entry.getKey())
                            .paramValue(entry.getValue())
                            .eventListenerYn("Y")   // 이벤트 리스너 실행 시 전달된 값이라는 표시
                            .build();
                    workflowParams.add(wp);
                }
            }

            // 4. 스테이지 매핑 조회
            List<WorkflowStageMapping> stages = workflowStageMappingRepository.findByWorkflow_WorkflowIdx(workflowIdx);

            // 5. DTO 생성
            WorkflowReqDto workflowReqDto = WorkflowReqDto.from(workflowEntity, workflowParams, stages);

            // 6. 워크플로우 실행
            result = workflowService.runWorkflow(workflowReqDto);

        } catch (Exception e) {
            log.error("runEventListenerPost error: {}", e.getMessage(), e);
        }
        return result;
    }

    @Override
    public Boolean runEventListenerPut(Long eventListenerIdx, Map<String, String> params) {
        Boolean result = false;

        try {
            // 1. 이벤트 리스너 조회
            EventListener eventListenerEntity = eventListenerRepository.findByEventListenerIdx(eventListenerIdx);
            Long workflowIdx = eventListenerEntity.getWorkflow().getWorkflowIdx();

            // 2. 워크플로우 조회
            Workflow workflowEntity = workflowRepository.findByWorkflowIdx(workflowIdx);

            // 3. Map<String, String> → List<WorkflowParam>
            List<WorkflowParam> workflowParams = new ArrayList<>();
            if (params != null && !params.isEmpty()) {
                for (Map.Entry<String, String> entry : params.entrySet()) {
                    WorkflowParam wp = WorkflowParam.builder()
                            .workflow(workflowEntity)
                            .paramKey(entry.getKey())
                            .paramValue(entry.getValue())
                            .eventListenerYn("Y")   // 이벤트 리스너 실행 시 전달된 값이라는 표시
                            .build();
                    workflowParams.add(wp);
                }
            }

            // 4. 스테이지 매핑 조회
            List<WorkflowStageMapping> stages = workflowStageMappingRepository.findByWorkflow_WorkflowIdx(workflowIdx);

            // 5. DTO 생성
            WorkflowReqDto workflowReqDto = WorkflowReqDto.from(workflowEntity, workflowParams, stages);

            // 6. 워크플로우 실행
            result = workflowService.runWorkflow(workflowReqDto);

        } catch (Exception e) {
            log.error("runEventListenerPost error: {}", e.getMessage(), e);
        }
        return result;
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
