package kr.co.mcmp.workflow.service;

import com.cdancy.jenkins.rest.domain.job.BuildInfo;
import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.oss.entity.Oss;
import kr.co.mcmp.oss.entity.OssType;
import kr.co.mcmp.oss.repository.OssRepository;
import kr.co.mcmp.oss.repository.OssTypeRepository;
import kr.co.mcmp.workflow.Entity.WorkflowHistory;
import kr.co.mcmp.workflow.Entity.Workflow;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowHistoryDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowParamDto;
import kr.co.mcmp.workflow.dto.reqDto.WorkflowReqDto;
import kr.co.mcmp.workflow.dto.resDto.WorkflowRunHistoryResDto;
import kr.co.mcmp.workflow.repository.WorkflowHistoryRepository;
import kr.co.mcmp.workflow.repository.WorkflowRepository;
import kr.co.mcmp.workflow.service.jenkins.service.JenkinsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@Service
public class WorkflowAsyncExecutor {

    private final OssRepository ossRepository;

    private final OssTypeRepository ossTypeRepository;

    private final WorkflowHistoryRepository workflowHistoryRepository;

    private final WorkflowRepository workflowRepository;

    private final JenkinsService jenkinsService;

    @Async("workflowTaskExecutor")
    public void runWorkflow(WorkflowReqDto workflowReqDto) {
        try {
            runWorkflowCallback(workflowReqDto);
        } catch (Exception e) {
            updateWorkflowRunStatus(workflowReqDto, "FAILED", null);
            log.error("Workflow async run failed. workflowIdx: {}, workflowName: {}",
                    workflowReqDto.getWorkflowInfo() != null ? workflowReqDto.getWorkflowInfo().getWorkflowIdx() : null,
                    workflowReqDto.getWorkflowInfo() != null ? workflowReqDto.getWorkflowInfo().getWorkflowName() : null,
                    e);
        }
    }

    public Boolean runWorkflowCallback(WorkflowReqDto workflowReqDto) {
        Map<String, List<String>> jenkinsJobParams = null;

        if (!CollectionUtils.isEmpty(workflowReqDto.getWorkflowParams())) {
            Map<String, List<String>> finalJenkinsJobParams = new HashMap<>();

            for (WorkflowParamDto param : workflowReqDto.getWorkflowParams()) {
                finalJenkinsJobParams.put(param.getParamKey(), Arrays.asList(param.getParamValue()));
            }

            jenkinsJobParams = finalJenkinsJobParams;
        }

        OssDto ossDto = getOssDto(workflowReqDto.getWorkflowInfo().getOssIdx());
        OssTypeDto ossTypeDto = getOssTypeDto(ossDto.getOssTypeIdx());

        int jenkinsBuildId = jenkinsService.buildJenkinsJob(ossDto, workflowReqDto.getWorkflowInfo().getWorkflowName(), jenkinsJobParams);
        int buildNumber = jenkinsService.getQueueExecutableNumber(ossDto, jenkinsBuildId);
        updateWorkflowRunStatus(workflowReqDto, "IN_PROGRESS", buildNumber);

        saveWorkflowHistory(
                workflowReqDto,
                ossDto,
                ossTypeDto,
                "script",
                workflowReqDto.getWorkflowInfo().getScript(),
                "root",
                null);

        if (!CollectionUtils.isEmpty(workflowReqDto.getWorkflowParams())) {
            for (WorkflowParamDto paramDto : workflowReqDto.getWorkflowParams()) {
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
        }

        BuildInfo buildInfo = jenkinsService.waitJenkinsBuild(ossDto, workflowReqDto.getWorkflowInfo().getWorkflowName(), jenkinsBuildId, buildNumber);
        log.info("BuildInfo ==> {}", buildInfo.toString());
        updateWorkflowRunStatus(workflowReqDto, buildInfo.result(), buildInfo.number());

        saveWorkflowHistory(
                workflowReqDto,
                ossDto,
                ossTypeDto,
                "result",
                buildInfo.result(),
                "root",
                null);

        WorkflowRunHistoryResDto jenkinsBuildHistory = jenkinsService.getJenkinsBuildStage(ossDto, workflowReqDto.getWorkflowInfo().getWorkflowName(), buildInfo.number());
        return "SUCCESS".equals(jenkinsBuildHistory.getStatus().toUpperCase());
    }

    private void updateWorkflowRunStatus(WorkflowReqDto workflowReqDto, String status, Integer buildNumber) {
        if (workflowReqDto.getWorkflowInfo() == null || workflowReqDto.getWorkflowInfo().getWorkflowIdx() == null) {
            return;
        }

        Workflow workflow = workflowRepository.findByWorkflowIdx(workflowReqDto.getWorkflowInfo().getWorkflowIdx());
        if (workflow == null) {
            return;
        }

        workflow.updateRunStatus(status, buildNumber != null ? buildNumber : workflow.getLatestBuildNumber());
        workflowRepository.save(workflow);
    }

    private OssTypeDto getOssTypeDto(Long ossTypeIdx) {
        OssType ossType = ossTypeRepository.findByOssTypeIdx(ossTypeIdx);
        return OssTypeDto.from(ossType);
    }

    private OssDto getOssDto(Long ossIdx) {
        Oss ossEntity = ossRepository.findByOssIdx(ossIdx);
        return OssDto.from(ossEntity);
    }

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
}
