import request from "@/common/request";
import type { Workflow } from "@/views/type/type"

// 워크플로우 목록
export const getWorkflowList = () => {
  return request.get('/workflow/list')
}

// 중복확인
export function duplicateCheck(workflowName:string) {
  return request.get(`/workflow/name/duplicate?workflowName=${workflowName}`)
}

// default 스크립트
export function getTemplateStage(workflowName:string) {
  return request.get(`/workflow/template/${workflowName}`)
}

// 파이프라인 목록
export function getWorkflowPipelineList() {
  return request.get(`/workflow/workflowStageList`)
}

// 파이프라인 구분 목록
export function getPipelineCdList() {
  return request.get(`/workflowStageType/list`);
}

// 워크플로우 상세
export function getWorkflowDetailInfo(workflowIdx:number | string | string[]) {
  return request.get("/workflow/" + workflowIdx);
}

// 저장
export function registWorkflow(workflow: Workflow | any) {
  return request.post(`/workflow`, workflow);
}

// 수정
export function updateWorkflow(workflow: Workflow | any) {
  return request.patch(`/workflow/${workflow.workflowInfo.workflowIdx}`, workflow);
}


// 삭제
export function deleteWorkflow(workflowIdx: number) {
  return request.delete(`/workflow/${workflowIdx}`);
}

// 배포 실행
export function runWorkflow(params: Workflow) {
  return request.post(`/workflow/run`, params);
}























// export function getWorkflowDeployDetailInfo(workflowIdx) {
//   return request.get(`/workflow/${workflowIdx}`);
// }

// export function putWorkflowDeploy(params) {
//   return request.put(`/workflow/${params.workflowIdx}`, params);
// }

// export function workflowHistoryList(workflowIdx) {
//   return request.get(`/jenkins/logs/${workflowIdx}`)
// }






















// export function getPipelineLog(params) {
//   return request.post('/getPipelineLog', params)
// }

// export function getPipelineLogDetail(link) {
//     return request({
//         headers:{'Content-Type': 'application/json' },
//         url: '/getPipelineLogDetail',
//         method: 'post',
//         data:link
//     })
//   }

// export function getConsoleLog(params) {
//     return request.post('/deploy/getConsoleLog', params)
// }


// export function getProfiles(params) {
//     return request.post('/projects/profiles', params)
// }

// // 수정 완료
// export function getStageList(){
//     return request.get('/common/group/stage')
// }

// export function getDeployCdList(){
//     return request.get('/common/group/deploy')
// }


// // 수정 완료
// export function getProviderList(){
//     return request.get('/common/group/provider')
// }

// export function getStageListByRemoteHostId(remoteHostId){
//     return request.get('/deploy/getStageListByRemoteHostId/'+remoteHostId)
// }

// // 수정 완료
// export function getDeployConfigCount(providerCd){
//     return request.get(`/config/k8s/count?providerCd=${providerCd}`);    
//     // return request.get(`/config/k8s/count?serviceGroupId=${serviceGroupId}`);

//     // return request.get(`/config/k8s/count?stageCd=`);
// }

// export function gitlabCloneUrlCheck(params){
//     return request.get(`/deploy/gitlab/connection/check?gitlabId=${params.gitlabId}&gitlabProjectPath=${params.gitlabProjectPath}`)
// }






