package kr.co.strato.mcmp.deploy.model;

import java.io.Serializable;

import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Tag(name = "DeployHistory", description = "워크플로우 배포 이력")
public class DeployHistory implements Serializable {

	private static final long serialVersionUID = -7862871855538941152L;

	private	Integer workflowHistoryId;
	private	Integer workflowId;
	private	String	workflowYaml;
	private	String  pipelineScript;
	private	Integer	jenkinsBuildId;
	private	Integer	buildNumber;
	private	String	runResult;
	private	String 	runMessage;

	private String 	runUserId;
	private String 	runUserName;
	private String 	runDate;
}
