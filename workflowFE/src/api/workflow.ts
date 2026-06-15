import request from "@/common/request";
import type { Workflow } from "@/views/type/type"

// Comment translated to English.
// export const getWorkflowList = () => {
//   return request.get('/workflow/list')
// }
export const getWorkflowList = (eventlistenerYn:String) => {
  return request.get(`/eventlistener/workflowList/${eventlistenerYn}`)
}

// Comment translated to English.
export function duplicateCheck(workflowName:string) {
  return request.get(`/workflow/name/duplicate?workflowName=${encodeURIComponent(workflowName)}`)
}

// Comment translated to English.
export function getTemplateStage(workflowName:string) {
  return request.get(`/workflow/template/${workflowName}`)
}

// Comment translated to English.
export function getWorkflowPipelineList() {
  return request.get(`/workflow/workflowStageList`)
}

// Comment translated to English.
export function getPipelineCdList() {
  return request.get(`/workflowStageType/list`);
}

// Comment translated to English.
// export function getWorkflowDetailInfo(workflowIdx:number | string | string[]) {
//   return request.get("/workflow/" + workflowIdx + "/N");
// }
export function getWorkflowDetailInfo(workflowIdx:number | string | string[], eventlistenerYn:String) {
  return request.get(`/eventlistener/workflowDetail/${workflowIdx}/${eventlistenerYn}`);
}

// Comment translated to English.
export function registWorkflow(workflow: Workflow | any) {
  return request.post(`/workflow`, workflow);
}

// Comment translated to English.
export function updateWorkflow(workflow: Workflow | any) {
  return request.patch(`/workflow/${workflow.workflowInfo.workflowIdx}`, workflow);
}


// Comment translated to English.
export function deleteWorkflow(workflowIdx: number) {
  return request.delete(`/workflow/${workflowIdx}`);
}

// Comment translated to English.
export function runWorkflow(params: Workflow | any) {
  return request.post(`/workflow/run`, params);
}

export function existEventListener(workflowIdx: number) {
  return request.get(`/workflow/existEventListener/${workflowIdx}`);
}

export function getWorkflowLog(workflowIdx: number) {
  return request.get(`/workflow/log/${workflowIdx}`)
}

export function getWorkflowRunHistory(workflowIdx?: number | string | string[]) {
  return request.get(`/workflow/runHistory/${workflowIdx}`)
}

export function getWorkflowRunHistoryDetail(params: { workflowIdx: string | number | string[] | undefined, buildName: string, stageIdx: string }) {
  return request.get(`/workflow/stageHistory/${params.workflowIdx}?buildIdx=${params.buildName}&nodeIdx=${params.stageIdx}`)
}
