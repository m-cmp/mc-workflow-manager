export interface Workflow {
  workflowId: Number
  workflowName: String
  workflowPurpose: String
  jenkinsId: Number
  jenkinsUrl: String
  jenkinsName: String
  jenkinsJobName: String
  pipelineScript: String
  pipelineParam: Array<{
    paramKey,
    paramValue,
    paramDesc
  }>
  pipelines: Array<Pipeline>
  regId: String
  regName: String
  regDate: String
  modId: String
  modName: String
  modDate: String
}

export interface Pipeline {
  pipelineId: Number
	pipelineCd: String
	pipelineCdName: String
	pipelineName: String
	pipelineScript: String
  pipelineOrder: Number
  isDefaultScript: Boolean
  defaultScriptTag: String
}

export interface Oss {
  ossName: String
  ossId: String
  ossUrl: String
}

export interface PipelineCd {
  codeDesc: String
  codeName: String
  codeOrder: Number
  commonCd: String
  commonGroupCd: String
  modDate: String
  modId: String
  modName: String
  protectedYn: String
  regDate: String
  regId: String
  regName: String
}

export interface History {
  workflowHistoryId: Number
  workflowId: Number
  workflowYaml: String
  pipelineScript: String
  jenkinsBuildId: String
  buildNumber: Number
  runResult: String
  runMessage: String
  log: String
  runUserId: String
  runUserName: String
  runDate: String
}