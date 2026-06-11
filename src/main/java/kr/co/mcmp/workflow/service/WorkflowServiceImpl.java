package kr.co.mcmp.workflow.service;

import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.oss.dto.OssTypeDto;
import kr.co.mcmp.oss.entity.Oss;
import kr.co.mcmp.oss.entity.OssType;
import kr.co.mcmp.oss.repository.OssRepository;
import kr.co.mcmp.oss.repository.OssTypeRepository;
import kr.co.mcmp.eventListener.repository.EventListenerRepository;
import kr.co.mcmp.api.response.ResponseCode;
import kr.co.mcmp.exception.McmpException;
import kr.co.mcmp.infraManager.service.McInfraManagerService;
import kr.co.mcmp.workflow.Entity.Workflow;
import kr.co.mcmp.workflow.Entity.WorkflowHistory;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowHistoryDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowParamDto;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowStageMappingDto;
import kr.co.mcmp.workflow.dto.reqDto.WorkflowReqDto;
import kr.co.mcmp.workflow.dto.resDto.*;
import kr.co.mcmp.workflowStage.Entity.WorkflowStage;
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

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Slf4j
@RequiredArgsConstructor
@Service
public class WorkflowServiceImpl implements WorkflowService {

    private static final int MAX_JENKINS_BUILD_LOOKUP_COUNT = 200;
    private static final Set<String> WORKFLOW_STAGE_CATEGORIES = Set.of(
            "infra",
            "k8s",
            "app",
            "database",
            "utility"
    );

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

    private final McInfraManagerService mcInfraManagerService;

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
            String status = StringUtils.hasText(workflowDto.getStatus()) ? workflowDto.getStatus() : "-";
            workflowDto = WorkflowDto.ofWithStatus(workflowDto, status);

            List<WorkflowParamDto> paramList =
                    workflowParamRepository.findByWorkflow_WorkflowIdx(workflow.getWorkflowIdx())
                                            .stream()
                                            .map(WorkflowParamDto::from)
                                            .collect(Collectors.toList());

            List<WorkflowStageMappingDto> stageList = getCurrentWorkflowStageMappingDtos(workflow.getWorkflowIdx());
            workflowDto = workflowDtoWithScript(workflowDto, stageList);

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
        List<WorkflowParamDto> workflowParams = sanitizeWorkflowParams(workflowReqDto.getWorkflowParams());
        List<WorkflowStageMappingDto> workflowStageMappings = defaultWorkflowStageMappings(workflowReqDto.getWorkflowStageMappings());

        // jenkins 정보 조회
        OssDto ossDto = getOssDto(workflowReqDto.getWorkflowInfo().getOssIdx());

        try {
            if (workflowRepository.findByWorkflowName(workflowReqDto.getWorkflowInfo().getWorkflowName()) != null) {
                log.warn("Workflow name already exists: {}", workflowReqDto.getWorkflowInfo().getWorkflowName());
                return null;
            }

            // DB
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
            List<WorkflowStageMappingDto> currentStageMappings = getCurrentWorkflowStageMappingDtos(workflowEntity.getWorkflowIdx());
            workflowDto = workflowDtoWithScript(workflowDto, currentStageMappings);

            synchronizeJenkinsJobIfAvailable(
                    ossDto,
                    workflowDto.getWorkflowName(),
                    workflowDto.getScript(),
                    workflowParams);

            result = workflowEntity.getWorkflowIdx();
        } catch (Exception e) {
            log.error(e.getMessage(), e);
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
            Workflow previousWorkflow = workflowRepository.findByWorkflowIdx(workflowReqDto.getWorkflowInfo().getWorkflowIdx());
            if (previousWorkflow == null) {
                return false;
            }

            Workflow duplicatedWorkflow = workflowRepository.findByWorkflowName(workflowReqDto.getWorkflowInfo().getWorkflowName());
            if (duplicatedWorkflow != null && !duplicatedWorkflow.getWorkflowIdx().equals(workflowReqDto.getWorkflowInfo().getWorkflowIdx())) {
                log.warn("Workflow name already exists: {}", workflowReqDto.getWorkflowInfo().getWorkflowName());
                return false;
            }

            OssTypeDto ossTypeDto = getOssTypeDto(ossDto.getOssTypeIdx());

            // 1. Workflow
            Workflow workflowEntity = WorkflowDto.toEntity(workflowReqDto.getWorkflowInfo(), ossDto, ossTypeDto);
            if (workflowEntity.getRunDate() == null) {
                workflowEntity.updateRunDate(previousWorkflow.getRunDate());
            }
            if (workflowEntity.getRunStatus() == null) {
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
            List<WorkflowStageMappingDto> currentStageMappings = getCurrentWorkflowStageMappingDtos(workflowEntity.getWorkflowIdx());
            workflowDto = workflowDtoWithScript(workflowDto, currentStageMappings);

            synchronizeJenkinsJobIfAvailable(
                    ossDto,
                    workflowDto.getWorkflowName(),
                    workflowDto.getScript(),
                    workflowParams);

            result = true;
            deleteRenamedJenkinsJob(ossDto, previousWorkflow.getWorkflowName(), workflowEntity.getWorkflowName());
        } catch (Exception e) {
            log.error(e.getMessage(), e);
        }
        return result;
    }

    private boolean synchronizeJenkinsJobIfAvailable(OssDto ossDto, String workflowName, String script, List<WorkflowParamDto> workflowParams) {
        try {
            if (!jenkinsService.isJenkinsConnect(ossDto)) {
                log.warn("Jenkins job synchronization skipped. Jenkins is not reachable. workflowName: {}", workflowName);
                return false;
            }

            if (jenkinsService.isExistJobName(ossDto, workflowName)) {
                return jenkinsService.updateJenkinsJobPipeline_v2(ossDto, workflowName, script, workflowParams);
            }

            return jenkinsService.createJenkinsJob_v2(ossDto, workflowName, script, workflowParams);
        } catch (Exception e) {
            log.warn("Jenkins job synchronization failed. workflowName: {}", workflowName, e);
            return false;
        }
    }

    private void deleteRenamedJenkinsJob(OssDto ossDto, String previousWorkflowName, String currentWorkflowName) {
        if (!StringUtils.hasText(previousWorkflowName)
                || !StringUtils.hasText(currentWorkflowName)
                || previousWorkflowName.equals(currentWorkflowName)) {
            return;
        }

        deleteJenkinsJobIfAvailable(ossDto, previousWorkflowName);
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

            Workflow workflowEntity = workflowRepository.findByWorkflowIdx(workflowIdx);
            if (workflowEntity == null) {
                return false;
            }
            WorkflowDto workflowDto = WorkflowDto.from(workflowEntity);
            OssDto ossDto = getOssDto(workflowDto.getOssIdx());
            deleteJenkinsJobIfAvailable(ossDto, workflowDto.getWorkflowName());

            // 1. Workflow Stage Mapping
            workflowStageMappingRepository.deleteByWorkflow_WorkflowIdx(workflowIdx);

            // 2. Workflow Param
            workflowParamRepository.deleteByWorkflow_WorkflowIdx(workflowIdx);

            // 3. Workflow
            workflowRepository.deleteByWorkflowIdx(workflowIdx);

            result = true;
        } catch (Exception e) {
            log.error(e.getMessage());
        }

        return result;
    }

    private void deleteJenkinsJobIfAvailable(OssDto ossDto, String workflowName) {
        try {
            if (!jenkinsService.isJenkinsConnect(ossDto)) {
                log.warn("Jenkins job delete skipped. Jenkins is not reachable. workflowName: {}", workflowName);
                return;
            }
            jenkinsService.deleteJenkinsJob(ossDto, workflowName);
        } catch (Exception e) {
            log.warn("Jenkins job delete failed. workflowName: {}", workflowName, e);
        }
    }

    @Override
    public Boolean existEventListener(Long workflowIdx) {
        if (workflowIdx == null || workflowIdx == 0) {
            return false;
        }
        return eventListenerRepository.existsByWorkflow_WorkflowIdx(workflowIdx);
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
            if (workflowDto == null) {
                return null;
            }

                    List<WorkflowParamDto> paramList = workflowParamRepository.findByWorkflow_WorkflowIdx(workflowIdx)
                    .stream()
                    .map(WorkflowParamDto::from)
                    .collect(Collectors.toList());

            List<WorkflowStageMappingDto> stageList = getCurrentWorkflowStageMappingDtos(workflowIdx);
            workflowDto = workflowDtoWithScript(workflowDto, stageList);

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
        WorkflowDto workflowDto = getWorkflowDto(workflowIdx);
        if (workflowDto == null) {
            return false;
        }

        List<WorkflowParamDto> paramList = workflowParamRepository.findByWorkflow_WorkflowIdx(workflowIdx)
                                            .stream()
                                            .map(WorkflowParamDto::from)
                                            .collect(Collectors.toList());

        List<WorkflowStageMappingDto> stageList = getCurrentWorkflowStageMappingDtos(workflowIdx);
        workflowDto = workflowDtoWithScript(workflowDto, stageList);

        WorkflowReqDto workflowReqDto = WorkflowReqDto.of(workflowDto, paramList, stageList);

        validateInfraDynamicReviewBeforeRun(workflowReqDto);
        // 배포 실행 관련 사용자 이력 정보 수정
        updateWorkflowRunDate(workflowIdx);
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
        WorkflowReqDto runRequest = currentWorkflowRunRequest(workflowReqDto);
        validateInfraDynamicReviewBeforeRun(runRequest);
        if (runRequest.getWorkflowInfo() != null) {
            updateWorkflowRunDate(runRequest.getWorkflowInfo().getWorkflowIdx());
        }
        workflowAsyncExecutor.runWorkflow(runRequest);
        return true;
    }

    private WorkflowReqDto currentWorkflowRunRequest(WorkflowReqDto workflowReqDto) {
        if (workflowReqDto == null
                || workflowReqDto.getWorkflowInfo() == null
                || workflowReqDto.getWorkflowInfo().getWorkflowIdx() == null) {
            return workflowReqDto;
        }

        Long workflowIdx = workflowReqDto.getWorkflowInfo().getWorkflowIdx();
        Workflow workflow = workflowRepository.findByWorkflowIdx(workflowIdx);
        if (workflow == null) {
            return workflowReqDto;
        }

        WorkflowDto workflowDto = WorkflowDto.from(workflow);
        List<WorkflowStageMappingDto> stageList = getCurrentWorkflowStageMappingDtos(workflowIdx);
        workflowDto = workflowDtoWithScript(workflowDto, stageList);
        List<WorkflowParamDto> savedParams = workflowParamRepository.findByWorkflow_WorkflowIdx(workflowIdx)
                .stream()
                .map(WorkflowParamDto::from)
                .collect(Collectors.toList());
        List<WorkflowParamDto> requestedParams = sanitizeWorkflowParams(workflowReqDto.getWorkflowParams());
        List<WorkflowParamDto> runParams = mergeWorkflowParams(savedParams, requestedParams);

        return WorkflowReqDto.of(workflowDto, runParams, stageList);
    }

    private WorkflowDto workflowDtoWithScript(WorkflowDto workflowDto, List<WorkflowStageMappingDto> stageList) {
        String currentScript = buildScriptFromStageMappings(stageList);
        if (!StringUtils.hasText(currentScript)) {
            return workflowDto;
        }

        return WorkflowDto.builder()
                .workflowIdx(workflowDto.getWorkflowIdx())
                .workflowName(workflowDto.getWorkflowName())
                .workflowPurpose(workflowDto.getWorkflowPurpose())
                .ossIdx(workflowDto.getOssIdx())
                .script(currentScript)
                .status(workflowDto.getStatus())
                .runDate(workflowDto.getRunDate())
                .latestBuildNumber(workflowDto.getLatestBuildNumber())
                .build();
    }

    private String buildScriptFromStageMappings(List<WorkflowStageMappingDto> stageList) {
        if (CollectionUtils.isEmpty(stageList)) {
            return null;
        }

        String script = stageList.stream()
                .map(WorkflowStageMappingDto::getStageContent)
                .filter(StringUtils::hasText)
                .collect(Collectors.joining());

        return StringUtils.hasText(script) ? normalizeDeclarativePipelineScript(script) : null;
    }

    private String normalizeDeclarativePipelineScript(String script) {
        if (!StringUtils.hasText(script)) {
            return script;
        }

        String trimmedScript = script.trim();
        if (trimmedScript.contains("pipeline {") || !trimmedScript.contains("stage(")) {
            return script;
        }

        StringBuilder imports = new StringBuilder();
        StringBuilder stageBody = new StringBuilder();
        boolean stageBodyStarted = false;

        for (String line : trimmedScript.split("\\R", -1)) {
            if (!stageBodyStarted && line.trim().startsWith("import ")) {
                imports.append(line.trim()).append(System.lineSeparator());
                continue;
            }
            stageBodyStarted = true;
            stageBody.append(line).append(System.lineSeparator());
        }

        StringBuilder wrappedScript = new StringBuilder();
        if (!imports.isEmpty()) {
            wrappedScript.append(imports).append(System.lineSeparator());
        }
        wrappedScript.append("pipeline {").append(System.lineSeparator())
                .append("    agent any").append(System.lineSeparator())
                .append("    stages {").append(System.lineSeparator())
                .append(indentStageBody(stageBody.toString()))
                .append("    }").append(System.lineSeparator())
                .append("}").append(System.lineSeparator());

        return wrappedScript.toString();
    }

    private String indentStageBody(String stageBody) {
        String[] lines = stageBody.strip().split("\\R", -1);
        int minIndent = Arrays.stream(lines)
                .filter(StringUtils::hasText)
                .mapToInt(this::leadingWhitespaceCount)
                .min()
                .orElse(0);

        return Arrays.stream(lines)
                .map(line -> {
                    String normalizedLine = line.length() >= minIndent ? line.substring(minIndent) : line.stripLeading();
                    return StringUtils.hasText(normalizedLine) ? "    " + normalizedLine : "";
                })
                .collect(Collectors.joining(System.lineSeparator(), "", System.lineSeparator()));
    }

    private int leadingWhitespaceCount(String value) {
        int count = 0;
        while (count < value.length() && Character.isWhitespace(value.charAt(count))) {
            count++;
        }
        return count;
    }

    private List<WorkflowParamDto> mergeWorkflowParams(List<WorkflowParamDto> savedParams, List<WorkflowParamDto> requestedParams) {
        Map<String, WorkflowParamDto> paramsByKey = new LinkedHashMap<>();

        for (WorkflowParamDto param : sanitizeWorkflowParams(savedParams)) {
            paramsByKey.put(param.getParamKey(), param);
        }
        for (WorkflowParamDto param : sanitizeWorkflowParams(requestedParams)) {
            paramsByKey.put(param.getParamKey(), param);
        }

        return new ArrayList<>(paramsByKey.values());
    }

    private void validateInfraDynamicReviewBeforeRun(WorkflowReqDto workflowReqDto) {
        if (!needsInfraDynamicReview(workflowReqDto)) {
            return;
        }

        Map<String, Object> payload = buildInfraDynamicReviewPayload(workflowReqDto);
        if (payload.isEmpty()) {
            return;
        }

        Object reviewResult = mcInfraManagerService.reviewInfraDynamic(getParamValue(workflowReqDto, "NAMESPACE", "system"), null, payload);
        if (hasInfraReviewError(reviewResult)) {
            String message = getInfraReviewMessage(reviewResult);
            throw new McmpException(ResponseCode.RUN_FAILED_DEPLOY, "Infra 사전 검증 실패: " + message);
        }
    }

    private boolean needsInfraDynamicReview(WorkflowReqDto workflowReqDto) {
        if (workflowReqDto == null) {
            return false;
        }

        if (workflowReqDto.getWorkflowStageMappings() != null) {
            for (WorkflowStageMappingDto stage : workflowReqDto.getWorkflowStageMappings()) {
                String stageName = normalizeText(stage.getWorkflowStageName());
                String stageContent = normalizeText(stage.getStageContent());
                if ("infra-create".equals(stageName) || stageContent.contains("infra-create") || stageContent.contains("infraDynamic")) {
                    return true;
                }
            }
        }

        return StringUtils.hasText(getParamValue(workflowReqDto, "INFRA_ID", null))
                && StringUtils.hasText(getParamValue(workflowReqDto, "SPEC_ID", null))
                && StringUtils.hasText(getParamValue(workflowReqDto, "IMAGE_ID", null));
    }

    private Map<String, Object> buildInfraDynamicReviewPayload(WorkflowReqDto workflowReqDto) {
        List<Map<String, Object>> nodeGroups = new ArrayList<>();
        List<String> cspList = Arrays.stream(getParamValue(workflowReqDto, "CSP_LIST", "").split(","))
                .map(String::trim)
                .filter(StringUtils::hasText)
                .collect(Collectors.toList());

        if (cspList.isEmpty()) {
            Map<String, Object> nodeGroup = buildNodeGroupReviewPayload(workflowReqDto, "", getParamValue(workflowReqDto, "CSP", getParamValue(workflowReqDto, "PROVIDER", "")));
            if (!nodeGroup.isEmpty()) {
                nodeGroups.add(nodeGroup);
            }
        } else {
            for (String csp : cspList) {
                Map<String, Object> nodeGroup = buildNodeGroupReviewPayload(workflowReqDto, normalizeCspKey(csp) + "_", csp);
                if (!nodeGroup.isEmpty()) {
                    nodeGroups.add(nodeGroup);
                }
            }
        }

        if (nodeGroups.isEmpty()) {
            return Collections.emptyMap();
        }

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("name", getParamValue(
                workflowReqDto,
                "INFRA_ID",
                getParamValue(workflowReqDto, "INFRA_PREFIX", Optional.ofNullable(workflowReqDto.getWorkflowInfo()).map(WorkflowDto::getWorkflowName).orElse("workflow-infra"))));
        payload.put("description", getParamValue(workflowReqDto, "INFRA_DESC", "Workflow created infra"));
        payload.put("installMonAgent", getParamValue(workflowReqDto, "INSTALL_MON_AGENT", "no"));
        payload.put("policyOnPartialFailure", getParamValue(workflowReqDto, "POLICY_ON_PARTIAL_FAILURE", "continue"));
        payload.put("nodeGroups", nodeGroups);
        return payload;
    }

    private Map<String, Object> buildNodeGroupReviewPayload(WorkflowReqDto workflowReqDto, String prefix, String csp) {
        String region = getParamValue(workflowReqDto, prefix + "REGION", getParamValue(workflowReqDto, "REGION", ""));
        String connectionName = getParamValue(workflowReqDto, prefix + "CONNECTION_NAME", getParamValue(workflowReqDto, "CONNECTION_NAME", deriveConnectionName(csp, region)));
        String specId = getParamValue(workflowReqDto, prefix + "SPEC_ID", getParamValue(workflowReqDto, "SPEC_ID", ""));
        String imageId = getParamValue(workflowReqDto, prefix + "IMAGE_ID", getParamValue(workflowReqDto, "IMAGE_ID", ""));

        if (!StringUtils.hasText(specId) || !StringUtils.hasText(imageId)) {
            return Collections.emptyMap();
        }

        Map<String, Object> nodeGroup = new LinkedHashMap<>();
        nodeGroup.put("name", getParamValue(workflowReqDto, "INFRA_NODEGROUP_NAME", "g1"));
        nodeGroup.put("nodeGroupSize", parseInteger(getParamValue(workflowReqDto, "INFRA_NODEGROUP_SIZE", "1"), 1));
        nodeGroup.put("specId", specId);
        nodeGroup.put("imageId", imageId);
        nodeGroup.put("rootDiskType", getParamValue(workflowReqDto, "ROOT_DISK_TYPE", "default"));
        nodeGroup.put("rootDiskSize", parseInteger(getParamValue(workflowReqDto, "ROOT_DISK_SIZE", "50"), 50));
        if (StringUtils.hasText(connectionName)) {
            nodeGroup.put("connectionName", connectionName);
        }
        String zone = getParamValue(workflowReqDto, prefix + "ZONE", getParamValue(workflowReqDto, "ZONE", ""));
        if (StringUtils.hasText(zone)) {
            nodeGroup.put("zone", zone);
        }
        return nodeGroup;
    }

    @SuppressWarnings("unchecked")
    private boolean hasInfraReviewError(Object reviewResult) {
        if (reviewResult == null) {
            return true;
        }

        String text = String.valueOf(reviewResult).toLowerCase(Locale.ROOT);
        if (text.contains("sold out") || text.contains("reviewstatus=error") || text.contains("reviewstatus:error")) {
            return true;
        }

        if (reviewResult instanceof Map<?, ?> map) {
            Object status = firstMapValue((Map<String, Object>) map, "reviewStatus", "status", "validationStatus");
            if (status != null) {
                String normalizedStatus = normalizeText(String.valueOf(status));
                if (Set.of("error", "failed", "fail").contains(normalizedStatus)) {
                    return true;
                }
            }

            for (Object value : map.values()) {
                if (hasInfraReviewError(value)) {
                    return true;
                }
            }
            return false;
        }

        if (reviewResult instanceof List<?> list) {
            return list.stream().anyMatch(this::hasInfraReviewError);
        }

        return false;
    }

    @SuppressWarnings("unchecked")
    private String getInfraReviewMessage(Object reviewResult) {
        if (reviewResult instanceof Map<?, ?> map) {
            Object message = firstMapValue((Map<String, Object>) map, "message", "detail", "details", "reason", "errorMessage");
            if (message != null && StringUtils.hasText(String.valueOf(message))) {
                return String.valueOf(message);
            }
            for (Object value : map.values()) {
                String nestedMessage = getInfraReviewMessage(value);
                if (StringUtils.hasText(nestedMessage)) {
                    return nestedMessage;
                }
            }
        }
        if (reviewResult instanceof List<?> list) {
            for (Object value : list) {
                String nestedMessage = getInfraReviewMessage(value);
                if (StringUtils.hasText(nestedMessage)) {
                    return nestedMessage;
                }
            }
        }
        return "선택한 Image/Spec 조합으로 인프라를 생성할 수 없습니다.";
    }

    private Object firstMapValue(Map<String, Object> map, String... keys) {
        for (String key : keys) {
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                if (entry.getKey() != null && entry.getKey().equalsIgnoreCase(key)) {
                    return entry.getValue();
                }
            }
        }
        return null;
    }

    private String getParamValue(WorkflowReqDto workflowReqDto, String key, String defaultValue) {
        if (workflowReqDto == null || workflowReqDto.getWorkflowParams() == null) {
            return defaultValue;
        }

        for (WorkflowParamDto param : workflowReqDto.getWorkflowParams()) {
            if (param.getParamKey() != null && param.getParamKey().trim().equalsIgnoreCase(key)) {
                return StringUtils.hasText(param.getParamValue()) ? param.getParamValue().trim() : defaultValue;
            }
        }
        return defaultValue;
    }

    private String normalizeCspKey(String value) {
        return Optional.ofNullable(value)
                .orElse("")
                .trim()
                .toUpperCase(Locale.ROOT)
                .replaceAll("[^A-Z0-9]", "_");
    }

    private String normalizeText(String value) {
        return Optional.ofNullable(value).orElse("").trim().toLowerCase(Locale.ROOT);
    }

    private String deriveConnectionName(String csp, String region) {
        return StringUtils.hasText(csp) && StringUtils.hasText(region) ? csp + "-" + region : "";
    }

    private int parseInteger(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
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
                                                                .filter(type -> WORKFLOW_STAGE_CATEGORIES.contains(type.getWorkflowStageTypeName()))
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
                    synchronizeJenkinsJobIfAvailable(
                            ossDto,
                            workflowResDto.getWorkflowInfo().getWorkflowName(),
                            workflowResDto.getWorkflowInfo().getScript(),
                            workflowResDto.getWorkflowParams());
                }
            }
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
        if (workflowDto == null) {
            return WorkflowLogResDto.createList();
        }
        OssDto ossDto = getOssDto(workflowDto.getOssIdx());

        List<WorkflowLogResDto> resList = WorkflowLogResDto.createList();
        Integer latestBuildNumber = workflowDto.getLatestBuildNumber();
        if (latestBuildNumber == null || latestBuildNumber <= 0) {
            String fallbackLog = buildWorkflowHistoryFallbackLog(workflowIdx);
            if (StringUtils.hasText(fallbackLog)) {
                return WorkflowLogResDto.addToList(resList, 0, fallbackLog);
            }
            return resList;
        }

        int minBuildNumber = Math.max(1, latestBuildNumber - MAX_JENKINS_BUILD_LOOKUP_COUNT + 1);
        for (int buildNumber = latestBuildNumber; buildNumber >= minBuildNumber; buildNumber--) {
            try {
                String log = jenkinsService.getJenkinsLog(
                        ossDto.getOssUrl(),
                        ossDto.getOssUsername(),
                        ossDto.getOssPassword(),
                        workflowDto.getWorkflowName(),
                        buildNumber
                );
                resList = WorkflowLogResDto.addToList(resList, buildNumber, log);

            } catch (Exception e) {
                log.warn("Jenkins console log lookup failed. workflowName: {}, buildNumber: {}",
                        workflowDto.getWorkflowName(), buildNumber, e);
                if (resList.isEmpty()) {
                    String fallbackLog = buildWorkflowHistoryFallbackLog(workflowIdx);
                    if (StringUtils.hasText(fallbackLog)) {
                        resList = WorkflowLogResDto.addToList(resList, 0, fallbackLog);
                        break;
                    }
                    resList = WorkflowLogResDto.addToList(
                            resList,
                            latestBuildNumber,
                            "Jenkins console log is not available. Please check Jenkins connection or build existence."
                    );
                }
                break;
            }
        }
        return resList;
    }

    private String buildWorkflowHistoryFallbackLog(Long workflowIdx) {
        List<WorkflowHistory> workflowHistories = workflowHistoryRepository.findByWorkflow_WorkflowIdx(workflowIdx);
        if (CollectionUtils.isEmpty(workflowHistories)) {
            return "";
        }

        List<WorkflowHistory> recentHistories = workflowHistories.stream()
                .filter(history -> history != null && StringUtils.hasText(history.getDataType()))
                .sorted(Comparator.comparing(
                        WorkflowHistory::getWorkflowHistoryIdx,
                        Comparator.nullsLast(Comparator.reverseOrder())))
                .limit(200)
                .sorted(Comparator.comparing(
                        WorkflowHistory::getWorkflowHistoryIdx,
                        Comparator.nullsLast(Comparator.naturalOrder())))
                .collect(Collectors.toList());

        if (recentHistories.isEmpty()) {
            return "";
        }

        StringBuilder fallbackLog = new StringBuilder();
        fallbackLog.append("Jenkins console log is not available. Showing workflow execution history saved in DB.\n");
        String previousParamKey = null;
        for (WorkflowHistory history : recentHistories) {
            String dataType = history.getDataType();
            String data = history.getData();
            if ("paramValue".equals(dataType) && isSensitiveParamKey(previousParamKey)) {
                data = "******";
            }

            fallbackLog.append("[")
                    .append(history.getDate() == null ? "-" : history.getDate())
                    .append("] ")
                    .append(dataType)
                    .append(": ")
                    .append(truncateHistoryData(data))
                    .append("\n");

            previousParamKey = "paramKey".equals(dataType) ? history.getData() : null;
        }
        return fallbackLog.toString();
    }

    private boolean isSensitiveParamKey(String paramKey) {
        if (!StringUtils.hasText(paramKey)) {
            return false;
        }

        String normalizedKey = paramKey.toUpperCase(Locale.ROOT);
        return normalizedKey.contains("PASSWORD")
                || normalizedKey.contains("PASS")
                || normalizedKey.contains("SECRET")
                || normalizedKey.contains("TOKEN")
                || normalizedKey.contains("KEY_FILE")
                || normalizedKey.contains("PRIVATE_KEY");
    }

    private String truncateHistoryData(String data) {
        if (data == null) {
            return "";
        }
        int maxLength = 2000;
        return data.length() > maxLength ? data.substring(0, maxLength) + "...(truncated)" : data;
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
        if (workflow == null) {
            return null;
        }
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
        if (workflowDto == null) {
            return WorkflowRunHistoryResDto.createList();
        }

        // oss 조회
        OssDto ossDto = getOssDto(workflowDto.getOssIdx());


        List<WorkflowRunHistoryResDto> buildHistoryList = WorkflowRunHistoryResDto.createList();
        Integer latestBuildNumber = workflowDto.getLatestBuildNumber();
        if (latestBuildNumber == null || latestBuildNumber <= 0) {
            if (StringUtils.hasText(buildWorkflowHistoryFallbackLog(workflowIdx))) {
                buildHistoryList.add(WorkflowRunHistoryResDto.builder()
                        .name("DB History")
                        .status(StringUtils.hasText(workflowDto.getStatus()) ? workflowDto.getStatus() : "-")
                        .startTimeMillis(workflowDto.getRunDate() == null
                                ? 0L
                                : workflowDto.getRunDate()
                                        .atZone(java.time.ZoneId.systemDefault())
                                        .toInstant()
                                        .toEpochMilli())
                        .durationTimeMillis(0L)
                        .stages(Collections.emptyList())
                        .build());
            }
            return buildHistoryList;
        }

        int minBuildNumber = Math.max(1, latestBuildNumber - MAX_JENKINS_BUILD_LOOKUP_COUNT + 1);
        for (int buildNumber = latestBuildNumber; buildNumber >= minBuildNumber; buildNumber--) {
            try {
                WorkflowRunHistoryResDto jenkinsBuildHistory = jenkinsService.getJenkinsBuildStage(ossDto, workflowDto.getWorkflowName(), buildNumber);
                buildHistoryList = WorkflowRunHistoryResDto.addToList(buildHistoryList, jenkinsBuildHistory);
            } catch (Exception e) {
                log.warn("Jenkins build stage history lookup failed. workflowName: {}, buildNumber: {}",
                        workflowDto.getWorkflowName(), buildNumber, e);
                break;
            }
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
        if (workflowDto == null) {
            return null;
        }

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

    private List<WorkflowStageMappingDto> getWorkflowStageMappingDtos(Long workflowIdx) {
        return toWorkflowStageMappingDtos(
                workflowStageMappingRepository.findByWorkflow_WorkflowIdxOrderByStageOrderAscMappingIdxAsc(workflowIdx));
    }

    private List<WorkflowStageMappingDto> getCurrentWorkflowStageMappingDtos(Long workflowIdx) {
        return toWorkflowStageMappingDtos(
                workflowStageMappingRepository.findByWorkflow_WorkflowIdxOrderByStageOrderAscMappingIdxAsc(workflowIdx),
                true);
    }

    private List<WorkflowStageMappingDto> toWorkflowStageMappingDtos(List<kr.co.mcmp.workflow.Entity.WorkflowStageMapping> workflowStageMappings) {
        return toWorkflowStageMappingDtos(workflowStageMappings, false);
    }

    private List<WorkflowStageMappingDto> toWorkflowStageMappingDtos(
            List<kr.co.mcmp.workflow.Entity.WorkflowStageMapping> workflowStageMappings,
            boolean preferCurrentStageContent) {
        if (CollectionUtils.isEmpty(workflowStageMappings)) {
            return Collections.emptyList();
        }

        Map<Long, WorkflowStage> workflowStagesByIdx = new HashMap<>();
        return workflowStageMappings.stream()
                .map(stageMapping -> {
                    WorkflowStage workflowStage = null;
                    Long workflowStageIdx = stageMapping.getWorkflowStageIdx();
                    if (workflowStageIdx != null) {
                        workflowStage = workflowStagesByIdx.computeIfAbsent(
                                workflowStageIdx,
                                workflowStageRepository::findByWorkflowStageIdx);
                    }
                    WorkflowStageMappingDto stageMappingDto = WorkflowStageMappingDto.from(stageMapping, workflowStage);
                    if (preferCurrentStageContent && workflowStage != null && StringUtils.hasText(workflowStage.getWorkflowStageContent())) {
                        stageMappingDto = WorkflowStageMappingDto.builder()
                                .mappingIdx(stageMappingDto.getMappingIdx())
                                .workflowIdx(stageMappingDto.getWorkflowIdx())
                                .stageOrder(stageMappingDto.getStageOrder())
                                .workflowStageIdx(stageMappingDto.getWorkflowStageIdx())
                                .workflowStageName(stageMappingDto.getWorkflowStageName())
                                .workflowStageTypeName(stageMappingDto.getWorkflowStageTypeName())
                                .stageContent(workflowStage.getWorkflowStageContent())
                                .defaultParams(stageMappingDto.getDefaultParams())
                                .build();
                    }
                    return stageMappingDto;
                })
                .collect(Collectors.toList());
    }

    private List<WorkflowStageMappingDto> defaultWorkflowStageMappings(List<WorkflowStageMappingDto> workflowStageMappings) {
        if (CollectionUtils.isEmpty(workflowStageMappings)) {
            return Collections.emptyList();
        }

        List<WorkflowStageMappingDto> result = new ArrayList<>();
        int fallbackOrder = 0;

        for (WorkflowStageMappingDto stageMapping : workflowStageMappings) {
            if (stageMapping == null) {
                continue;
            }

            String stageContent = stageMapping.getStageContent();
            Long workflowStageIdx = stageMapping.getWorkflowStageIdx();

            if (shouldUseCurrentWorkflowStageContent(stageContent, workflowStageIdx)) {
                WorkflowStage workflowStage = workflowStageRepository.findByWorkflowStageIdx(workflowStageIdx);
                if (workflowStage != null) {
                    stageContent = workflowStage.getWorkflowStageContent();
                }
            }

            if (!StringUtils.hasText(stageContent)) {
                log.warn("Workflow stage mapping skipped because stage content is empty. workflowStageIdx: {}", workflowStageIdx);
                continue;
            }

            Integer stageOrder = stageMapping.getStageOrder() != null ? stageMapping.getStageOrder() : fallbackOrder;
            result.add(WorkflowStageMappingDto.builder()
                    .mappingIdx(stageMapping.getMappingIdx())
                    .workflowIdx(stageMapping.getWorkflowIdx())
                    .stageOrder(stageOrder)
                    .workflowStageIdx(workflowStageIdx)
                    .stageContent(stageContent)
                    .build());
            fallbackOrder++;
        }

        return result;
    }

    private boolean shouldUseCurrentWorkflowStageContent(String stageContent, Long workflowStageIdx) {
        if (workflowStageIdx == null) {
            return false;
        }
        if (!StringUtils.hasText(stageContent)) {
            return true;
        }

        String normalizedStageContent = stageContent.trim().toLowerCase(Locale.ROOT);
        return Set.of("true", "false").contains(normalizedStageContent)
                || !normalizedStageContent.contains("stage(");
    }
}
