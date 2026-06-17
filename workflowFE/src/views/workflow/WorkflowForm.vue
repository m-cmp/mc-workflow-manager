<template>
  <div>
    <!-- Page header -->
    <div class="page-header">
      <div class="row align-items-center">
        <div class="col">
          <h2 class="page-title">{{ mode === 'new' ? 'New' : 'Detail' }} Workflow</h2>
        </div>
      </div>
    </div>

    <!-- Data card -->
    <div class="card card-flush w-100" ref="workflowForm">
      <div 
      class="card-body" 
      v-if="
            workflowInfoFormData &&
            workflowParamsFormData &&
            workflowStageMappingsFormData">
        <div class="card-title">
          <!-- Workflow Name -->
          <div class="mb-3">
            <label class="form-label required">
              Workflow Name
            </label>
            <div class="grid gap-0 column-gap-3">
              <input type="text" ref="workflowName" class="form-control p-2 g-col-11" placeholder="Enter the workflow name" v-model="workflowInfoFormData.workflowName" @input="onChangeWorkflowName" />
              <button
                  v-if="!duplicatedWorkflow"
                  class="btn btn-primary chk"
                  @click="onClickDuplicatWorkflowName(workflowInfoFormData.workflowName)"
                  style="margin:3px; width: 150px;"
                >Duplicate Check</button>
                <button
                  v-else
                  class="btn btn-success"
                  style="margin:3px; width: 150px;"
                >Duplicate Check</button>
            </div>
          </div>

          <!-- Purpose -->
          <div class="mb-3">
            <label class="form-label required">Purpose</label>
            <div class="grid gap-0 column-gap-3">
              <select ref="workflowPurpose" v-model="workflowInfoFormData.workflowPurpose" class="form-select p-2 g-col-12">
                <option value="">Select Workflow Purpose.</option>
                <option v-for="(purpose, idx) in workflowPurposeList" :value="purpose.value" :key="idx">
                  {{ purpose.name }}
                </option>
              </select>
            </div>
          </div>

          <!-- Infra Deployment Setting -->
          <div class="mb-3" v-if="showTumblebugSelectorControl">
            <div class="d-flex align-items-center justify-content-between mb-2">
              <label class="form-label mb-0">Tumblebug Parameter Selection</label>
              <label class="form-check form-switch mb-0">
                <input
                  class="form-check-input"
                  type="checkbox"
                  v-model="tumblebugSelectorEnabled"
                />
                <span class="form-check-label">{{ tumblebugSelectorEnabled ? 'Enabled' : 'Disabled' }}</span>
              </label>
            </div>
          </div>

          <div class="mb-3" v-if="showInfraSettings">
            <div class="grid gap-0 column-gap-3 mb-2">
              <div class="tumblebug-param-field g-col-4">
                <label class="tumblebug-param-label">
                  <code>{{ getSelectionParamKeyLabel('NAMESPACE') }}</code>
                  <span>Namespace</span>
                </label>
                <input
                  v-model="selectedNamespace"
                  class="form-control p-2"
                  :list="namespaceInputListId"
                  placeholder="Namespace"
                  autocomplete="off"
                  @input="onInputNamespace"
                  @change="onChangeNamespace"
                />
                <datalist :id="namespaceInputListId">
                  <option
                    v-for="option in namespaceOptions"
                    :key="option.value"
                    :value="option.value"
                  >
                    {{ option.label }}
                  </option>
                </datalist>
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
                <input
                  v-model="selectedInfra"
                  class="form-control p-2"
                  :list="infraInputListId"
                  placeholder="Infra ID"
                  autocomplete="off"
                  @input="onInputInfra"
                  @change="onChangeInfra"
                />
                <datalist :id="infraInputListId">
                  <option
                    v-for="option in infraOptions"
                    :key="option.value"
                    :value="option.value"
                  >
                    {{ option.label }}
                  </option>
                </datalist>
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
            <div class="grid gap-0 column-gap-3 mb-2">
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
                  :options="effectiveZoneOptions"
                  :placeholder="zonePlaceholder"
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

          <!-- OSS URL -->
          <!-- <div class="mb-3">
            <label class="form-label required">OSS URL</label>
            <div class="grid gap-0 column-gap-3">
              <input type="text" class="form-control p-2 g-col-12" placeholder="Enter the OSS URL" :value="ossUrl" disabled/>
            </div>
          </div> -->
          <!-- Pipeline -->
          <PipelineGenerator
            :mode="mode"
            :workflow-stage-mappings-form-data="workflowStageMappingsFormData"
            @init-workflow-stage-mappings="initWorkflowStageMappings"
            @on-click-create-script="onClickCreateScript"
            @splice-workflow-stage-mappings-form-data="spliceWorkflowStageMappingsFormData"
          />

          <!-- Parameters -->
          <ParamForm 
            :popup="false"
            :workflow-param-data="workflowParamsFormData"
            event-listener-yn="N"
          />

          <WorkflowHistoryList
            :workflow-idx="workflowInfoFormData.workflowIdx"
            :workflow-name="workflowInfoFormData.workflowName"
          />
            
          <div class="row align-items-center">
            <div id="gap" class="col" />
            <div class="col-auto ms-auto">
              <div class="btn-list">
                <button class="btn btn-primary" @click="onClickSubmit">
                  {{ mode === 'new' ? 'Regist' : 'Edit' }}
                </button>
                <!-- <button v-show="mode === 'edit'" class="btn btn-info" @click="onClickRun">
                  Run
                </button> -->
                <button class="btn btn-secondary" @click="onClickGoBack">
                  Go Back
                </button>
                <button class="btn btn-right border" @click="onClickList">
                  To List
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { nextTick, ref } from 'vue';
import { onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
// @ts-ignore
import { getOssList } from '@/api/oss'
// @ts-ignore
import type { Workflow, WorkflowPurpose, Oss, WorkflowInfo, WorkflowParams, WorkflowStageMappings } from '@/views/type/type'
// @ts-ignore
import PipelineGenerator from '@/views/workflow/components/PipelineGenerator.vue';
// @ts-ignore
import { duplicateCheck, getWorkflowDetailInfo, registWorkflow, updateWorkflow, getTemplateStage } from '@/api/workflow'
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
import { useToast } from 'vue-toastification';
// @ts-ignore
import ParamForm from './components/ParamForm.vue';
// @ts-ignore
import WorkflowHistoryList from '@/views/workflow/components/WorkflowHistoryList.vue';
import SearchableSelect from '@/views/workflow/components/SearchableSelect.vue';
import { reactive } from 'vue';
// @ts-ignore
import _ from 'lodash';
import { computed } from 'vue';
import { watch } from 'vue';
import { useUserStore } from '@/stores/user'

const toast = useToast()
const route = useRoute();
const router = useRouter();
const userInfo = useUserStore()
const DEFAULT_SCHEMA_SQL_CONTENT = 'CREATE TABLE IF NOT EXISTS sample_data (id INT PRIMARY KEY, name VARCHAR(100));'
const DEFAULT_INSERT_SQL = "INSERT INTO sample_data (id, name) VALUES (1, 'sample row');"

onMounted(async () => {
  setMode()
  await setWorkflowFormData()
  await setOssInfo()
  setWorkflowPurposeList()
  await initTumblebugSelectionValues()
  await loadInfraOptions()
})

// ================================================================================= Set mode
const mode = ref('new' as string)
const setMode = () => {
  mode.value = route.params.workflowIdx === undefined ? 'new' : 'detail'
}

// ================================================================================= Set create / edit data
// workflowInfo data
let workflowInfoFormData = reactive({} as WorkflowInfo)
const workflowParamsFormData = ref([] as Array<WorkflowParams>)
const workflowStageMappingsFormData = ref([] as Array<WorkflowStageMappings>)

const defaultWorkflowInfoFormData = {
    workflowIdx: 0,
    workflowName: '',
    workflowPurpose: '',
    ossIdx: 0,
    script: '',
}
const defaultWorkflowParamsFormData = [
    {
      paramKey: '',
      paramValue: '',
      eventListenerYn: 'N'
    }
  ]

const setWorkflowFormData = async () => {
  if (mode.value === 'new') {
    workflowInfoFormData = { ...defaultWorkflowInfoFormData }
    workflowParamsFormData.value = [ ...defaultWorkflowParamsFormData ]
    workflowStageMappingsFormData.value = []
    duplicatedWorkflow.value = false
    checkedWorkflowName.value = ''
  }
  else {
    const { data } = await getWorkflowDetailInfo(route.params.workflowIdx, 'N')
    workflowInfoFormData = {
      ...data.workflowInfo,
      workflowPurpose: normalizeWorkflowPurposeValue(data.workflowInfo.workflowPurpose),
    }
    workflowParamsFormData.value = [ ...data.workflowParams ]
    workflowStageMappingsFormData.value = [ ...data.workflowStageMappings ]

    workflowInfoFormData = { ...workflowInfoFormData, workflowIdx: route.params.workflowIdx }
    duplicatedWorkflow.value = true
    checkedWorkflowName.value = workflowInfoFormData.workflowName
  }
}

// ================================================================================= Infra manager options / auto parameters
interface InfraOption {
  label: string
  value: string
  searchText?: string
  meta?: Record<string, any>
}

type InfraOptionKind = 'default' | 'image' | 'spec' | 'k8sVersion'

interface VmSelectionDefault {
  region: string
  connectionName: string
  zone: string
  specId: string
  imageId: string
}

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
const inputIdSuffix = Math.random().toString(36).slice(2)
const namespaceInputListId = `tumblebug-namespace-options-${inputIdSuffix}`
const infraInputListId = `tumblebug-infra-options-${inputIdSuffix}`
const namespaceOptions = ref([] as Array<InfraOption>)
const regionOptions = ref([] as Array<InfraOption>)
const imageOptions = ref([] as Array<InfraOption>)
const specOptions = ref([] as Array<InfraOption>)
const infraOptions = ref([] as Array<InfraOption>)
const accessHostOptions = ref([] as Array<InfraOption>)
const connectionOptions = ref([] as Array<InfraOption>)
const zoneOptions = ref([] as Array<InfraOption>)
const zoneLoading = ref(false)
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
const tumblebugStageNames = [
  'infra-create',
  'k8s-cluster-create',
  'k8s-kubeconfig-get',
  'mariadb-install',
  'infra-ssh-connect-check',
  'ssh-command-exec',
]
const tumblebugSelectionParamKeys = [
  'TUMBLEBUG_SELECTOR_YN',
  'NAMESPACE',
  'PROVIDER',
  'CSP',
  'REGION',
  'IMAGE',
  'IMAGE_ID',
  'SPEC',
  'SPEC_ID',
  'K8S_VERSION',
  'INFRA_ID',
  'SSH_HOST',
  'DB_HOST',
  'K8S_CLUSTER_ID',
  'CONNECTION_NAME',
  'ZONE',
]
const tumblebugSelectorManagedParamKeys = [
  'PROVIDER',
  'CSP',
  'REGION',
  'CONNECTION_NAME',
  'ZONE',
  'IMAGE',
  'IMAGE_ID',
  'SPEC',
  'SPEC_ID',
  'K8S_VERSION',
]
const selectorRequiredStageNames = ['infra-create', 'k8s-cluster-create', 'multi-csp-vm-deploy', 'multi-csp-k8s-cluster-deploy']
const selectorCandidateStageNames = [...selectorRequiredStageNames, ...tumblebugStageNames]
const kubernetesImageStageNames = ['k8s-cluster-create', 'k8s-nodegroup-add', 'multi-csp-k8s-cluster-deploy']
const kubernetesImageEnabled = ref(false)
const kubernetesImageModeChanged = ref(false)
const noZoneOption = { label: 'No zone required', value: '', searchText: 'no zone optional blank' }
const vmSelectionDefaults: Record<string, VmSelectionDefault> = {
  alibaba: {
    region: 'ap-northeast-2',
    connectionName: 'alibaba-ap-northeast-2',
    zone: 'ap-northeast-2a',
    specId: 'alibaba+ap-northeast-2+ecs.e-c1m1.large',
    imageId: 'ubuntu_22_04_x64_20G_alibase_20260522.vhd',
  },
  aws: {
    region: 'ap-northeast-1',
    connectionName: 'aws-ap-northeast-1',
    zone: 'ap-northeast-1a',
    specId: 'aws+ap-northeast-1+t3.small',
    imageId: 'ami-00b4561fe1d28c285',
  },
  azure: {
    region: 'koreacentral',
    connectionName: 'azure-koreacentral',
    zone: '1',
    specId: 'azure+koreacentral+Standard_D2s_v3',
    imageId: 'Canonical:ubuntu-22_04-lts:server:22.04.202603110',
  },
  ibm: {
    region: 'jp-osa',
    connectionName: 'ibm-jp-osa',
    zone: 'jp-osa-1',
    specId: 'ibm+jp-osa+bxf-2x8',
    imageId: 'r034-ed053bf7-43c9-4b64-844b-77918ac3d597',
  },
  ncp: {
    region: 'kr',
    connectionName: 'ncp-kr',
    zone: 'KR-1',
    specId: 'ncp+kr+c2-g3',
    imageId: '104630229',
  },
  nhn: {
    region: 'kr1',
    connectionName: 'nhn-kr1',
    zone: 'kr-pub-a',
    specId: 'nhn+kr1+m2.c1m2',
    imageId: '0f07c795-2a46-44fc-a61b-fa0d96763ce2',
  },
  tencent: {
    region: 'ap-seoul',
    connectionName: 'tencent-ap-seoul',
    zone: 'ap-seoul-1',
    specId: 'tencent+ap-seoul+BF1.MEDIUM2',
    imageId: 'img-487zeit5',
  },
}

const hasSelectorCandidate = computed(() => {
  return mode.value === 'new'
    || workflowStageMappingsFormData.value.some((stage) => selectorCandidateStageNames.includes(stage.workflowStageName || ''))
    || workflowParamsFormData.value.some((param) => tumblebugSelectionParamKeys.includes(param.paramKey?.trim().toUpperCase() || ''))
})

const hasSelectorRequiredStage = computed(() => {
  return workflowStageMappingsFormData.value.some((stage) => selectorRequiredStageNames.includes(stage.workflowStageName || ''))
})

const isKubernetesImageWorkflow = computed(() => {
  return workflowStageMappingsFormData.value.some((stage) => kubernetesImageStageNames.includes((stage.workflowStageName || '').toLowerCase()))
})

const isNoZoneProvider = computed(() => infraProvider.value.toLowerCase() === 'azure')

const effectiveZoneOptions = computed(() => {
  if (zoneOptions.value.length > 0) {
    return zoneOptions.value
  }

  if (
    !zoneLoading.value
    && isNoZoneProvider.value
    && selectedSpec.value
    && selectedRegion.value
    && (selectedConnectionName.value || deriveConnectionName())
  ) {
    return [noZoneOption]
  }

  return []
})

const zonePlaceholder = computed(() => {
  return effectiveZoneOptions.value.length === 1 && effectiveZoneOptions.value[0].value === ''
    ? noZoneOption.label
    : 'Zone'
})

const tumblebugSelectorEnabled = computed({
  get: () => {
    const configuredValue = getWorkflowParamValue('TUMBLEBUG_SELECTOR_YN').trim().toUpperCase()
    if (['Y', 'YES', 'TRUE', '1'].includes(configuredValue)) return true
    if (['N', 'NO', 'FALSE', '0'].includes(configuredValue)) return false
    return hasSelectorRequiredStage.value
  },
  set: (enabled: boolean) => {
    upsertWorkflowParam('TUMBLEBUG_SELECTOR_YN', enabled ? 'Y' : 'N')
    if (!enabled) {
      removeTumblebugSelectorManagedParams()
    } else {
      applyInfraSelectionParams()
    }
  },
})

const showTumblebugSelectorControl = computed(() => hasSelectorCandidate.value)

const showInfraSettings = computed(() => {
  return showTumblebugSelectorControl.value && tumblebugSelectorEnabled.value
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

const initTumblebugSelectionValues = async () => {
  isInitializingSelection.value = true
  try {
    const resourceIdParts = parseTumblebugResourceId(getWorkflowParamValue('SPEC_ID') || getWorkflowParamValue('IMAGE_ID'))
    if (resourceIdParts.provider) {
      infraProvider.value = resourceIdParts.provider
    }

    selectedNamespace.value = getNamespaceParamValue()
    selectedInfra.value = getWorkflowParamValue('INFRA_ID') || getWorkflowParamValue('K8S_CLUSTER_ID')
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

const getVmSelectionDefault = () => {
  if (kubernetesImageEnabled.value || isKubernetesImageWorkflow.value) {
    return undefined
  }
  return vmSelectionDefaults[infraProvider.value.toLowerCase()]
}

const applyVmSelectionDefault = () => {
  const defaults = getVmSelectionDefault()
  if (!defaults) return
  selectedRegion.value = selectedRegion.value || defaults.region
  selectedConnectionName.value = selectedConnectionName.value || defaults.connectionName
  selectedZone.value = selectedZone.value || defaults.zone
  selectedSpec.value = selectedSpec.value || defaults.specId
  selectedImage.value = selectedImage.value || defaults.imageId
}

const syncSelectionFromCurrentCspParams = () => {
  if (!isMultiCspWorkflow()) {
    return
  }

  const defaults = getVmSelectionDefault()
  const resourceIdParts = parseTumblebugResourceId(getCurrentCspParamValue('SPEC_ID') || getCurrentCspParamValue('IMAGE_ID'))
  selectedRegion.value = getCurrentCspParamValue('REGION') || resourceIdParts.region || defaults?.region || ''
  selectedImage.value = getCurrentCspParamValue('IMAGE_ID') || defaults?.imageId || ''
  selectedSpec.value = getCurrentCspParamValue('SPEC_ID') || defaults?.specId || ''
  selectedK8sVersion.value = getCurrentCspParamValue('K8S_VERSION')
  selectedConnectionName.value = getCurrentCspParamValue('CONNECTION_NAME') || defaults?.connectionName || ''
  selectedZone.value = getCurrentCspParamValue('ZONE') || defaults?.zone || ''
}

const getInputValue = (event: Event | undefined, fallback = '') => {
  return (event?.target as HTMLInputElement | null)?.value ?? fallback
}

const onInputNamespace = (event?: Event) => {
  selectedNamespace.value = getInputValue(event, selectedNamespace.value)
  upsertWorkflowParam('NAMESPACE', selectedNamespace.value)
}

const onChangeNamespace = async () => {
  upsertWorkflowParam('NAMESPACE', selectedNamespace.value)
  selectedAccessHost.value = ''
  accessHostOptions.value = []
  await Promise.all([loadMcInfraSpecs(), loadMcInfraInfras()])
  await loadMcInfraImages()
  if (selectedInfra.value) {
    await loadMcInfraAccessHosts()
  }
}

const onChangeInfraProvider = async () => {
  selectedRegion.value = ''
  selectedImage.value = ''
  selectedSpec.value = ''
  selectedConnectionName.value = ''
  selectedZone.value = ''
  selectedK8sVersion.value = ''
  syncSelectionFromCurrentCspParams()
  applyVmSelectionDefault()
  await loadInfraOptions()
  applyInfraSelectionParams()
}

const onChangeInfraSelection = () => {
  applyInfraSelectionParams()
}

const onInputInfra = (event?: Event) => {
  selectedInfra.value = getInputValue(event, selectedInfra.value)
  syncInfraIdParams()
}

const onChangeInfra = async () => {
  syncInfraIdParams()
  selectedAccessHost.value = ''
  accessHostOptions.value = []
  if (selectedInfra.value) {
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
  applyVmSelectionDefault()
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
    zoneLoading.value = false
    return
  }

  zoneLoading.value = true
  try {
    const { data } = await getMcInfraAvailableZones({
      specId: selectedSpec.value,
      providerName: infraProvider.value,
      regionName: selectedRegion.value,
      connectionName: selectedConnectionName.value || deriveConnectionName(),
    })
    if (loadSeq !== zoneLoadSeq) return
    zoneOptions.value = normalizeInfraOptions(data)
    if (selectedZone.value && !zoneOptions.value.some((option) => option.value === selectedZone.value)) {
      selectedZone.value = ''
    }
    zoneLoading.value = false
  } catch (error) {
    if (loadSeq !== zoneLoadSeq) return
    zoneOptions.value = []
    zoneLoading.value = false
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
    'items', 'list', 'result'
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
  return workflowParamsFormData.value.find((param) => param.paramKey?.toUpperCase() === paramKey.toUpperCase())?.paramValue || ''
}

const hasWorkflowParam = (paramKey: string) => {
  return workflowParamsFormData.value.some((param) => param.paramKey?.trim().toUpperCase() === paramKey.toUpperCase())
}

const syncInfraIdParams = () => {
  upsertWorkflowParam('INFRA_ID', selectedInfra.value)
  if (isKubernetesImageWorkflow.value || hasWorkflowParam('K8S_CLUSTER_ID')) {
    upsertWorkflowParam('K8S_CLUSTER_ID', selectedInfra.value)
  }
}

const getNamespaceParamValue = () => {
  return selectedNamespace.value || getWorkflowParamValue('NAMESPACE') || userInfo.projectInfo.ns_id || ''
}

const getResourceCatalogNamespace = () => {
  return selectedNamespace.value || getNamespaceParamValue() || 'system'
}

const applyInfraSelectionParams = () => {
  if (!tumblebugSelectorEnabled.value) {
    return
  }

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

const removeTumblebugSelectorManagedParams = () => {
  workflowParamsFormData.value = workflowParamsFormData.value.filter((param) => {
    const key = param.paramKey?.trim().toUpperCase() || ''
    if (tumblebugSelectorManagedParamKeys.includes(key)) {
      return false
    }
    return !tumblebugSelectorManagedParamKeys.some((managedKey) => key.endsWith(`_${managedKey}`))
  })
  selectedImage.value = ''
  selectedSpec.value = ''
  selectedRegion.value = ''
  selectedConnectionName.value = ''
  selectedZone.value = ''
  selectedK8sVersion.value = ''
}

const getSelectedOptionLabel = (options: Array<InfraOption>, value: string) => {
  if (!value) return ''
  return options.find((option) => option.value === value)?.label || value
}

const getDefaultK8sRootDiskType = () => {
  return infraProvider.value?.trim().toLowerCase() === 'alibaba' ? 'cloud_essd' : 'default'
}

const addDefaultParamsForStage = (stage?: string | WorkflowStageMappings) => {
  const stageName = typeof stage === 'string' ? stage : stage?.workflowStageName
  if (!stageName) return

  const workflowName = workflowInfoFormData.workflowName || 'workflow'
  const defaultInfraId = `${workflowName}-infra`
  const defaultClusterId = `${workflowName}-cluster`
  const responseDefaultParams = typeof stage === 'string' ? [] : (stage?.defaultParams || [])
  const stageParamMap: Record<string, Array<WorkflowParams>> = {
    'infra-create': [
      { paramKey: 'TUMBLEBUG', paramValue: 'http://mc-infra-manager:1323', eventListenerYn: 'N' },
      { paramKey: 'USER', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'USERPASS', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'NAMESPACE', paramValue: getNamespaceParamValue(), eventListenerYn: 'N' },
      { paramKey: 'INFRA_ID', paramValue: defaultInfraId, eventListenerYn: 'N' },
      { paramKey: 'REGION', paramValue: selectedRegion.value, eventListenerYn: 'N' },
      { paramKey: 'CONNECTION_NAME', paramValue: deriveConnectionName(), eventListenerYn: 'N' },
      { paramKey: 'ZONE', paramValue: '', eventListenerYn: 'N' },
      { paramKey: 'IMAGE', paramValue: selectedImage.value, eventListenerYn: 'N' },
      { paramKey: 'IMAGE_ID', paramValue: selectedImage.value, eventListenerYn: 'N' },
      { paramKey: 'SPEC', paramValue: selectedSpec.value, eventListenerYn: 'N' },
      { paramKey: 'SPEC_ID', paramValue: selectedSpec.value, eventListenerYn: 'N' },
      { paramKey: 'SSH_USER', paramValue: 'cb-user', eventListenerYn: 'N' },
      { paramKey: 'INFRA_ACCESS_INFO_MAX_ATTEMPTS', paramValue: '30', eventListenerYn: 'N' },
      { paramKey: 'INFRA_ACCESS_INFO_INTERVAL_SECONDS', paramValue: '10', eventListenerYn: 'N' },
    ],
    'multi-csp-vm-delete': [
      { paramKey: 'TUMBLEBUG', paramValue: 'http://mc-infra-manager:1323', eventListenerYn: 'N' },
      { paramKey: 'USER', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'USERPASS', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'NAMESPACE', paramValue: getNamespaceParamValue(), eventListenerYn: 'N' },
      { paramKey: 'CSP_LIST', paramValue: 'aws,azure,gcp,ncp,nhn,alibaba,tencent,ibm,kt', eventListenerYn: 'N' },
      { paramKey: 'INFRA_PREFIX', paramValue: 'multi-csp-vm', eventListenerYn: 'N' },
      { paramKey: 'INFRA_ID_LIST', paramValue: '', eventListenerYn: 'N' },
      { paramKey: 'INFRA_DELETE_OPTION', paramValue: 'terminate', eventListenerYn: 'N' },
    ],
    'k8s-cluster-create': [
      { paramKey: 'TUMBLEBUG', paramValue: 'http://mc-infra-manager:1323', eventListenerYn: 'N' },
      { paramKey: 'USER', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'USERPASS', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'NAMESPACE', paramValue: getNamespaceParamValue(), eventListenerYn: 'N' },
      { paramKey: 'PROVIDER', paramValue: infraProvider.value, eventListenerYn: 'N' },
      { paramKey: 'CSP', paramValue: infraProvider.value, eventListenerYn: 'N' },
      { paramKey: 'REGION', paramValue: selectedRegion.value, eventListenerYn: 'N' },
      { paramKey: 'CONNECTION_NAME', paramValue: deriveConnectionName(), eventListenerYn: 'N' },
      { paramKey: 'K8S_CLUSTER_ID', paramValue: defaultClusterId, eventListenerYn: 'N' },
      { paramKey: 'K8S_NODEGROUP_NAME', paramValue: 'ng1', eventListenerYn: 'N' },
      { paramKey: 'IMAGE', paramValue: selectedImage.value, eventListenerYn: 'N' },
      { paramKey: 'IMAGE_ID', paramValue: selectedImage.value, eventListenerYn: 'N' },
      { paramKey: 'SPEC', paramValue: selectedSpec.value, eventListenerYn: 'N' },
      { paramKey: 'SPEC_ID', paramValue: selectedSpec.value, eventListenerYn: 'N' },
      { paramKey: 'K8S_VERSION', paramValue: selectedK8sVersion.value || '1.33', eventListenerYn: 'N' },
      { paramKey: 'K8S_DESIRED_NODE_SIZE', paramValue: '1', eventListenerYn: 'N' },
      { paramKey: 'K8S_MIN_NODE_SIZE', paramValue: '1', eventListenerYn: 'N' },
      { paramKey: 'K8S_MAX_NODE_SIZE', paramValue: '3', eventListenerYn: 'N' },
      { paramKey: 'ROOT_DISK_TYPE', paramValue: getDefaultK8sRootDiskType(), eventListenerYn: 'N' },
      { paramKey: 'ROOT_DISK_SIZE', paramValue: '30', eventListenerYn: 'N' },
      { paramKey: 'K8S_NODEGROUP_CREATE_IF_MISSING', paramValue: 'true', eventListenerYn: 'N' },
      { paramKey: 'K8S_STATUS_MAX_ATTEMPTS', paramValue: '360', eventListenerYn: 'N' },
      { paramKey: 'K8S_STATUS_INTERVAL_SECONDS', paramValue: '10', eventListenerYn: 'N' },
      { paramKey: 'K8S_READY_STATUS', paramValue: 'Active,Running', eventListenerYn: 'N' },
    ],
    'k8s-kubeconfig-get': [
      { paramKey: 'TUMBLEBUG', paramValue: 'http://mc-infra-manager:1323', eventListenerYn: 'N' },
      { paramKey: 'USER', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'USERPASS', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'NAMESPACE', paramValue: getNamespaceParamValue(), eventListenerYn: 'N' },
      { paramKey: 'K8S_CLUSTER_ID', paramValue: getWorkflowParamValue('K8S_CLUSTER_ID') || defaultClusterId, eventListenerYn: 'N' },
      { paramKey: 'K8S_KUBECONFIG_MAX_ATTEMPTS', paramValue: '30', eventListenerYn: 'N' },
      { paramKey: 'K8S_KUBECONFIG_INTERVAL_SECONDS', paramValue: '10', eventListenerYn: 'N' },
      { paramKey: 'KUBECONFIG_CONTENT', paramValue: '', eventListenerYn: 'N' },
    ],
    'app-deploy-helm': [
      { paramKey: 'KUBECONFIG_CONTENT', paramValue: '', eventListenerYn: 'N' },
      { paramKey: 'KUBE_NAMESPACE', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'RELEASE_NAME', paramValue: 'mariadb', eventListenerYn: 'N' },
      { paramKey: 'HELM_REPO_NAME', paramValue: 'groundhog2k', eventListenerYn: 'N' },
      { paramKey: 'HELM_REPO_URL', paramValue: 'https://groundhog2k.github.io/helm-charts', eventListenerYn: 'N' },
      { paramKey: 'HELM_CHART', paramValue: 'groundhog2k/mariadb', eventListenerYn: 'N' },
      { paramKey: 'HELM_CHART_VERSION', paramValue: '4.5.0', eventListenerYn: 'N' },
      { paramKey: 'HELM_RECREATE_ON_IMMUTABLE_ERROR', paramValue: 'true', eventListenerYn: 'N' },
      { paramKey: 'K8S_API_READY_MAX_ATTEMPTS', paramValue: '360', eventListenerYn: 'N' },
      { paramKey: 'K8S_API_READY_INTERVAL_SECONDS', paramValue: '10', eventListenerYn: 'N' },
      { paramKey: 'K8S_NODE_READY_MIN_COUNT', paramValue: '1', eventListenerYn: 'N' },
      { paramKey: 'HELM_VALUES_ARGS', paramValue: '--set settings.rootPassword.value=mariadb_pass --set userDatabase.name.value=testdb --set userDatabase.user.value=mariadb_user --set userDatabase.password.value=mariadb_pass --wait --timeout 10m', eventListenerYn: 'N' },
      { paramKey: 'DB_EXEC_MODE', paramValue: 'k8s', eventListenerYn: 'N' },
      { paramKey: 'DB_POD_SELECTOR', paramValue: 'app.kubernetes.io/instance=mariadb,app.kubernetes.io/name=mariadb', eventListenerYn: 'N' },
    ],
    'app-deploy-manifest': [
      { paramKey: 'KUBECONFIG_CONTENT', paramValue: '', eventListenerYn: 'N' },
      { paramKey: 'KUBE_NAMESPACE', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'K8S_MANIFEST', paramValue: '', eventListenerYn: 'N' },
    ],
    'app-deploy-status-check': [
      { paramKey: 'KUBECONFIG_CONTENT', paramValue: '', eventListenerYn: 'N' },
      { paramKey: 'KUBE_NAMESPACE', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'DEPLOYMENT_NAME', paramValue: '', eventListenerYn: 'N' },
      { paramKey: 'ROLLOUT_TIMEOUT', paramValue: '300s', eventListenerYn: 'N' },
    ],
    'mariadb-install': [
      { paramKey: 'NAMESPACE', paramValue: getNamespaceParamValue(), eventListenerYn: 'N' },
      { paramKey: 'INFRA_ID', paramValue: defaultInfraId, eventListenerYn: 'N' },
      { paramKey: 'DB_EXEC_MODE', paramValue: 'ssh', eventListenerYn: 'N' },
      { paramKey: 'DB_HOST', paramValue: '', eventListenerYn: 'N' },
      { paramKey: 'DB_PORT', paramValue: '3306', eventListenerYn: 'N' },
      { paramKey: 'DB_NAME', paramValue: 'testdb', eventListenerYn: 'N' },
      { paramKey: 'DB_USER', paramValue: 'mariadb_user', eventListenerYn: 'N' },
      { paramKey: 'DB_PASSWORD', paramValue: 'mariadb_pass', eventListenerYn: 'N' },
      { paramKey: 'SSH_HOST', paramValue: '', eventListenerYn: 'N' },
      { paramKey: 'SSH_USER', paramValue: 'cb-user', eventListenerYn: 'N' },
      { paramKey: 'SSH_KEY_FILE', paramValue: '', eventListenerYn: 'N' },
    ],
    'db-backup-import': [
      { paramKey: 'DB_EXEC_MODE', paramValue: 'auto', eventListenerYn: 'N' },
      { paramKey: 'DB_HOST', paramValue: '', eventListenerYn: 'N' },
      { paramKey: 'DB_PORT', paramValue: '3306', eventListenerYn: 'N' },
      { paramKey: 'DB_NAME', paramValue: 'testdb', eventListenerYn: 'N' },
      { paramKey: 'DB_USER', paramValue: 'mariadb_user', eventListenerYn: 'N' },
      { paramKey: 'DB_PASSWORD', paramValue: 'mariadb_pass', eventListenerYn: 'N' },
      { paramKey: 'DB_BACKUP_FILE', paramValue: 'schema.sql', eventListenerYn: 'N' },
      { paramKey: 'SCHEMA_SQL_CONTENT', paramValue: DEFAULT_SCHEMA_SQL_CONTENT, eventListenerYn: 'N' },
      { paramKey: 'KUBE_NAMESPACE', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'RELEASE_NAME', paramValue: 'mariadb', eventListenerYn: 'N' },
      { paramKey: 'DB_POD_SELECTOR', paramValue: 'app.kubernetes.io/instance=mariadb,app.kubernetes.io/name=mariadb', eventListenerYn: 'N' },
    ],
    'db-schema-import': [
      { paramKey: 'DB_EXEC_MODE', paramValue: 'auto', eventListenerYn: 'N' },
      { paramKey: 'DB_HOST', paramValue: '', eventListenerYn: 'N' },
      { paramKey: 'DB_PORT', paramValue: '3306', eventListenerYn: 'N' },
      { paramKey: 'DB_NAME', paramValue: 'testdb', eventListenerYn: 'N' },
      { paramKey: 'DB_USER', paramValue: 'mariadb_user', eventListenerYn: 'N' },
      { paramKey: 'DB_PASSWORD', paramValue: 'mariadb_pass', eventListenerYn: 'N' },
      { paramKey: 'SCHEMA_SQL_FILE', paramValue: 'schema.sql', eventListenerYn: 'N' },
      { paramKey: 'SCHEMA_SQL_CONTENT', paramValue: DEFAULT_SCHEMA_SQL_CONTENT, eventListenerYn: 'N' },
      { paramKey: 'KUBE_NAMESPACE', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'RELEASE_NAME', paramValue: 'mariadb', eventListenerYn: 'N' },
      { paramKey: 'DB_POD_SELECTOR', paramValue: 'app.kubernetes.io/instance=mariadb,app.kubernetes.io/name=mariadb', eventListenerYn: 'N' },
    ],
    'db-data-insert': [
      { paramKey: 'DB_EXEC_MODE', paramValue: 'auto', eventListenerYn: 'N' },
      { paramKey: 'DB_HOST', paramValue: '', eventListenerYn: 'N' },
      { paramKey: 'DB_PORT', paramValue: '3306', eventListenerYn: 'N' },
      { paramKey: 'DB_NAME', paramValue: 'testdb', eventListenerYn: 'N' },
      { paramKey: 'DB_USER', paramValue: 'mariadb_user', eventListenerYn: 'N' },
      { paramKey: 'DB_PASSWORD', paramValue: 'mariadb_pass', eventListenerYn: 'N' },
      { paramKey: 'INSERT_SQL', paramValue: DEFAULT_INSERT_SQL, eventListenerYn: 'N' },
      { paramKey: 'KUBE_NAMESPACE', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'RELEASE_NAME', paramValue: 'mariadb', eventListenerYn: 'N' },
      { paramKey: 'DB_POD_SELECTOR', paramValue: 'app.kubernetes.io/instance=mariadb,app.kubernetes.io/name=mariadb', eventListenerYn: 'N' },
    ],
  }

  const resolveDefaultParamValue = (paramKey: string, paramValue: string) => {
    const existingValue = getWorkflowParamValue(paramKey)
    const normalizedKey = paramKey.trim().toUpperCase()

    switch (normalizedKey) {
      case 'NAMESPACE':
        return getNamespaceParamValue() || paramValue
      case 'PROVIDER':
      case 'CSP':
        return infraProvider.value || paramValue
      case 'REGION':
        return selectedRegion.value || paramValue
      case 'CONNECTION_NAME':
        return existingValue || selectedConnectionName.value || deriveConnectionName() || paramValue
      case 'ZONE':
        return selectedZone.value || existingValue || paramValue
      case 'IMAGE':
      case 'IMAGE_ID':
        return selectedImage.value || paramValue
      case 'SPEC':
      case 'SPEC_ID':
        return selectedSpec.value || paramValue
      case 'K8S_VERSION':
        return selectedK8sVersion.value || existingValue || paramValue
      case 'ROOT_DISK_TYPE':
        if ((stageName || '').trim().toLowerCase() === 'k8s-cluster-create') {
          return getDefaultK8sRootDiskType()
        }
        return existingValue || paramValue
      case 'INFRA_ID':
        return existingValue || paramValue || defaultInfraId
      case 'K8S_CLUSTER_ID':
        return existingValue || paramValue || defaultClusterId
      case 'SSH_HOST':
      case 'DB_HOST':
        return selectedAccessHost.value || existingValue || paramValue
      default:
        return paramValue
    }
  }

  const defaultParams = responseDefaultParams.length > 0 ? responseDefaultParams : (stageParamMap[stageName] || [])
  defaultParams.forEach((param) => {
    const paramKey = param.paramKey?.trim().toUpperCase()
    if (!paramKey) return
    upsertWorkflowParam(paramKey, resolveDefaultParamValue(paramKey, param.paramValue || ''), param.eventListenerYn, false)
  })
}

watch(
  () => workflowStageMappingsFormData.value
    .map((stage) => stage.workflowStageName)
    .filter(Boolean)
    .join('|'),
  () => {
    workflowStageMappingsFormData.value
      .filter((stage) => Boolean(stage.workflowStageName))
      .forEach((stage) => addDefaultParamsForStage(stage))
  }
)

const upsertWorkflowParam = (paramKey: string, paramValue: string, eventListenerYn = 'N', overwrite = true) => {
  if (!paramKey) return
  const normalizedKey = paramKey.trim().toUpperCase()
  const existingParam = workflowParamsFormData.value.find((param) => param.paramKey?.trim().toUpperCase() === normalizedKey)

  if (existingParam) {
    if (overwrite || !existingParam.paramValue) {
      existingParam.paramValue = paramValue
    }
    existingParam.eventListenerYn = existingParam.eventListenerYn || eventListenerYn
    return
  }

  workflowParamsFormData.value.push({
    paramIdx: 0,
    paramKey: normalizedKey,
    paramValue,
    eventListenerYn,
  })
}


// ================================================================================= Duplicate check
const duplicatedWorkflow = ref(false as boolean)
const checkedWorkflowName = ref('')
const normalizeWorkflowName = (workflowName?: string) => (workflowName || '').trim()
const onChangeWorkflowName = () => {
  const currentWorkflowName = normalizeWorkflowName(workflowInfoFormData.workflowName)
  duplicatedWorkflow.value = Boolean(currentWorkflowName && currentWorkflowName === checkedWorkflowName.value)
}
const onClickDuplicatWorkflowName = async (workflowName: string) => {
  const currentWorkflowName = normalizeWorkflowName(workflowName)
  if (!currentWorkflowName) {
    toast.error('Please enter Workflow Name.')
    return
  }

  const { data } = await duplicateCheck(currentWorkflowName)
  if (!data) {
    toast.success('Name is available.')
    duplicatedWorkflow.value = true
    checkedWorkflowName.value = currentWorkflowName
  }
  else {
    toast.error('Name is already in use.')
    duplicatedWorkflow.value = false
  }
}

// ================================================================================= Purpose list

const workflowPurposeList = ref([] as Array<WorkflowPurpose>)
const workflowPurposeValueMap: Record<string, string> = {
  deploy: 'For Deployment',
  run: 'For Execution',
  test: 'For Testing',
  webhook: 'For Webhook',
}
const normalizeWorkflowPurposeValue = (workflowPurpose?: string) => {
  return workflowPurposeValueMap[workflowPurpose || ''] || workflowPurpose || ''
}
const setWorkflowPurposeList = () => {
  workflowPurposeList.value = [
    {
      name: "For Deployment",
      value: "For Deployment"
    },
    {
      name: "For Execution",
      value: "For Execution"
    },
      {
      name: "For Testing",
      value: "For Testing"
    },
      {
      name: "For Webhook",
      value: "For Webhook"
    },
  ]
}

// ================================================================================= OSS URL
const ossUrl = ref('')
const setOssInfo = async () => {
  try {
    const { data } = await getOssList('JENKINS')

    if (data) {
      if (workflowInfoFormData) {
        // Create
        if (mode.value === 'new') {
          workflowInfoFormData.ossIdx = data ? data[0].ossIdx : 'No OSS information'
          ossUrl.value = data ? data[0].ossUrl : 'NULL'  
        }

        // Edit
        else {
          data.forEach((oss: Oss) => {
              if (oss.ossIdx === workflowInfoFormData.ossIdx) {
                ossUrl.value = oss.ossUrl
              }
          }) 
        }
      }
    }
  } catch (error) {
    console.log(error)
  }
}

// ================================================================================= Registration Action
const onClickSubmit = async () => {
  // ================= Validation =================
  if (!workflowInfoFormData.workflowName) {
    toast.error('Please enter Workflow Name.');
    return;
  }
  if (!duplicatedWorkflow.value || checkedWorkflowName.value !== normalizeWorkflowName(workflowInfoFormData.workflowName)) {
    toast.error('Please perform duplicate check for the name.');
    return;
  }
  if (!workflowInfoFormData.workflowPurpose) {
    toast.error('Please select Purpose.');
    return;
  }
  if (!workflowStageMappingsFormData.value || workflowStageMappingsFormData.value.length === 0) {
    toast.error('Please create Pipeline script.');
    return;
  }
  if (!setSubmitParam()) {
    return
  }
  if(mode.value === 'new')
    await _registWorkflow()
  else 
    await _updateWorkflow()
}
const _registWorkflow = async () => {
  const param = {
    workflowInfo: { ...workflowInfoFormData },
    workflowParams: [ ...workflowParamsFormData.value ],
    workflowStageMappings: [ ...workflowStageMappingsFormData.value ]
  }
  const { data } = await registWorkflow(param)
  if (data) {
    toast.success('Registered successfully.')
    router.push('/web/workflows/workflow/list')
  }
  else {
    toast.error('Failed to register.')
  }
}

const _updateWorkflow = async () => {
  const param = {
    workflowInfo: { ...workflowInfoFormData },
    workflowParams: [ ...workflowParamsFormData.value ],
    workflowStageMappings: [ ...workflowStageMappingsFormData.value ]
  }

  const { data } = await updateWorkflow(param)

  if (data) {
    toast.success('Updated successfully.')
    router.push('/web/workflows/workflow/list')
  }
  else {
    toast.error('Failed to update.')
  }
}
const setSubmitParam = () => {
  setWorkflowInfoScript()
  if (!cleanupWorkflowParams()) {
    return false
  }
  setRemoveWorkflowParamIdx()
  if (mode.value == 'new') {
    setRemoveWorkflowIdx()
  }
  return true
}

const setWorkflowInfoScript = () => {
  let str:string = ''
  workflowStageMappingsFormData.value.forEach((item) => {
    str += item.stageContent

    if (!item.isDefaultScript) 
      str += '\n'
  })

  workflowInfoFormData = {
    ...workflowInfoFormData,
    workflowPurpose: normalizeWorkflowPurposeValue(workflowInfoFormData.workflowPurpose),
    script: str,
  }
}

const setRemoveWorkflowIdx = () => {
  delete workflowInfoFormData.workflowIdx
}

const setRemoveWorkflowParamIdx = () => {
  workflowParamsFormData.value.forEach((param) => {
    delete param['paramIdx']
  })
}

const cleanupWorkflowParams = () => {
  const seenKeys = new Set<string>()
  const cleanedParams: Array<WorkflowParams> = []

  for (const param of workflowParamsFormData.value) {
    const paramKey = param.paramKey?.trim()
    if (!paramKey) continue

    const normalizedKey = paramKey.toUpperCase()
    if (seenKeys.has(normalizedKey)) {
      toast.error(`Duplicate parameter key: ${normalizedKey}`)
      return false
    }

    seenKeys.add(normalizedKey)
    cleanedParams.push({
      ...param,
      paramKey: normalizedKey,
      paramValue: param.paramValue ?? '',
      eventListenerYn: param.eventListenerYn || 'N',
    })
  }

  workflowParamsFormData.value = cleanedParams
  return true
}
// ================================================================================= Run Action
const onClickRun = () => {
  toast.success('Executed!')
}

// ================================================================================= Go to list
const onClickList = () => {
  router.push('/web/workflows/workflow/list')
}

// ================================================================================= Go back
const onClickGoBack = () => {
  router.push('/web/workflows/workflow/list')
}

// ================================================================================= PipelineGenerator
const initWorkflowStageMappings = () => {
  workflowStageMappingsFormData.value = []
}

// Template stage list
const onClickCreateScript = async () => {

  if (workflowInfoFormData.workflowName === '') {
    toast.error('Please enter workflow name.')
    return
  }

  else if (!workflowInfoFormData.workflowPurpose) {
    toast.error('Please select purpose.')
    return
  }
  await _getTemplateStage(workflowInfoFormData.workflowName);
}

// Variable for marking default script start / end
const defaultScriptTagFlags = ["DEFAULT_START", "DEFAULT_END"]
// Generate default script after validation when 'Create Script' is clicked
const _getTemplateStage = async (workflowName:string) => {
  try {
    initWorkflowStageMappings()

    const { data } = await getTemplateStage(workflowName)
    const list:Array<WorkflowStageMappings> = data || []

    // Default script flag
    // Data to be included when creating variables to mark script start and end
    list.forEach((item:WorkflowStageMappings, index:number) => {
      item.isDefaultScript = true;
      item.defaultScriptTag = defaultScriptTagFlags[index];
    })
    
    workflowStageMappingsFormData.value = [...list]
  } catch (error) {
    workflowStageMappingsFormData.value = [];
    toast.error(String(error));
  }
}

const spliceWorkflowStageMappingsFormData = (transClone: WorkflowStageMappings) => {
  workflowStageMappingsFormData.value.splice(workflowStageMappingsFormData.value.length - 1, 0, transClone);
  addDefaultParamsForStage(transClone)
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
