/*
  2023.02.27 신규 devops API 작성중
*/

import request from "@/common/request";

/*
  - OSS 연결에 사용되는 API (통합)
  - gitlab / jenkins / harbor 등
*/
export function getOssDuplicate(params){
  return request({
    url: `/config/oss/duplicate`,
    method: 'get',
    params
  });
}


export function getOssConnection(ossId){
  return request({
    url: `/config/oss/${ossId}`,
    method: 'get'
  });
}

export function getInfraList(ossId) {
  return request({
    url: `/infra`,
    method: 'get'
  });
}

export function getOssConnectionList(param){
  if(param.oss) {
    return request({
      url: `/config/oss/list?ossCd=${param.oss}`,
      method: 'get',
    });
  }
  else {
    return request({
      url: `/config/oss/list`,
      method: 'get',
    });
  }
}

export function setOssConnection(data){
  return request({
    url: '/config/oss',
    method: 'post',
    data,
  });
}

export function updateOssConnection(data){
  return request({
    url: `/config/oss/${data.ossId}`,
    method: 'put',
    data,
  });
}

export function deleteOssConnection(ossId){
  return request({
    url: `/config/oss/${ossId}`,
    method: 'delete',
  });
}

export function checkOssConnection(data){
  return request({
    url: '/config/oss/connection/check',
    method: 'post',
    data,
  });
}

export function getCommonOssList(){
  return request({
    url: '/common/group/OSS',
    method: 'get',
  });
}











/* 
  현재 사용 안하는 API (추후 삭제 필요)
*/
export function checkGitlabConnection(params) {
  return request({
    url: '/gitlab/connect',
    method: 'post',
    params
  })
}

export function checkJenkinsConnection(data) {
  return request({
    url: '/configuration/checkJenkinsConnection',
    method: 'post',
    data
  })
}

export function checkArgoCDConnection(data) {
  return request({
    url: '/argocd/checkConnect',
    method: 'post',
    data
  })
}

export function checkSonarQubeConnection(data) {
  return request({
    url: '/sonarqube/checkConnect',
    method: 'post',
    data
  })
}

export function checkAnchoreConnection(data) {
  return request({
    url: '/anchore/checkConnect',
    method: 'post',
    data
  })
}

export function getGitlabAccount() {
  return request({
    url: '/configuration/getGitlabAccount',
    method: 'get'
  })
}

export function getJenkinsAccount() {
  return request({
    url: '/configuration/getJekninsAccount',
    method: 'get'
  })
}

export function getArgoCDAccount() {
  return request({
    url: '/argocd/argoInfo',
    method: 'get'
  })
}

export function getSonarQubeAccount() {
  return request({
    url: '/sonarqube/sonarInfo',
    method: 'get'
  })
}

export function getAnchoreAccount() {
  return request({
    url: '/anchore/anchoreInfo',
    method: 'get'
  })
}

export function setGitlabAccount(data) {
  return request({
    url: '/configuration/setGitlabAccount',
    method: 'post',
    data
  })
}

export function setJenkinsAccount(data) {
  return request({
    url: '/configuration/setJenkinsAccount',
    method: 'post',
    data
  })
}

export function setArgoCDAccount(data) {
  return request({
    url: '/argocd/saveArgoInfo',
    method: 'post',
    data
  })
}

export function setSonarQubeAccount(data) {
  return request({
    url: '/sonarqube/saveSonarInfo',
    method: 'post',
    data
  })
}

export function setAnchoreAccount(data) {
  return request({
    url: '/anchore/saveAnchoreInfo',
    method: 'post',
    data
  })
}

export function getPortalHome() {
  return request({
    url: '/configuration/getPortalHome',
    method: 'get'
  })
}

export function setPortalHome(data) {
  return request({
    url: '/configuration/setPortalHome',
    method: 'post',
    data
  })
}

