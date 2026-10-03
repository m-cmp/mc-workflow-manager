export const getDefaultK8sRootDiskSize = (provider = '') => {
  return provider.trim().toLowerCase() === 'ncp' ? '100' : '40'
}

export const resolveK8sRootDiskSize = (provider = '', value = '', providerChanged = false) => {
  const defaultSize = getDefaultK8sRootDiskSize(provider)
  const size = value.trim()
  if (providerChanged || !size || size === '30' || (defaultSize === '100' && Number(size) < 100)) {
    return defaultSize
  }
  return size
}
