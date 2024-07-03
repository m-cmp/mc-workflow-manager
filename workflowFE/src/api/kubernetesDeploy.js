/*
  2023.03.10 신규 devops K8S Deploy Api 작업
*/
import request from "@/common/request.js";

/*
export function getKubernetesDeployNameList(projectId) {  
	return request.get('/k8s/deploy/name?projectId='+projectId);
}
*/

export function getKubernetesDeployNameList(projectId) {  
	return request.get('/k8s/deploy/name/list?projectId='+projectId);
}

// 수정 완료
export function getConfigList(params){
	return request.get(`/config/k8s/list?providerCd=${params.providerCd}&stageCd=${params.stageCd}&serviceGroupId=${params.serviceGroupId}`);
}

export function getAZCredentialList(params){
	return request.get(`/az/credentials/name?groupId=${params.groupId}&stageId=${params.stageId}`);
}

// 수정 완료
export function getNamespaceList(k8sId) {
	return request.get(`/config/k8s/${k8sId}/namespace/name`);
}

// 수정 완료
export function getControllerCodeList() {
	return request.get("/common/group/Controller");
}

// 수정완료
export function getStrategyTypeList() {
	return request.get("/common/group/StrategyType");
}

// 수정완료
export function getRolloutStrategyTypeList() {
	return request.get("/common/group/RolloutStrategy");
}

// 수정 완료
export function getNodeSelectorList(k8sId) {
	return request.get(`/config/k8s/${k8sId}/node/label`);
}

// 수정 완료
export function getPVCVolumeList(k8sId) {
	return request.get(`/config/k8s/${k8sId}/pvc/name`);
}

// 수정 완료
export function getStorageClassList(k8sId) {
	return request.get(`/config/k8s/${k8sId}/storage/name`);
}

// 수정완료
export function getHostPathVolumeList() {
	return request.get(`/common/group/HostPathVolumeType`);
}

// 수정완료
export function getServiceTypeList() {
	return request.get("/common/group/ServiceType");
}
////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////
export function createKubernetesDeploy(params) {
    return request.post('/k8s/deploy', params);
}


// 수정 완료
export function updateKubernetesDeploy(params) {
    return request.put(`/k8s/deploy/${params.deployId}`,params);
}

export function getKubernetesDeploy(deployId) {
    return request.get('/k8s/deploy/' + deployId);
}

// 수정 완료
export function getKubernetesHistoryList(deployId) {
    return request.get(`/k8s/deploy/${deployId}/history`);
}

export function getKubernetesHistoryStatus(params) {
  return request.get(`/k8s/deploy/${params.deployId}/history/${params.deployHistoryId}`);
}

// 수정 완료
export function getKubernetesApplicationStatus(deployId) {
  return request.get(`/k8s/deploy/${deployId}/status`);
}

// 카탈로그 배포이력 조회
export function getCatalogDeployhistoryInfo(catalogDeployId) {

    return request.get(`/catalog/deploy/${catalogDeployId}/history`)
}


// 수정 완료
export function deployKubernetesNow(params) {
    return request.post(`/k8s/deploy/${params.deployId}/run`,params)
}

// 수정 완료
export function deleteKubernetesDeploy(deployId) {
    return request.delete('/k8s/deploy/' + deployId);
}

// export function getYaml(params) {
// 	return request.post('/k8s/deploy/yaml', params);
// }

// 수정 완료 - Method명 변경 필요
export function getDeployYaml(params) {
	return request.post('/k8s/deploy/yaml', params);
}

export function getYaml(params) {
	return request.post('/catalog/deploy/values', params);
}

// 수정 완료
export function duplicateCheckName(params) {
	return request.get(`/k8s/deploy/name/duplicate?name=${params.name}&k8sId=${params.k8sId}&namespace=${params.namespace}`);
}

// 수정 완료
export function deployKubernetesApproveRequest(params) {
  return request.post(`/k8s/deploy/${params.deployId}/approve`, params)
}

// 수정 완료
export function deployKubernetesApproveAccept(params) {
  return request.post(`/k8s/deploy/${params.deployId}/history/${params.deployHistoryId}/accept`)
  
}
// 수정완료
export function deployKubernetesApproveReject(params) {
  return request.post(`/k8s/deploy/${params.deployId}/history/${params.deployHistoryId}/reject`)
}

export function getDeployHistory(params) {
  return request({
    url: `/argocd/deploy/applications/${params.projectId}/${params.buildDeployId}`,
    method: 'get'
  })
}

// 수정 완료
export function cancelKubernetesScheduledDeploy(params) {
  return request.post(`/k8s/deploy/${params.deployId}/history/${params.deployHistoryId}/cancel`,params);
}

// 수정 완료
export function runKubernetesDeployRollback(params) {
  return request.post(`/k8s/deploy/${params.deployId}/rollback`,params);
}

// 수정 완료
export function runDeployPromote(deployId) {
  return request.post(`/k8s/deploy/${deployId}/promote`);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 카탈로그용 API
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
export function getKubernetesCatalogDeployNameList(data) {  
	return request({
    url: '/catalog/deploy/list',
    method: 'post',
    data
  });
}
export function getConfigListCatalog(params){
	return request.get(`/k8s/config/name?groupId=${params.groupId}&stageId=${params.stageId}`);
}
export function createKubernetesCatalogDeploy(params) {
  return request.post('/catalog/deploy', params);
}
export function catalogDeployKubernetesNow(params) {
  return request({
    url: `/catalog/deploy/${params.catalogDeployId}/run`,
    method: 'get',
    body: params
  })
}

// 카탈로그 배포 삭제
export function deleteKubernetesCatalogDeploy(catalogDeployId) {
  return request.delete(`/catalog/deploy/${catalogDeployId}`);
}