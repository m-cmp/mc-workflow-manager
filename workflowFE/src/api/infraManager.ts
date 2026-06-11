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
  return request.get(`/infra-manager/providers/${encodeURIComponent(providerName)}/regions${buildQueryString(params)}`)
}

export const getMcInfraProviders = (params?: QueryParams) => {
  return request.get(`/infra-manager/providers${buildQueryString(params)}`)
}

export const getMcInfraNamespaces = (params?: QueryParams) => {
  return request.get(`/infra-manager/namespaces${buildQueryString(params)}`)
}

export const getMcInfraConnConfigs = (params?: QueryParams) => {
  return request.get(`/infra-manager/conn-configs${buildQueryString(params)}`)
}

export const getMcInfraAvailableZones = (params?: QueryParams) => {
  return request.get(`/infra-manager/available-zones${buildQueryString(params)}`)
}

export const getMcInfraK8sVersions = (params?: QueryParams) => {
  return request.get(`/infra-manager/k8s-versions${buildQueryString(params)}`)
}

export const getMcInfraResources = (nsId: string, resourceType: 'image' | 'spec', params?: QueryParams) => {
  return request.get(`/infra-manager/namespaces/${encodeURIComponent(nsId)}/resources/${resourceType}${buildQueryString(params)}`)
}

export const reviewMcInfraDynamic = (nsId: string, payload: Record<string, any>, params?: QueryParams) => {
  return request.post(`/infra-manager/namespaces/${encodeURIComponent(nsId)}/infra-dynamic-review${buildQueryString(params)}`, payload)
}

export const getMcInfraList = (nsId: string, params?: QueryParams) => {
  return request.get(`/infra-manager/namespaces/${encodeURIComponent(nsId)}/infra${buildQueryString(params)}`)
}

export const getMcInfra = (nsId: string, infraId: string, params?: QueryParams) => {
  return request.get(`/infra-manager/namespaces/${encodeURIComponent(nsId)}/infra/${encodeURIComponent(infraId)}${buildQueryString(params)}`)
}
