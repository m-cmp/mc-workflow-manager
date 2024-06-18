package kr.co.strato.mcmp.deploy.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import kr.co.strato.mcmp.deploy.model.Deploy;
import kr.co.strato.mcmp.deploy.model.DeployHistory;
import kr.co.strato.mcmp.jenkins.pipeline.model.Pipeline;

@Mapper
public interface DeployMapper {

	// 워크플로우 배포 목록 조회
	List<Deploy> selectDeployList(Deploy deploy);
	
	// 워크플로우 배포 상세 조회
	Deploy selectDeploy(int deployId);
	
	// 워크플로우 배포명 중복 체크
	boolean isDeployNameDuplicated(String deployName);
	
	// 워크플로우 배포 등록
	int insertDeploy(Deploy deploy);
	
	// 워크플로우 배포 수정
	int updateDeploy(Deploy deploy);
	
	// 워크플로우 배포 삭제
	int deleteDeploy(int deployId);

	// 젠킨스 파이프라인 목록 조회
	List<Pipeline> selectDeployPipelineList(int deployId);

	// 젠킨스 파이프라인 배포 등록
	int insertDeployPipeline(Deploy deploy);

	// 젠킨스 파이프라인 배포 삭제
	int deleteDeployPipeline(int deployId);
	
	// 워크플로우 배포 이력 목록 조회
	List<DeployHistory> selectDeployHistoryList(DeployHistory history);
	
	// 워크플로우 배포 이력 상세 조회
	DeployHistory selectDeployHistory(int workflowHistoryId);
	
	// 워크플로우 배포 이력 등록
	int insertDeployHistory(DeployHistory history);
	
	// 워크플로우 배포 이력 수정
	int updateDeployHistory(DeployHistory history);
	
	// 워크플로우 배포 이력 삭제
	int deleteDeployHistory(int workflowId);
}
