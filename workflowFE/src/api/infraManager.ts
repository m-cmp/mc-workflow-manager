import request from "@/common/request";

type QueryParams = Record<string, string | number | undefined>

const buildQueryString = (params?: QueryParams) => {
  const searchParams = new URLSearchParams()
  Object.entries(params || {}).forEach(([key, value]) => {
    if (value !== undefined && value !== '') {
      searchParams.append(key, String(value))
    }
  })
  const queryString = searchParams.toString()
  return queryString ? `?${queryString}` : ''
}

export const getMcInfraRegions = (providerName: string, params?: QueryParams) => {
  return request.get(`/infra-manager/providers/${providerName}/regions${buildQueryString(params)}`)
}

export const getMcInfraResources = (nsId: string, resourceType: 'image' | 'spec', params?: QueryParams) => {
  return request.get(`/infra-manager/namespaces/${nsId}/resources/${resourceType}${buildQueryString(params)}`)
}

export const getMcInfraList = (nsId: string, params?: QueryParams) => {
  return request.get(`/infra-manager/namespaces/${nsId}/infra${buildQueryString(params)}`)
}

export const getMcInfra = (nsId: string, infraId: string, params?: QueryParams) => {
  return request.get(`/infra-manager/namespaces/${nsId}/infra/${infraId}${buildQueryString(params)}`)
}
