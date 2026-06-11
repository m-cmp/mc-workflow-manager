<template>
  <div class="mb-3" v-if="showSelector">
    <label class="form-label">Tumblebug Parameter Selection</label>
    <div class="grid gap-0 column-gap-3 mb-2">
      <div class="tumblebug-param-field g-col-4">
        <label class="tumblebug-param-label">
          <code>{{ getSelectionParamKeyLabel('NAMESPACE') }}</code>
          <span>Namespace</span>
        </label>
        <SearchableSelect
          v-model="selectedNamespace"
          :options="namespaceOptions"
          placeholder="Namespace"
          @change="onChangeNamespace"
        />
      </div>
      <div class="tumblebug-param-field g-col-4">
        <label class="tumblebug-param-label">
          <code>{{ getSelectionParamKeyLabel(['PROVIDER', 'CSP']) }}</code>
          <span>CSP</span>
        </label>
        <SearchableSelect
          v-model="infraProvider"
          :options="infraProviderOptions"
          placeholder="CSP"
          @change="onChangeInfraProvider"
        />
      </div>
      <div class="tumblebug-param-field g-col-4">
        <label class="tumblebug-param-label">
          <code>{{ getSelectionParamKeyLabel('REGION') }}</code>
          <span>Region</span>
        </label>
        <SearchableSelect
          v-model="selectedRegion"
          :options="regionOptions"
          placeholder="Region"
          @change="onChangeInfraSelection"
        />
      </div>
    </div>
    <div class="grid gap-0 column-gap-3 mb-2">
      <div class="tumblebug-param-field g-col-6">
        <label class="tumblebug-param-label">
          <code>{{ getSpecSelectionParamKeyLabel() }}</code>
          <span>VM/K8s Spec</span>
        </label>
        <SearchableSelect
          v-model="selectedSpec"
          :options="specOptions"
          placeholder="VM/K8s Spec"
          :title="getSelectedOptionLabel(specOptions, selectedSpec)"
          @change="onChangeInfraSelection"
        />
      </div>
      <div class="tumblebug-param-field g-col-6">
        <label class="tumblebug-param-label">
          <code>{{ getImageSelectionParamKeyLabel() }}</code>
          <span class="tumblebug-param-label-actions">
            <span>Image</span>
            <span class="form-check form-switch tumblebug-k8s-toggle" title="Load Kubernetes node images">
              <input
                class="form-check-input"
                type="checkbox"
                v-model="kubernetesImageEnabled"
                @change="onChangeKubernetesImageMode"
              />
              <span class="form-check-label">K8s</span>
            </span>
          </span>
        </label>
        <SearchableSelect
          v-model="selectedImage"
          :options="imageOptions"
          :placeholder="selectedSpec ? (kubernetesImageEnabled ? 'K8s Image' : 'Image') : 'Select Spec first'"
          :title="getSelectedOptionLabel(imageOptions, selectedImage)"
          @change="onChangeInfraSelection"
        />
      </div>
    </div>
    <div class="grid gap-0 column-gap-3 mb-2">
      <div class="tumblebug-param-field g-col-5">
        <label class="tumblebug-param-label">
          <code>{{ getSelectionParamKeyLabel('INFRA_ID') }}</code>
          <span>Existing Infra</span>
        </label>
        <SearchableSelect
          v-model="selectedInfra"
          :options="infraOptions"
          placeholder="Existing Infra"
          @change="onChangeInfra"
        />
      </div>
      <div class="tumblebug-param-field g-col-5">
        <label class="tumblebug-param-label">
          <code>{{ getSelectionParamKeyLabel(['SSH_HOST', 'DB_HOST']) }}</code>
          <span>SSH/DB Host</span>
        </label>
        <SearchableSelect
          v-model="selectedAccessHost"
          :options="accessHostOptions"
          placeholder="SSH/DB Host"
          @change="onChangeAccessHost"
        />
      </div>
      <div class="tumblebug-param-field g-col-2">
        <label class="tumblebug-param-label tumblebug-param-action-label">
          <span>Reload</span>
        </label>
        <button class="btn btn-outline-primary w-100" @click="onClickRefreshInfraOptions">
          Refresh
        </button>
      </div>
    </div>
    <div class="grid gap-0 column-gap-3">
      <div class="tumblebug-param-field" :class="isKubernetesImageWorkflow ? 'g-col-4' : 'g-col-6'">
        <label class="tumblebug-param-label">
          <code>{{ getSelectionParamKeyLabel('CONNECTION_NAME') }}</code>
          <span>Connection Config</span>
        </label>
        <SearchableSelect
          v-model="selectedConnectionName"
          :options="connectionOptions"
          placeholder="Connection Config"
          @change="onChangeConnectionName"
        />
      </div>
      <div class="tumblebug-param-field" :class="isKubernetesImageWorkflow ? 'g-col-4' : 'g-col-6'">
        <label class="tumblebug-param-label">
          <code>{{ getSelectionParamKeyLabel('ZONE') }}</code>
          <span>Zone</span>
        </label>
        <SearchableSelect
          v-model="selectedZone"
          :options="zoneOptions"
          placeholder="Zone"
          @change="onChangeZone"
        />
      </div>
      <div class="tumblebug-param-field g-col-4" v-if="isKubernetesImageWorkflow">
        <label class="tumblebug-param-label">
          <code>{{ getSelectionParamKeyLabel('K8S_VERSION') }}</code>
          <span>K8s Version</span>
        </label>
        <SearchableSelect
          v-model="selectedK8sVersion"
          :options="k8sVersionOptions"
          placeholder="K8s Version"
          :title="getSelectedOptionLabel(k8sVersionOptions, selectedK8sVersion)"
          @change="onChangeK8sVersion"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, nextTick, onMounted, ref, watch } from 'vue'
import {
  getMcInfra,
  getMcInfraAvailableZones,
  getMcInfraConnConfigs,
  getMcInfraK8sVersions,
  getMcInfraList,
  getMcInfraNamespaces,
  getMcInfraProviders,
  getMcInfraRegions,
  getMcInfraResources,
} from '@/api/infraManager'
import { useUserStore } from '@/stores/user'
import type { WorkflowParams, WorkflowStageMappings } from '@/views/type/type'
import SearchableSelect from '@/views/workflow/components/SearchableSelect.vue'

interface InfraOption {
  label: string
  value: string
  searchText?: string
  meta?: Record<string, any>
}

type InfraOptionKind = 'default' | 'image' | 'spec' | 'k8sVersion'

interface Props {
  workflowName?: string
  workflowParamData: Array<WorkflowParams>
  workflowStageMappings?: Array<WorkflowStageMappings>
}

const props = withDefaults(defineProps<Props>(), {
  workflowName: '',
  workflowStageMappings: () => [],
})

const userInfo = useUserStore()
const paramData = computed(() => props.workflowParamData || [])
const defaultInfraProviderList = ['aws', 'azure', 'gcp', 'ncp', 'nhn', 'alibaba', 'tencent', 'ibm', 'kt']
const infraProviderOptions = ref(sortInfraOptions(defaultInfraProviderList.map((provider) => ({ label: provider, value: provider }))))
const infraProvider = ref('aws')
const selectedRegion = ref('')
const selectedImage = ref('')
const selectedSpec = ref('')
const selectedNamespace = ref('')
const selectedInfra = ref('')
const selectedAccessHost = ref('')
const selectedConnectionName = ref('')
const selectedZone = ref('')
const selectedK8sVersion = ref('')
const isInitializingSelection = ref(false)
const namespaceOptions = ref([] as Array<InfraOption>)
const regionOptions = ref([] as Array<InfraOption>)
const imageOptions = ref([] as Array<InfraOption>)
const specOptions = ref([] as Array<InfraOption>)
const infraOptions = ref([] as Array<InfraOption>)
const accessHostOptions = ref([] as Array<InfraOption>)
const connectionOptions = ref([] as Array<InfraOption>)
const zoneOptions = ref([] as Array<InfraOption>)
const k8sVersionOptions = ref([] as Array<InfraOption>)
let providerLoadSeq = 0
let namespaceLoadSeq = 0
let regionLoadSeq = 0
let imageLoadSeq = 0
let specLoadSeq = 0
let connectionLoadSeq = 0
let zoneLoadSeq = 0
let k8sVersionLoadSeq = 0
let infraLoadSeq = 0
let accessHostLoadSeq = 0
const selectorRequiredStageNames = ['infra-create', 'k8s-cluster-create', 'multi-csp-vm-deploy', 'multi-csp-k8s-cluster-deploy']
const kubernetesImageStageNames = ['k8s-cluster-create', 'k8s-nodegroup-add', 'multi-csp-k8s-cluster-deploy']
const kubernetesImageEnabled = ref(false)
const kubernetesImageModeChanged = ref(false)

const showSelector = computed(() => {
  const configuredValue = getWorkflowParamValue('TUMBLEBUG_SELECTOR_YN').trim().toUpperCase()
  if (['N', 'NO', 'FALSE', '0'].includes(configuredValue)) {
    return false
  }
  if (['Y', 'YES', 'TRUE', '1'].includes(configuredValue)) {
    return true
  }

  return props.workflowStageMappings.some((stage) => selectorRequiredStageNames.includes(stage.workflowStageName || ''))
})

const isKubernetesImageWorkflow = computed(() => {
  return props.workflowStageMappings.some((stage) => kubernetesImageStageNames.includes((stage.workflowStageName || '').toLowerCase()))
})

onMounted(async () => {
  await initSelectionValues()
  await loadInfraOptions()
})

watch(selectedRegion, async (newRegion, oldRegion) => {
  if (isInitializingSelection.value) {
    return
  }
  resetRegionDependentSelection(newRegion, oldRegion)
  await loadMcInfraConnConfigs()
  await loadMcInfraK8sVersions()
  await loadMcInfraSpecs()
  await loadMcInfraImages()
  await loadMcInfraAvailableZones()
  applyInfraSelectionParams()
})

watch(selectedSpec, async (newSpec, oldSpec) => {
  if (isInitializingSelection.value) {
    return
  }
  if (newSpec !== oldSpec) {
    selectedImage.value = ''
  }
  await loadMcInfraImages()
  await loadMcInfraAvailableZones()
  applyInfraSelectionParams()
})

watch(isKubernetesImageWorkflow, async (enabled) => {
  if (kubernetesImageModeChanged.value || kubernetesImageEnabled.value === enabled) {
    return
  }

  kubernetesImageEnabled.value = enabled
  if (!isInitializingSelection.value) {
    selectedImage.value = ''
    await loadMcInfraK8sVersions()
    await loadMcInfraImages()
    applyInfraSelectionParams()
  }
})

watch(
  () => props.workflowName,
  async () => {
    await initSelectionValues()
  }
)

const initSelectionValues = async () => {
  isInitializingSelection.value = true
  try {
    const resourceIdParts = parseTumblebugResourceId(getWorkflowParamValue('SPEC_ID') || getWorkflowParamValue('IMAGE_ID'))
    if (resourceIdParts.provider) {
      infraProvider.value = resourceIdParts.provider
    }

    selectedNamespace.value = getNamespaceParamValue()
    selectedInfra.value = getWorkflowParamValue('INFRA_ID')
    selectedAccessHost.value = getWorkflowParamValue('SSH_HOST') || getWorkflowParamValue('DB_HOST')
    selectedRegion.value = getWorkflowParamValue('REGION') || resourceIdParts.region
    selectedImage.value = getWorkflowParamValue('IMAGE_ID') || getWorkflowParamValue('IMAGE')
    selectedSpec.value = getWorkflowParamValue('SPEC_ID') || getWorkflowParamValue('SPEC')
    selectedK8sVersion.value = getWorkflowParamValue('K8S_VERSION')
    selectedConnectionName.value = getWorkflowParamValue('CONNECTION_NAME')
    selectedZone.value = getWorkflowParamValue('ZONE')
    syncSelectionFromCurrentCspParams()
    if (!kubernetesImageModeChanged.value) {
      kubernetesImageEnabled.value = isKubernetesImageWorkflow.value
    }
  } finally {
    await nextTick()
    isInitializingSelection.value = false
  }
}

const parseTumblebugResourceId = (resourceId?: string) => {
  const parts = (resourceId || '').split('+')
  if (parts.length < 3) {
    return { provider: '', region: '' }
  }

  return {
    provider: parts[0],
    region: parts[1],
  }
}

const normalizeCspKey = (provider?: string) => {
  return (provider || '').trim().toUpperCase().replace(/[^A-Z0-9]/g, '_')
}

const deriveConnectionName = () => {
  return infraProvider.value && selectedRegion.value
    ? `${infraProvider.value}-${selectedRegion.value}`
    : ''
}

const resetRegionDependentSelection = (newRegion?: string, oldRegion?: string) => {
  const previousDerivedConnectionName = infraProvider.value && oldRegion
    ? `${infraProvider.value}-${oldRegion}`
    : ''

  if (!newRegion || selectedConnectionName.value === previousDerivedConnectionName) {
    selectedConnectionName.value = ''
  } else if (selectedConnectionName.value && !selectedConnectionName.value.includes(newRegion)) {
    selectedConnectionName.value = ''
  }

  clearImageAndSpecSelection()
  selectedZone.value = ''
  selectedK8sVersion.value = ''
}

const getCspListValues = () => {
  return getWorkflowParamValue('CSP_LIST')
    .split(',')
    .map((csp) => csp.trim())
    .filter(Boolean)
}

const isMultiCspWorkflow = () => {
  return getCspListValues().length > 0
}

const getSelectionParamKey = (paramKey: string) => {
  const normalizedKey = paramKey.trim().toUpperCase()
  const multiCspParamKeys = ['REGION', 'CONNECTION_NAME', 'ZONE', 'IMAGE_ID', 'SPEC_ID', 'K8S_VERSION']

  if (isMultiCspWorkflow() && multiCspParamKeys.includes(normalizedKey)) {
    const cspKey = normalizeCspKey(infraProvider.value)
    return cspKey ? `${cspKey}_${normalizedKey}` : normalizedKey
  }

  return normalizedKey
}

const getSelectionParamKeyLabel = (paramKeys: string | Array<string>) => {
  const keys = Array.isArray(paramKeys) ? paramKeys : [paramKeys]
  return keys.map((paramKey) => getSelectionParamKey(paramKey)).join(' / ')
}

const getImageSelectionParamKeyLabel = () => {
  return isMultiCspWorkflow()
    ? getSelectionParamKeyLabel('IMAGE_ID')
    : getSelectionParamKeyLabel(['IMAGE', 'IMAGE_ID'])
}

const getSpecSelectionParamKeyLabel = () => {
  return isMultiCspWorkflow()
    ? getSelectionParamKeyLabel('SPEC_ID')
    : getSelectionParamKeyLabel(['SPEC', 'SPEC_ID'])
}

const getCurrentCspParamValue = (suffix: string) => {
  const cspKey = normalizeCspKey(infraProvider.value)
  return cspKey ? getWorkflowParamValue(`${cspKey}_${suffix}`) : ''
}

const syncSelectionFromCurrentCspParams = () => {
  if (!isMultiCspWorkflow()) {
    return
  }

  const resourceIdParts = parseTumblebugResourceId(getCurrentCspParamValue('SPEC_ID') || getCurrentCspParamValue('IMAGE_ID'))
  selectedRegion.value = getCurrentCspParamValue('REGION') || resourceIdParts.region || ''
  selectedImage.value = getCurrentCspParamValue('IMAGE_ID')
  selectedSpec.value = getCurrentCspParamValue('SPEC_ID')
  selectedK8sVersion.value = getCurrentCspParamValue('K8S_VERSION')
  selectedConnectionName.value = getCurrentCspParamValue('CONNECTION_NAME')
  selectedZone.value = getCurrentCspParamValue('ZONE')
}

const onChangeNamespace = async () => {
  selectedInfra.value = ''
  selectedAccessHost.value = ''
  accessHostOptions.value = []
  if (selectedNamespace.value) {
    upsertWorkflowParam('NAMESPACE', selectedNamespace.value)
  }
  await Promise.all([loadMcInfraSpecs(), loadMcInfraInfras()])
  await loadMcInfraImages()
}

const onChangeInfraProvider = async () => {
  selectedRegion.value = ''
  selectedImage.value = ''
  selectedSpec.value = ''
  selectedConnectionName.value = ''
  selectedZone.value = ''
  selectedK8sVersion.value = ''
  syncSelectionFromCurrentCspParams()
  await loadInfraOptions()
  applyInfraSelectionParams()
}

const onChangeInfraSelection = () => {
  applyInfraSelectionParams()
}

const onChangeInfra = async () => {
  selectedAccessHost.value = ''
  accessHostOptions.value = []
  if (selectedInfra.value) {
    upsertWorkflowParam('INFRA_ID', selectedInfra.value)
    await loadMcInfraAccessHosts()
  }
}

const onChangeAccessHost = () => {
  const selectedHostOption = accessHostOptions.value.find((option) => option.value === selectedAccessHost.value)
  if (!selectedHostOption) return

  upsertWorkflowParam('SSH_HOST', selectedHostOption.value)
  upsertWorkflowParam('DB_HOST', selectedHostOption.value)
  if (selectedHostOption.meta?.sshUser) {
    upsertWorkflowParam('SSH_USER', selectedHostOption.meta.sshUser)
  }
}

const onChangeConnectionName = async () => {
  clearImageAndSpecSelection()
  selectedK8sVersion.value = ''
  await loadMcInfraSpecs()
  await loadMcInfraImages()
  await loadMcInfraAvailableZones()
  applyInfraSelectionParams()
}

const onChangeZone = () => {
  applyInfraSelectionParams()
}

const onChangeK8sVersion = () => {
  applyInfraSelectionParams()
}

const onChangeKubernetesImageMode = async () => {
  kubernetesImageModeChanged.value = true
  selectedImage.value = ''
  imageOptions.value = []
  await loadMcInfraImages()
  applyInfraSelectionParams()
}

const onClickRefreshInfraOptions = async () => {
  await loadInfraOptions()
}

const loadInfraOptions = async () => {
  await loadMcInfraProviders()
  await loadMcInfraNamespaces()
  await loadMcInfraRegions()
  ensureSelectedRegionOption()
  await loadMcInfraConnConfigs()
  await loadMcInfraK8sVersions()
  await Promise.all([
    loadMcInfraSpecs(),
    loadMcInfraInfras(),
  ])
  await loadMcInfraImages()
  await loadMcInfraAvailableZones()
  if (selectedInfra.value) {
    await loadMcInfraAccessHosts()
  }
}

const loadMcInfraProviders = async () => {
  const loadSeq = ++providerLoadSeq
  infraProviderOptions.value = []
  try {
    const { data } = await getMcInfraProviders()
    if (loadSeq !== providerLoadSeq) return
    const providers = normalizeInfraOptions(data)
    infraProviderOptions.value = providers.length > 0
      ? providers
      : defaultInfraProviderList.map((provider) => ({ label: provider, value: provider }))
  } catch (error) {
    if (loadSeq !== providerLoadSeq) return
    infraProviderOptions.value = defaultInfraProviderList.map((provider) => ({ label: provider, value: provider }))
  }

  if (loadSeq !== providerLoadSeq) return
  if (!infraProviderOptions.value.some((provider) => provider.value === infraProvider.value)) {
    infraProvider.value = infraProviderOptions.value[0]?.value || ''
  }
}

const loadMcInfraNamespaces = async () => {
  const loadSeq = ++namespaceLoadSeq
  namespaceOptions.value = []
  try {
    const { data } = await getMcInfraNamespaces()
    if (loadSeq !== namespaceLoadSeq) return
    namespaceOptions.value = normalizeInfraOptions(data)
    if (!selectedNamespace.value) {
      selectedNamespace.value = getNamespaceParamValue()
    }
  } catch (error) {
    if (loadSeq !== namespaceLoadSeq) return
    namespaceOptions.value = []
  }
}

const loadMcInfraRegions = async () => {
  const loadSeq = ++regionLoadSeq
  regionOptions.value = []
  try {
    const { data } = await getMcInfraRegions(infraProvider.value)
    if (loadSeq !== regionLoadSeq) return
    regionOptions.value = normalizeInfraOptions(data)
  } catch (error) {
    if (loadSeq !== regionLoadSeq) return
    regionOptions.value = []
  }
}

const ensureSelectedRegionOption = () => {
  if (regionOptions.value.length === 0) {
    return
  }

  if (selectedRegion.value && isSelectedValueInOptions(selectedRegion.value, regionOptions.value)) {
    return
  }

  const currentCspRegion = getCurrentCspParamValue('REGION')
  if (currentCspRegion && isSelectedValueInOptions(currentCspRegion, regionOptions.value)) {
    selectedRegion.value = currentCspRegion
    return
  }

  selectedRegion.value = regionOptions.value[0]?.value || selectedRegion.value
}

const ensureSelectedConnectionOption = () => {
  if (connectionOptions.value.length === 0) {
    selectedConnectionName.value = ''
    return
  }

  if (selectedConnectionName.value && isSelectedValueInOptions(selectedConnectionName.value, connectionOptions.value)) {
    return
  }

  const derivedConnectionName = deriveConnectionName()
  const derivedOption = connectionOptions.value.find((option) => option.value === derivedConnectionName)
  const selectedOption = derivedOption || connectionOptions.value[0]
  selectedConnectionName.value = selectedOption?.value || ''

  const inferredRegion = inferRegionFromConnectionName(selectedConnectionName.value)
  if (inferredRegion && inferredRegion !== selectedRegion.value) {
    selectedRegion.value = inferredRegion
  }
}

const inferRegionFromConnectionName = (connectionName: string) => {
  const providerPrefix = `${infraProvider.value}-`
  return connectionName?.startsWith(providerPrefix)
    ? connectionName.slice(providerPrefix.length)
    : ''
}

const loadMcInfraImages = async () => {
  const loadSeq = ++imageLoadSeq
  imageOptions.value = []
  if (!selectedSpec.value) {
    selectedImage.value = ''
    return
  }
  try {
    const query = {
      providerName: infraProvider.value,
      regionName: selectedRegion.value,
      connectionName: selectedConnectionName.value || deriveConnectionName(),
      matchedSpecId: selectedSpec.value,
      isKubernetesImage: kubernetesImageEnabled.value ? 'true' : undefined,
    }
    const { data } = await getMcInfraResources(getResourceCatalogNamespace(), 'image', query)
    if (loadSeq !== imageLoadSeq) return
    imageOptions.value = normalizeInfraOptions(data, 'image')
    clearInvalidImageSelection()
  } catch (error) {
    if (loadSeq !== imageLoadSeq) return
    imageOptions.value = []
  }
}

const loadMcInfraSpecs = async () => {
  const loadSeq = ++specLoadSeq
  specOptions.value = []
  try {
    const query = {
      providerName: infraProvider.value,
      regionName: selectedRegion.value,
      connectionName: selectedConnectionName.value || deriveConnectionName(),
    }
    const { data } = await getMcInfraResources(getResourceCatalogNamespace(), 'spec', query)
    if (loadSeq !== specLoadSeq) return
    specOptions.value = normalizeInfraOptions(data, 'spec')
    clearInvalidSpecSelection()
  } catch (error) {
    if (loadSeq !== specLoadSeq) return
    specOptions.value = []
    clearInvalidSpecSelection()
  }
}

const loadMcInfraConnConfigs = async () => {
  const loadSeq = ++connectionLoadSeq
  connectionOptions.value = []
  try {
    const query = {
      providerName: infraProvider.value,
      regionName: selectedRegion.value,
      filterVerified: 'true',
    }
    const { data } = await getMcInfraConnConfigs(query)
    if (loadSeq !== connectionLoadSeq) return
    let options = normalizeInfraOptions(data)
    if (options.length === 0 && selectedRegion.value) {
      const fallback = await getMcInfraConnConfigs({
        providerName: infraProvider.value,
        filterVerified: 'true',
      })
      if (loadSeq !== connectionLoadSeq) return
      options = normalizeInfraOptions(fallback.data)
    }
    connectionOptions.value = options
    ensureSelectedConnectionOption()
  } catch (error) {
    if (loadSeq !== connectionLoadSeq) return
    connectionOptions.value = []
  }
}

const loadMcInfraK8sVersions = async () => {
  const loadSeq = ++k8sVersionLoadSeq
  k8sVersionOptions.value = []
  if (!isKubernetesImageWorkflow.value || !infraProvider.value || !selectedRegion.value) {
    return
  }

  try {
    const { data } = await getMcInfraK8sVersions({
      providerName: infraProvider.value,
      regionName: selectedRegion.value,
    })
    if (loadSeq !== k8sVersionLoadSeq) return
    k8sVersionOptions.value = normalizeInfraOptions(data, 'k8sVersion')
    ensureSelectedK8sVersionOption()
  } catch (error) {
    if (loadSeq !== k8sVersionLoadSeq) return
    k8sVersionOptions.value = []
  }
}

const ensureSelectedK8sVersionOption = () => {
  if (!isKubernetesImageWorkflow.value || k8sVersionOptions.value.length === 0) {
    return
  }

  if (selectedK8sVersion.value && isSelectedValueInOptions(selectedK8sVersion.value, k8sVersionOptions.value)) {
    return
  }

  const currentVersion = isMultiCspWorkflow()
    ? getCurrentCspParamValue('K8S_VERSION')
    : getWorkflowParamValue('K8S_VERSION')
  if (currentVersion && isSelectedValueInOptions(currentVersion, k8sVersionOptions.value)) {
    selectedK8sVersion.value = currentVersion
    applyInfraSelectionParams()
    return
  }

  selectedK8sVersion.value = k8sVersionOptions.value[0]?.value || selectedK8sVersion.value
  applyInfraSelectionParams()
}

const loadMcInfraAvailableZones = async () => {
  const loadSeq = ++zoneLoadSeq
  zoneOptions.value = []
  if (!selectedSpec.value) {
    return
  }

  try {
    const { data } = await getMcInfraAvailableZones({ specId: selectedSpec.value })
    if (loadSeq !== zoneLoadSeq) return
    zoneOptions.value = normalizeInfraOptions(data)
    if (selectedZone.value && !zoneOptions.value.some((option) => option.value === selectedZone.value)) {
      selectedZone.value = ''
    }
  } catch (error) {
    if (loadSeq !== zoneLoadSeq) return
    zoneOptions.value = []
  }
}

const loadMcInfraInfras = async () => {
  const loadSeq = ++infraLoadSeq
  infraOptions.value = []
  if (!selectedNamespace.value) {
    return
  }

  try {
    const { data } = await getMcInfraList(selectedNamespace.value, { option: 'simple' })
    if (loadSeq !== infraLoadSeq) return
    infraOptions.value = normalizeInfraOptions(data)
  } catch (error) {
    if (loadSeq !== infraLoadSeq) return
    infraOptions.value = []
  }
}

const loadMcInfraAccessHosts = async () => {
  const loadSeq = ++accessHostLoadSeq
  accessHostOptions.value = []
  if (!selectedNamespace.value || !selectedInfra.value) {
    return
  }

  try {
    const { data } = await getMcInfra(selectedNamespace.value, selectedInfra.value, {
      option: 'accessinfo',
      accessInfoOption: 'showSshKey',
    })
    if (loadSeq !== accessHostLoadSeq) return
    accessHostOptions.value = normalizeAccessHostOptions(data)
  } catch (error) {
    if (loadSeq !== accessHostLoadSeq) return
    accessHostOptions.value = []
  }
}

const normalizeInfraOptions = (response: any, optionKind: InfraOptionKind = 'default'): Array<InfraOption> => {
  const payload = response?.data ?? response
  const sourceList = findFirstArray(payload)
  const seen = new Set<string>()

  return sourceList
    .map((item: any) => {
      const value = getInfraOptionValue(item, optionKind)
      const label = getInfraOptionLabel(item, value, optionKind)
      const searchText = getInfraOptionSearchText(item, value, label, optionKind)
      return { label, value, searchText }
    })
    .filter((option: InfraOption) => {
      if (!option.value || seen.has(option.value)) return false
      seen.add(option.value)
      return true
    })
    .sort(compareInfraOptions)
}

function sortInfraOptions(options: Array<InfraOption>) {
  return [...options].sort(compareInfraOptions)
}

function compareInfraOptions(left: InfraOption, right: InfraOption) {
  const leftText = (left.label || left.value || '').trim()
  const rightText = (right.label || right.value || '').trim()
  const labelCompare = leftText.localeCompare(rightText, undefined, { numeric: true, sensitivity: 'base' })
  if (labelCompare !== 0) return labelCompare
  return (left.value || '').localeCompare(right.value || '', undefined, { numeric: true, sensitivity: 'base' })
}

const getInfraOptionValue = (item: any, optionKind: InfraOptionKind) => {
  if (optionKind === 'k8sVersion') {
    return String(firstText([
      item?.id,
      item?.version,
      item?.value,
      item?.name,
      item,
    ]))
  }

  if (optionKind === 'spec') {
    const specName = firstText([
      item?.specId,
      item?.id,
      item?.cspSpecId,
      item?.cspSpecName,
      item?.CspSpecName,
      item?.specName,
      item?.Name,
      item?.VMSpecName,
      item?.name,
    ])
    return String(buildSpecOptionValue(item, specName))
  }

  return String(firstText(
    optionKind === 'image' ? [
      item?.imageId,
      item?.id,
      item?.cspImageId,
      item?.name,
    ] : [],
    [
      item?.id,
      item?.specId,
      item?.imageId,
      item?.configName,
      item?.connectionName,
      item?.providerName,
      item?.provider,
      item?.csp,
      item?.cspName,
      item?.nsId,
      item?.name,
      item?.infraId,
      item?.regionName,
      item?.RegionName,
      item?.region,
      item?.assignedRegion,
      item?.zoneId,
      item?.zoneName,
      item?.zone,
      item?.assignedZone,
      item,
    ]
  ))
}

const getInfraOptionLabel = (item: any, value: string, optionKind: InfraOptionKind) => {
  if (optionKind === 'k8sVersion') {
    return formatOptionLabel(value, firstDifferentText(value, [
      item?.name,
      item?.displayName,
      item?.version,
      item?.value,
    ]))
  }

  if (optionKind === 'image') {
    return formatOptionLabel(value, firstDifferentText(value, [
      item?.displayName,
      item?.imageName,
      item?.cspImageName,
      item?.guestOS,
      item?.GuestOS,
      item?.guestOs,
      item?.osDistribution,
      item?.OSDistribution,
      item?.osPlatform,
      item?.OSPlatform,
      item?.description,
      item?.Description,
      item?.name,
    ]))
  }

  if (optionKind === 'spec') {
    const specDetail = firstDifferentText(value, [
      item?.displayName,
      item?.specName,
      item?.cspSpecName,
      item?.CspSpecName,
      item?.Name,
      item?.VMSpecName,
      item?.description,
      item?.Description,
      item?.name,
    ]) || formatSpecResourceDetail(item)
    return formatOptionLabel(value, specDetail)
  }

  const label = firstText([
    item?.name,
    item?.id,
    item?.configName,
    item?.connectionName,
    item?.providerName,
    item?.provider,
    item?.csp,
    item?.cspName,
    item?.nsId,
    item?.infraId,
    item?.specName,
    item?.imageName,
    item?.specId,
    item?.imageId,
    item?.regionName,
    item?.RegionName,
    item?.region,
    item?.assignedRegion,
    item?.zoneId,
    item?.zoneName,
    item?.zone,
    item?.assignedZone,
    value,
  ])
  return String(label)
}

const getInfraOptionSearchText = (item: any, value: string, label: string, optionKind: InfraOptionKind) => {
  const provider = firstText([item?.providerName, item?.provider, item?.csp, item?.cspName, infraProvider.value])
  const region = firstText([item?.regionName, item?.RegionName, item?.region, item?.assignedRegion, selectedRegion.value])
  const imageTexts = optionKind === 'image'
    ? [
      item?.displayName,
      item?.imageName,
      item?.cspImageName,
      item?.guestOS,
      item?.GuestOS,
      item?.guestOs,
      item?.osDistribution,
      item?.OSDistribution,
      item?.osPlatform,
      item?.OSPlatform,
      item?.description,
      item?.Description,
    ]
    : []
  const specTexts = optionKind === 'spec'
    ? [
      item?.displayName,
      item?.specName,
      item?.cspSpecName,
      item?.CspSpecName,
      item?.Name,
      item?.VMSpecName,
      item?.description,
      item?.Description,
      formatSpecResourceDetail(item),
    ]
    : []
  const versionTexts = optionKind === 'k8sVersion'
    ? [
      item?.name,
      item?.displayName,
      item?.version,
      item?.value,
    ]
    : []
  const candidates = uniqueTextValues([
    value,
    label,
    item?.id,
    item?.name,
    item?.imageId,
    item?.specId,
    item?.cspImageId,
    item?.cspSpecId,
    item?.configName,
    item?.connectionName,
    item?.infraId,
    item?.regionName,
    item?.RegionName,
    item?.region,
    item?.assignedRegion,
    ...imageTexts,
    ...specTexts,
    ...versionTexts,
  ])
  const aliases = uniqueTextValues(
    candidates.flatMap((candidate) => [
      provider && region ? `${provider}+${region}+${candidate}` : '',
      provider && region ? `${provider}-${region}-${candidate}` : '',
      provider && region ? `${provider} ${region} ${candidate}` : '',
    ])
  )

  return [...candidates, ...aliases].join('\n')
}

const uniqueTextValues = (values: Array<any>) => {
  const seen = new Set<string>()
  return values
    .map((value) => value === undefined || value === null ? '' : String(value).trim())
    .filter((value) => {
      if (!value || seen.has(value)) return false
      seen.add(value)
      return true
    })
}

const firstText = (...groups: Array<Array<any>>) => {
  for (const group of groups) {
    for (const value of group) {
      const text = value === undefined || value === null ? '' : String(value).trim()
      if (text) return text
    }
  }
  return ''
}

const firstDifferentText = (baseValue: string, values: Array<any>) => {
  const normalizedBase = normalizeTextForCompare(baseValue)
  for (const value of values) {
    const text = removeResourceIdFromDetail(
      value === undefined || value === null ? '' : String(value).trim(),
      baseValue
    )
    if (text && normalizeTextForCompare(text) !== normalizedBase) {
      return text
    }
  }
  return ''
}

const removeResourceIdFromDetail = (detail: string, resourceId: string) => {
  if (!detail || !resourceId) return detail
  return detail
    .replace(new RegExp(`\\s*\\(${escapeRegExp(resourceId)}\\)\\s*$`), '')
    .replace(new RegExp(`^${escapeRegExp(resourceId)}\\s*/\\s*`), '')
    .trim()
}

const escapeRegExp = (value: string) => {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

const formatOptionLabel = (value: string, detail?: string) => {
  return detail ? `${value} / ${detail}` : value
}

const formatSpecResourceDetail = (item: any) => {
  const cpu = firstText([item?.vCpu, item?.VCpu?.Count, item?.VCpu, item?.num_vCPU])
  const memory = firstText([item?.memoryGiB, item?.mem_GiB, mibToGiB(item?.MemSizeMib)])
  const parts = []
  if (cpu) parts.push(`${cpu} vCPU`)
  if (memory) parts.push(`${memory} GiB`)
  return parts.join(' / ')
}

const buildSpecOptionValue = (item: any, specName: string) => {
  if (!specName) return ''
  if (specName.includes('+')) return specName

  const provider = firstText([item?.providerName, item?.provider, item?.csp, item?.cspName, infraProvider.value])
  const region = firstText([item?.regionName, item?.RegionName, item?.region, item?.Region, item?.assignedRegion, selectedRegion.value])
  return provider && region ? `${provider}+${region}+${specName}` : specName
}

const mibToGiB = (value: any) => {
  const text = value === undefined || value === null ? '' : String(value).trim()
  if (!text) return ''
  const parsed = Number(text)
  if (Number.isNaN(parsed)) return ''
  const gib = parsed / 1024
  return Number.isInteger(gib) ? String(gib) : gib.toFixed(2)
}

const clearInvalidSpecSelection = () => {
  if (!selectedSpec.value || !isConnectionLikeSpecValue(selectedSpec.value)) {
    return
  }

  selectedSpec.value = ''
  applyInfraSelectionParams()
}

const clearImageAndSpecSelection = () => {
  selectedImage.value = ''
  selectedSpec.value = ''
}

const clearInvalidImageSelection = () => {
  if (!selectedImage.value || imageOptions.value.length === 0) {
    return
  }

  if (!isSelectedValueInOptions(selectedImage.value, imageOptions.value)) {
    selectedImage.value = ''
    applyInfraSelectionParams()
  }
}

const isSelectedValueInOptions = (value: string, options: Array<InfraOption>) => {
  const normalizedValue = normalizeTextForCompare(value)
  return options.some((option) => {
    return normalizeTextForCompare(option.value) === normalizedValue
      || normalizeTextForCompare(option.label) === normalizedValue
      || normalizeTextForCompare(option.searchText).split('\n').some((item) => item.trim() === normalizedValue)
  })
}

const isConnectionLikeSpecValue = (value: string) => {
  const normalizedValue = normalizeTextForCompare(value)
  if (!normalizedValue) return false

  const derivedConnectionName = normalizeTextForCompare(deriveConnectionName())
  const selectedConnection = normalizeTextForCompare(selectedConnectionName.value)
  const selectedRegionName = normalizeTextForCompare(selectedRegion.value)
  const provider = normalizeTextForCompare(infraProvider.value)

  return normalizedValue === derivedConnectionName
    || normalizedValue === selectedConnection
    || normalizedValue === selectedRegionName
    || normalizedValue === provider
}

const normalizeTextForCompare = (value?: string) => {
  return (value || '').trim().toLowerCase()
}

const findFirstArray = (payload: any): Array<any> => {
  if (Array.isArray(payload)) return payload
  if (!payload || typeof payload !== 'object') return []

  const preferredKeys = [
    'ns', 'namespace', 'namespaces', 'namespaceList',
    'provider', 'providers', 'providerList',
    'connectionconfig', 'connConfig', 'connConfigs', 'connectionConfig', 'connectionConfigs',
    'infra', 'infras', 'infraList',
    'regions', 'region', 'regionList',
    'availableZones', 'allVerifiedZones', 'zones', 'zoneList',
    'availableK8sVersion', 'availableK8sVersions', 'k8sVersion', 'k8sVersions', 'versions', 'versionList',
    'images', 'image', 'imageList',
    'specs', 'spec', 'specList',
    'idList', 'output',
    'resources', 'resource', 'resourceList',
    'items', 'list', 'result',
  ]

  for (const key of preferredKeys) {
    if (Array.isArray(payload[key])) return payload[key]
  }

  for (const value of Object.values(payload)) {
    const nested = findFirstArray(value)
    if (nested.length > 0) return nested
  }

  return []
}

const normalizeAccessHostOptions = (response: any): Array<InfraOption> => {
  const payload = response?.data ?? response
  const nodes = [] as Array<any>
  collectAccessNodes(payload, nodes)

  const seen = new Set<string>()
  return nodes
    .map((node: any) => {
      const host = String(node?.publicIP ?? node?.publicIp ?? node?.privateIP ?? node?.privateIp ?? node?.host ?? '')
      const nodeId = String(node?.nodeId ?? node?.id ?? node?.name ?? '')
      const sshUser = String(node?.nodeUserName ?? node?.userName ?? node?.sshUser ?? '')
      const labelPrefix = nodeId ? `${nodeId} / ` : ''
      return {
        label: `${labelPrefix}${host}`,
        value: host,
        meta: { sshUser, nodeId },
      }
    })
    .filter((option: InfraOption) => {
      if (!option.value || seen.has(option.value)) return false
      seen.add(option.value)
      return true
    })
    .sort(compareInfraOptions)
}

const collectAccessNodes = (value: any, nodes: Array<any>) => {
  if (Array.isArray(value)) {
    value.forEach((item) => collectAccessNodes(item, nodes))
    return
  }

  if (!value || typeof value !== 'object') return

  const hasHost = value.publicIP || value.publicIp || value.privateIP || value.privateIp || value.host
  if (hasHost) {
    nodes.push(value)
  }

  Object.values(value).forEach((nested) => collectAccessNodes(nested, nodes))
}

const getWorkflowParamValue = (paramKey: string) => {
  return paramData.value.find((param) => param.paramKey?.toUpperCase() === paramKey.toUpperCase())?.paramValue || ''
}

const getNamespaceParamValue = () => {
  return getWorkflowParamValue('NAMESPACE') || userInfo.projectInfo.ns_id || selectedNamespace.value || ''
}

const getResourceCatalogNamespace = () => {
  return selectedNamespace.value || getNamespaceParamValue() || 'system'
}

const applyInfraSelectionParams = () => {
  const namespace = selectedNamespace.value || getNamespaceParamValue()
  if (namespace) {
    upsertWorkflowParam('NAMESPACE', namespace)
  }
  upsertWorkflowParam('PROVIDER', infraProvider.value)
  upsertWorkflowParam('CSP', infraProvider.value)

  if (isMultiCspWorkflow()) {
    const cspKey = normalizeCspKey(infraProvider.value)
    if (cspKey) {
      upsertWorkflowParam(`${cspKey}_REGION`, selectedRegion.value)
      upsertWorkflowParam(`${cspKey}_CONNECTION_NAME`, selectedConnectionName.value || deriveConnectionName())
      upsertWorkflowParam(`${cspKey}_ZONE`, selectedZone.value)
      upsertWorkflowParam(`${cspKey}_IMAGE_ID`, selectedImage.value)
      upsertWorkflowParam(`${cspKey}_SPEC_ID`, selectedSpec.value)
      if (isKubernetesImageWorkflow.value) {
        upsertWorkflowParam(`${cspKey}_K8S_VERSION`, selectedK8sVersion.value)
      }
    }
    return
  }

  upsertWorkflowParam('REGION', selectedRegion.value)
  upsertWorkflowParam('CONNECTION_NAME', selectedConnectionName.value || deriveConnectionName())
  upsertWorkflowParam('ZONE', selectedZone.value)
  upsertWorkflowParam('IMAGE', selectedImage.value)
  upsertWorkflowParam('IMAGE_ID', selectedImage.value)
  upsertWorkflowParam('SPEC', selectedSpec.value)
  upsertWorkflowParam('SPEC_ID', selectedSpec.value)
  if (isKubernetesImageWorkflow.value) {
    upsertWorkflowParam('K8S_VERSION', selectedK8sVersion.value)
  }
}

const getSelectedOptionLabel = (options: Array<InfraOption>, value: string) => {
  if (!value) return ''
  return options.find((option) => option.value === value)?.label || value
}

const upsertWorkflowParam = (paramKey: string, paramValue: string, eventListenerYn = 'N') => {
  if (!paramKey) return
  const normalizedKey = paramKey.trim().toUpperCase()
  const existingParam = paramData.value.find((param) => param.paramKey?.trim().toUpperCase() === normalizedKey)

  if (existingParam) {
    existingParam.paramValue = paramValue
    existingParam.eventListenerYn = existingParam.eventListenerYn || eventListenerYn
    return
  }

  paramData.value.push({
    paramIdx: 0,
    paramKey: normalizedKey,
    paramValue,
    eventListenerYn,
  })
}
</script>

<style scoped>
.tumblebug-param-field {
  min-width: 0;
}

.tumblebug-param-label {
  align-items: center;
  display: flex;
  gap: 0.5rem;
  justify-content: space-between;
  margin-bottom: 0.35rem;
  min-height: 1.45rem;
}

.tumblebug-param-label code {
  background: #eef4ff;
  border-radius: 4px;
  color: #206bc4;
  font-size: 0.72rem;
  line-height: 1.2;
  min-width: 0;
  overflow-wrap: anywhere;
  padding: 0.14rem 0.38rem;
}

.tumblebug-param-label span {
  color: #667085;
  flex: 0 0 auto;
  font-size: 0.75rem;
  font-weight: 500;
}

.tumblebug-param-label-actions {
  align-items: center;
  display: flex;
  gap: 0.5rem;
}

.tumblebug-k8s-toggle {
  align-items: center;
  display: flex;
  gap: 0.25rem;
  margin: 0;
  min-height: 0;
}

.tumblebug-k8s-toggle .form-check-input {
  cursor: pointer;
  margin-top: 0;
}

.tumblebug-k8s-toggle .form-check-label {
  color: #475467;
  cursor: pointer;
  font-size: 0.72rem;
  font-weight: 600;
}

.tumblebug-param-action-label {
  justify-content: flex-end;
}
</style>
