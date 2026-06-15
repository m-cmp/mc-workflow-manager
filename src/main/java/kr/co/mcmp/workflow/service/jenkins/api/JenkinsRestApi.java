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
import kr.co.mcmp.workflow.service.jenkins.exception.JenkinsException;
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
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Slf4j
@RequiredArgsConstructor
@Component
public class JenkinsRestApi {
	
	private static final int DEFAULT_RETRY_INTERVAL = 3000;

	private static final long QUEUE_BUILD_NUMBER_TIMEOUT_MILLIS = 300000;

	private static final Duration JENKINS_CONNECT_TIMEOUT = Duration.ofSeconds(2);

	private final JenkinsRestClient client;

    /**
     * Get JenkinsClient object
     */
    private JenkinsClient getJenkinsClient(String url, String id, String password) {
    	String plainTextPassword = Base64Util.base64Decoding(AES256Util.decrypt(password));

        return JenkinsClient.builder().endPoint(url)
			                .credentials(id + ":" + plainTextPassword)
			                .build();
    }

    /**
     * Check Jenkins connection
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

    /* Comment translated to English. */
    public Crumb getJenkinsCrumb(String url, String id, String password) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);

        return jenkinsClient.api().crumbIssuerApi().crumb();
    }

    /**
     * List Jenkins jobs
     */
    public List<Job> getJenkinsJobList(String url, String id, String password) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JobsApi jobsApi = jenkinsClient.api().jobsApi();
        return jobsApi.jobList("/").jobs();
    }

    /**
     * Get Jenkins job
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
     * Create Jenkins job
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
     * Update Jenkins job
     * @throws UnsupportedEncodingException
     */
    public boolean updateJenkinsJob(String url, String id, String password, String jobName, String configXml) throws UnsupportedEncodingException {
        try {
            return updateJenkinsJobConfigXml(url, id, password, jobName, configXml);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("[updateJenkinsJob] Jenkins Job config update interrupted. jobName: {}", jobName, e);
            return false;
        } catch (Exception e) {
            log.error("[updateJenkinsJob] Jenkins Job config update failed. jobName: {}", jobName, e);
            return false;
        }
    }

    public int updateJenkinsJobAndBuildNow(String url, String id, String password, String jobName, String configXml,
                                           Map<String, List<String>> params, String verificationMarker) {
        try {
            updateAndVerifyJenkinsJobConfigXml(url, id, password, jobName, configXml, verificationMarker);
            return buildJenkinsJobNow(url, id, password, jobName, params);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new JenkinsException(500, "Interrupted while updating Jenkins config.xml before build");
        } catch (JenkinsException e) {
            throw e;
        } catch (Exception e) {
            log.error("[updateJenkinsJobAndBuildNow] Jenkins update/build failed. jobName: {}", jobName, e);
            throw new JenkinsException(500, "Jenkins update/build failed", e.getMessage());
        }
    }

    private void updateAndVerifyJenkinsJobConfigXml(String url, String id, String password, String jobName,
                                                    String configXml, String verificationMarker) throws Exception {
        int maxAttempts = verificationMarker != null && !verificationMarker.isBlank() ? 3 : 1;
        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
            boolean updated = updateJenkinsJobConfigXml(url, id, password, jobName, configXml);
            if (!updated) {
                throw new JenkinsException(500, "Jenkins config.xml update failed before build");
            }

            if (verificationMarker == null || verificationMarker.isBlank()) {
                return;
            }

            String currentConfig = getJenkinsJobConfigXml(url, id, password, jobName);
            if (currentConfig != null && currentConfig.contains(verificationMarker)) {
                return;
            }

            log.warn("[updateJenkinsJobAndBuildNow] Jenkins config.xml verification failed after update. jobName: {}, marker: {}, attempt: {}/{}",
                    jobName, verificationMarker, attempt, maxAttempts);
            Thread.sleep(500L);
        }

        throw new JenkinsException(500, "Jenkins config.xml verification failed before build", verificationMarker);
    }

    private boolean updateJenkinsJobConfigXml(String url, String id, String password, String jobName, String configXml) throws Exception {
        String auth = basicAuth(id, password);
        String jobConfigUrl = normalizedJenkinsUrl(url) + "/job/" + encodePathSegment(jobName) + "/config.xml";

        HttpRequest.Builder requestBuilder = HttpRequest.newBuilder()
                .uri(URI.create(jobConfigUrl))
                .timeout(Duration.ofSeconds(30))
                .header("Authorization", "Basic " + auth)
                .header("Content-Type", "application/xml; charset=UTF-8")
                .POST(HttpRequest.BodyPublishers.ofString(configXml, StandardCharsets.UTF_8));

        try {
            JenkinsCrumbHeader crumb = getJenkinsCrumbHeader(url, auth);
            if (crumb != null) {
                requestBuilder.header(crumb.requestField(), crumb.value());
                if (crumb.cookieHeader() != null && !crumb.cookieHeader().isBlank()) {
                    requestBuilder.header("Cookie", crumb.cookieHeader());
                }
            }
        } catch (Exception e) {
            log.warn("[updateJenkinsJob] Jenkins crumb lookup failed. Continue with basic auth only. jobName: {}, message: {}",
                    jobName, e.getMessage());
        }

        HttpResponse<String> response = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build()
                .send(requestBuilder.build(), HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));

        boolean success = response.statusCode() >= 200 && response.statusCode() < 300;
        if (!success) {
            log.error("[updateJenkinsJob] Jenkins config.xml update failed. jobName: {}, status: {}, body: {}",
                    jobName, response.statusCode(), response.body());
        } else {
            log.info("[updateJenkinsJob] Jenkins config.xml update accepted. jobName: {}, status: {}",
                    jobName, response.statusCode());
        }
        return success;
    }

    public String getJenkinsJobConfigXml(String url, String id, String password, String jobName) {
        try {
            String auth = basicAuth(id, password);
            String jobConfigUrl = normalizedJenkinsUrl(url) + "/job/" + encodePathSegment(jobName) + "/config.xml";

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(jobConfigUrl))
                    .timeout(Duration.ofSeconds(30))
                    .header("Authorization", "Basic " + auth)
                    .header("Cache-Control", "no-cache")
                    .GET()
                    .build();

            HttpResponse<String> response = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(10))
                    .build()
                    .send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));

            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                log.error("[getJenkinsJobConfigXml] Jenkins config.xml lookup failed. jobName: {}, status: {}, body: {}",
                        jobName, response.statusCode(), response.body());
                throw new JenkinsException(response.statusCode(), "Jenkins config.xml lookup failed");
            }

            log.info("[getJenkinsJobConfigXml] Jenkins config.xml loaded. jobName: {}, length: {}, hasK8sHelmMarker: {}",
                    jobName,
                    response.body() != null ? response.body().length() : 0,
                    response.body() != null && response.body().contains("k8s-helm-bootstrap-v3"));
            return response.body();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new JenkinsException(500, "Interrupted while reading Jenkins config.xml");
        } catch (JenkinsException e) {
            throw e;
        } catch (Exception e) {
            log.error("[getJenkinsJobConfigXml] Jenkins config.xml lookup error. jobName: {}", jobName, e);
            throw new JenkinsException(500, "Jenkins config.xml lookup error", e.getMessage());
        }
    }

    private String basicAuth(String id, String password) {
        String plainTextPassword = Base64Util.base64Decoding(AES256Util.decrypt(password));
        return Base64.getEncoder()
                .encodeToString((id + ":" + plainTextPassword).getBytes(StandardCharsets.UTF_8));
    }

    private JenkinsCrumbHeader getJenkinsCrumbHeader(String url, String auth) throws Exception {
        String crumbUrl = normalizedJenkinsUrl(url) + "/crumbIssuer/api/json";
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(crumbUrl))
                .timeout(Duration.ofSeconds(10))
                .header("Authorization", "Basic " + auth)
                .GET()
                .build();

        HttpResponse<String> response = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build()
                .send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));

        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            log.warn("[updateJenkinsJob] Jenkins crumb lookup returned status: {}", response.statusCode());
            return null;
        }

        String requestField = extractJsonString(response.body(), "crumbRequestField");
        String crumb = extractJsonString(response.body(), "crumb");
        if (requestField == null || crumb == null) {
            return null;
        }

        String cookieHeader = response.headers()
                .allValues("Set-Cookie")
                .stream()
                .map(cookie -> cookie.split(";", 2)[0])
                .filter(cookie -> !cookie.isBlank())
                .collect(Collectors.joining("; "));

        return new JenkinsCrumbHeader(requestField, crumb, cookieHeader);
    }

    private String extractJsonString(String body, String fieldName) {
        if (body == null) {
            return null;
        }
        Pattern pattern = Pattern.compile("\"" + Pattern.quote(fieldName) + "\"\\s*:\\s*\"([^\"]*)\"");
        Matcher matcher = pattern.matcher(body);
        return matcher.find() ? matcher.group(1) : null;
    }

    private record JenkinsCrumbHeader(String requestField, String value, String cookieHeader) {
    }

    private String normalizedJenkinsUrl(String url) {
        return url.endsWith("/") ? url.substring(0, url.length() - 1) : url;
    }

    private String encodePathSegment(String value) throws UnsupportedEncodingException {
        return URLEncoder.encode(value, "UTF-8").replace("+", "%20");
    }

    /**
     * Delete Jenkins job
     */
    public RequestStatus deleteJenkinsJob(String url, String id, String password, String jobName) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JobsApi jobsApi = jenkinsClient.api().jobsApi();
        return jobsApi.delete(null, jobName);
    }

    /**
     * Build Jenkins job
     */
    public int buildJenkinsJob(String url, String id, String password, String jobName, Map<String, List<String>> params) {
        try {
            return buildJenkinsJobNow(url, id, password, jobName, params);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new JenkinsException(500, "Interrupted while requesting Jenkins build");
        } catch (JenkinsException e) {
            throw e;
        } catch (Exception e) {
            log.error("[buildJenkinsJob] Jenkins build request failed. jobName: {}", jobName, e);
            throw new JenkinsException(500, "Jenkins build request failed", e.getMessage());
        }
    }

    private int buildJenkinsJobNow(String url, String id, String password, String jobName, Map<String, List<String>> params) throws Exception {
        String auth = basicAuth(id, password);
        String buildUrl = normalizedJenkinsUrl(url)
                + "/job/" + encodePathSegment(jobName)
                + "/buildWithParameters?delay=0sec";

        HttpRequest.Builder requestBuilder = HttpRequest.newBuilder()
                .uri(URI.create(buildUrl))
                .timeout(Duration.ofSeconds(30))
                .header("Authorization", "Basic " + auth)
                .header("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8")
                .POST(HttpRequest.BodyPublishers.ofString(buildFormBody(params), StandardCharsets.UTF_8));

        try {
            JenkinsCrumbHeader crumb = getJenkinsCrumbHeader(url, auth);
            if (crumb != null) {
                requestBuilder.header(crumb.requestField(), crumb.value());
                if (crumb.cookieHeader() != null && !crumb.cookieHeader().isBlank()) {
                    requestBuilder.header("Cookie", crumb.cookieHeader());
                }
            }
        } catch (Exception e) {
            log.warn("[buildJenkinsJob] Jenkins crumb lookup failed. Continue with basic auth only. jobName: {}, message: {}",
                    jobName, e.getMessage());
        }

        HttpResponse<String> response = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build()
                .send(requestBuilder.build(), HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));

        boolean success = response.statusCode() >= 200 && response.statusCode() < 400;
        if (!success) {
            log.error("[buildJenkinsJob] Jenkins build request failed. jobName: {}, status: {}, body: {}",
                    jobName, response.statusCode(), response.body());
            throw new JenkinsException(response.statusCode(), "Jenkins build request failed");
        }

        int queueId = resolveQueueId(response.headers().firstValue("Location").orElse(""));
        log.info("[buildJenkinsJob] Jenkins build requested. jobName: {}, status: {}, queueId: {}",
                jobName, response.statusCode(), queueId);
        return queueId;
    }

    private String buildFormBody(Map<String, List<String>> params) {
        if (params == null || params.isEmpty()) {
            return "";
        }

        return params.entrySet()
                .stream()
                .flatMap(entry -> {
                    List<String> values = entry.getValue();
                    if (values == null || values.isEmpty()) {
                        return List.of(Map.entry(entry.getKey(), "")).stream();
                    }
                    return values.stream().map(value -> Map.entry(entry.getKey(), value == null ? "" : value));
                })
                .map(entry -> encodeFormValue(entry.getKey()) + "=" + encodeFormValue(entry.getValue()))
                .collect(Collectors.joining("&"));
    }

    private String encodeFormValue(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }

    private int resolveQueueId(String location) {
        if (location == null) {
            return 0;
        }

        Matcher matcher = Pattern.compile("/queue/item/(\\d+)/?").matcher(location);
        return matcher.find() ? Integer.parseInt(matcher.group(1)) : 0;
    }

    /**
     * Get Jenkins job build number
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

    /* Comment translated to English. */
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
                log.info("[ Build in progress... ] / jobName:{} / jenkins build id:{} / build queue number:{}", jobName, jenkinsBuildId, buildNumber);

                Thread.sleep(DEFAULT_RETRY_INTERVAL);

                buildInfo = jobsApi.buildInfo(null, jobName, buildNumber);
            }

            log.info("[ Build finished. ]/ result:{} / building():{} / duration:{} / number:{} / jenkinsBuildId:{} / displayName:{} / fullDisplayName:{}",
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
            log.warn("[ Build queue ID is missing. Using expected build number. ] / queue id:{} / fallback build number:{}",
                    jenkinsBuildId, fallbackBuildNumber);
            return fallbackBuildNumber;
        }

        long deadline = System.currentTimeMillis() + QUEUE_BUILD_NUMBER_TIMEOUT_MILLIS;

        while (System.currentTimeMillis() <= deadline) {
            QueueItem currentQueueItem = getQueueItemSafely(queueApi, jenkinsBuildId);

            if (currentQueueItem == null) {
                if (fallbackBuildNumber > 0) {
                    log.info("[ Build queue information is missing. Using expected build number. ] / queue id:{} / fallback build number:{}",
                            jenkinsBuildId, fallbackBuildNumber);
                    return fallbackBuildNumber;
                }

                log.info("[ Waiting for build queue lookup... ] / queue id:{}", jenkinsBuildId);
            } else if (currentQueueItem.cancelled()) {
                throw new IllegalStateException("Jenkins build queue was cancelled. queue id: " + jenkinsBuildId);
            } else if (currentQueueItem.executable() != null && currentQueueItem.executable().number() > 0) {
                return currentQueueItem.executable().number();
            } else {
                log.info("[ Waiting in build queue... ] / queue id:{} / url:{}", currentQueueItem.id(), currentQueueItem.url());
            }

            Thread.sleep(DEFAULT_RETRY_INTERVAL);
        }

        if (fallbackBuildNumber > 0) {
            log.warn("[ Build queue wait timed out. Using expected build number. ] / queue id:{} / fallback build number:{}",
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
                log.info("[ Waiting for build information... ] / jobName:{} / build number:{}", jobName, buildNumber);
            }

            Thread.sleep(DEFAULT_RETRY_INTERVAL);
        }

        if (lastException != null) {
            throw new IllegalStateException("Timed out waiting Jenkins build info. jobName: " + jobName + ", build number: " + buildNumber, lastException);
        }

        throw new IllegalStateException("Timed out waiting Jenkins build info. jobName: " + jobName + ", build number: " + buildNumber);
    }

    /**
     * Get build console log
     */
    public String getJenkinsBuildConsoleLog(String url, String id, String password, String jobName, int buildNumber) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JobsApi jobsApi = jenkinsClient.api().jobsApi();
        return jobsApi.progressiveText(null, jobName, buildNumber, 0).text();
    }

    /**
     * Get workflow
     */
    public Workflow getJenkinsWorkflow(String url, String id, String password, String jobName, int buildNumber) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JobsApi jobsApi = jenkinsClient.api().jobsApi();
        return jobsApi.workflow(null, jobName, buildNumber);
    }

    /**
     * Get pipeline node
     */
    public PipelineNode getJenkinsPipelineNode(String url, String id, String password, String jobName, int buildNumber, int stageId) {
        JenkinsClient jenkinsClient = getJenkinsClient(url, id, password);
        JobsApi jobsApi = jenkinsClient.api().jobsApi();
        return jobsApi.pipelineNode(null, jobName, buildNumber, stageId);
    }

    /**
     * Get JUnit test result
     */
    public ResponseEntity<JsonNode> getJunitTestReport(String baseUrl, String id, String password, String jobName, int buildNumber) {
    	String apiUrl = String.format("%s/job/%s/%d/testReport/api/json", baseUrl, jobName, buildNumber);

    	ResponseEntity<JsonNode> response = client.requestByBasicAuth(apiUrl, id, password, HttpMethod.GET, null, JsonNode.class);

    	return response;
    }

    /**
     * Get build stage view
     */
    public ResponseEntity<WorkflowRunHistoryResDto> getWorkflow(String baseUrl, String id, String password, String jobName, int buildNumber) {
        String apiUrl = String.format("%s/job/%s/%d/wfapi/describe", baseUrl, jobName, buildNumber);

        ResponseEntity<WorkflowRunHistoryResDto> response = client.requestByBasicAuth(apiUrl, id, password, HttpMethod.GET, null, WorkflowRunHistoryResDto.class);

        return response;
    }

    /**
     * Get build stage logs
     */
    public ResponseEntity<JenkinsBuildDescribeLog> getPipelineNode(String baseUrl, String id, String password, String jobName, int buildNumber, int nodeId) {
    	String apiUrl = String.format("%s/job/%s/%d/execution/node/%d/wfapi/describe", baseUrl, jobName, buildNumber,nodeId);

    	ResponseEntity<JenkinsBuildDescribeLog> response = client.requestByBasicAuth(apiUrl, id, password, HttpMethod.GET, null, JenkinsBuildDescribeLog.class);

    	return response;
    }

    /**
     * Get build stage detail log
     */
    public ResponseEntity<JenkinsBuildDetailLog> getPipelineNodeLog(String baseUrl, String id, String password, String jobName, int buildNumber, int nodeId) {
        String apiUrl = String.format("%s/job/%s/%d/execution/node/%d/wfapi/log", baseUrl, jobName, buildNumber,nodeId);

        ResponseEntity<JenkinsBuildDetailLog> response = client.requestByBasicAuth(apiUrl, id, password, HttpMethod.GET, null, JenkinsBuildDetailLog.class);

        return response;
    }

    /**
     * Get job pipeline script
     */
    public ResponseEntity<byte[]> getJobPipelineScript(String baseUrl, String id, String password, String jobName) {
        String apiUrl = String.format("%s/job/%s/config.xml", baseUrl, jobName);

        ResponseEntity<byte[]> response = client.requestByBasicAuth(apiUrl, id, password, HttpMethod.GET, null, byte[].class);

        return response;
    }

    /**
     * Get Jenkins credential detail
     */
    public ResponseEntity<JenkinsCredential> getCredential(String baseUrl, String id, String password, String credentialName) {
        String apiUrl = String.format("%s/credentials/store/system/domain/_/credential/%s/api/json/", baseUrl, credentialName);

        ResponseEntity<JenkinsCredential> response = client.requestByBasicAuth(apiUrl, id, password, HttpMethod.GET, null, JenkinsCredential.class);

        return response;
    }

    /**
     * Create Jenkins credential
     */
    public ResponseEntity<String> createCredential(String baseUrl, String id, String password, Crumb crumb, String credentialXml) {
        String apiUrl = String.format("%s/credentials/store/system/domain/_/createCredentials", baseUrl);

        ResponseEntity<String> response = client.requestJenkinsCrumbAPI(apiUrl, id, password, crumb, HttpMethod.POST, credentialXml, String.class);

        return response;
    }

    /**
     * Update Jenkins credential
     */
    public ResponseEntity<String> updateCredential(String baseUrl, String id, String password, Crumb crumb, String credentialName, String credentialXml) {
    	String apiUrl = String.format("%s/credentials/store/system/domain/_/credential/%s/config.xml", baseUrl, credentialName);

    	ResponseEntity<String> response = client.requestJenkinsCrumbAPI(apiUrl, id, password, crumb, HttpMethod.POST, credentialXml, String.class);

    	return response;
    }

    /**
     * Delete Jenkins credential
     */
    public ResponseEntity<Object> deleteCredential(String baseUrl, String id, String password, Crumb crumb, String credentialName) {
    	String apiUrl = String.format("%s/credentials/store/system/domain/_/credential/%s/doDelete", baseUrl, credentialName);

    	ResponseEntity<Object> response = client.requestJenkinsCrumbAPI(apiUrl, id, password, crumb, HttpMethod.POST, null, Object.class);

    	return response;
    }
}
