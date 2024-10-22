package kr.co.mcmp.workflow.service;

import com.cdancy.jenkins.rest.domain.job.BuildInfo;
import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.oss.entity.Oss;
import kr.co.mcmp.oss.entity.OssType;
import kr.co.mcmp.oss.repository.OssRepository;
import kr.co.mcmp.oss.repository.OssTypeRepository;
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
import org.springframework.scheduling.annotation.Async;
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

    private final WorkflowStageTypeRepository workflowStageTypeRepository;

    private final WorkflowStageRepository workflowStageRepository;

    private final JenkinsService jenkinsService;

    private final JenkinsPipelineGeneratorService pipelineService;

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

        // jenkins 정보 조회
        OssDto ossDto = getOssDto(workflowReqDto.getWorkflowInfo().getOssIdx());

        try {
            // jenkins > job 생성
            isCreate = jenkinsService.createJenkinsJob_v2(
                                ossDto,
                                workflowReqDto.getWorkflowInfo().getWorkflowName(),
                                workflowReqDto.getWorkflowInfo().getScript(),
                                workflowReqDto.getWorkflowParams());

            // DB
            if ( isCreate ) {
                OssTypeDto ossTypeDto = getOssTypeDto(ossDto.getOssTypeIdx());

                // 1. Workflow
                Workflow workflowEntity = WorkflowDto.toEntity(workflowReqDto.getWorkflowInfo(), ossDto, ossTypeDto);
                workflowEntity = workflowRepository.save(workflowEntity);
                WorkflowDto workflowDto = getWorkflowDto(workflowEntity.getWorkflowIdx());

                // 2. Workflow Param
                if ( !CollectionUtils.isEmpty(workflowReqDto.getWorkflowParams()) ) {
                    for(WorkflowParamDto param :workflowReqDto.getWorkflowParams()) {
                        workflowParamRepository.save(WorkflowParamDto.toEntity(param, workflowDto, ossDto, ossTypeDto));
                    }
                }

                // 3. Workflow Stage Mapping
                if ( !CollectionUtils.isEmpty(workflowReqDto.getWorkflowStageMappings()) ) {
                    for(WorkflowStageMappingDto stage :workflowReqDto.getWorkflowStageMappings()) {
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

            boolean isUpdate = jenkinsService.updateJenkinsJobPipeline_v2(
                    ossDto,
                    workflowReqDto.getWorkflowInfo().getWorkflowName(),
                    workflowReqDto.getWorkflowInfo().getScript(),
                    workflowReqDto.getWorkflowParams());

            if ( isUpdate ) {
                OssTypeDto ossTypeDto = getOssTypeDto(ossDto.getOssTypeIdx());

                // 1. Workflow
                Workflow workflowEntity = WorkflowDto.toEntity(workflowReqDto.getWorkflowInfo(), ossDto, ossTypeDto);
                workflowEntity = workflowRepository.save(workflowEntity);
                WorkflowDto workflowDto = getWorkflowDto(workflowEntity.getWorkflowIdx());

                // 2. Workflow Param (삭제 후 재등록)
                if ( !CollectionUtils.isEmpty(workflowReqDto.getWorkflowParams()) ) {
                    workflowParamRepository.deleteByWorkflow_WorkflowIdx(workflowEntity.getWorkflowIdx());

                    for (WorkflowParamDto param : workflowReqDto.getWorkflowParams()) {
                        workflowParamRepository.save(WorkflowParamDto.toEntity(param, workflowDto, ossDto, ossTypeDto));
                    }
                }

                // 3. Workflow Stage Mapping (삭제 후 재등록)
                if ( !CollectionUtils.isEmpty(workflowReqDto.getWorkflowStageMappings()) ) {
                    workflowStageMappingRepository.deleteByWorkflow_WorkflowIdx(workflowEntity.getWorkflowIdx());

                    for(WorkflowStageMappingDto stage : workflowReqDto.getWorkflowStageMappings()) {
                        workflowStageMappingRepository.save(WorkflowStageMappingDto.toEntity(stage, workflowDto, ossDto, ossTypeDto));
                    }
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
    @Async
    @Override
    public Boolean runWorkflow(Long workflowIdx) {
        // 배포 실행 관련 사용자 이력 정보 수정
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

        return runWorkflowCallback(workflowReqDto);
    }

    /**
     * 배포 실행
     * @param workflowReqDto
     * @return
     */
    @Async
    @Override
    public Boolean runWorkflow(WorkflowReqDto workflowReqDto) {
        return runWorkflowCallback(workflowReqDto);
    }

    public Boolean runWorkflowCallback(WorkflowReqDto workflowReqDto) {

        Map<String, List<String>> jenkinsJobParams = null;

        if(!StringUtils.isEmpty(workflowReqDto.getWorkflowParams())) {
            Map<String, List<String>> finalJenkinsJobParams = new HashMap<>();

            for(WorkflowParamDto param : workflowReqDto.getWorkflowParams()) {
                finalJenkinsJobParams.put(param.getParamKey(), Arrays.asList(param.getParamValue()));
            }

            jenkinsJobParams = finalJenkinsJobParams;
        }

        // OSS 접속 정보 조회
        OssTypeDto ossTypeDto = getOssTypeDto(workflowReqDto.getWorkflowInfo().getOssIdx());
        OssDto ossDto = getOssDto(workflowReqDto.getWorkflowInfo().getOssIdx());

        // Jenkins Job 실행
        int jenkinsBuildId = jenkinsService.buildJenkinsJob(ossDto, workflowReqDto.getWorkflowInfo().getWorkflowName(), jenkinsJobParams);
        int buildNumber = jenkinsService.getQueueExecutableNumber(ossDto, jenkinsBuildId);

        // 배포 이력 정보 등록
        saveWorkflowHistory(
                workflowReqDto,
                ossDto,
                ossTypeDto,
                "script",
                workflowReqDto.getWorkflowInfo().getScript(),
                "root",
                null);

        for(WorkflowParamDto paramDto : workflowReqDto.getWorkflowParams()) {
            saveWorkflowHistory(
                workflowReqDto,
                ossDto,
                ossTypeDto,
                "paramKey",
                paramDto.getParamKey(),
                "root",
                null);

            saveWorkflowHistory(
                workflowReqDto,
                ossDto,
                ossTypeDto,
                "paramValue",
                paramDto.getParamValue(),
                "root",
                null);
        }

        // Jenkins Job 실행 대기
        BuildInfo buildInfo = jenkinsService.waitJenkinsBuild(ossDto, workflowReqDto.getWorkflowInfo().getWorkflowName(), jenkinsBuildId, buildNumber);
        log.info("BuildInfo ==> {}", buildInfo.toString());

        // TODO : 실행후 액션 필요 (기존 : History에 결과값 추가)
        saveWorkflowHistory(
            workflowReqDto,
            ossDto,
            ossTypeDto,
            "result",
            buildInfo.result(),
            "root",
            null);

        // 빌드 실행 결과 확인
        WorkflowRunHistoryResDto jenkinsBuildHistory = jenkinsService.getJenkinsBuildStage(ossDto, workflowReqDto.getWorkflowInfo().getWorkflowName(), buildInfo.number());
        if("SUCCESS".equals(jenkinsBuildHistory.getStatus().toUpperCase()))
            return true;
        else
            return false;
    }

    /**
     * 젠킨스 파이프라인 목록 (빌드 시 사용할 파이프라인 목록)
     * @return
     */
    @Override
    public List<WorkflowStageTypeAndStageNameResDto> getWorkflowStageList() {

        List<WorkflowStageTypeDto> workflowStageTypeDtoList = workflowStageTypeRepository.findAll()
                                                                .stream()
                                                                .map(WorkflowStageTypeDto::from)
                                                                .collect(Collectors.toList());

        List<WorkflowStageTypeAndStageNameResDto> result = new ArrayList<>();

        workflowStageTypeDtoList.forEach(type -> {
            List<WorkflowStageDto> workflowStageDtoList = workflowStageRepository.findByWorkflowStageType(WorkflowStageTypeDto.toEntity(type))
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
     * @param ossTypeDto
     * @param ossDto
     */
    public void createJenkinsJob(OssTypeDto ossTypeDto, OssDto ossDto) {
        try {
            // OSS 를 등록을 할때 존재하지 않을 경우 Jenkins Job 자동 생성
            if(ossTypeDto.getOssTypeName().toUpperCase().equals("JENKINS")) {
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

    /**
     * WorkflowHistory 저장
     * @param workflowReqDto
     * @param ossDto
     * @param ossTypeDto
     * @param dataType
     * @param data
     */
    private void saveWorkflowHistory(WorkflowReqDto workflowReqDto, OssDto ossDto, OssTypeDto ossTypeDto, String dataType, String data, String userId, LocalDateTime date) {
        WorkflowHistory workflowHistoryEntity = WorkflowHistoryDto.buildEntity(
                workflowReqDto.getWorkflowInfo(),
                ossDto,
                ossTypeDto,
                dataType,
                data,
                userId,
                date
        );
        workflowHistoryRepository.save(workflowHistoryEntity);
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
}
