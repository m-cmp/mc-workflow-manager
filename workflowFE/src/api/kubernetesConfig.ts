import request from "@/common/request.js";

// 추후 삭제
// 서비스 그룹 > 설정 > 클러스터 > 목록
export function getKubernetesConfigList(data) {
  return request({
    url: '/config/k8s/list',
    method: 'get',
    data
  })
}


// 서비스 그룹 > 설정 > 클러스터 > 목록
export function getClusterConfigList(serviceGroupId) {
  return request({
    url: `/config/k8s/list?serviceGroupId=${serviceGroupId}`,
    method: 'get',
  })
}

// 서비스 그룹 > 설정 > 클러스터 > 신규 클러스터/ProviderCd 목록
export function getClusterConfigProviderList() {
  return request({
    url: '/common/group/provider',
    method: 'get'
  })
}

// 서비스 그룹 > 설정 > 클러스터 > 신규 클러스터/StageCd 목록
export function getClusterConfigStageList() {
  return request({
    url: '/common/group/stage',
    method: 'get'
  })
}

// 서비스 그룹 > 설정 > 클러스터 > 신규 클러스터 / 클러스터명 중복체크
export function duplicateCheck(k8sName) {
  return request({
    url: `/config/k8s/name/duplicate?k8sName=${k8sName}`,
    method: 'get'
  })
}

// 서비스 그룹 > 설정 > 클러스터 > 신규 클러스터 / ArgoCD 커넥션 체크
export function connectionCheck(data) {
  return request({
    url: `/config/k8s/connection/check`,
    method: 'post',
    data
  })
}


// 서비스 그룹 > 설정 > 클러스터 > 신규 클러스터 / 등록
export function createClusterConfig(data) {
  return request({
    url: '/config/k8s',
    method: 'post',
    data
  })
}

// 서비스 그룹 > 설정 > 쿠버네티스 > 상세
export function getKubernetesConfig(k8sId) {
  return request({
    url: '/config/k8s/' + k8sId,
    method: 'get'
  })
}

export function updateKubernetesConfig(data) {
  return request({
    url: '/config/k8s/'+ data.k8sId,
    method: 'put',
    data
  })
}

export function deleteKubernetesConfig(k8sId) {
  return request({
    url: '/config/k8s/' + k8sId,
    method: 'delete'
  })
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////










