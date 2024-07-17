package kr.co.strato.jenkins.pipeline.service;

import java.util.ArrayList;
import java.util.List;

//import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

//import kr.co.strato.jenkins.pipeline.mapper.JenkinsPipelineMapper;
import kr.co.strato.jenkins.pipeline.model.Pipeline;
import kr.co.strato.util.JenkinsPipelineUtil;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class JenkinsPipelineService {

//	@Autowired
//	private JenkinsPipelineMapper pipelineMapper;
//
//	/**
//	 * 스테이지 목록 조회
//	 * @param pipeline
//	 * @return
//	 */
//	public List<Pipeline> getPipelineList(Pipeline pipeline) {
//		return pipelineMapper.selectJenkinsPipelineList(pipeline);
//	}
//
//	/**
//	 * 스테이지 상세 조회
//	 * @param pipelineId
//	 * @return
//	 */
//	public Pipeline getPipeline(int pipelineId) {
//		return pipelineMapper.selectJenkinsPipeline(pipelineId);
//	}
//
//	/**
//	 * 기본 스크립트 조회
//	 * @param pipelineCd
//	 * @return
//	 */
//	public List<Pipeline> getDefaultPipeline(String pipelineCd) {
//		Pipeline pipeline = new Pipeline();
//		pipeline.setPipelineCd(pipelineCd);
//
//		List<Pipeline> pipelines = pipelineMapper.selectJenkinsPipelineList(pipeline);
//		if ( CollectionUtils.isEmpty(pipelines) ) {
//			StringBuffer sb = new StringBuffer();
//
//			JenkinsPipelineUtil.appendLine(sb, "stage('" + pipelineCd.toLowerCase().replaceAll("_", " ") + "') {", 2);
//			JenkinsPipelineUtil.appendLine(sb, "steps {", 3);
//			JenkinsPipelineUtil.appendLine(sb, "echo '>>>>>STAGE: " + pipelineCd + "'", 4);
//			JenkinsPipelineUtil.appendLine(sb, "", 1);
//			JenkinsPipelineUtil.appendLine(sb, "// 스크립트를 작성해주세요.", 4);
//			JenkinsPipelineUtil.appendLine(sb, "}", 3);
//			JenkinsPipelineUtil.appendLine(sb, "}", 2);
//			JenkinsPipelineUtil.appendLine(sb, "", 1);
//
//			pipeline.setPipelineScript(sb.toString());
//
//			pipelines = new ArrayList<>();
//			pipelines.add(pipeline);
//		}
//
//		return pipelines;
//	}
//
//	/**
//	 * 스테이지 명 중복 체크
//	 * @param pipelineCd
//	 * @param pipelineName
//	 * @return
//	 */
//	public boolean isPipelineNameDuplicated(String pipelineCd, String pipelineName) {
//		Pipeline pipeline = new Pipeline();
//		pipeline.setPipelineCd(pipelineCd);
//		pipeline.setPipelineName(pipelineName);
//
//		// 중복이면 true / 아니면 false
//		return pipelineMapper.isPipelineNameDuplicated(pipeline);
//	}
//
//	/**
//	 * 스테이지 등록
//	 * @param pipeline
//	 * @return
//	 */
//	public int createPipeline(Pipeline pipeline) {
//		pipelineMapper.insertJenkinsPipeline(pipeline);
//		return pipeline.getPipelineId();
//	}
//
//	/**
//	 * 스테이지 수정
//	 * @param pipeline
//	 * @return
//	 */
//	public int updatePipeline(Pipeline pipeline) {
//		pipelineMapper.updateJenkinsPipeline(pipeline);
//		return pipeline.getPipelineId();
//	}
//
//	/**
//	 * 스테이지 삭제
//	 * @param pipelineId
//	 * @return
//	 */
//	public int deletePipeline(int pipelineId) {
//		return pipelineMapper.deleteJenkinsPipeline(pipelineId);
//	}
}

	
	