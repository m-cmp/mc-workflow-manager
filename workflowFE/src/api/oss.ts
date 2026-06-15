import request from "@/common/request";
import type { Oss } from "@/views/type/type";


// Comment translated to English.
export const getOssTypeList = () => {
  return request.get('/ossType/list')
}

// Comment translated to English.
// Comment translated to English.
export const getOssTypeFilteredList = () => {
  return request.get('/ossType/filter/list')
}

// Comment translated to English.
export const getOssAllList = () => {
  return request.get('/oss/list')
}

// Comment translated to English.
export const getOssList = (ossTypeName:string) => {
  return request.get(`/oss/list/${ossTypeName}`)
}

// Comment translated to English.
export function duplicateCheck(param: { ossName:string, ossUrl:string, ossUsername:string}) {
  return request.get(`/oss/duplicate?ossName=${param.ossName}&ossUrl=${param.ossUrl}&ossUsername=${param.ossUsername}`)
}


// Comment translated to English.
export function ossConnectionChecked(param: { ossUrl: string, ossUsername: string, ossPassword: string, ossTypeIdx: number }) {
  return request.post(`/oss/connection-check`, param)
}


// Comment translated to English.
export function getOssDetailInfo(ossIdx:number | string | string[]) {
  return request.get("/oss/" + ossIdx);
}


// Comment translated to English.
export function registOss(param:Oss) {
  return request.post(`/oss`, param)
}

// Comment translated to English.
export function updateOss(param: Oss) {
  return request.patch(`/oss/${param.ossIdx}`, param)
}

// Comment translated to English.
export function deleteOss(ossIdx: number) {
  return request.delete(`/oss/${ossIdx}`)
}