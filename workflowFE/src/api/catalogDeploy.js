import request from "@/common/request";

// 카탈로그 목록
export function getCatalogList(nexusId) {
    return request({
        url: `/catalog/list?nexusId=${nexusId}`,
        method: 'get'
    })
}

// 카탈로그 배포 목록
export function getCatalogDeployList(data) {
    return request({
        url: '/catalog/deploy/list',
        method: 'post',
        data
    })
}

// deploy  상세정보
export function getCatalogDeployDetailInfo(catalogDeployId) {
	return request({
        url: `/catalog/deploy/${catalogDeployId}`,
        method: 'get'
    })
}

// 스테이지 목록
export function getStageList(){
    return request({
        url: '/common/group/stage',
        method: 'get'
    })
}

// 카탈로그 배포 상태 조회
export function getCatalogDeployStatus(params) {
    return request({
        url: `/catalog/deploy/${params.catalogDeployId}/status`,
        method: 'get'
    })
}

// 카탈로그 배포 수정
export function putCatalogDeploy(data) {
    return request({
        url: `/catalog/deploy/${data.catalogDeployId}`,
        method: 'put',
        data
    })
}

// 2023.03.16 - 파라미터값 받아서 하드코딩 제거
export function getCatalogDeployConfigCount(){
    return request({
        url: '/config/k8s/count?stageCd=DEV',
        method: 'get'
    })
}

// 카탈로그 배포명 중복체크
export function duplicateCheck(params) {
    return request({
        url: `/catalog/deploy/name/duplicate?k8sId=${params.k8sId}&deployName=${params.deployName}`,
        method: 'get',
    })
}

// Provider 목록
export function getProviderList(){
    return request({
        url: '/common/group/provider',
        method: 'get'
    })
}


export function getClusterConfigList(params){
    return request({
        url: `/config/k8s/list?providerCd=${params.providerCd}&stageCd=${params.stageCd}&serviceGroupId=${params.serviceGroupId}`,
        method: 'get'
    })
}
