package kr.co.mcmp.workflow.service;

import com.cdancy.jenkins.rest.domain.job.BuildInfo;
import kr.co.mcmp.workflow.dto.resDto.WorkflowListResDto;
import kr.co.mcmp.workflow.service.jenkins.JenkinsPipelineGeneratorService;
import kr.co.mcmp.workflow.service.jenkins.service.JenkinsService;
import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.oss.repository.OssRepository;
import kr.co.mcmp.oss.repository.OssTypeRepository;
import kr.co.mcmp.workflow.Entity.Workflow;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowHistoryDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowParamDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowStageMappingDto;
import kr.co.mcmp.workflow.dto.reqDto.WorkflowReqDto;
import kr.co.mcmp.workflow.dto.resDto.WorkflowDetailResDto;
import kr.co.mcmp.workflow.dto.resDto.WorkflowStageTypeAndStageNameResDto;
import kr.co.mcmp.workflow.repository.WorkflowHistoryRepository;
import kr.co.mcmp.workflow.repository.WorkflowParamRepository;
import kr.co.mcmp.workflow.repository.WorkflowRepository;
import kr.co.mcmp.workflow.repository.WorkflowStageMappingRepository;
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
import java.util.*;
import java.util.stream.Collectors;

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

    private final JenkinsService jenkinsService;

    private final WorkflowStageTypeRepository workflowStageTypeRepository;

    private final WorkflowStageRepository workflowStageRepository;

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

            WorkflowDto workflowDto = WorkflowDto.from(workflowRepository.findByWorkflowIdx(workflow.getWorkflowIdx()));

            List<WorkflowParamDto> paramList =
                    workflowParamRepository.findByWorkflow_WorkflowIdx(workflow.getWorkflowIdx()).stream()
                            .map(WorkflowParamDto::from)
                            .collect(Collectors.toList());

            List<WorkflowStageMappingDto> stageList =
                    workflowStageMappingRepository.findByWorkflow_WorkflowIdx(workflow.getWorkflowIdx()).stream()
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
        try {
            // jenkins 정보 조회
            OssDto ossDto = OssDto.from(ossRepository.findByOssIdx(workflowReqDto.getWorkflowInfo().getOssIdx()));

            // jenkins > job 생성
            boolean isCreate = jenkinsService.createJenkinsJob_v2(
                    ossDto,
                    workflowReqDto.getWorkflowInfo().getWorkflowName(),
                    workflowReqDto.getWorkflowInfo().getScript(),
                    workflowReqDto.getWorkflowParams());

            // DB
            if ( isCreate ) {
                OssTypeDto ossTypeDto = OssTypeDto.from(ossTypeRepository.findByOssTypeIdx(ossDto.getOssTypeIdx()));
                // 1. Workflow
                Workflow workflow = workflowRepository.save(WorkflowDto.toEntity(workflowReqDto.getWorkflowInfo(), ossDto, ossTypeDto));

                // 2. Workflow Param
                workflowReqDto.getWorkflowParams().forEach(param -> {
                    workflowParamRepository.save(WorkflowParamDto.toEntity(param, WorkflowDto.from(workflow), ossDto, ossTypeDto));
                });

                // 3. Workflow Stage Mapping
                if ( !CollectionUtils.isEmpty(workflowReqDto.getWorkflowStageMappings()) ) {
                    workflowReqDto.getWorkflowStageMappings().forEach(stage -> {
                        workflowStageMappingRepository.save(WorkflowStageMappingDto.toEntity(stage, WorkflowDto.from(workflow), ossDto, ossTypeDto));
                    });
                }

                result = workflow.getWorkflowIdx();

            }
        } catch (IOException e) {
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
            OssDto ossDto = OssDto.from(ossRepository.findByOssIdx(workflowReqDto.getWorkflowInfo().getOssIdx()));

            boolean isUpdate = jenkinsService.updateJenkinsJobPipeline_v2(
                    ossDto,
                    workflowReqDto.getWorkflowInfo().getWorkflowName(),
                    workflowReqDto.getWorkflowInfo().getScript(),
                    workflowReqDto.getWorkflowParams());

            if ( isUpdate ) {
                OssTypeDto ossTypeDto = OssTypeDto.from(ossTypeRepository.findByOssTypeIdx(ossDto.getOssTypeIdx()));
                // 1. Workflow
                Workflow workflow = workflowRepository.save(WorkflowDto.toEntity(workflowReqDto.getWorkflowInfo(), ossDto, ossTypeDto));

                // 2. Workflow Param (삭제 후 재등록)
                workflowReqDto.getWorkflowParams().forEach(param -> {
                    workflowParamRepository.deleteByWorkflow_WorkflowIdx(workflow.getWorkflowIdx());
                });
                workflowReqDto.getWorkflowParams().forEach(param -> {
                    workflowParamRepository.save(WorkflowParamDto.toEntity(param, WorkflowDto.from(workflow), ossDto, ossTypeDto));
                });

                // 3. Workflow Stage Mapping (삭제 후 재등록)
                if ( !CollectionUtils.isEmpty(workflowReqDto.getWorkflowStageMappings()) ) {
                    workflowReqDto.getWorkflowStageMappings().forEach(stage -> {
                        workflowStageMappingRepository.deleteByWorkflow_WorkflowIdx(workflow.getWorkflowIdx());
                    });
                    workflowReqDto.getWorkflowStageMappings().forEach(stage -> {
                        workflowStageMappingRepository.save(WorkflowStageMappingDto.toEntity(stage, WorkflowDto.from(workflow), ossDto, ossTypeDto));
                    });
                }

                result = true;
            }
        } catch (UnsupportedEncodingException uee) {
            log.error(uee.getMessage());
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

        // Jenkins 삭제
        WorkflowDto workflowDto = WorkflowDto.from(workflowRepository.findByWorkflowIdx(workflowIdx));
        OssDto jenkins = OssDto.from(ossRepository.findByOssIdx(workflowDto.getOssIdx()));
        boolean isDelete = jenkinsService.deleteJenkinsJob(jenkins, workflowDto.getWorkflowName());

//        TODO : 관련테이블 삭제 필요
        if ( isDelete ) {
            // 1. Workflow Stage Mapping
            workflowStageMappingRepository.deleteByWorkflow_WorkflowIdx(workflowIdx);

            // 2. Workflow Param
            workflowParamRepository.deleteByWorkflow_WorkflowIdx(workflowIdx);

            // 3. Workflow
            workflowRepository.deleteByWorkflowIdx(workflowIdx);

            result = true;
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
        WorkflowDto workflowDto = WorkflowDto.from(workflowRepository.findByWorkflowIdx(workflowIdx));

        List<WorkflowParamDto> paramList =
                workflowParamRepository.findByWorkflow_WorkflowIdx(workflowIdx).stream()
                    .map(WorkflowParamDto::from)
                    .collect(Collectors.toList());

        List<WorkflowStageMappingDto> stageList =
                workflowStageMappingRepository.findByWorkflow_WorkflowIdx(workflowIdx).stream()
                    .map(WorkflowStageMappingDto::from)
                    .collect(Collectors.toList());

        WorkflowDetailResDto workflowDetail = WorkflowDetailResDto.of(workflowDto, paramList, stageList);

        return workflowDetail;
    }

    /**
     * 워크플로우명 중복 체크
     * @param workflowName
     * @return
     */
    @Override
    public Boolean isWorkflowNameDuplicated(String workflowName) {
        Workflow workflow = workflowRepository.findByWorkflowName(workflowName);
        if (StringUtils.isEmpty(workflow))
            return false;
        else
            return true;
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
        WorkflowDto workflowDto = WorkflowDto.from(workflowRepository.findByWorkflowIdx(workflowIdx));

        List<WorkflowParamDto> paramList =
                workflowParamRepository.findByWorkflow_WorkflowIdx(workflowIdx).stream()
                        .map(WorkflowParamDto::from)
                        .collect(Collectors.toList());

        List<WorkflowStageMappingDto> stageList =
                workflowStageMappingRepository.findByWorkflow_WorkflowIdx(workflowIdx).stream()
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
            workflowReqDto.getWorkflowParams().forEach(param-> {
                List<String> valueList = new ArrayList<>();
                valueList.add(param.getParamValue());
                finalJenkinsJobParams.put(param.getParamKey(), valueList);
            });
            jenkinsJobParams = finalJenkinsJobParams;
        }

        // OSS 접속 정보 조회
        OssTypeDto ossTypeDto = OssTypeDto.from(ossTypeRepository.findByOssTypeIdx(workflowReqDto.getWorkflowInfo().getOssIdx()));
        OssDto ossDto = OssDto.from(ossRepository.findByOssIdx(workflowReqDto.getWorkflowInfo().getOssIdx()));

        // Jenkins Job 실행
        int jenkinsBuildId = jenkinsService.buildJenkinsJob(ossDto, workflowReqDto.getWorkflowInfo().getWorkflowName(), jenkinsJobParams);
        int buildNumber = jenkinsService.getQueueExecutableNumber(ossDto, jenkinsBuildId);

        // 배포 이력 정보 등록
        workflowHistoryRepository.save(WorkflowHistoryDto.buildEntity(workflowReqDto.getWorkflowInfo(), ossDto, ossTypeDto, workflowReqDto.getWorkflowInfo().getScript(), "root", null));


        // Jenkins Job 실행 대기
        BuildInfo buildInfo = jenkinsService.waitJenkinsBuild(ossDto, workflowReqDto.getWorkflowInfo().getWorkflowName(), jenkinsBuildId, buildNumber);
        log.info("BuildInfo ==> {}", buildInfo.toString());
        // TODO : 실행후 액션 필요 (기존 : History에 결과값 추가)

        return true;
    }

    /**
     * 젠킨스 파이프라인 목록 (빌드 시 사용할 파이프라인 목록)
     * @return
     */
    @Override
    public List<WorkflowStageTypeAndStageNameResDto> getWorkflowStageList() {

        List<WorkflowStageTypeDto> workflowStageTypeDtoList =
                workflowStageTypeRepository.findAll().stream()
                .map(WorkflowStageTypeDto::from)
                .collect(Collectors.toList());

        List<WorkflowStageTypeAndStageNameResDto> result = new ArrayList<>();
        workflowStageTypeDtoList.forEach(type -> {
            List<WorkflowStageDto> workflowStageDtoList =
                    workflowStageRepository.findByWorkflowStageType(WorkflowStageTypeDto.toEntity(type)).stream()
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

    @Override
    public List<WorkflowHistoryDto> getWorkflowHistoryList(Long workflowIdx) {
        return workflowHistoryRepository.findByWorkflow_WorkflowIdx(workflowIdx)
                .stream()
                .map(WorkflowHistoryDto::from)
                .collect(Collectors.toList());
    }

    @Override
    public List<WorkflowParamDto> getWorkflowParamList() {
        return workflowParamRepository.findAll().stream()
                .map(WorkflowParamDto::from)
                .collect(Collectors.toList());
    }
}
