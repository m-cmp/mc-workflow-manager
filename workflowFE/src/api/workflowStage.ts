import request from "@/common/request";
import type { WorkflowStage } from "@/views/type/type";


// Comment translated to English.
export const getWorkflowStageTypeList = () => {
  return request.get('/workflowStageType/list')
}

// Comment translated to English.
export const getWorkflowStageList = () => {
  return request.get('/workflowStage/list')
}

// Comment translated to English.
export function getWorkflowStageDetailInfo(workflowStageIdx:number) {
  return request.get("/workflowStage/" + workflowStageIdx);
}

// Comment translated to English.
export function duplicateCheck(param: { workflowStageName:string, workflowStageTypeName:string}) {
  return request.get(`/workflowStage/duplicate?workflowStageName=${param.workflowStageName}&workflowStageTypeName=${param.workflowStageTypeName}`)
}

// Comment translated to English.
export function registWorkflowStage(param: WorkflowStage) {
  return request.post(`/workflowStage`, param)
}

// Comment translated to English.
export function updateWorkflowStage(param: WorkflowStage) {
  return request.patch(`/workflowStage/${param.workflowStageIdx}`, param)
}

// Comment translated to English.
export function deleteWorkflowStage(workflowStageIdx: number) {
  return request.delete(`/workflowStage/${workflowStageIdx}`)
}

// Comment translated to English.
export function getWorkflowStageDefaultScript(workflowStageTypeName: string) {
  return request.get(`/workflowStage/default/script/${workflowStageTypeName}`)
}













