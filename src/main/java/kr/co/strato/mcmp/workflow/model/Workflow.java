package kr.co.strato.mcmp.workflow.model;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

import io.swagger.v3.oas.annotations.tags.Tag;
import kr.co.strato.mcmp.jenkins.pipeline.model.Pipeline;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Tag(name = "Workflow", description = "워크플로우 배포")
public class Workflow implements Serializable {

    private static final long serialVersionUID = -8388783861371138452L;

    // 워크플로우 일련번호
    private Integer workflowId;
    // 워크플로우 명
    private String workflowName;
    // 배포 용도(배포용/실행용/테스트용/웹훅용)
    private String workflowPurpose;
    // JENKINS_일련번호
    private Integer jenkinsId;
    // 젠킨스 URL
    private String jenkinsUrl;
    // 젠킨스 명
    private String jenkinsName;

    // 젠킨스 작업 명
    private String jenkinsJobName;
    // 젠킨스 파이프라인 스크립트
    private String pipelineScript;
    // 젠킨스 파이프라인 파라미터
    private List<params> pipelineParam;
    // 젠킨스 파이프라인(stage)
    private List<Pipeline> pipelines;

    // 등록자 아이디
    private String regId;
    // 등록자 명
    private String regName;
    // 등록일시
    private String regDate;
    // 수정자 아이디
    private String modId;
    // 수정자 명
    private String modName;
    // 수정일시
    private String modDate;

    @Getter
    @Setter
    public static class params {
        private String paramKey;
        private String paramValue;
    }
}
