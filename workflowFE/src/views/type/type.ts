export interface Oss {
  ossIdx: number
  ossTypeIdx: number
  ossName: string
  ossDesc: string
  ossUsername: string
  ossPassword: string
  ossUrl: string
}
export interface OssType {
  ossTypeIdx: number
  ossTypeName: string
  ossTypeDesc: string
}
export interface WorkflowStage {
  workflowStageIdx: number
  workflowStageTypeIdx: number
  workflowStageTypeName: string
  workflowStageName: string
  workflowStageDesc: string
  workflowStageContent: string
  workflowStageOrder: number
}

export interface WorkflowStageType {
  workflowStageTypeDesc: string
  workflowStageTypeIdx: number 
  workflowStageTypeName: string
}

export interface Workflow {
  workflowInfo: WorkflowInfo
  workflowParams: Array<WorkflowParams>
  workflowStageMappings: Array<WorkflowStageMappings>
}

export interface WorkflowInfo {
  workflowIdx?: number | string | string[]
  workflowName: string
  workflowPurpose: string
  ossIdx: number
  script: string | string[]
}

export interface WorkflowParams {
  paramIdx?: number
  paramKey: string
  paramValue: string
}
        
export interface WorkflowStageMappings {
  mappingIdx?: number
  stageOrder: number
  workflowStageTypeIdx: number
  stageContent: string

  defaultScriptTag: string
  isDefaultScript: boolean
}

export interface WorkflowPurpose {
  name: string
  value: string
}

export interface EventListener {
  eventListenerIdx: number
  eventListenerName: string
  eventListenerDesc: string
  eventListenerUrl: string
  workflowIdx: number
  eventListenerCallUrl: string
}

export interface WorkflowLog {
  buildIdx: number
  buildLog: string
}


























// export interface Pipeline {
//   pipelineId: number
// 	pipelineCd: string
// 	pipelineCdName: string
// 	pipelineName: string
// 	pipelineScript: string
//   pipelineOrder: number
//   isDefaultScript: boolean
//   defaultScriptTag: string
// }

// export interface PipelineCd {
//   codeDesc: string
//   codeName: string
//   codeOrder: number
//   commonCd: string
//   commonGroupCd: string
//   modDate: string
//   modId: string
//   modName: string
//   protectedYn: string
//   regDate: string
//   regId: string
//   regName: string
// }

// export interface History {
//   workflowHistoryId: number
//   workflowIdx: number
//   workflowYaml: string
//   pipelineScript: string
//   jenkinsBuildId: string
//   buildnumber: number
//   runResult: string
//   runMessage: string
//   log: string
//   runUserId: string
//   runUserName: string
//   runDate: string
// }