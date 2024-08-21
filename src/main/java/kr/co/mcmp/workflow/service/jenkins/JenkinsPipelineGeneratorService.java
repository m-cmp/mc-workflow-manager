package kr.co.mcmp.workflow.service.jenkins;

import kr.co.mcmp.util.JenkinsPipelineUtil;
import kr.co.mcmp.workflow.dto.entityMappingDto.WorkflowStageMappingDto;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class JenkinsPipelineGeneratorService {

	/**
	 * Template 조회 (Workflow)
	 * @return
	 */
	public List<WorkflowStageMappingDto> getWorkflowTemplate(String workflowName) {

		// Checkout And Build 파이프라인(CHECKOUTBUILD)
		WorkflowStageMappingDto startPipeline = WorkflowStageMappingDto.setWorkflowTemplate(getStartPipelineWorkflow(workflowName));

		// Docker Image or WAR File Upload(FILEUPLOAD)
		WorkflowStageMappingDto endPipeline = WorkflowStageMappingDto.setWorkflowTemplate(getEndPipeline());

		List<WorkflowStageMappingDto> pipelines = new ArrayList<>();
		pipelines.add(startPipeline);
		pipelines.add(endPipeline);

		return pipelines;
	}

	/**
	 * Pipeline 시작 부분 생성
	 */
	private String getStartPipelineWorkflow(String workflowName) {
		StringBuffer sb = new StringBuffer();

		JenkinsPipelineUtil.appendLine(sb,
			"import groovy.json.JsonOutput\n" +
				"import groovy.json.JsonSlurper\n" +
				"import groovy.json.JsonSlurperClassic");

		JenkinsPipelineUtil.appendLine(sb, "\n");

		JenkinsPipelineUtil.appendLine(sb, "def getSSHKey(jsonInput){\n" +
				"    def json = new JsonSlurper().parseText(jsonInput)\n" +
				"    def eachPemVal = '';\n" +
				"    json.each { myData ->\n" +
				"        if(eachPemVal != ''){return true}\n" +
				"        if(myData.key == 'McisSubGroupAccessInfo'){\n" +
				"            def v1 = myData.value\n" +
				"            v1.each{vv ->\n" +
				"                if(eachPemVal != ''){return true}\n" +
				"                vv.each{\n" +
				"                    vv2 ->\n" +
				"                    if(eachPemVal != ''){return true}\n" +
				"                    if(vv2.key == \"McisVmAccessInfo\"){\n" +
				"                        def v2 = vv2.value\n" +
				"                        v2.each{\n" +
				"                            vv3 ->\n" +
				"                            if(eachPemVal != ''){return true}\n" +
				"                            vv3.each{\n" +
				"                                vvv3 ->\n" +
				"                                if(eachPemVal != ''){return true}\n" +
				"                                 if(vvv3.key == \"privateKey\"){\n" +
				"                                    eachPemVal = vvv3.value;\n" +
				"                                    return true;\n" +
				"                                 }\n" +
				"                            }\n" +
				"                        } \n" +
				"                    } \n" +
				"                }\n" +
				"            }\n" +
				"        }\n" +
				"    }\n" +
				"    return eachPemVal\n" +
				"}");

		JenkinsPipelineUtil.appendLine(sb, "\n");

		JenkinsPipelineUtil.appendLine(sb, "def getPublicInfoList(jsonInput){\n" +
				"    def json = new JsonSlurper().parseText(jsonInput)\n" +
				"    def eachPemVal = [];\n" +
				"    json.each { myData ->\n" +
				"        if(myData.key == 'McisSubGroupAccessInfo'){\n" +
				"           def v1 = myData.value\n" +
				"           def v1ary = v1.McisVmAccessInfo\n" +
				"           v1ary.each{ v2 -> \n" +
				"                v2.each{ v3 ->\n" +
				"                   eachPemVal.add(v3.publicIP)\n" +
				"                }\n" +
				"           }\n" +
				"        }\n" +
				"    }\n" +
				"    return eachPemVal\n" +
				"}");

		JenkinsPipelineUtil.appendLine(sb, "\n");

		JenkinsPipelineUtil.appendLine(sb, "pipeline {\n" +
				"  agent any\n" +
				"  \n" +
				"  environment {\n" +
				"    env = ''\n" +
				"  }\n" +
				"  \n" +
				"  stages {\n");

		return sb.toString();
	}
	/**
	 * Pipeline 끝 부분 생성
	 */
	public String getEndPipeline() {
		StringBuffer sb = new StringBuffer();

		JenkinsPipelineUtil.appendLine(sb, "  }\n" +
				"}\n");

		return sb.toString();
	}
}
