package kr.co.mcmp.workflow.service;

import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.oss.entity.Oss;
import kr.co.mcmp.oss.entity.OssType;
import kr.co.mcmp.oss.repository.OssRepository;
import kr.co.mcmp.oss.repository.OssTypeRepository;
import kr.co.mcmp.eventListener.repository.EventListenerRepository;
import kr.co.mcmp.workflow.Entity.Workflow;
import kr.co.mcmp.workflow.Entity.WorkflowHistory;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowHistoryDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowParamDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowStageMappingDto;
import kr.co.mcmp.workflow.dto.reqDto.WorkflowReqDto;
import kr.co.mcmp.workflow.dto.resDto.*;
import kr.co.mcmp.workflow.repository.WorkflowHistoryRepository;
import kr.co.mcmp.workflow.repository.WorkflowParamRepository;
import kr.co.mcmp.workflow.repository.WorkflowRepository;
import kr.co.mcmp.workflow.repository.WorkflowStageMappingRepository;
import kr.co.mcmp.workflow.service.jenkins.JenkinsPipelineGeneratorService;
import kr.co.mcmp.workflow.service.jenkins.model.JenkinsBuildDescribeLog;
import kr.co.mcmp.workflow.service.jenkins.service.JenkinsService;
import kr.co.mcmp.workflowStage.dto.WorkflowStageDto;
import kr.co.mcmp.workflowStage.dto.WorkflowStageTypeDto;
import kr.co.mcmp.workflowStage.repository.WorkflowStageRepository;
import kr.co.mcmp.workflowStage.repository.WorkflowStageTypeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Slf4j
@RequiredArgsConstructor
@Service
public class WorkflowServiceImpl implements WorkflowService {

    private final OssRepository ossRepository;

    private final OssTypeRepository ossTypeRepository;

    private final WorkflowRepository workflowRepository;

    private final WorkflowParamRepository workflowParamRepository;

    private final WorkflowStageMappingRepository workflowStageMappingRepository;

    private final WorkflowHistoryRepository workflowHistoryRepository;

    private final EventListenerRepository eventListenerRepository;

    private final WorkflowStageTypeRepository workflowStageTypeRepository;

    private final WorkflowStageRepository workflowStageRepository;

    private final JenkinsService jenkinsService;

    private final JenkinsPipelineGeneratorService pipelineService;

    private final WorkflowAsyncExecutor workflowAsyncExecutor;

    /**
     * 워크플로우 목록 조회
     * @return
     */
    @Override
    public List<WorkflowListResDto> getWorkflowList() {

        List<WorkflowDto> workflowList = workflowRepository.findAll()
            .stream()
            .map(WorkflowDto::from)
            .collect(Collectors.toList());

        List<WorkflowListResDto> list = new ArrayList<>();
        workflowList.forEach((workflow)-> {
            WorkflowDto workflowDto = getWorkflowDto(workflow.getWorkflowIdx());

            List<WorkflowParamDto> paramList =
                    workflowParamRepository.findByWorkflow_WorkflowIdx(workflow.getWorkflowIdx())
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
        });
        return list;
    }

    /**
     * 워크플로우 생성
     * @param workflowReqDto
     * @return Long
     * @throws java.io.IOException
     */
    @Override
    @Transactional(rollbackFor = { RuntimeException.class })
    public Long registWorkflow(WorkflowReqDto workflowReqDto) {
        Long result = null;
        boolean isCreate = false;
        List<WorkflowParamDto> workflowParams = sanitizeWorkflowParams(workflowReqDto.getWorkflowParams());
        List<WorkflowStageMappingDto> workflowStageMappings = defaultWorkflowStageMappings(workflowReqDto.getWorkflowStageMappings());

        // jenkins 정보 조회
        OssDto ossDto = getOssDto(workflowReqDto.getWorkflowInfo().getOssIdx());

        try {
            if (workflowRepository.findByWorkflowName(workflowReqDto.getWorkflowInfo().getWorkflowName()) != null) {
                log.warn("Workflow name already exists: {}", workflowReqDto.getWorkflowInfo().getWorkflowName());
                return null;
            }

            // jenkins > job 생성
            isCreate = jenkinsService.createJenkinsJob_v2(
                                ossDto,
                                workflowReqDto.getWorkflowInfo().getWorkflowName(),
                                workflowReqDto.getWorkflowInfo().getScript(),
                                workflowParams);

            // DB
            if ( isCreate ) {
                OssTypeDto ossTypeDto = getOssTypeDto(ossDto.getOssTypeIdx());

                // 1. Workflow
                Workflow workflowEntity = WorkflowDto.toEntity(workflowReqDto.getWorkflowInfo(), ossDto, ossTypeDto);
                workflowEntity = workflowRepository.save(workflowEntity);
                WorkflowDto workflowDto = getWorkflowDto(workflowEntity.getWorkflowIdx());

                // 2. Workflow Param
                if ( !CollectionUtils.isEmpty(workflowParams) ) {
                    for(WorkflowParamDto param : workflowParams) {
                        workflowParamRepository.save(WorkflowParamDto.toEntity(param, workflowDto, ossDto, ossTypeDto));
                    }
                }

                // 3. Workflow Stage Mapping
                if ( !CollectionUtils.isEmpty(workflowStageMappings) ) {
                    for(WorkflowStageMappingDto stage : workflowStageMappings) {
                        workflowStageMappingRepository.save(WorkflowStageMappingDto.toEntity(stage, workflowDto, ossDto, ossTypeDto));
                    }
                }

                result = workflowEntity.getWorkflowIdx();
            }
        } catch (IOException e) {
            if(isCreate) jenkinsService.deleteJenkinsJob(ossDto, workflowReqDto.getWorkflowInfo().getWorkflowName());
            log.error(e.getMessage());
        }
        return result;
    }

    /**
     * 배포 정보 수정
     * @param workflowReqDto
     * @return Long
     * @throws java.io.IOException
     */
    @Override
    @Transactional(rollbackFor = { RuntimeException.class })
    public Boolean updateWorkflow(WorkflowReqDto workflowReqDto) {
        Boolean result = false;
        try {
            OssDto ossDto = getOssDto(workflowReqDto.getWorkflowInfo().getOssIdx());
            List<WorkflowParamDto> workflowParams = sanitizeWorkflowParams(workflowReqDto.getWorkflowParams());
            List<WorkflowStageMappingDto> workflowStageMappings = defaultWorkflowStageMappings(workflowReqDto.getWorkflowStageMappings());
            Workflow duplicatedWorkflow = workflowRepository.findByWorkflowName(workflowReqDto.getWorkflowInfo().getWorkflowName());
            if (duplicatedWorkflow != null && !duplicatedWorkflow.getWorkflowIdx().equals(workflowReqDto.getWorkflowInfo().getWorkflowIdx())) {
                log.warn("Workflow name already exists: {}", workflowReqDto.getWorkflowInfo().getWorkflowName());
                return false;
            }

            boolean isUpdate = jenkinsService.updateJenkinsJobPipeline_v2(
                    ossDto,
                    workflowReqDto.getWorkflowInfo().getWorkflowName(),
                    workflowReqDto.getWorkflowInfo().getScript(),
                    workflowParams);

            if ( isUpdate ) {
                OssTypeDto ossTypeDto = getOssTypeDto(ossDto.getOssTypeIdx());
                Workflow previousWorkflow = workflowRepository.findByWorkflowIdx(workflowReqDto.getWorkflowInfo().getWorkflowIdx());

                // 1. Workflow
                Workflow workflowEntity = WorkflowDto.toEntity(workflowReqDto.getWorkflowInfo(), ossDto, ossTypeDto);
                if (previousWorkflow != null && workflowEntity.getRunDate() == null) {
                    workflowEntity.updateRunDate(previousWorkflow.getRunDate());
                }
                if (previousWorkflow != null && workflowEntity.getRunStatus() == null) {
                    workflowEntity.updateRunStatus(previousWorkflow.getRunStatus(), previousWorkflow.getLatestBuildNumber());
                }
                workflowEntity = workflowRepository.save(workflowEntity);
                WorkflowDto workflowDto = getWorkflowDto(workflowEntity.getWorkflowIdx());

                // 2. Workflow Param (삭제 후 재등록)
                workflowParamRepository.deleteByWorkflow_WorkflowIdx(workflowEntity.getWorkflowIdx());
                for (WorkflowParamDto param : workflowParams) {
                    workflowParamRepository.save(WorkflowParamDto.toEntity(param, workflowDto, ossDto, ossTypeDto));
                }

                // 3. Workflow Stage Mapping (삭제 후 재등록)
                workflowStageMappingRepository.deleteByWorkflow_WorkflowIdx(workflowEntity.getWorkflowIdx());
                for(WorkflowStageMappingDto stage : workflowStageMappings) {
                    workflowStageMappingRepository.save(WorkflowStageMappingDto.toEntity(stage, workflowDto, ossDto, ossTypeDto));
                }

                result = true;
            }
        } catch (UnsupportedEncodingException uee) {
            log.error(uee.getMessage());
        } catch (IOException ioe) {
            log.error(ioe.getMessage());
        }
        return result;
    }

    /**
     * 배포 정보 삭제
     * @param workflowIdx
     * @return
     */
    @Override
    @Transactional(rollbackFor = { RuntimeException.class })
    public Boolean deleteWorkflow(Long workflowIdx) {
        boolean result = false;

        try {
            if (eventListenerRepository.existsByWorkflow_WorkflowIdx(workflowIdx)) {
                log.warn("Workflow {} is connected to an Event Listener. Delete request is blocked.", workflowIdx);
                return false;
            }

            // Jenkins 삭제
            Workflow workflowEntity = workflowRepository.findByWorkflowIdx(workflowIdx);
            WorkflowDto workflowDto = WorkflowDto.from(workflowEntity);

            OssDto ossDto = getOssDto(workflowDto.getOssIdx());

            boolean isDelete = jenkinsService.deleteJenkinsJob(ossDto, workflowDto.getWorkflowName());

            if ( isDelete ) {
                // 1. Workflow Stage Mapping
                workflowStageMappingRepository.deleteByWorkflow_WorkflowIdx(workflowIdx);

                // 2. Workflow Param
                workflowParamRepository.deleteByWorkflow_WorkflowIdx(workflowIdx);

                // 3. Workflow
                workflowRepository.deleteByWorkflowIdx(workflowIdx);

                result = true;
            }
        } catch (Exception e) {
            log.error(e.getMessage());
        }

        return result;
    }

    /**
     * 배포 조회
     * @param workflowIdx
     * @return
     */
    @Override
    public WorkflowDetailResDto getWorkflow(Long workflowIdx) {
        try {
            WorkflowDto workflowDto = getWorkflowDto(workflowIdx);

                    List<WorkflowParamDto> paramList = workflowParamRepository.findByWorkflow_WorkflowIdx(workflowIdx)
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

    /**
     * 워크플로우명 중복 체크
     * @param workflowName
     * @return
     */
    @Override
    public Boolean isWorkflowNameDuplicated(String workflowName) {
        Boolean result = true;

        try {
            Workflow workflow = workflowRepository.findByWorkflowName(workflowName);

            if (StringUtils.isEmpty(workflow))
                result = false;
        } catch (Exception e) {
            log.error(e.getMessage());
        }

        return result;
    }

    /**
     * 배포 실행
     * @param workflowIdx
     * @return
     */
    @Override
    public Boolean runWorkflow(Long workflowIdx) {
        // 배포 실행 관련 사용자 이력 정보 수정
        updateWorkflowRunDate(workflowIdx);
        WorkflowDto workflowDto = getWorkflowDto(workflowIdx);

        List<WorkflowParamDto> paramList = workflowParamRepository.findByWorkflow_WorkflowIdx(workflowIdx)
                                            .stream()
                                            .map(WorkflowParamDto::from)
                                            .collect(Collectors.toList());

        List<WorkflowStageMappingDto> stageList = workflowStageMappingRepository.findByWorkflow_WorkflowIdx(workflowIdx)
                                            .stream()
                                            .map(WorkflowStageMappingDto::from)
                                            .collect(Collectors.toList());

        WorkflowReqDto workflowReqDto = WorkflowReqDto.of(workflowDto, paramList, stageList);

        workflowAsyncExecutor.runWorkflow(workflowReqDto);
        return true;
    }

    /**
     * 배포 실행
     * @param workflowReqDto
     * @return
     */
    @Override
    public Boolean runWorkflow(WorkflowReqDto workflowReqDto) {
        if (workflowReqDto.getWorkflowInfo() != null) {
            updateWorkflowRunDate(workflowReqDto.getWorkflowInfo().getWorkflowIdx());
        }
        workflowAsyncExecutor.runWorkflow(workflowReqDto);
        return true;
    }

    /**
     * 젠킨스 파이프라인 목록 (빌드 시 사용할 파이프라인 목록)
     * @return
     */
    @Override
    public List<WorkflowStageTypeAndStageNameResDto> getWorkflowStageList() {

        List<WorkflowStageTypeDto> workflowStageTypeDtoList = workflowStageTypeRepository.findAllByOrderByWorkflowStageTypeIdxAsc()
                                                                .stream()
                                                                .map(WorkflowStageTypeDto::from)
                                                                .collect(Collectors.toList());

        List<WorkflowStageTypeAndStageNameResDto> result = new ArrayList<>();

        workflowStageTypeDtoList.forEach(type -> {
            List<WorkflowStageDto> workflowStageDtoList = workflowStageRepository.findByWorkflowStageTypeOrderByStageOrder(WorkflowStageTypeDto.toEntity(type))
                                                            .stream()
                                                            .map(WorkflowStageDto::from)
                                                            .collect(Collectors.toList());

            if(!StringUtils.isEmpty(workflowStageDtoList)) {
                WorkflowStageTypeAndStageNameResDto output = WorkflowStageTypeAndStageNameResDto.of(type.getWorkflowStageTypeName(), workflowStageDtoList);
                result.add(output);
            }
        });
        return result;
    }


    /**
     * 기본 스크립트 생성
     * @param workflowName
     * @return
     */
    @Override
    public List<WorkflowStageMappingDto> getWorkflowTemplate(String workflowName) {
        return pipelineService.getWorkflowTemplate(workflowName);
    }

    /**
     * Workflow History 목록
     * @param workflowIdx
     * @param dataType
     * @return
     */
    @Override
    public List<WorkflowHistoryDto> getWorkflowHistoryList(Long workflowIdx, String dataType) {
        Stream<WorkflowHistory> historyStream = workflowHistoryRepository.findByWorkflow_WorkflowIdx(workflowIdx).stream();

        if (dataType != null && !dataType.isEmpty()) {
            historyStream = historyStream.filter(history -> dataType.equals(history.getDataType()));
        }

        return historyStream
                .map(WorkflowHistoryDto::from)
                .collect(Collectors.toList());
    }

    /**
     * 파라미터 목록
     * @return
     */
    @Override
    public List<WorkflowParamDto> getWorkflowParamList() {
        return workflowParamRepository.findAll()
                .stream()
                .map(WorkflowParamDto::from)
                .collect(Collectors.toList());
    }

    /**
     * Jenkins Job 자동 생성
     * @param ossTypeName
     * @param ossDto
     */
    public void createJenkinsJob(String ossTypeName, OssDto ossDto) {
        try {
            // OSS 를 등록을 할때 존재하지 않을 경우 Jenkins Job 자동 생성
            if(ossTypeName.toUpperCase().equals("JENKINS")) {
                List<WorkflowListResDto> workflowListResDtoList = getWorkflowList();
                for(WorkflowListResDto workflowResDto : workflowListResDtoList) {
                    boolean isExistJob = jenkinsService.isExistJobName(ossDto, workflowResDto.getWorkflowInfo().getWorkflowName());
                    if(!isExistJob) {
                        jenkinsService.createJenkinsJob_v2(
                                ossDto,
                                workflowResDto.getWorkflowInfo().getWorkflowName(),
                                workflowResDto.getWorkflowInfo().getScript(),
                                workflowResDto.getWorkflowParams());
                    }
                    log.info("Jenkins Job 생성 완료 : {}", isExistJob);
                }
            }
        } catch (IOException ioe) {
            log.error(ioe.getMessage());
        } catch (Exception e) {
            log.error(e.getMessage());
        }
    }

    /**
     * Workflow 로그
     * @param workflowIdx
     * @return
     */
    public List<WorkflowLogResDto> getWorkflowLog(Long workflowIdx) {
        WorkflowDto workflowDto = getWorkflowDto(workflowIdx);
        OssDto ossDto = getOssDto(workflowDto.getOssIdx());

        List<WorkflowLogResDto> resList = WorkflowLogResDto.createList();

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
                resList = WorkflowLogResDto.addToList(resList, buildNumber, log);

                buildNumber++;
            } catch (Exception e) {
                break; // 더 이상 빌드가 없으면 루프 종료
            }
        }
        return resList;
    }


    /**
     * OSSTypeDto 정보 조회
     * @param ossTypeIdx
     * @return
     */
    public OssTypeDto getOssTypeDto(Long ossTypeIdx) {
        OssType ossType = ossTypeRepository.findByOssTypeIdx(ossTypeIdx);
        return OssTypeDto.from(ossType);
    }
    /**
     * OSSDto 정보 조회
     * @param ossIdx
     * @return
     */
    public OssDto getOssDto(Long ossIdx) {
        Oss ossEntity = ossRepository.findByOssIdx(ossIdx);
        return OssDto.from(ossEntity);
    }

    /**
     * WorkflowDto 정보 조회
     * @param workflowIdx
     * @return
     */
    public WorkflowDto getWorkflowDto(Long workflowIdx) {
        Workflow workflow = workflowRepository.findByWorkflowIdx(workflowIdx);
        return WorkflowDto.from(workflow);
    }

    public void updateWorkflowRunDate(Long workflowIdx) {
        if (workflowIdx == null || workflowIdx == 0) {
            return;
        }

        Workflow workflow = workflowRepository.findByWorkflowIdx(workflowIdx);
        if (workflow == null) {
            return;
        }

        workflow.updateRunDate(LocalDateTime.now());
        workflow.updateRunStatus("IN_PROGRESS", null);
        workflowRepository.save(workflow);
    }

    /**
     * getWorkflowRunHistoryList 정보 조회
     * @param workflowIdx
     * @return
     */
    public List<WorkflowRunHistoryResDto> getWorkflowRunHistoryList(Long workflowIdx) {

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

        List<WorkflowRunHistoryResDto> buildHistoryList = WorkflowRunHistoryResDto.createList();

        for(WorkflowLogResDto buildInfo : buildList) {
            WorkflowRunHistoryResDto jenkinsBuildHistory = jenkinsService.getJenkinsBuildStage(ossDto, workflowDto.getWorkflowName(), buildInfo.getBuildIdx());
            buildHistoryList = WorkflowRunHistoryResDto.addToList(buildHistoryList, jenkinsBuildHistory);
        }

        return buildHistoryList;
    }

    /**
     * getWorkflowStageHistoryList 정보 조회
     * @param workflowIdx
     * @param buildIdx
     * @param nodeIdx
     * @return
 */
    @Override
    public JenkinsBuildDescribeLog getWorkflowStageHistoryList(Long workflowIdx, int buildIdx, int nodeIdx) {

        // jenkins job Name 조회
        WorkflowDto workflowDto = getWorkflowDto(workflowIdx);

        // oss 조회
        OssDto ossDto = getOssDto(workflowDto.getOssIdx());

        return jenkinsService.getJenkinsBuildStageLog(ossDto, workflowDto.getWorkflowName(), buildIdx, nodeIdx);
    }

    private List<WorkflowParamDto> sanitizeWorkflowParams(List<WorkflowParamDto> workflowParams) {
        if (CollectionUtils.isEmpty(workflowParams)) {
            return Collections.emptyList();
        }

        Map<String, WorkflowParamDto> paramsByKey = new LinkedHashMap<>();
        for (WorkflowParamDto param : workflowParams) {
            if (param == null || !StringUtils.hasText(param.getParamKey())) {
                continue;
            }

            String normalizedKey = param.getParamKey().trim().toUpperCase();
            if (paramsByKey.containsKey(normalizedKey)) {
                continue;
            }

            paramsByKey.put(normalizedKey, WorkflowParamDto.builder()
                    .paramIdx(param.getParamIdx())
                    .workflowIdx(param.getWorkflowIdx())
                    .paramKey(normalizedKey)
                    .paramValue(param.getParamValue() == null ? "" : param.getParamValue())
                    .eventListenerYn(StringUtils.hasText(param.getEventListenerYn()) ? param.getEventListenerYn() : "N")
                    .build());
        }

        return new ArrayList<>(paramsByKey.values());
    }

    private List<WorkflowStageMappingDto> defaultWorkflowStageMappings(List<WorkflowStageMappingDto> workflowStageMappings) {
        if (CollectionUtils.isEmpty(workflowStageMappings)) {
            return Collections.emptyList();
        }
        return workflowStageMappings;
    }
}
