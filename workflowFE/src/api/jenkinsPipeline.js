import request from "@/common/request";

// Jenkins 파이프라인 목록
export function getJenkinsPipeLineList() {
  return request({
     url: `/wf/pipeline/list`,
     method: 'get',
  })
}

// Jenkins 파이프라인 생성
export function createJenkinsPipeLine(data) {
  return request({
     url: `/wf/pipeline`,
     method: 'post',
     data
  })
}

// Jenkins 파이프라인 수정
export function updateJenkinsPipeLine(data) {
  return request({
     url: `/wf/pipeline/${data.pipelineId}`,
     method: 'put',
     data
  })
}

// Jenkins 파이프라인 상세
export function getPipelineDetail(pipelineId) {
  return request({
     url: `/wf/pipeline/${pipelineId}`,
     method: 'get',
  })
}

// Jenkins 파이프라인 삭제
export function deleteJenkinsPipeline(data) {
  return request({
     url: `/wf/pipeline/${data.pipelineId}`,
     method: 'delete',
  })
}

// Jenkins 파이프라인 명 중복체크
export function duplicateJenkinsPipelineName(data) {
  return request({
    url: `/wf/pipeline/name/duplicate?pipelineCd=${data.pipelineCd}&pipelineName=${data.pipelineName}`,
    method: 'get',
  })
}

export function getStageCdList() {
  return request({
    url: `/common/group/Pipeline`,
    method: 'get',
  })
}

export function getBuildCdList() {
  return request({
    url: `/common/group/ProjectBuild`,
    method: 'get',
  })
}

export function updateStageCdList(data) {
  return request({
    url: `/common/group/Pipeline/code`,
    method: 'post',
    data
  })
}

export function deleteStageCdList(data) {
  return request({
    url: `/common/group/Pipeline/code/${data.commonCd}`,
    method: 'delete',
  })
}

export function getDefaultScript(data) {
  return request({
    url: `/wf/pipeline/default?pipelineCd=${data.pipelineCd}`,
    method: 'get',
  })
}
