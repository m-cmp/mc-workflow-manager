/*
    2023.02.24 신규 devops deploy 공통 api 작업
*/

import request from "@/common/request";

// 수정 완료
export function getDeployList(params) {
    return request.post('/deploy/list',params);
}

// deploy  상세정보 구하기
export function getDeployDetailInfo(workflowId) {
  return request.get("/deploy/" + workflowId);
}

// 수정 완료
export function duplicateCheck(params) {
  return request.get(`/deploy/name/duplicate?deployName=${params.workflowName}`)
}


export function getPipelineLog(params) {
  return request.post('/getPipelineLog', params)
}

export function getPipelineLogDetail(link) {
    return request({
        headers:{'Content-Type': 'application/json' },
        url: '/getPipelineLogDetail',
        method: 'post',
        data:link
    })
  }

export function getConsoleLog(params) {
    return request.post('/deploy/getConsoleLog', params)
}


export function getProfiles(params) {
    return request.post('/projects/profiles', params)
}

// 수정 완료
export function getStageList(){
    return request.get('/common/group/stage')
}

export function getDeployCdList(){
    return request.get('/common/group/deploy')
}


// 수정 완료
export function getProviderList(){
    return request.get('/common/group/provider')
}

export function getStageListByRemoteHostId(remoteHostId){
    return request.get('/deploy/getStageListByRemoteHostId/'+remoteHostId)
}

// 수정 완료
export function getDeployConfigCount(providerCd){
    return request.get(`/config/k8s/count?providerCd=${providerCd}`);    
    // return request.get(`/config/k8s/count?serviceGroupId=${serviceGroupId}`);

    // return request.get(`/config/k8s/count?stageCd=`);
}

export function gitlabCloneUrlCheck(params){
    return request.get(`/deploy/gitlab/connection/check?gitlabId=${params.gitlabId}&gitlabProjectPath=${params.gitlabProjectPath}`)
}

export function getDefaultPipeline(params) {
    return request.get(`/deploy/jenkins/pipeline/default?gitlabId=${params.gitlabId}&gitlabProjectPath=${params.gitlabProjectPath}&branch=${params.branch}&k8sId=${params.k8sId}&deployName=${params.deployName}`)
}

export function getPipelineCdList(){
    return request.get(`/common/group/pipeline`);
}

export function getScriptList(params) {
    return request.get(`/deploy/jenkins/pipeline/${params.pipelineCd}`);
}
export function postWorkflowDeploy(params){
    return request.post(`/deploy`,params);
}

export function deleteWorkflowDeploy(workflowId) {
  return request.delete(`/deploy/${workflowId}`);
}

export function getWorkflowDeployDetailInfo(workflowId) {
  return request.get(`/deploy/${workflowId}`);
}

export function putWorkflowDeploy(params) {
  return request.put(`/deploy/${params.workflowId}`, params);
}

export function runWorkflowDeploy(params) {
  return request.post(`/deploy/${params.workflowId}/run`);
}