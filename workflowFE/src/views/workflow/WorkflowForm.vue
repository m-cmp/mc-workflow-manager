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
              <input type="text" ref="workflowName" class="form-control p-2 g-col-11" placeholder="Enter the workflow name" v-model="workflowInfoFormData.workflowName" />
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
          <div class="mb-3" v-if="showInfraSettings">
            <label class="form-label">Tumblebug Parameter Selection</label>
            <div class="grid gap-0 column-gap-3 mb-2">
              <select class="form-select p-2 g-col-3" v-model="selectedNamespace" @change="onChangeNamespace">
                <option value="">Namespace</option>
                <option v-for="option in namespaceOptions" :value="option.value" :key="option.value">
                  {{ option.label }}
                </option>
              </select>
              <select class="form-select p-2 g-col-3" v-model="infraProvider" @change="onChangeInfraProvider">
                <option v-for="provider in infraProviderList" :value="provider" :key="provider">
                  {{ provider }}
                </option>
              </select>
              <select class="form-select p-2 g-col-2" v-model="selectedRegion" @change="onChangeInfraSelection">
                <option value="">Region</option>
                <option v-for="option in regionOptions" :value="option.value" :key="option.value">
                  {{ option.label }}
                </option>
              </select>
              <select class="form-select p-2 g-col-2" v-model="selectedImage" @change="onChangeInfraSelection">
                <option value="">Image</option>
                <option v-for="option in imageOptions" :value="option.value" :key="option.value">
                  {{ option.label }}
                </option>
              </select>
              <select class="form-select p-2 g-col-2" v-model="selectedSpec" @change="onChangeInfraSelection">
                <option value="">VM Spec</option>
                <option v-for="option in specOptions" :value="option.value" :key="option.value">
                  {{ option.label }}
                </option>
              </select>
            </div>
            <div class="grid gap-0 column-gap-3 mb-2">
              <select class="form-select p-2 g-col-5" v-model="selectedInfra" @change="onChangeInfra">
                <option value="">Existing Infra</option>
                <option v-for="option in infraOptions" :value="option.value" :key="option.value">
                  {{ option.label }}
                </option>
              </select>
              <select class="form-select p-2 g-col-5" v-model="selectedAccessHost" @change="onChangeAccessHost">
                <option value="">SSH/DB Host</option>
                <option v-for="option in accessHostOptions" :value="option.value" :key="option.value">
                  {{ option.label }}
                </option>
              </select>
              <button class="btn btn-outline-primary g-col-2" @click="onClickRefreshInfraOptions">
                Refresh
              </button>
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
import { ref } from 'vue';
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
import { getMcInfra, getMcInfraList, getMcInfraNamespaces, getMcInfraRegions, getMcInfraResources } from '@/api/infraManager'
import { useToast } from 'vue-toastification';
// @ts-ignore
import ParamForm from './components/ParamForm.vue';
// @ts-ignore
import WorkflowHistoryList from '@/views/workflow/components/WorkflowHistoryList.vue';
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

onMounted(async () => {
  setMode()
  await setWorkflowFormData()
  await setOssInfo()
  setWorkflowPurposeList()
  initTumblebugSelectionValues()
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
  }
  else {
    const { data } = await getWorkflowDetailInfo(route.params.workflowIdx, 'N')
    workflowInfoFormData = { ...data.workflowInfo }
    workflowParamsFormData.value = [ ...data.workflowParams ]
    workflowStageMappingsFormData.value = [ ...data.workflowStageMappings ]

    workflowInfoFormData = { ...workflowInfoFormData, workflowIdx: route.params.workflowIdx }
    duplicatedWorkflow.value = true
  }
}

// ================================================================================= Infra manager options / auto parameters
interface InfraOption {
  label: string
  value: string
  meta?: Record<string, any>
}

const infraProviderList = ['aws', 'azure', 'gcp', 'ncp', 'nhn', 'alibaba', 'tencent', 'ibm']
const infraProvider = ref('aws')
const selectedRegion = ref('')
const selectedImage = ref('')
const selectedSpec = ref('')
const selectedNamespace = ref('')
const selectedInfra = ref('')
const selectedAccessHost = ref('')
const namespaceOptions = ref([] as Array<InfraOption>)
const regionOptions = ref([] as Array<InfraOption>)
const imageOptions = ref([] as Array<InfraOption>)
const specOptions = ref([] as Array<InfraOption>)
const infraOptions = ref([] as Array<InfraOption>)
const accessHostOptions = ref([] as Array<InfraOption>)

const showInfraSettings = computed(() => {
  return mode.value === 'new' || workflowStageMappingsFormData.value.some((stage) => stage.workflowStageName === 'infra-create')
})

watch(selectedRegion, async () => {
  await Promise.all([loadMcInfraImages(), loadMcInfraSpecs()])
  applyInfraSelectionParams()
})

const initTumblebugSelectionValues = () => {
  selectedNamespace.value = getNamespaceParamValue()
  selectedInfra.value = getWorkflowParamValue('INFRA_ID')
  selectedAccessHost.value = getWorkflowParamValue('SSH_HOST') || getWorkflowParamValue('DB_HOST')
  selectedRegion.value = getWorkflowParamValue('REGION')
  selectedImage.value = getWorkflowParamValue('IMAGE_ID') || getWorkflowParamValue('IMAGE')
  selectedSpec.value = getWorkflowParamValue('SPEC_ID') || getWorkflowParamValue('SPEC')
}

const onChangeNamespace = async () => {
  selectedInfra.value = ''
  selectedAccessHost.value = ''
  accessHostOptions.value = []
  if (selectedNamespace.value) {
    upsertWorkflowParam('NAMESPACE', selectedNamespace.value)
  }
  await Promise.all([loadMcInfraImages(), loadMcInfraSpecs(), loadMcInfraInfras()])
}

const onChangeInfraProvider = async () => {
  selectedRegion.value = ''
  selectedImage.value = ''
  selectedSpec.value = ''
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

const onClickRefreshInfraOptions = async () => {
  await loadInfraOptions()
}

const loadInfraOptions = async () => {
  await loadMcInfraNamespaces()
  await Promise.all([loadMcInfraRegions(), loadMcInfraImages(), loadMcInfraSpecs(), loadMcInfraInfras()])
  if (selectedInfra.value) {
    await loadMcInfraAccessHosts()
  }
}

const loadMcInfraNamespaces = async () => {
  try {
    const { data } = await getMcInfraNamespaces()
    namespaceOptions.value = normalizeInfraOptions(data)
    if (!selectedNamespace.value) {
      selectedNamespace.value = getNamespaceParamValue()
    }
  } catch (error) {
    namespaceOptions.value = []
  }
}

const loadMcInfraRegions = async () => {
  try {
    const { data } = await getMcInfraRegions(infraProvider.value)
    regionOptions.value = normalizeInfraOptions(data)
  } catch (error) {
    regionOptions.value = []
  }
}

const loadMcInfraImages = async () => {
  try {
    const query = selectedRegion.value ? { filterKey: 'regionName', filterVal: selectedRegion.value } : {}
    const { data } = await getMcInfraResources(getResourceCatalogNamespace(), 'image', query)
    imageOptions.value = normalizeInfraOptions(data)
  } catch (error) {
    imageOptions.value = []
  }
}

const loadMcInfraSpecs = async () => {
  try {
    const query = {
      providerName: infraProvider.value,
      regionName: selectedRegion.value,
    }
    const { data } = await getMcInfraResources(getResourceCatalogNamespace(), 'spec', query)
    specOptions.value = normalizeInfraOptions(data)
  } catch (error) {
    specOptions.value = []
  }
}

const loadMcInfraInfras = async () => {
  if (!selectedNamespace.value) {
    infraOptions.value = []
    return
  }

  try {
    const { data } = await getMcInfraList(selectedNamespace.value, { option: 'simple' })
    infraOptions.value = normalizeInfraOptions(data)
  } catch (error) {
    infraOptions.value = []
  }
}

const loadMcInfraAccessHosts = async () => {
  if (!selectedNamespace.value || !selectedInfra.value) {
    accessHostOptions.value = []
    return
  }

  try {
    const { data } = await getMcInfra(selectedNamespace.value, selectedInfra.value, { option: 'accessinfo' })
    accessHostOptions.value = normalizeAccessHostOptions(data)
  } catch (error) {
    accessHostOptions.value = []
  }
}

const normalizeInfraOptions = (response: any): Array<InfraOption> => {
  const payload = response?.data ?? response
  const sourceList = findFirstArray(payload)
  const seen = new Set<string>()

  return sourceList
    .map((item: any) => {
      const value = String(
        item?.id ??
        item?.nsId ??
        item?.name ??
        item?.infraId ??
        item?.specId ??
        item?.imageId ??
        item?.regionName ??
        item?.RegionName ??
        item?.region ??
        item?.connectionName ??
        item ?? ''
      )
      const label = String(
        item?.name ??
        item?.id ??
        item?.nsId ??
        item?.infraId ??
        item?.specName ??
        item?.imageName ??
        item?.specId ??
        item?.imageId ??
        item?.regionName ??
        item?.RegionName ??
        item?.region ??
        value
      )
      return { label, value }
    })
    .filter((option: InfraOption) => {
      if (!option.value || seen.has(option.value)) return false
      seen.add(option.value)
      return true
    })
}

const findFirstArray = (payload: any): Array<any> => {
  if (Array.isArray(payload)) return payload
  if (!payload || typeof payload !== 'object') return []

  const preferredKeys = [
    'ns', 'namespace', 'namespaces', 'namespaceList',
    'infra', 'infras', 'infraList',
    'regions', 'region', 'regionList',
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

const getNamespaceParamValue = () => {
  return getWorkflowParamValue('NAMESPACE') || userInfo.projectInfo.ns_id || selectedNamespace.value || ''
}

const getResourceCatalogNamespace = () => {
  return selectedNamespace.value || getNamespaceParamValue() || 'system'
}

const applyInfraSelectionParams = () => {
  const namespace = getNamespaceParamValue()
  if (namespace) {
    upsertWorkflowParam('NAMESPACE', namespace)
  }
  upsertWorkflowParam('REGION', selectedRegion.value)
  upsertWorkflowParam('IMAGE', selectedImage.value)
  upsertWorkflowParam('IMAGE_ID', selectedImage.value)
  upsertWorkflowParam('SPEC', selectedSpec.value)
  upsertWorkflowParam('SPEC_ID', selectedSpec.value)
}

const addDefaultParamsForStage = (stageName?: string) => {
  if (!stageName) return

  const workflowName = workflowInfoFormData.workflowName || 'workflow'
  const defaultInfraId = `${workflowName}-infra`
  const stageParamMap: Record<string, Array<WorkflowParams>> = {
    'infra-create': [
      { paramKey: 'TUMBLEBUG', paramValue: 'http://mc-infra-manager:1323', eventListenerYn: 'N' },
      { paramKey: 'USER', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'USERPASS', paramValue: 'default', eventListenerYn: 'N' },
      { paramKey: 'NAMESPACE', paramValue: getNamespaceParamValue(), eventListenerYn: 'N' },
      { paramKey: 'INFRA_ID', paramValue: defaultInfraId, eventListenerYn: 'N' },
      { paramKey: 'REGION', paramValue: selectedRegion.value, eventListenerYn: 'N' },
      { paramKey: 'IMAGE', paramValue: selectedImage.value, eventListenerYn: 'N' },
      { paramKey: 'IMAGE_ID', paramValue: selectedImage.value, eventListenerYn: 'N' },
      { paramKey: 'SPEC', paramValue: selectedSpec.value, eventListenerYn: 'N' },
      { paramKey: 'SPEC_ID', paramValue: selectedSpec.value, eventListenerYn: 'N' },
    ],
    'mariadb-install': [
      { paramKey: 'NAMESPACE', paramValue: getNamespaceParamValue(), eventListenerYn: 'N' },
      { paramKey: 'INFRA_ID', paramValue: defaultInfraId, eventListenerYn: 'N' },
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
      { paramKey: 'DB_HOST', paramValue: '', eventListenerYn: 'N' },
      { paramKey: 'DB_PORT', paramValue: '3306', eventListenerYn: 'N' },
      { paramKey: 'DB_NAME', paramValue: 'testdb', eventListenerYn: 'N' },
      { paramKey: 'DB_USER', paramValue: 'mariadb_user', eventListenerYn: 'N' },
      { paramKey: 'DB_PASSWORD', paramValue: 'mariadb_pass', eventListenerYn: 'N' },
      { paramKey: 'DB_BACKUP_FILE', paramValue: 'schema.sql', eventListenerYn: 'N' },
      { paramKey: 'SCHEMA_SQL_CONTENT', paramValue: '', eventListenerYn: 'N' },
    ],
    'db-schema-import': [
      { paramKey: 'DB_HOST', paramValue: '', eventListenerYn: 'N' },
      { paramKey: 'DB_PORT', paramValue: '3306', eventListenerYn: 'N' },
      { paramKey: 'DB_NAME', paramValue: 'testdb', eventListenerYn: 'N' },
      { paramKey: 'DB_USER', paramValue: 'mariadb_user', eventListenerYn: 'N' },
      { paramKey: 'DB_PASSWORD', paramValue: 'mariadb_pass', eventListenerYn: 'N' },
      { paramKey: 'SCHEMA_SQL_FILE', paramValue: 'schema.sql', eventListenerYn: 'N' },
      { paramKey: 'SCHEMA_SQL_CONTENT', paramValue: '', eventListenerYn: 'N' },
    ],
    'db-data-insert': [
      { paramKey: 'DB_HOST', paramValue: '', eventListenerYn: 'N' },
      { paramKey: 'DB_PORT', paramValue: '3306', eventListenerYn: 'N' },
      { paramKey: 'DB_NAME', paramValue: 'testdb', eventListenerYn: 'N' },
      { paramKey: 'DB_USER', paramValue: 'mariadb_user', eventListenerYn: 'N' },
      { paramKey: 'DB_PASSWORD', paramValue: 'mariadb_pass', eventListenerYn: 'N' },
      { paramKey: 'INSERT_SQL', paramValue: "INSERT INTO sample_table VALUES (1, 'sample row');", eventListenerYn: 'N' },
    ],
  }

  stageParamMap[stageName]?.forEach((param) => upsertWorkflowParam(param.paramKey, param.paramValue, param.eventListenerYn))
}

const upsertWorkflowParam = (paramKey: string, paramValue: string, eventListenerYn = 'N') => {
  if (!paramKey) return
  const normalizedKey = paramKey.trim().toUpperCase()
  const existingParam = workflowParamsFormData.value.find((param) => param.paramKey?.trim().toUpperCase() === normalizedKey)

  if (existingParam) {
    if (paramValue || !existingParam.paramValue) {
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
const onClickDuplicatWorkflowName = async (workflowName: string) => {
  const { data } = await duplicateCheck(workflowName)
  if (!data) {
    toast.success('Name is available.')
    duplicatedWorkflow.value = true
  }
  else
    toast.error('Name is already in use.')
}

// ================================================================================= Purpose list

const workflowPurposeList = ref([] as Array<WorkflowPurpose>)
const setWorkflowPurposeList = () => {
  workflowPurposeList.value = [
    {
      name: "For Deployment",
      value: "deploy"
    },
    {
      name: "For Execution",
      value: "run"
    },
      {
      name: "For Testing",
      value: "test"
    },
      {
      name: "For Webhook",
      value: "webhook"
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

  workflowInfoFormData = {...workflowInfoFormData, script: str}
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
  addDefaultParamsForStage(transClone.workflowStageName)
}
</script>
