package kr.co.strato.mcmp.deploy.model;

import java.io.Serializable;
import java.util.List;

import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.strato.mcmp.jenkins.pipeline.model.Pipeline;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Tag(name = "Deploy", description = "워크플로우 배포")
public class Deploy implements Serializable {

	private static final long serialVersionUID = -8388783861371138452L;
	
	private	Integer workflowId;
	private	String	workflowName;
	private	Integer gitlabId;
	private String	gitlabProjectPath;
	private	String	groupName;
	private String	projectName;
	private	String	branch;
	private Integer vmId;
	private String	vmName;
	private Integer k8sId;
	private String	k8sName;
	private String	providerCd;
	private	String	workflowYaml;
	private	Integer jenkinsId;
	private String  jenkinsJobName;
	private String  pipelineScript;			// 사용자가 편집한 파이프라인 스크립트
	
	private List<Pipeline> pipelines;		// 파이프라인 목록

    private String  regId;
    private String  regName;
    private String  regDate;
    private String  modId;
    private String  modName;
    private String  modDate;
}
