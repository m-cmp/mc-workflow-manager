<template>
  <div class="param-form mt-5 mb-5" v-if="paramData">
    <div class="param-toolbar">
      <div>
        <label class="form-label mb-1">Parameters</label>
        <div class="text-muted small">
          {{ visibleParamCount }} / {{ paramData.length }}
        </div>
      </div>

      <div class="param-toolbar-actions">
        <div class="param-search">
          <input
            class="form-control form-control-sm"
            type="search"
            placeholder="Search"
            v-model="searchText"
          />
        </div>

        <label class="form-check form-switch param-switch">
          <input class="form-check-input" type="checkbox" v-model="showOnlyEmpty" />
          <span class="form-check-label">Empty</span>
        </label>

        <button
          v-if="advancedParamCount > 0"
          class="btn btn-outline-secondary btn-sm"
          type="button"
          @click="showAdvanced = !showAdvanced"
        >
          {{ showAdvanced ? 'Hide Advanced' : `Advanced ${advancedParamCount}` }}
        </button>

        <button
          v-if="secretParamCount > 0"
          class="btn btn-outline-secondary btn-sm"
          type="button"
          @click="showSecrets = !showSecrets"
        >
          {{ showSecrets ? 'Hide Secret' : 'Show Secret' }}
        </button>

        <button
          v-if="!props.popup"
          class="btn btn-primary btn-sm"
          type="button"
          @click="addParams"
        >
          Add
        </button>
      </div>
    </div>

    <datalist id="workflow-param-key-options">
      <option v-for="option in paramKeyOptions" :key="option" :value="option" />
    </datalist>

    <div v-if="visibleSections.length === 0" class="param-empty">
      No parameters
    </div>

    <div
      v-for="section in visibleSections"
      :key="section.key"
      class="param-section"
    >
      <div class="param-section-header">
        <div class="param-section-title">
          <span class="param-section-dot" :class="`param-section-dot-${section.key}`"></span>
          {{ section.title }}
        </div>
        <span class="badge bg-secondary-lt text-secondary">{{ section.rows.length }}</span>
      </div>

      <div class="param-row-list">
        <div
          v-for="row in section.rows"
          :key="`${row.index}-${row.param.paramKey}`"
          class="param-row"
          :class="{ 'param-row-empty': isEmptyParam(row.param) }"
        >
          <div class="param-key-area">
            <div v-if="props.popup || isKeyLocked(row.param.paramKey)" class="param-key-readonly">
              <span class="param-label">{{ getParamLabel(row.param.paramKey) }}</span>
              <code>{{ normalizeParamKey(row.param.paramKey) || 'PARAM_KEY' }}</code>
            </div>
            <div v-else>
              <label class="form-label small mb-1">Key</label>
              <input
                class="form-control form-control-sm param-key-input"
                type="text"
                list="workflow-param-key-options"
                placeholder="PARAM_KEY"
                v-model="row.param.paramKey"
                @blur="inputData(row.index)"
              />
            </div>
            <div v-if="getParamHint(row.param.paramKey)" class="param-hint">
              {{ getParamHint(row.param.paramKey) }}
            </div>
          </div>

          <div class="param-value-area">
            <label class="form-label small mb-1">Value</label>
            <div v-if="isFileUploadParam(row.param.paramKey)" class="backup-file-upload">
              <div class="input-group input-group-sm">
                <input
                  class="form-control param-value-input"
                  type="text"
                  placeholder="schema.sql"
                  v-model="row.param.paramValue"
                />
                <label class="btn btn-outline-primary mb-0">
                  Upload
                  <input
                    class="d-none"
                    type="file"
                    accept=".sql,.txt,.dump,.backup,.bak"
                    @change="onChangeBackupFile($event, row.index)"
                  />
                </label>
              </div>
              <div class="param-hint">
                Uploaded file content is applied to SCHEMA_SQL_CONTENT.
              </div>
            </div>
            <textarea
              v-else-if="isLongTextParam(row.param.paramKey)"
              class="form-control form-control-sm param-value-input param-value-code"
              placeholder="Value"
              rows="4"
              v-model="row.param.paramValue"
            />
            <input
              v-else
              class="form-control form-control-sm param-value-input"
              :type="isSecretParam(row.param.paramKey) && !showSecrets ? 'password' : 'text'"
              placeholder="Value"
              v-model="row.param.paramValue"
            />
          </div>

          <button
            v-if="!props.popup"
            class="btn btn-outline-danger btn-icon param-remove-btn"
            type="button"
            aria-label="Remove parameter"
            @click="removeParams(row.index)"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
              <path d="M4 7h16"/>
              <path d="M10 11v6"/>
              <path d="M14 11v6"/>
              <path d="M5 7l1 12a2 2 0 0 0 2 2h8a2 2 0 0 0 2 -2l1 -12"/>
              <path d="M9 7v-3h6v3"/>
            </svg>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { WorkflowParams } from '@/views/type/type';
import { computed, onMounted, ref } from 'vue';
import { useToast } from 'vue-toastification';
import { useUserStore } from '@/stores/user'

const toast = useToast()
const userInfo = useUserStore()

interface Props {
  popup: boolean
  workflowParamData: Array<WorkflowParams>
  eventListenerYn: string
}

interface ParamRow {
  index: number
  param: WorkflowParams
  normalizedKey: string
  sectionKey: string
  isAdvanced: boolean
}

interface ParamSection {
  key: string
  title: string
  rows: Array<ParamRow>
}

const props = defineProps<Props>()
const paramData = computed(() => props.workflowParamData)
const searchText = ref('')
const showOnlyEmpty = ref(false)
const showAdvanced = ref(false)
const showSecrets = ref(false)

const lockedParamKeys = ['MCI', 'CLUSTER', 'NAMESPACE']
const hiddenParamKeys = ['TUMBLEBUG_SELECTOR_YN']
const tumblebugSelectorParamKeys = [
  'PROVIDER',
  'CSP',
  'REGION',
  'CONNECTION_NAME',
  'ZONE',
  'IMAGE',
  'IMAGE_ID',
  'SPEC',
  'SPEC_ID',
]
const longTextParamKeys = [
  'SCHEMA_SQL_CONTENT',
  'INSERT_SQL',
  'VERIFY_SQL',
  'KUBECONFIG_CONTENT',
  'K8S_MANIFEST',
  'HTTP_BODY',
  'NOTIFICATION_PAYLOAD',
  'SCRIPT_CONTENT',
]
const secretParamHints = ['PASSWORD', 'USERPASS', 'SECRET', 'TOKEN', 'PRIVATE_KEY', 'SSH_PRIVATE_KEY']
const advancedParamKeys = [
  'TUMBLEBUG',
  'USER',
  'USERPASS',
  'ROOT_DISK_TYPE',
  'ROOT_DISK_SIZE',
  'INSTALL_MON_AGENT',
  'POLICY_ON_PARTIAL_FAILURE',
  'INFRA_ACCESS_INFO_MAX_ATTEMPTS',
  'INFRA_ACCESS_INFO_INTERVAL_SECONDS',
  'K8S_STATUS_MAX_ATTEMPTS',
  'K8S_STATUS_INTERVAL_SECONDS',
  'K8S_READY_STATUS',
  'K8S_KUBECONFIG_MAX_ATTEMPTS',
  'K8S_KUBECONFIG_INTERVAL_SECONDS',
  'ROLLOUT_TIMEOUT',
]
const sectionDefinitions = [
  {
    key: 'infra',
    title: 'Infra',
    keys: [
      'NAMESPACE',
      'PROVIDER',
      'CSP',
      'REGION',
      'CONNECTION_NAME',
      'ZONE',
      'IMAGE',
      'IMAGE_ID',
      'SPEC',
      'SPEC_ID',
      'INFRA_ID',
      'INFRA_ID_LIST',
      'INFRA_PREFIX',
      'INFRA_DELETE_OPTION',
      'INFRA_NODEGROUP_NAME',
      'INFRA_NODEGROUP_SIZE',
      'SSH_HOST',
      'SSH_USER',
      'SSH_KEY_FILE',
    ],
  },
  {
    key: 'k8s',
    title: 'K8s',
    keys: [
      'K8S_CLUSTER_ID',
      'CLUSTER_PREFIX',
      'K8S_NODEGROUP_NAME',
      'K8S_NODEGROUP_PREFIX',
      'K8S_VERSION',
      'K8S_DESIRED_NODE_SIZE',
      'K8S_MIN_NODE_SIZE',
      'K8S_MAX_NODE_SIZE',
      'K8S_CREATE_OPTION',
      'KUBECONFIG_CONTENT',
      'KUBE_NAMESPACE',
      'DEPLOYMENT_NAME',
      'DB_POD_SELECTOR',
    ],
  },
  {
    key: 'db',
    title: 'Database',
    keys: [
      'DB_EXEC_MODE',
      'DB_HOST',
      'DB_PORT',
      'DB_NAME',
      'DB_USER',
      'DB_PASSWORD',
      'RELEASE_NAME',
      'HELM_CHART',
      'HELM_VALUES_ARGS',
    ],
  },
  {
    key: 'data',
    title: 'Data',
    keys: [
      'DB_BACKUP_FILE',
      'SCHEMA_SQL_FILE',
      'SCHEMA_SQL_CONTENT',
      'INSERT_SQL',
      'VERIFY_SQL',
      'K8S_MANIFEST',
    ],
  },
  {
    key: 'multi',
    title: 'Multi CSP',
    prefixes: ['AWS_', 'AZURE_', 'GCP_', 'NCP_', 'NHN_', 'ALIBABA_', 'TENCENT_', 'IBM_', 'KT_'],
    keys: ['CSP_LIST'],
  },
  {
    key: 'advanced',
    title: 'Advanced',
    keys: advancedParamKeys,
  },
  {
    key: 'custom',
    title: 'Custom',
    keys: [],
  },
]
const paramLabels: Record<string, string> = {
  TUMBLEBUG: 'Tumblebug URL',
  USER: 'Tumblebug User',
  USERPASS: 'Tumblebug Password',
  NAMESPACE: 'Namespace',
  PROVIDER: 'Provider',
  CSP: 'CSP',
  REGION: 'Region',
  CONNECTION_NAME: 'Connection Config',
  ZONE: 'Zone',
  IMAGE: 'Image',
  IMAGE_ID: 'Image ID',
  SPEC: 'VM/K8s Spec',
  SPEC_ID: 'Spec ID',
  INFRA_ID: 'Infra ID',
  INFRA_ID_LIST: 'Infra ID List',
  SSH_HOST: 'SSH Host',
  SSH_USER: 'SSH User',
  SSH_KEY_FILE: 'SSH Key File',
  K8S_CLUSTER_ID: 'Cluster ID',
  K8S_NODEGROUP_NAME: 'Node Group',
  KUBECONFIG_CONTENT: 'Kubeconfig',
  KUBE_NAMESPACE: 'K8s Namespace',
  DB_EXEC_MODE: 'DB Execute Mode',
  DB_HOST: 'DB Host',
  DB_PORT: 'DB Port',
  DB_NAME: 'DB Name',
  DB_USER: 'DB User',
  DB_PASSWORD: 'DB Password',
  DB_BACKUP_FILE: 'Backup File',
  SCHEMA_SQL_FILE: 'Schema File',
  SCHEMA_SQL_CONTENT: 'Schema SQL',
  INSERT_SQL: 'Insert SQL',
  VERIFY_SQL: 'Verify SQL',
  HELM_CHART: 'Helm Chart',
  HELM_VALUES_ARGS: 'Helm Values',
  RELEASE_NAME: 'Release Name',
  CSP_LIST: 'CSP List',
  INFRA_DELETE_OPTION: 'Delete Option',
}
const paramHints: Record<string, string> = {
  REGION: 'Selected from mc-infra-manager.',
  IMAGE_ID: 'Image resource ID used by Tumblebug.',
  SPEC_ID: 'Spec resource ID used by Tumblebug.',
  INFRA_ID: 'Target or new infra name.',
  INFRA_ID_LIST: 'Optional comma separated infra IDs. Overrides CSP List and Infra Prefix.',
  INFRA_DELETE_OPTION: 'Tumblebug infra delete option.',
  SSH_HOST: 'Used for SSH based stages.',
  DB_HOST: 'MariaDB host or service address.',
  DB_EXEC_MODE: 'auto, ssh, or k8s.',
  DB_BACKUP_FILE: 'Upload a SQL backup file. The file name is used as DB_BACKUP_FILE.',
  SCHEMA_SQL_CONTENT: 'Inline schema SQL.',
  INSERT_SQL: 'SQL executed after import.',
  KUBECONFIG_CONTENT: 'Inline kubeconfig.',
  CSP_LIST: 'Comma separated CSP list.',
}

const paramKeyOptions = computed(() => {
  const keys = new Set<string>()
  sectionDefinitions.forEach((section) => {
    section.keys?.forEach((key) => keys.add(key))
  })
  paramData.value.forEach((param) => {
    const key = normalizeParamKey(param.paramKey)
    if (key && !isHiddenParam(key)) keys.add(key)
  })
  return Array.from(keys)
    .filter((key) => !isHiddenParam(key))
    .sort()
})

const paramRows = computed(() => {
  return paramData.value
    .map((param, index) => {
      const normalizedKey = normalizeParamKey(param.paramKey)
      return {
        index,
        param,
        normalizedKey,
        sectionKey: getSectionKey(normalizedKey),
        isAdvanced: isAdvancedParam(normalizedKey),
      }
    })
    .filter((row) => !isHiddenParam(row.normalizedKey))
})

const filteredRows = computed(() => {
  const query = searchText.value.trim().toUpperCase()

  return paramRows.value.filter((row) => {
    const value = row.param.paramValue || ''
    const label = getParamLabel(row.normalizedKey)
    const matchesQuery = !query
      || row.normalizedKey.includes(query)
      || value.toUpperCase().includes(query)
      || label.toUpperCase().includes(query)
    const matchesEmptyFilter = !showOnlyEmpty.value || isEmptyParam(row.param)
    const matchesAdvancedFilter = showAdvanced.value || !row.isAdvanced || !!query || showOnlyEmpty.value

    return matchesQuery && matchesEmptyFilter && matchesAdvancedFilter
  })
})

const visibleSections = computed(() => {
  return sectionDefinitions
    .map((section) => ({
      key: section.key,
      title: section.title,
      rows: filteredRows.value.filter((row) => row.sectionKey === section.key),
    }))
    .filter((section) => section.rows.length > 0)
})

const visibleParamCount = computed(() => {
  return visibleSections.value.reduce((count, section) => count + section.rows.length, 0)
})

const advancedParamCount = computed(() => {
  return paramRows.value.filter((row) => row.isAdvanced).length
})

const secretParamCount = computed(() => {
  return paramRows.value.filter((row) => isSecretParam(row.normalizedKey)).length
})

onMounted(() => {
  setInitParam()
})

const setInitParam = () => {
  if(paramData.value.length === 0)
    paramData.value.push({
      paramIdx: 0,
      paramKey: '',
      paramValue: '',
      eventListenerYn: props.eventListenerYn,
    })
}

const inputData = (idx:number) => {
  const param = paramData.value[idx]
  param.paramKey = normalizeParamKey(param.paramKey)

  if (param.paramKey === 'NAMESPACE')
    param.paramValue = userInfo.projectInfo.ns_id
  else if (param.paramKey === 'MCI')
    param.paramValue = userInfo.projectInfo.mci_id
  else if (param.paramKey === 'CLUSTER')
    param.paramValue = userInfo.projectInfo.cluster_id
}

const normalizeParamKey = (paramKey?: string) => {
  return (paramKey || '').trim().toUpperCase()
}

const isTumblebugSelectorDisabled = computed(() => {
  const value = paramData.value
    .find((param) => normalizeParamKey(param.paramKey) === 'TUMBLEBUG_SELECTOR_YN')
    ?.paramValue
  return ['N', 'NO', 'FALSE', '0'].includes(String(value || '').trim().toUpperCase())
})

const isHiddenParam = (paramKey?: string) => {
  const key = normalizeParamKey(paramKey)
  if (hiddenParamKeys.includes(key)) {
    return true
  }
  if (!isTumblebugSelectorDisabled.value) {
    return false
  }
  if (tumblebugSelectorParamKeys.includes(key)) {
    return true
  }
  return tumblebugSelectorParamKeys.some((selectorKey) => key.endsWith(`_${selectorKey}`))
}

const isKeyLocked = (paramKey?: string) => {
  return lockedParamKeys.includes(normalizeParamKey(paramKey))
}

const isLongTextParam = (paramKey?: string) => {
  return longTextParamKeys.includes(normalizeParamKey(paramKey))
}

const isFileUploadParam = (paramKey?: string) => {
  return normalizeParamKey(paramKey) === 'DB_BACKUP_FILE'
}

const isSecretParam = (paramKey?: string) => {
  const key = normalizeParamKey(paramKey)
  return secretParamHints.some((hint) => key.includes(hint))
}

const isEmptyParam = (param: WorkflowParams) => {
  return !param.paramKey?.trim() || !String(param.paramValue ?? '').trim()
}

const isAdvancedParam = (paramKey?: string) => {
  const key = normalizeParamKey(paramKey)
  return advancedParamKeys.includes(key)
    || key.endsWith('_MAX_ATTEMPTS')
    || key.endsWith('_INTERVAL_SECONDS')
    || key.includes('TIMEOUT')
}

const getSectionKey = (paramKey?: string) => {
  const key = normalizeParamKey(paramKey)

  if (!key) return 'custom'

  const matchedSection = sectionDefinitions.find((section) => {
    return section.key !== 'custom'
      && (
        section.keys?.includes(key)
        || section.prefixes?.some((prefix) => key.startsWith(prefix))
      )
  })

  return matchedSection?.key || 'custom'
}

const getParamLabel = (paramKey?: string) => {
  const key = normalizeParamKey(paramKey)
  if (!key) return 'New Parameter'
  return paramLabels[key] || key
}

const getParamHint = (paramKey?: string) => {
  return paramHints[normalizeParamKey(paramKey)] || ''
}

const onChangeBackupFile = async (event: Event, idx: number) => {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) {
    return
  }

  try {
    const content = await readTextFile(file)
    const backupFileParam = paramData.value[idx]
    backupFileParam.paramValue = file.name
    upsertParamValue('SCHEMA_SQL_CONTENT', content)
    toast.success(`${file.name} 파일이 적용되었습니다.`)
  } catch (error) {
    console.log(error)
    toast.error('파일을 읽지 못했습니다.')
  } finally {
    input.value = ''
  }
}

const readTextFile = (file: File) => {
  return new Promise<string>((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => resolve(String(reader.result || ''))
    reader.onerror = () => reject(reader.error)
    reader.readAsText(file)
  })
}

const upsertParamValue = (paramKey: string, paramValue: string) => {
  const normalizedKey = normalizeParamKey(paramKey)
  const existingParam = paramData.value.find((param) => normalizeParamKey(param.paramKey) === normalizedKey)
  if (existingParam) {
    existingParam.paramValue = paramValue
    return
  }

  paramData.value.push({
    paramIdx: 0,
    paramKey: normalizedKey,
    paramValue,
    eventListenerYn: props.eventListenerYn,
  })
}

const addParams = () => {
  paramData.value.push({
    paramIdx: 0,
    paramKey: '',
    paramValue: '',
    eventListenerYn: props.eventListenerYn,
  })
  showAdvanced.value = true
}

const removeParams = (idx: number) => {
  if(paramData.value.length !== 1)
    paramData.value.splice(idx, 1)
  else
    toast.error('비워두셔도 됩니다.')
}
</script>

<style scoped>
.param-form {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.param-toolbar {
  align-items: flex-start;
  display: flex;
  gap: 1rem;
  justify-content: space-between;
}

.param-toolbar-actions {
  align-items: center;
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  justify-content: flex-end;
}

.param-search {
  min-width: 180px;
}

.backup-file-upload {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.param-switch {
  align-items: center;
  display: flex;
  gap: 0.35rem;
  margin: 0;
  min-height: 2rem;
}

.param-section {
  border: 1px solid #dbe3ec;
  border-radius: 6px;
  overflow: hidden;
}

.param-section-header {
  align-items: center;
  background: #f7f9fc;
  border-bottom: 1px solid #dbe3ec;
  display: flex;
  justify-content: space-between;
  padding: 0.65rem 0.85rem;
}

.param-section-title {
  align-items: center;
  color: #1f2937;
  display: flex;
  font-size: 0.9rem;
  font-weight: 600;
  gap: 0.5rem;
}

.param-section-dot {
  border-radius: 999px;
  display: inline-block;
  height: 0.55rem;
  width: 0.55rem;
}

.param-section-dot-infra {
  background: #206bc4;
}

.param-section-dot-k8s {
  background: #2fb344;
}

.param-section-dot-db {
  background: #ae3ec9;
}

.param-section-dot-data {
  background: #f59f00;
}

.param-section-dot-multi {
  background: #d6336c;
}

.param-section-dot-advanced {
  background: #64748b;
}

.param-section-dot-custom {
  background: #0ca678;
}

.param-row-list {
  display: flex;
  flex-direction: column;
}

.param-row {
  align-items: flex-start;
  display: grid;
  gap: 0.75rem;
  grid-template-columns: minmax(180px, 0.85fr) minmax(220px, 1.35fr) auto;
  padding: 0.8rem 0.85rem;
}

.param-row + .param-row {
  border-top: 1px solid #edf1f5;
}

.param-row-empty {
  background: #fffaf0;
}

.param-key-readonly {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  min-height: 2rem;
}

.param-label {
  color: #1f2937;
  font-size: 0.88rem;
  font-weight: 600;
}

.param-key-readonly code {
  color: #64748b;
  font-size: 0.74rem;
}

.param-hint {
  color: #667085;
  font-size: 0.75rem;
  line-height: 1.35;
  margin-top: 0.3rem;
}

.param-value-code {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
  line-height: 1.45;
  min-height: 7rem;
}

.param-remove-btn {
  align-self: end;
  height: 2rem;
  padding: 0;
  width: 2rem;
}

.param-empty {
  align-items: center;
  border: 1px dashed #cbd5e1;
  border-radius: 6px;
  color: #64748b;
  display: flex;
  justify-content: center;
  min-height: 4rem;
}

@media (max-width: 768px) {
  .param-toolbar {
    flex-direction: column;
  }

  .param-toolbar-actions,
  .param-search {
    width: 100%;
  }

  .param-row {
    grid-template-columns: 1fr;
  }

  .param-remove-btn {
    justify-self: end;
  }
}
</style>
