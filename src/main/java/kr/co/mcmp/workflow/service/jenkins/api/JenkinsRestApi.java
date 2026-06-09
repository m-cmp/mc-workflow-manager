package kr.co.mcmp.workflow.service.jenkins.api;

import com.cdancy.jenkins.rest.JenkinsApi;
import com.cdancy.jenkins.rest.JenkinsClient;
import com.cdancy.jenkins.rest.domain.common.RequestStatus;
import com.cdancy.jenkins.rest.domain.crumb.Crumb;
import com.cdancy.jenkins.rest.domain.job.*;
import com.cdancy.jenkins.rest.domain.queue.QueueItem;
import com.cdancy.jenkins.rest.features.JobsApi;
import com.cdancy.jenkins.rest.features.QueueApi;
import com.fasterxml.jackson.databind.JsonNode;
import kr.co.mcmp.util.AES256Util;
import kr.co.mcmp.util.Base64Util;
import kr.co.mcmp.workflow.dto.resDto.WorkflowRunHistoryResDto;
import kr.co.mcmp.workflow.service.jenkins.model.JenkinsBuildDescribeLog;
import kr.co.mcmp.workflow.service.jenkins.model.JenkinsBuildDetailLog;
import kr.co.mcmp.workflow.service.jenkins.model.JenkinsCredential;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;

import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;
import java.util.List;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@Component
public class JenkinsRestApi {
	
	private static final int DEFAULT_RETRY_INTERVAL = 3000;

	private static final long QUEUE_BUILD_NUMBER_TIMEOUT_MILLIS = 300000;

	private static final Duration JENKINS_CONNECT_TIMEOUT = Duration.ofSeconds(2);

	private final JenkinsRestClient client;

    /**
     * JenkinsClient Object 획득
     */
    private JenkinsClient getJenkinsClient(String url, String id, String password) {
    	String plainTextPassword = Base64Util.base64Decoding(AES256Util.decrypt(password));

        return JenkinsClient.builder().endPoint(url)
			                .credentials(id + ":" + plainTextPassword)
			                .build();
    }

    /**
     * Jenkins 연결 확인
     */
    public boolean isConnect(String url, String id, String password) {
        try {
            String plainTextPassword = Base64Util.base64Decoding(AES256Util.decrypt(password));
            String auth = Base64.getEncoder()
                    .encodeToString((id + ":" + plainTextPassword).getBytes(StandardCharsets.UTF_8));

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(toJenkinsApiUrl(url)))
                    .timeout(JENKINS_CONNECT_TIMEOUT)
                    .header("Authorization", "Basic " + auth)
                    .GET()
                    .build();

            HttpResponse<Void> response = HttpClient.newBuilder()
                    .connectTimeout(JENKINS_CONNECT_TIMEOUT)
                    .build()
                    .send(request, HttpResponse.BodyHandlers.discarding());

            return response.statusCode() >= 200 && response.statusCode() < 300;
        } catch (Exception e) {
            log.warn("Jenkins connection check failed. url: {}, message: {}", url, e.getMessage());
            return false;
        }
    }

    private String toJenkinsApiUrl(String url) {
        String normalizedUrl = url.endsWith("/") ? url.substring(0, url.length() - 1) : url;
        return normalizedUrl + "/api/json";
    }

    /**
     * Crumb 조회
     */
    public Crumb getJenkinsCrumb(String url, String id, String password) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);

        return jenkinsClient.api().crumbIssuerApi().crumb();
    }

    /**
     * Jenkins Job 목록 조회
     */
    public List<Job> getJenkinsJobList(String url, String id, String password) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JobsApi jobsApi = jenkinsClient.api().jobsApi();
        return jobsApi.jobList("/").jobs();
    }

    /**
     * Jenkins Job 조회
     */
    public JobInfo getJenkinsJob(String url, String id, String password, String jobName) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JobsApi jobsApi = jenkinsClient.api().jobsApi();
        return jobsApi.jobInfo("/",jobName);
    }

    public int getNextBuildNumber(String url, String id, String password, String jobName) {
        JobInfo jobInfo = getJenkinsJob(url, id, password, jobName);
        return jobInfo != null ? jobInfo.nextBuildNumber() : 0;
    }

    /**
     * Jenkins Job 생성
     * @throws UnsupportedEncodingException
     */
    public RequestStatus createJenkinsJob(String url, String id, String password, String jobName, String configXml) throws UnsupportedEncodingException {
        configXml = URLEncoder.encode(configXml, "UTF-8");
        log.debug("[JenkinsRestApi.createJenkinsJob] jobName: {}, configXmlLength: {}", jobName, configXml.length());

        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JobsApi jobsApi = jenkinsClient.api().jobsApi();
        return jobsApi.create(null, jobName, configXml);
    }

    /**
     * Jenkins Job 수정
     * @throws UnsupportedEncodingException
     */
    public boolean updateJenkinsJob(String url, String id, String password, String jobName, String configXml) throws UnsupportedEncodingException {
        configXml = URLEncoder.encode(configXml, "UTF-8");

        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JobsApi jobsApi = jenkinsClient.api().jobsApi();
        return jobsApi.config(null, jobName, configXml);
    }

    /**
     * Jenkins Job 삭제
     */
    public RequestStatus deleteJenkinsJob(String url, String id, String password, String jobName) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JobsApi jobsApi = jenkinsClient.api().jobsApi();
        return jobsApi.delete(null, jobName);
    }

    /**
     * Jenkins Job 빌드
     */
    public int buildJenkinsJob(String url, String id, String password, String jobName, Map<String, List<String>> params) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JobsApi jobsApi = jenkinsClient.api().jobsApi();
        return jobsApi.buildWithParameters(null, jobName, params).value();
    }

    /**
     * Jenkins Job > Build Number 조회
     * @param url
     * @param id
     * @param password
//     * @param jobName
     * @param jenkinsBuildId
     * @return
     */
    public int getQueueExecutableNumber(String url, String id, String password, int jenkinsBuildId) {
        return getQueueExecutableNumber(url, id, password, jenkinsBuildId, 0);
    }

    public int getQueueExecutableNumber(String url, String id, String password, int jenkinsBuildId, int fallbackBuildNumber) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);

        QueueApi queueApi = jenkinsClient.api().queueApi();

        try {
            return resolveQueueExecutableNumber(queueApi, jenkinsBuildId, fallbackBuildNumber);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("[getQueueExecutableNumber] InterruptedException >>>>", e);
            throw new IllegalStateException("Interrupted while waiting Jenkins queue executable number.", e);
        }
    }

    /**
     * Jenkins Job 빌드 대기, 빌드 진행 상태 모니터링
     */
    public BuildInfo waitJenkinsBuild(String url, String id, String password, String jobName, int jenkinsBuildId, int buildNumber) {
        BuildInfo buildInfo = null;

        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JenkinsApi jenkinsApi = jenkinsClient.api();

        JobsApi jobsApi = jenkinsApi.jobsApi();
        QueueApi queueApi = jenkinsApi.queueApi();

        try {
            buildNumber = resolveQueueExecutableNumber(queueApi, jenkinsBuildId, buildNumber);

            buildInfo = waitBuildInfoAvailable(jobsApi, jobName, buildNumber);
            while (buildInfo.building()) {
                log.info("[ 빌드 진행 중... ] / jobName:{} / jenkins build id:{} / build queue number:{}", jobName, jenkinsBuildId, buildNumber);

                Thread.sleep(DEFAULT_RETRY_INTERVAL);

                buildInfo = jobsApi.buildInfo(null, jobName, buildNumber);
            }

            log.info("[ 빌드 종료. ]/ result:{} / building():{} / duration:{} / number:{} / jenkinsBuildId:{} / displayName:{} / fullDisplayName:{}",
                    buildInfo.result(), buildInfo.building(), buildInfo.duration(), buildInfo.number(), buildInfo.queueId(),
                    buildInfo.displayName(), buildInfo.fullDisplayName(), buildInfo.queueId());

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("[waitJenkinsBuild] InterruptedException >>>>", e);
            throw new IllegalStateException("Interrupted while waiting Jenkins build.", e);
        }
        return buildInfo;
    }

    private int resolveQueueExecutableNumber(QueueApi queueApi, int jenkinsBuildId, int fallbackBuildNumber) throws InterruptedException {
        if (jenkinsBuildId <= 0 && fallbackBuildNumber > 0) {
            log.warn("[ 빌드 큐 ID 없음. 예상 build number 사용 ] / queue id:{} / fallback build number:{}",
                    jenkinsBuildId, fallbackBuildNumber);
            return fallbackBuildNumber;
        }

        long deadline = System.currentTimeMillis() + QUEUE_BUILD_NUMBER_TIMEOUT_MILLIS;

        while (System.currentTimeMillis() <= deadline) {
            QueueItem currentQueueItem = getQueueItemSafely(queueApi, jenkinsBuildId);

            if (currentQueueItem == null) {
                if (fallbackBuildNumber > 0) {
                    log.info("[ 빌드 큐 정보 없음. 예상 build number 사용 ] / queue id:{} / fallback build number:{}",
                            jenkinsBuildId, fallbackBuildNumber);
                    return fallbackBuildNumber;
                }

                log.info("[ 빌드 큐 조회 대기중... ] / queue id:{}", jenkinsBuildId);
            } else if (currentQueueItem.cancelled()) {
                throw new IllegalStateException("Jenkins build queue was cancelled. queue id: " + jenkinsBuildId);
            } else if (currentQueueItem.executable() != null && currentQueueItem.executable().number() > 0) {
                return currentQueueItem.executable().number();
            } else {
                log.info("[ 빌드 큐에서 대기중... ] / queue id:{} / url:{}", currentQueueItem.id(), currentQueueItem.url());
            }

            Thread.sleep(DEFAULT_RETRY_INTERVAL);
        }

        if (fallbackBuildNumber > 0) {
            log.warn("[ 빌드 큐 대기 시간 초과. 예상 build number 사용 ] / queue id:{} / fallback build number:{}",
                    jenkinsBuildId, fallbackBuildNumber);
            return fallbackBuildNumber;
        }

        throw new IllegalStateException("Timed out waiting Jenkins queue executable number. queue id: " + jenkinsBuildId);
    }

    private QueueItem getQueueItemSafely(QueueApi queueApi, int jenkinsBuildId) {
        try {
            return queueApi.queueItem(jenkinsBuildId);
        } catch (RuntimeException e) {
            log.debug("Jenkins queue item is not available yet. queue id: {}", jenkinsBuildId, e);
            return null;
        }
    }

    private BuildInfo waitBuildInfoAvailable(JobsApi jobsApi, String jobName, int buildNumber) throws InterruptedException {
        if (buildNumber <= 0) {
            throw new IllegalStateException("Jenkins build number is not resolved. jobName: " + jobName);
        }

        RuntimeException lastException = null;
        long deadline = System.currentTimeMillis() + QUEUE_BUILD_NUMBER_TIMEOUT_MILLIS;

        while (System.currentTimeMillis() <= deadline) {
            try {
                BuildInfo buildInfo = jobsApi.buildInfo(null, jobName, buildNumber);
                if (buildInfo != null && buildInfo.number() > 0) {
                    return buildInfo;
                }
            } catch (RuntimeException e) {
                lastException = e;
                log.info("[ 빌드 정보 조회 대기중... ] / jobName:{} / build number:{}", jobName, buildNumber);
            }

            Thread.sleep(DEFAULT_RETRY_INTERVAL);
        }

        if (lastException != null) {
            throw new IllegalStateException("Timed out waiting Jenkins build info. jobName: " + jobName + ", build number: " + buildNumber, lastException);
        }

        throw new IllegalStateException("Timed out waiting Jenkins build info. jobName: " + jobName + ", build number: " + buildNumber);
    }

    /**
     * Build Console Log 조회
     */
    public String getJenkinsBuildConsoleLog(String url, String id, String password, String jobName, int buildNumber) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JobsApi jobsApi = jenkinsClient.api().jobsApi();
        return jobsApi.progressiveText(null, jobName, buildNumber, 0).text();
    }

    /**
     * Workflow 조회
     */
    public Workflow getJenkinsWorkflow(String url, String id, String password, String jobName, int buildNumber) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JobsApi jobsApi = jenkinsClient.api().jobsApi();
        return jobsApi.workflow(null, jobName, buildNumber);
    }

    /**
     * Pipeline Node 조회
     */
    public PipelineNode getJenkinsPipelineNode(String url, String id, String password, String jobName, int buildNumber, int stageId) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JobsApi jobsApi = jenkinsClient.api().jobsApi();
        return jobsApi.pipelineNode(null, jobName, buildNumber, stageId);
    }

    /**
     * JUnit Test 결과 조회
     */
    public ResponseEntity<JsonNode> getJunitTestReport(String baseUrl, String id, String password, String jobName, int buildNumber) {
    	String apiUrl = String.format("%s/job/%s/%d/testReport/api/json", baseUrl, jobName, buildNumber);

    	ResponseEntity<JsonNode> response = client.requestByBasicAuth(apiUrl, id, password, HttpMethod.GET, null, JsonNode.class);

    	return response;
    }

    /**
     * Build Stage View 조회
     */
    public ResponseEntity<WorkflowRunHistoryResDto> getWorkflow(String baseUrl, String id, String password, String jobName, int buildNumber) {
        String apiUrl = String.format("%s/job/%s/%d/wfapi/describe", baseUrl, jobName, buildNumber);

        ResponseEntity<WorkflowRunHistoryResDto> response = client.requestByBasicAuth(apiUrl, id, password, HttpMethod.GET, null, WorkflowRunHistoryResDto.class);

        return response;
    }

    /**
     * Build Stage Logs 조회
     */
    public ResponseEntity<JenkinsBuildDescribeLog> getPipelineNode(String baseUrl, String id, String password, String jobName, int buildNumber, int nodeId) {
    	String apiUrl = String.format("%s/job/%s/%d/execution/node/%d/wfapi/describe", baseUrl, jobName, buildNumber,nodeId);

    	ResponseEntity<JenkinsBuildDescribeLog> response = client.requestByBasicAuth(apiUrl, id, password, HttpMethod.GET, null, JenkinsBuildDescribeLog.class);

    	return response;
    }

    /**
     * Build Stage Detail Log 조회
     */
    public ResponseEntity<JenkinsBuildDetailLog> getPipelineNodeLog(String baseUrl, String id, String password, String jobName, int buildNumber, int nodeId) {
        String apiUrl = String.format("%s/job/%s/%d/execution/node/%d/wfapi/log", baseUrl, jobName, buildNumber,nodeId);

        ResponseEntity<JenkinsBuildDetailLog> response = client.requestByBasicAuth(apiUrl, id, password, HttpMethod.GET, null, JenkinsBuildDetailLog.class);

        return response;
    }

    /**
     * Job Pipeline Script 조회
     */
    public ResponseEntity<byte[]> getJobPipelineScript(String baseUrl, String id, String password, String jobName) {
        String apiUrl = String.format("%s/job/%s/config.xml", baseUrl, jobName);

        ResponseEntity<byte[]> response = client.requestByBasicAuth(apiUrl, id, password, HttpMethod.GET, null, byte[].class);

        return response;
    }

    /**
     * jenkins credential 상세 조회
     */
    public ResponseEntity<JenkinsCredential> getCredential(String baseUrl, String id, String password, String credentialName) {
        String apiUrl = String.format("%s/credentials/store/system/domain/_/credential/%s/api/json/", baseUrl, credentialName);

        ResponseEntity<JenkinsCredential> response = client.requestByBasicAuth(apiUrl, id, password, HttpMethod.GET, null, JenkinsCredential.class);

        return response;
    }

    /**
     * jenkins credential 생성
     */
    public ResponseEntity<String> createCredential(String baseUrl, String id, String password, Crumb crumb, String credentialXml) {
        String apiUrl = String.format("%s/credentials/store/system/domain/_/createCredentials", baseUrl);

        ResponseEntity<String> response = client.requestJenkinsCrumbAPI(apiUrl, id, password, crumb, HttpMethod.POST, credentialXml, String.class);

        return response;
    }

    /**
     * jenkins credential 수정
     */
    public ResponseEntity<String> updateCredential(String baseUrl, String id, String password, Crumb crumb, String credentialName, String credentialXml) {
    	String apiUrl = String.format("%s/credentials/store/system/domain/_/credential/%s/config.xml", baseUrl, credentialName);

    	ResponseEntity<String> response = client.requestJenkinsCrumbAPI(apiUrl, id, password, crumb, HttpMethod.POST, credentialXml, String.class);

    	return response;
    }

    /**
     * jenkins credential 삭제
     */
    public ResponseEntity<Object> deleteCredential(String baseUrl, String id, String password, Crumb crumb, String credentialName) {
    	String apiUrl = String.format("%s/credentials/store/system/domain/_/credential/%s/doDelete", baseUrl, credentialName);

    	ResponseEntity<Object> response = client.requestJenkinsCrumbAPI(apiUrl, id, password, crumb, HttpMethod.POST, null, Object.class);

    	return response;
    }
}
