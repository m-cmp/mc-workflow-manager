import request from "@/common/request";

export function getAuth() {
  return request({
    url: '/auth',
    method: 'get'
  })


}

export function setAuth(data) {
  return request({
    url: '/auth',
    method: 'post',
    data
  })
}

export function getGroupList() {
  return request({
    url: '/groups',
    method: 'get'
  })
}

export function getCredentialList() {
  return request({
    url: '/credentials',
    method: 'get'
  })
}
