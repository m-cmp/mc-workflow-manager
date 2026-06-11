package kr.co.mcmp.workflow.service;

import com.cdancy.jenkins.rest.domain.job.BuildInfo;
import kr.co.mcmp.exception.McmpException;
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
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowDto;
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
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.LinkedHashMap;
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
            saveFailureWorkflowHistory(workflowReqDto, e);
            log.error("Workflow async run failed. workflowIdx: {}, workflowName: {}",
                    getWorkflowIdx(workflowReqDto),
                    getWorkflowName(workflowReqDto),
                    e);
        }
    }

    public Boolean runWorkflowCallback(WorkflowReqDto workflowReqDto) {
        Map<String, List<String>> jenkinsJobParams = null;
        List<WorkflowParamDto> workflowParams = normalizeWorkflowParams(workflowReqDto.getWorkflowParams());

        if (!CollectionUtils.isEmpty(workflowParams)) {
            Map<String, List<String>> finalJenkinsJobParams = new HashMap<>();

            for (WorkflowParamDto param : workflowParams) {
                finalJenkinsJobParams.put(param.getParamKey(), Arrays.asList(param.getParamValue()));
            }

            jenkinsJobParams = finalJenkinsJobParams;
        }

        OssDto ossDto = getOssDto(workflowReqDto.getWorkflowInfo().getOssIdx());
        OssTypeDto ossTypeDto = getOssTypeDto(ossDto.getOssTypeIdx());

        saveWorkflowRequestHistory(workflowReqDto, workflowParams, ossDto, ossTypeDto);

        String workflowName = workflowReqDto.getWorkflowInfo().getWorkflowName();
        int expectedBuildNumber = getExpectedBuildNumber(ossDto, workflowName);
        if (expectedBuildNumber <= 0) {
            expectedBuildNumber = getExpectedBuildNumber(ossDto, workflowName);
        }

        int jenkinsBuildId = updateAndBuildJenkinsJobForRun(workflowReqDto, workflowParams, ossDto, jenkinsJobParams);
        int buildNumber = jenkinsService.getQueueExecutableNumber(ossDto, jenkinsBuildId, expectedBuildNumber);
        updateWorkflowRunStatus(workflowReqDto, "IN_PROGRESS", buildNumber);


        BuildInfo buildInfo = jenkinsService.waitJenkinsBuild(ossDto, workflowReqDto.getWorkflowInfo().getWorkflowName(), jenkinsBuildId, buildNumber);
        log.info("BuildInfo ==> {}", buildInfo.toString());
        String finalStatus = StringUtils.hasText(buildInfo.result()) ? buildInfo.result() : "UNKNOWN";
        updateWorkflowRunStatus(workflowReqDto, finalStatus, buildInfo.number());

        saveWorkflowHistory(
                workflowReqDto,
                ossDto,
                ossTypeDto,
                "result",
                finalStatus,
                "root",
                null);

        try {
            WorkflowRunHistoryResDto jenkinsBuildHistory = jenkinsService.getJenkinsBuildStage(ossDto, workflowReqDto.getWorkflowInfo().getWorkflowName(), buildInfo.number());
            return jenkinsBuildHistory != null && "SUCCESS".equalsIgnoreCase(jenkinsBuildHistory.getStatus());
        } catch (Exception e) {
            log.warn("Jenkins workflow stage history lookup failed after build finished. workflowName: {}, buildNumber: {}",
                    workflowReqDto.getWorkflowInfo().getWorkflowName(), buildInfo.number(), e);
            return "SUCCESS".equalsIgnoreCase(finalStatus);
        }
    }

    private void saveWorkflowRequestHistory(WorkflowReqDto workflowReqDto, List<WorkflowParamDto> workflowParams, OssDto ossDto, OssTypeDto ossTypeDto) {
        saveWorkflowHistory(
                workflowReqDto,
                ossDto,
                ossTypeDto,
                "script",
                workflowReqDto.getWorkflowInfo().getScript(),
                "root",
                null);

        if (!CollectionUtils.isEmpty(workflowParams)) {
            for (WorkflowParamDto paramDto : workflowParams) {
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
    }

    private void synchronizeJenkinsJobForRun(WorkflowReqDto workflowReqDto, List<WorkflowParamDto> workflowParams, OssDto ossDto) {
        String workflowName = workflowReqDto.getWorkflowInfo().getWorkflowName();
        String pipelineScript = workflowReqDto.getWorkflowInfo().getScript();

        try {
            if (jenkinsService.isExistJobName(ossDto, workflowName)) {
                jenkinsService.updateJenkinsJobPipeline_v2(ossDto, workflowName, pipelineScript, workflowParams);
            } else {
                jenkinsService.createJenkinsJob_v2(ossDto, workflowName, pipelineScript, workflowParams);
            }
            log.info("Jenkins Job synchronized before run. workflowName: {}", workflowName);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to synchronize Jenkins Job before workflow run: " + workflowName, e);
        }
    }

    private int updateAndBuildJenkinsJobForRun(WorkflowReqDto workflowReqDto,
                                               List<WorkflowParamDto> workflowParams,
                                               OssDto ossDto,
                                               Map<String, List<String>> jenkinsJobParams) {
        String workflowName = workflowReqDto.getWorkflowInfo().getWorkflowName();
        String pipelineScript = workflowReqDto.getWorkflowInfo().getScript();

        try {
            int queueId = jenkinsService.updateAndBuildJenkinsJobForRun(
                    ossDto,
                    workflowName,
                    pipelineScript,
                    workflowParams,
                    jenkinsJobParams);
            log.info("Jenkins Job synchronized and build requested before stale overwrite window. workflowName: {}, queueId: {}",
                    workflowName, queueId);
            return queueId;
        } catch (IOException e) {
            throw new IllegalStateException("Failed to synchronize/build Jenkins Job before workflow run: " + workflowName, e);
        }
    }

    private int getExpectedBuildNumber(OssDto ossDto, String workflowName) {
        try {
            return jenkinsService.getNextBuildNumber(ossDto, workflowName);
        } catch (Exception e) {
            log.warn("Jenkins next build number lookup failed. workflowName: {}", workflowName, e);
            return 0;
        }
    }

    private List<WorkflowParamDto> normalizeWorkflowParams(List<WorkflowParamDto> workflowParams) {
        if (CollectionUtils.isEmpty(workflowParams)) {
            return List.of();
        }

        Map<String, WorkflowParamDto> paramsByKey = new LinkedHashMap<>();
        for (WorkflowParamDto param : workflowParams) {
            if (param == null || !StringUtils.hasText(param.getParamKey())) {
                continue;
            }

            String normalizedKey = param.getParamKey().trim().toUpperCase();
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

    private void saveFailureWorkflowHistory(WorkflowReqDto workflowReqDto, Exception e) {
        try {
            if (workflowReqDto == null || workflowReqDto.getWorkflowInfo() == null || workflowReqDto.getWorkflowInfo().getWorkflowIdx() == null) {
                return;
            }

            Workflow workflow = workflowRepository.findByWorkflowIdx(workflowReqDto.getWorkflowInfo().getWorkflowIdx());
            if (workflow == null || workflow.getOss() == null || workflow.getOss().getOssType() == null) {
                return;
            }

            WorkflowDto workflowDto = WorkflowDto.from(workflow);
            OssDto ossDto = OssDto.from(workflow.getOss());
            OssTypeDto ossTypeDto = OssTypeDto.from(workflow.getOss().getOssType());
            WorkflowReqDto historyReqDto = WorkflowReqDto.of(workflowDto, List.of(), List.of());

            saveWorkflowHistory(historyReqDto, ossDto, ossTypeDto, "result", "FAILED", "root", null);
            saveWorkflowHistory(historyReqDto, ossDto, ossTypeDto, "error", buildFailureMessage(e), "root", null);
        } catch (Exception historyException) {
            log.warn("Failed to save workflow failure history. workflowIdx: {}",
                    workflowReqDto != null && workflowReqDto.getWorkflowInfo() != null
                            ? workflowReqDto.getWorkflowInfo().getWorkflowIdx()
                            : null,
                    historyException);
        }
    }

    private String buildFailureMessage(Exception e) {
        if (e instanceof McmpException mcmpException) {
            StringBuilder message = new StringBuilder(e.getClass().getSimpleName());
            if (mcmpException.getResponseCode() != null) {
                message.append("[")
                        .append(mcmpException.getResponseCode().getCode())
                        .append(" ")
                        .append(mcmpException.getResponseCode().getMessage())
                        .append("]");
            }
            if (StringUtils.hasText(mcmpException.getDetail())) {
                message.append(": ").append(mcmpException.getDetail());
            }

            String failureMessage = message.toString();
            return failureMessage.length() > 4000 ? failureMessage.substring(0, 4000) : failureMessage;
        }

        StringBuilder message = new StringBuilder(e.getClass().getSimpleName());
        if (StringUtils.hasText(e.getMessage())) {
            message.append(": ").append(e.getMessage());
        }

        Throwable cause = e.getCause();
        if (cause != null) {
            message.append("\nCaused by: ").append(cause.getClass().getSimpleName());
            if (StringUtils.hasText(cause.getMessage())) {
                message.append(": ").append(cause.getMessage());
            }
        }

        String failureMessage = message.toString();
        return failureMessage.length() > 4000 ? failureMessage.substring(0, 4000) : failureMessage;
    }

    private Long getWorkflowIdx(WorkflowReqDto workflowReqDto) {
        return workflowReqDto != null && workflowReqDto.getWorkflowInfo() != null
                ? workflowReqDto.getWorkflowInfo().getWorkflowIdx()
                : null;
    }

    private String getWorkflowName(WorkflowReqDto workflowReqDto) {
        return workflowReqDto != null && workflowReqDto.getWorkflowInfo() != null
                ? workflowReqDto.getWorkflowInfo().getWorkflowName()
                : null;
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
