package kr.co.strato.mcmp.workflow.mapper;

import java.util.List;

import kr.co.strato.mcmp.workflow.model.Workflow;
import org.apache.ibatis.annotations.Mapper;

import kr.co.strato.mcmp.workflow.model.Workflow;
import kr.co.strato.mcmp.workflow.model.WorkflowHistory;
import kr.co.strato.mcmp.jenkins.pipeline.model.Pipeline;

@Mapper
public interface WorkflowMapper {

    // 워크플로우 목록 조회
    List<Workflow> selectWorkflowList(Workflow workflow);

    // 워크플로우 등록
    int insertWorkflow(Workflow workflow);

    // 워크플로우 파라미터 등록
    int insertWorkflowParams(Workflow workflow);

    // 젠킨스 파이프라인 등록
    int insertWorkflowPipeline(Workflow workflow);

    // 워크플로우 상세 조회(Id)
    Workflow selectWorkflow(int workflowId);
    // 워크플로우 상세 조회(name)
    Workflow selectWorkflowForName(String workflowName);

    // 파라미터 목록 조회
    List<Workflow.params> selectWorkflowParamList(int workflowId);
    // 젠킨스 파이프라인 목록 조회
    List<Pipeline> selectWorkflowPipelineList(int workflowId);

    // 워크플로우 명 중복 체크
    boolean isWorkflowNameDuplicated(String workflowName);

    // 워크플로우 배포 수정
    int updateWorkflow(Workflow workflow);

    // 젠킨스 파이프라인 배포 삭제
    int deleteWorkflowPipeline(int workflowId);

    // 워크플로우 배포 이력 등록
    int insertWorkflowHistory(WorkflowHistory history);

    // 워크플로우 배포 삭제
    int deleteWorkflow(int workflowId);

    // 워크플로우 파라미터 삭제
    int deleteWorkflowParam(int workflowId);





















    // 워크플로우 배포 이력 목록 조회
    List<WorkflowHistory> selectWorkflowHistoryList(int workflowId);

    // 워크플로우 배포 이력 상세 조회
    WorkflowHistory selectWorkflowHistory(int workflowHistoryId);


    // 워크플로우 배포 이력 수정
    int updateWorkflowHistory(WorkflowHistory history);

    // 워크플로우 배포 이력 삭제
    int deleteWorkflowHistory(int workflowId);
}
