package kr.co.mcmp.workflow.service.jenkins.service;

import com.cdancy.jenkins.rest.domain.common.RequestStatus;
import com.cdancy.jenkins.rest.domain.crumb.Crumb;
import com.cdancy.jenkins.rest.domain.job.BuildInfo;
import kr.co.mcmp.api.response.ResponseCode;
import kr.co.mcmp.exception.McmpException;
import kr.co.mcmp.oss.dto.OssDto;
import kr.co.mcmp.util.NamingUtils;
import kr.co.mcmp.util.XMLUtil;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowParamDto;
import kr.co.mcmp.workflow.dto.resDto.WorkflowRunHistoryResDto;
import kr.co.mcmp.workflow.service.jenkins.api.JenkinsRestApi;
import kr.co.mcmp.workflow.service.jenkins.exception.JenkinsException;
import kr.co.mcmp.workflow.service.jenkins.model.JenkinsBuildDescribeLog;
import kr.co.mcmp.workflow.service.jenkins.model.JenkinsCredential;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClientResponseException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import javax.xml.xpath.XPathExpressionException;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor
@Service
public class JenkinsService {

	private static final String RESOURCE_JENKINS_PATH = "/static/jenkins/";

	private static final String PIPELINE_XML_PATH = "/flow-definition/definition/script";

	private final JenkinsRestApi api;

    /* Comment translated to English. */
    public boolean isJenkinsConnect(OssDto jenkins) {
        return api.isConnect(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword());
    }

    /* Comment translated to English. */
    public boolean isExistJobName(OssDto jenkins, String jobName) {
        try {
            return Optional.ofNullable(api.getJenkinsJob(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), jobName)).isPresent();
        } catch (Exception e) {
            log.warn("Jenkins Job lookup failed or job does not exist. jobName: {}, message: {}", jobName, e.getMessage());
            return false;
        }
    }

    /* Comment translated to English. */
    public boolean createJenkinsJob_v2(OssDto jenkins, String jenkinsJobName, String pipelineScript, List<WorkflowParamDto> params) throws IOException {

        if ( isExistJobName(jenkins, jenkinsJobName) ) {
            log.error("[createJenkinsJob] Jenkins Job Name {} is exist.", jenkinsJobName);
            throw new McmpException(ResponseCode.EXISTS_JENKINS_JOB);
        }

        Document jobTemplateDocument = XMLUtil.getDocument(new ClassPathResource(RESOURCE_JENKINS_PATH+"jenkins-k8s-deploy-job-template.xml").getInputStream());

        addParameter(jobTemplateDocument, params);

        String configXml = null;
        try {
            Document addPipelineDoc = XMLUtil.appendXml(jobTemplateDocument, PIPELINE_XML_PATH, pipelineScript);
            configXml = XMLUtil.XmlToString(addPipelineDoc);
        } catch (XPathExpressionException e) {
            e.printStackTrace();
            throw new McmpException(ResponseCode.UNKNOWN_ERROR);
        }

        RequestStatus req = api.createJenkinsJob(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), jenkinsJobName, configXml);
        if ( req.value() ) {
            return true;
        } else {
            log.error("[createJenkinsJob] Jenkins Job create fail. message: {}", req.errors());
            throw new McmpException(ResponseCode.ERROR_JENKINS_API);
        }
    }
//
//    /*******
// Comment translated to English.
// Comment translated to English.
//     * @throws UnsupportedEncodingException
//     *
//     */
//    public boolean updateJenkinsJobPipeline(Oss jenkins, String jobName, String pipeline) throws UnsupportedEncodingException {
//        if ( !isExistJobName(jenkins, jobName) ) {
//            log.error("Jenkins Job Name {} is not exist.", jobName);
//            throw new McmpException(ResponseCode.NOT_EXISTS_JENKINS_JOB);
//        }
//
//        Document document = this.getJobConfigXml(jenkins, jobName);
//
//        String configXml = null;
//        try {
//            Document addPipelineDoc = XMLUtil.appendXml(document, PIPELINE_XML_PATH, pipeline);
//            configXml = XMLUtil.XmlToString(addPipelineDoc);
//        } catch (XPathExpressionException e) {
//            e.printStackTrace();
//            throw new McmpException(ResponseCode.UNKNOWN_ERROR);
//        }
//
//        boolean result = api.updateJenkinsJob(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), jobName, configXml);
//        if ( !result ) {
//            log.error("[updateJenkinsJobPipeline] Jenkins Job pipeline update fail.");
//            throw new McmpException(ResponseCode.ERROR_JENKINS_API);
//        }
//
//        return result;
//    }
//
    /* Comment translated to English. */
    public boolean updateJenkinsJobPipeline_v2(OssDto jenkins, String jenkinsJobName, String pipelineScript, List<WorkflowParamDto> params) throws IOException {
        if ( !isExistJobName(jenkins, jenkinsJobName) ) {
            log.error("Jenkins Job Name {} is not exist.", jenkinsJobName);
            throw new McmpException(ResponseCode.NOT_EXISTS_JENKINS_JOB);
        }

        Document document = this.getJobConfigXml(jenkins, jenkinsJobName);
        if (document == null) {
            document = XMLUtil.getDocument(new ClassPathResource(RESOURCE_JENKINS_PATH+"jenkins-k8s-deploy-job-template.xml").getInputStream());
        }

        addParameter(document, params);
        setQuietPeriodZero(document);

        String configXml = null;
        try {
            Document addPipelineDoc = XMLUtil.appendXml(document, PIPELINE_XML_PATH, pipelineScript);
            configXml = XMLUtil.XmlToString(addPipelineDoc);
        } catch (XPathExpressionException e) {
            e.printStackTrace();
            throw new McmpException(ResponseCode.UNKNOWN_ERROR);
        }

        boolean result = api.updateJenkinsJob(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), jenkinsJobName, configXml);
        if ( !result ) {
            log.error("[updateJenkinsJobPipeline] Jenkins Job pipeline update fail.");
            throw new McmpException(ResponseCode.ERROR_JENKINS_API);
        }
        verifyUpdatedJobConfig(jenkins, jenkinsJobName, pipelineScript);

        return result;
    }

    public int updateAndBuildJenkinsJobForRun(OssDto jenkins, String jenkinsJobName, String pipelineScript,
                                              List<WorkflowParamDto> params,
                                              Map<String, List<String>> jenkinsJobParams) throws IOException {
        if ( !isExistJobName(jenkins, jenkinsJobName) ) {
            createJenkinsJob_v2(jenkins, jenkinsJobName, pipelineScript, params);
            return buildJenkinsJob(jenkins, jenkinsJobName, jenkinsJobParams);
        }

        Document document = this.getJobConfigXml(jenkins, jenkinsJobName);
        if (document == null) {
            document = XMLUtil.getDocument(new ClassPathResource(RESOURCE_JENKINS_PATH+"jenkins-k8s-deploy-job-template.xml").getInputStream());
        }

        addParameter(document, params);
        setQuietPeriodZero(document);

        String configXml = null;
        try {
            Document addPipelineDoc = XMLUtil.appendXml(document, PIPELINE_XML_PATH, pipelineScript);
            configXml = XMLUtil.XmlToString(addPipelineDoc);
        } catch (XPathExpressionException e) {
            e.printStackTrace();
            throw new McmpException(ResponseCode.UNKNOWN_ERROR);
        }

        String verificationMarker = resolvePipelineVerificationMarker(pipelineScript);
        log.info("[updateAndBuildJenkinsJobForRun] Jenkins Job config update/build requested. jobName: {}, marker: {}",
                jenkinsJobName, verificationMarker);
        return api.updateJenkinsJobAndBuildNow(
                jenkins.getOssUrl(),
                jenkins.getOssUsername(),
                jenkins.getOssPassword(),
                jenkinsJobName,
                configXml,
                jenkinsJobParams,
                verificationMarker);
    }

    private void verifyUpdatedJobConfig(OssDto jenkins, String jenkinsJobName, String pipelineScript) {
        String marker = resolvePipelineVerificationMarker(pipelineScript);
        if (!StringUtils.hasText(marker)) {
            return;
        }

        try {
            Document jobConfigXml = getJobConfigXml(jenkins, jenkinsJobName);
            String currentConfig = XMLUtil.XmlToString(jobConfigXml);
            if (currentConfig == null || !currentConfig.contains(marker)) {
                log.error("[updateJenkinsJobPipeline] Jenkins Job config verification failed. jobName: {}, marker: {}",
                        jenkinsJobName, marker);
                throw new McmpException(ResponseCode.ERROR_JENKINS_API);
            }
            log.info("[updateJenkinsJobPipeline] Jenkins Job config verified. jobName: {}, marker: {}",
                    jenkinsJobName, marker);
        } catch (McmpException e) {
            throw e;
        } catch (Exception e) {
            log.error("[updateJenkinsJobPipeline] Jenkins Job config verification error. jobName: {}, marker: {}",
                    jenkinsJobName, marker, e);
            throw new McmpException(ResponseCode.ERROR_JENKINS_API);
        }
    }

    private String resolvePipelineVerificationMarker(String pipelineScript) {
        if (!StringUtils.hasText(pipelineScript)) {
            return null;
        }
        if (pipelineScript.contains("k8s-helm-bootstrap-v3")) {
            return "k8s-helm-bootstrap-v3";
        }
        if (pipelineScript.contains("k8s-cluster-create payload")) {
            return "k8s-cluster-create payload";
        }
        if (pipelineScript.contains("Installing helm ")) {
            return "Installing helm ";
        }
        return null;
    }

    /* Comment translated to English. */
    public Document getJobConfigXml(OssDto jenkins, String jobName) {
        String xmlStr = api.getJenkinsJobConfigXml(
                jenkins.getOssUrl(),
                jenkins.getOssUsername(),
                jenkins.getOssPassword(),
                jobName);
        return XMLUtil.getDocument(xmlStr);
    }


    /* Comment translated to English. */
    public boolean deleteJenkinsJob(OssDto jenkins, String jobName) {
    	boolean result = true;

        // Comment translated to English.
        if ( !isExistJobName(jenkins, jobName) ) {
            log.error("[deleteJenkinsJob] Jenkins Job Name {} does not exist.", jobName);
            return result;
        }

        RequestStatus req = api.deleteJenkinsJob(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), jobName);
        if ( !req.value() ) {
            log.error("[deleteJenkinsJob] Jenkins Job delete fail. message: {}", req.errors());
            throw new McmpException(ResponseCode.ERROR_JENKINS_API);
        }

        return result;
    }

    /* Comment translated to English. */
    public Crumb getJenkinsCrumb(OssDto jenkins) {

        Crumb crumb = api.getJenkinsCrumb(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword());

        return crumb;
    }

    /* Comment translated to English. */
    public boolean isCredentialExist(OssDto jenkins, String credentialName){
        try {
            api.getCredential(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), credentialName);
            return true;
        } catch (RestClientResponseException e){
            if(e.getRawStatusCode() == ResponseCode.NOT_FOUND.getCode()){
                return false;
            }else{
                throw new McmpException(ResponseCode.ERROR_JENKINS_API);
            }
        }
    }
//
//    /**
// Comment translated to English.
//     */
//    public String createCredential(Oss jenkins, Oss credentialOss, K8SConfig k8s, String credentialType) {
//        Crumb crumb = getJenkinsCrumb(jenkins);
//
//        String credentialName = null;
//        if ( credentialOss != null ) {
//        	credentialName = NamingUtils.getCredentialName(credentialOss.getOssId(), credentialOss.getOssName());
//        }
//        else {
//        	credentialName = NamingUtils.getCredentialName(k8s.getK8sId(), k8s.getK8sName());
//        }
//
//        boolean isCredentialExist = this.isCredentialExist(jenkins, credentialName);
//        if ( !isCredentialExist ) {
//	        String createCredentialXml = JenkinsCredential.createCredentialXml(credentialOss, k8s, credentialType);
//	        log.info("credentialXml >>> {}", createCredentialXml);
//	        api.createCredential(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), crumb, createCredentialXml);
//        }
//
//        return credentialName;
//    }
//
    /* Comment translated to English. */
    public String updateCredential(OssDto jenkins, OssDto credentialOss, String credentialType) {
    	Crumb crumb = getJenkinsCrumb(jenkins);

        String credentialName = null;
        if ( credentialOss != null ) {
        	credentialName = NamingUtils.getCredentialName(credentialOss.getOssIdx(), credentialOss.getOssName());
        }
		log.info("update credentialName >>> {}", credentialName);

    	boolean isCredentialExist = this.isCredentialExist(jenkins, credentialName);
    	if ( isCredentialExist ) {
    		String createCredentialXml = JenkinsCredential.createCredentialXml(credentialOss, credentialType);
    		log.info("credentialXml >>> {}", createCredentialXml);
    		api.updateCredential(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), crumb, credentialName, createCredentialXml);
    	}

    	return credentialName;
    }

    /* Comment translated to English. */
    public String deleteCredential(OssDto jenkins, OssDto credentialOss, String credentialType) {
    	Crumb crumb = getJenkinsCrumb(jenkins);

        String credentialName = null;
        if ( credentialOss != null ) {
        	credentialName = NamingUtils.getCredentialName(credentialOss.getOssIdx(), credentialOss.getOssName());
        }
    	log.info("delete credentialName >>> {}", credentialName);

    	boolean isCredentialExist = this.isCredentialExist(jenkins, credentialName);
    	if ( isCredentialExist ) {
    		api.deleteCredential(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), crumb, credentialName);
    	}

    	return credentialName;
    }
//
//    /**
// Comment translated to English.
//     */
//    public String getOssCredential(Oss jenkinsOss, Oss credentialOss, K8SConfig k8s, String credentialType) {
//        String credentialName = null;
//        if ( credentialOss != null ) {
//        	credentialName = NamingUtils.getCredentialName(credentialOss.getOssId(), credentialOss.getOssName());
//        }
//        else {
//        	credentialName = NamingUtils.getCredentialName(k8s.getK8sId(), k8s.getK8sName());
//        }
//
//        boolean isCredentialExist = this.isCredentialExist(jenkinsOss, credentialName);
//        if ( !isCredentialExist ) {
//            this.createCredential(jenkinsOss, credentialOss, k8s, credentialType);
//        }
//
//        return credentialName;
//    }
//
    private void addParameter(Document document, List<WorkflowParamDto> params) {
        if (CollectionUtils.isEmpty(params)) {
            return;
        }

        NodeList propertiesList = document.getElementsByTagName("properties");
        Element properties = (Element) propertiesList.item(0);

        NodeList parametersDefinitionPropertyList = properties.getElementsByTagName("hudson.model.ParametersDefinitionProperty");
        Element parameterDefinitionProperties;
        if (parametersDefinitionPropertyList.getLength() > 0) {
            parameterDefinitionProperties = (Element) parametersDefinitionPropertyList.item(0);
        } else {
            parameterDefinitionProperties = document.createElement("hudson.model.ParametersDefinitionProperty");
            properties.appendChild(parameterDefinitionProperties);
        }

        NodeList parameterDefinitionsList = parameterDefinitionProperties.getElementsByTagName("parameterDefinitions");
        for (int idx = parameterDefinitionsList.getLength() - 1; idx >= 0; idx--) {
            parameterDefinitionProperties.removeChild(parameterDefinitionsList.item(idx));
        }
        Element parameterDefinitions = document.createElement("parameterDefinitions");
        parameterDefinitionProperties.appendChild(parameterDefinitions);

        {
            Map<String, WorkflowParamDto> paramsByKey = new LinkedHashMap<>();
            for (WorkflowParamDto item : params) {
                if (item == null || item.getParamKey() == null || item.getParamKey().trim().isEmpty()) {
                    continue;
                }
                String normalizedKey = item.getParamKey().trim().toUpperCase();
                paramsByKey.put(normalizedKey, WorkflowParamDto.builder()
                        .paramIdx(item.getParamIdx())
                        .workflowIdx(item.getWorkflowIdx())
                        .paramKey(normalizedKey)
                        .paramValue(item.getParamValue() == null ? "" : item.getParamValue())
                        .eventListenerYn(item.getEventListenerYn())
                        .build());
            }

            new ArrayList<>(paramsByKey.values()).forEach(item -> {
                // Create new parameter node
                Element stringParameterDefinition = document.createElement("hudson.model.StringParameterDefinition");

                Element name = document.createElement("name");
                name.appendChild(document.createTextNode(item.getParamKey()));
                stringParameterDefinition.appendChild(name);

//                Element description = document.createElement("description");
//                description.appendChild(document.createTextNode(item.getParamDesc()));
//                stringParameterDefinition.appendChild(description);

                Element defaultValue = document.createElement("defaultValue");
                defaultValue.appendChild(document.createTextNode(item.getParamValue()));
                stringParameterDefinition.appendChild(defaultValue);

                Element trim = document.createElement("trim");
                trim.appendChild(document.createTextNode("true"));
                stringParameterDefinition.appendChild(trim);

                // Add the new parameter to the parameter definitions
                parameterDefinitions.appendChild(stringParameterDefinition);
            });
        }
    }

    private void setQuietPeriodZero(Document document) {
        Element root = document.getDocumentElement();
        Element quietPeriod = XMLUtil.getDirectChild(root, "quietPeriod");
        if (quietPeriod == null) {
            quietPeriod = document.createElement("quietPeriod");
            Element disabled = XMLUtil.getDirectChild(root, "disabled");
            if (disabled != null) {
                root.insertBefore(quietPeriod, disabled);
            } else {
                root.appendChild(quietPeriod);
            }
        }
        quietPeriod.setTextContent("0");
    }


    /* Comment translated to English. */
    public int buildJenkinsJob(OssDto jenkins, String jobName, Map<String, List<String>> jenkinsJobParams) {
        if ( !isExistJobName(jenkins, jobName) ) {
            log.error("Jenkins Job Name {} does not exist.", jobName);
            throw new McmpException(ResponseCode.NOT_EXISTS_JENKINS_JOB);
        }

        log.info("[buildJenkinsJob] Run jenkins job.");
        return api.buildJenkinsJob(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), jobName, jenkinsJobParams);
    }

    /* Comment translated to English. */
    public int getQueueExecutableNumber(OssDto jenkins, int jenkinsBuildId) {
    	return api.getQueueExecutableNumber(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), jenkinsBuildId);
    }

    public int getQueueExecutableNumber(OssDto jenkins, int jenkinsBuildId, int fallbackBuildNumber) {
        return api.getQueueExecutableNumber(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), jenkinsBuildId, fallbackBuildNumber);
    }

    public int getNextBuildNumber(OssDto jenkins, String jobName) {
        return api.getNextBuildNumber(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), jobName);
    }

    /* Comment translated to English. */
    public BuildInfo waitJenkinsBuild(OssDto jenkins, String jobName, int jenkinsBuildId, int buildNumber) {
        log.info("[buildJenkinsJob] Wait jenkins job >> JENKINS_BUILD_ID: {}", jenkinsBuildId);
        BuildInfo buildInfo = api.waitJenkinsBuild(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), jobName, jenkinsBuildId, buildNumber);

        return buildInfo;
    }

    public String getJenkinsLog(String url, String id, String password, String jobName, int buildNumber) {
        return api.getJenkinsBuildConsoleLog(url,id,password,jobName,buildNumber);
    }

    /**
     * Get build stage view
     */
    public WorkflowRunHistoryResDto getJenkinsBuildStage(OssDto jenkins, String jenkinsJobName, int buildNumber) {
        if ( !isExistJobName(jenkins, jenkinsJobName) ) {
            log.error("Jenkins Job Name {} does not exist.", jenkinsJobName);
            throw new McmpException(ResponseCode.NOT_EXISTS_JENKINS_JOB);
        }

        try {
            return api.getWorkflow(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), jenkinsJobName, buildNumber).getBody();
        } catch (JenkinsException e) {
            if ( e.getCode() == HttpStatus.UNAUTHORIZED.value() ) {
                throw new McmpException(ResponseCode.INCORRECT_JENKINS_CONNECTION_INFO);
            }
            else {
                throw new McmpException(ResponseCode.INTERNAL_SERVER_ERROR, e.getMessage());
            }
        }
    }

    /**
     * Get build stage logs
     *
     */
    public JenkinsBuildDescribeLog getJenkinsBuildStageLog(OssDto jenkins, String jenkinsJobName, int buildNumber, int nodeId) {
        if ( !isExistJobName(jenkins, jenkinsJobName) ) {
            log.error("Jenkins Job Name {} does not exist.", jenkinsJobName);
            throw new McmpException(ResponseCode.NOT_EXISTS_JENKINS_JOB);
        }

        try {
            return api.getPipelineNode(jenkins.getOssUrl(), jenkins.getOssUsername(), jenkins.getOssPassword(), jenkinsJobName, buildNumber, nodeId).getBody();
        } catch (JenkinsException e) {
            if ( e.getCode() == HttpStatus.UNAUTHORIZED.value() ) {
                throw new McmpException(ResponseCode.INCORRECT_JENKINS_CONNECTION_INFO);
            }
            else {
                throw new McmpException(ResponseCode.INTERNAL_SERVER_ERROR, e.getMessage());
            }
        }
    }
}
