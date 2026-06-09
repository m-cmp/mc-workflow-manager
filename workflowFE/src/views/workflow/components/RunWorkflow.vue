<template>
  <div class="modal modal-blur fade" id="runWorkflow" tabindex="-1" aria-hidden="true" ref="modalElement">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable" role="document">
      <div class="modal-content">
        <div class="modal-status bg-info"></div>

        <div class="modal-header">
          <h3 class="modal-title">Run Workflow</h3>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div v-if="runProgress.active" class="run-progress">
          <div class="d-flex align-items-center justify-content-between mb-2">
            <span class="text-muted">{{ runProgress.message }}</span>
            <span class="text-muted">{{ runProgress.completed }} / {{ runProgress.total }}</span>
          </div>
          <div class="progress">
            <div
              class="progress-bar progress-bar-striped progress-bar-animated"
              role="progressbar"
              :style="{ width: `${runProgressPercent}%` }"
              :aria-valuenow="runProgressPercent"
              aria-valuemin="0"
              aria-valuemax="100"
            />
          </div>
        </div>

        <div class="modal-body py-4">
          <div v-if="loading" class="d-flex justify-content-center py-4">
            <div class="spinner-border" role="status">
              <span class="visually-hidden">Loading...</span>
            </div>
          </div>
          <TumblebugParamSelector
            v-if="!loading && workflowFormData.workflowParams"
            :workflow-name="workflowFormData.workflowInfo?.workflowName"
            :workflow-param-data="workflowFormData.workflowParams"
            :workflow-stage-mappings="workflowFormData.workflowStageMappings || []"
          />
          <!-- 파라미터 -->
          <ParamForm 
            v-if="!loading && workflowFormData.workflowParams"
            :popup="true"
            :workflow-param-data="workflowFormData.workflowParams"
            event-listener-yn="N"
          />
        </div>

        <div class="modal-footer">
          <a href="#" class="btn btn-link link-secondary" data-bs-dismiss="modal">
            Cancel
          </a>
          <button
            type="button"
            class="btn btn-primary ms-auto"
            :class="{ disabled: running || loading }"
            :aria-disabled="running || loading"
            @click="onClickRun()"
          >
            {{ running ? 'Running...' : 'Run' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useToast } from 'vue-toastification';
import { Modal } from 'bootstrap';
// @ts-ignore
import { getWorkflowDetailInfo, runWorkflow } from '@/api/workflow';
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue';
// @ts-ignore
import type { Workflow } from '@/views/type/type'
// @ts-ignore
import ParamForm from '@/views/workflow/components/ParamForm.vue'
// @ts-ignore
import TumblebugParamSelector from '@/views/workflow/components/TumblebugParamSelector.vue'
// @ts-ignore
import { getMcInfraResources, reviewMcInfraDynamic } from '@/api/infraManager'

const toast = useToast()
/**
 * @Title Props / Emit
 */
interface Props {
  workflowIdx: number
}
const props = defineProps<Props>()
const emit = defineEmits(['get-workflow-list'])
const workflowIdx = computed(() => props.workflowIdx)
const workflowFormData = ref({} as Workflow)
const running = ref(false)
const loading = ref(false)
const modalElement = ref<HTMLElement>()
const runProgress = ref({
  active: false,
  completed: 0,
  total: 0,
  message: '',
})
const runProgressPercent = computed(() => {
  if (!runProgress.value.total) return 0
  return Math.min(100, Math.round((runProgress.value.completed / runProgress.value.total) * 100))
})

watch(() => workflowIdx.value, async () => {
  if (modalElement.value?.classList.contains('show')) {
    await loadWorkflowDetail()
  }
})

onMounted(() => {
  modalElement.value?.addEventListener('show.bs.modal', onShowModal)
})

onBeforeUnmount(() => {
  modalElement.value?.removeEventListener('show.bs.modal', onShowModal)
})

const onShowModal = async () => {
  await loadWorkflowDetail()
}

const loadWorkflowDetail = async () => {
  if (!workflowIdx.value) {
    workflowFormData.value = {} as Workflow
    return
  }

  loading.value = true
  try {
    const { data } = await getWorkflowDetailInfo(workflowIdx.value, 'N')
    workflowFormData.value = data
  } catch (error) {
    console.log(error)
    toast.error('워크플로우 실행 파라미터를 불러오지 못했습니다.')
  } finally {
    loading.value = false
  }
}

/**
 * @Title onClickRun
 * @Desc 실행 버튼 클릭시 동작 / 실행 api 호출
 */
const onClickRun = async () => {
  if (running.value || loading.value) {
    return
  }

  if (!workflowFormData.value.workflowInfo) {
    toast.error('워크플로우 실행 파라미터를 불러오지 못했습니다.')
    return
  }

  running.value = true
  try {
    await startRunProgress()
    if (!(await validateRunParameters())) {
      return
    }

    if (!(await reviewInfraDynamicBeforeRun())) {
      return
    }

    await setRunProgressMessage('Workflow 실행 요청 중')
    const { data } = await runWorkflow(workflowFormData.value)
    await completeRunProgressStep('Workflow 실행 요청 완료')
    if (data) {
      toast.success('워크플로우 실행 요청이 접수되었습니다.')
      closeModal()
    } else {
      toast.error('워크플로우 실행 요청을 처리하지 못했습니다.')
    }
    emit('get-workflow-list')
  } catch (error) {
    console.log(error)
    toast.error('워크플로우 실행 요청을 처리하지 못했습니다.')
  } finally {
    running.value = false
    stopRunProgress()
  }
}

const closeModal = () => {
  if (!modalElement.value) return
  Modal.getInstance(modalElement.value)?.hide()
}

const startRunProgress = async () => {
  runProgress.value = {
    active: true,
    completed: 0,
    total: getRunProgressStepCount(),
    message: '실행 전 검증 준비 중',
  }
  await flushRunProgressRender()
}

const stopRunProgress = () => {
  runProgress.value.active = false
}

const setRunProgressMessage = async (message: string) => {
  runProgress.value.message = message
  await flushRunProgressRender()
}

const completeRunProgressStep = async (message: string) => {
  runProgress.value.completed = Math.min(runProgress.value.completed + 1, runProgress.value.total)
  runProgress.value.message = message
  await flushRunProgressRender()
}

const flushRunProgressRender = async () => {
  await nextTick()
  await new Promise<void>((resolve) => {
    window.requestAnimationFrame(() => resolve())
  })
}

const getRunProgressStepCount = () => {
  const params = workflowFormData.value.workflowParams || []
  const stageNames = getWorkflowStageNames()
  const needsSpec = needsSpecValidation(params, stageNames)
  const needsImage = needsImageValidation(params, stageNames)
  const cspCount = Math.max(1, getCspList().length)
  const validationSteps = cspCount * Number(needsSpec) + cspCount * Number(needsImage)
  const reviewSteps = needsInfraDynamicReview() && buildInfraDynamicReviewPayload() ? 1 : 0
  return Math.max(1, validationSteps + reviewSteps + 1)
}

const reviewInfraDynamicBeforeRun = async () => {
  if (!needsInfraDynamicReview()) {
    return true
  }

  const payload = buildInfraDynamicReviewPayload()
  if (!payload) {
    return true
  }

  try {
    await setRunProgressMessage('Infra 사전 검증 중')
    const { data } = await reviewMcInfraDynamic(getResourceCatalogNamespace(), payload)
    await completeRunProgressStep('Infra 사전 검증 완료')
    if (hasInfraReviewError(data)) {
      toast.error(`Infra 사전 검증 실패: ${getInfraReviewMessage(data)}`)
      return false
    }
    return true
  } catch (error) {
    console.log(error)
    toast.error('Infra 사전 검증 요청을 처리하지 못했습니다.')
    return false
  }
}

const needsInfraDynamicReview = () => {
  const stageNames = getWorkflowStageNames()
  return stageNames.includes('infra-create')
}

const buildInfraDynamicReviewPayload = () => {
  const cspList = getParamValue('CSP_LIST')
    .split(',')
    .map((csp) => csp.trim())
    .filter(Boolean)

  const nodeGroups = cspList.length > 0
    ? cspList.map((csp) => buildNodeGroupReviewPayload(`${normalizeCspKey(csp)}_`, csp))
    : [buildNodeGroupReviewPayload('', getParamValue('CSP') || getParamValue('PROVIDER'))]

  const validNodeGroups = nodeGroups.filter(Boolean)
  if (validNodeGroups.length === 0) {
    return null
  }

  return {
    name: getParamValue('INFRA_ID') || getParamValue('INFRA_PREFIX') || workflowFormData.value.workflowInfo?.workflowName || 'workflow-infra',
    description: getParamValue('INFRA_DESC') || 'Workflow created infra',
    installMonAgent: getParamValue('INSTALL_MON_AGENT') || 'no',
    policyOnPartialFailure: getParamValue('POLICY_ON_PARTIAL_FAILURE') || 'continue',
    nodeGroups: validNodeGroups,
  }
}

const buildNodeGroupReviewPayload = (prefix: string, csp: string) => {
  const region = getParamValue(`${prefix}REGION`) || getParamValue('REGION')
  const connectionName = getParamValue(`${prefix}CONNECTION_NAME`) || getParamValue('CONNECTION_NAME') || deriveConnectionName(csp, region)
  const specId = getParamValue(`${prefix}SPEC_ID`) || getParamValue('SPEC_ID')
  const imageId = getParamValue(`${prefix}IMAGE_ID`) || getParamValue('IMAGE_ID')

  if (!specId || !imageId) {
    return null
  }

  const nodeGroup: Record<string, any> = {
    name: getParamValue('INFRA_NODEGROUP_NAME') || 'g1',
    nodeGroupSize: Number(getParamValue('INFRA_NODEGROUP_SIZE') || '1'),
    specId,
    imageId,
    rootDiskType: getParamValue('ROOT_DISK_TYPE') || 'default',
    rootDiskSize: Number(getParamValue('ROOT_DISK_SIZE') || '50'),
  }

  if (connectionName) {
    nodeGroup.connectionName = connectionName
  }
  const zone = getParamValue(`${prefix}ZONE`) || getParamValue('ZONE')
  if (zone) {
    nodeGroup.zone = zone
  }

  return nodeGroup
}

const hasInfraReviewError = (reviewResult: any) => {
  if (!reviewResult) return true
  const statusValues = collectObjectValuesByKey(reviewResult, ['reviewStatus', 'status', 'validationStatus'])
    .map((value) => normalizeValue(value))
  if (statusValues.some((status) => ['error', 'failed', 'fail'].includes(status))) {
    return true
  }

  const text = JSON.stringify(reviewResult).toLowerCase()
  return text.includes('"reviewstatus":"error"')
    || text.includes('"status":"error"')
    || text.includes('sold out')
}

const getInfraReviewMessage = (reviewResult: any) => {
  const messages = collectObjectValuesByKey(reviewResult, ['message', 'details', 'detail', 'reason', 'errorMessage'])
    .map((value) => String(value || '').trim())
    .filter(Boolean)
  return messages[0] || '선택한 Image/Spec 조합으로 생성할 수 없습니다.'
}

const collectObjectValuesByKey = (value: any, keys: Array<string>): Array<any> => {
  if (Array.isArray(value)) {
    return value.flatMap((item) => collectObjectValuesByKey(item, keys))
  }
  if (!value || typeof value !== 'object') {
    return []
  }

  const normalizedKeys = keys.map((key) => key.toLowerCase())
  return Object.entries(value).flatMap(([key, nestedValue]) => {
    const matched = normalizedKeys.includes(key.toLowerCase()) ? [nestedValue] : []
    return [...matched, ...collectObjectValuesByKey(nestedValue, keys)]
  })
}

const validateRunParameters = async () => {
  const params = workflowFormData.value.workflowParams || []
  const stageNames = getWorkflowStageNames()
  const needsSpec = needsSpecValidation(params, stageNames)
  const needsImage = needsImageValidation(params, stageNames)

  if (!needsSpec && !needsImage) {
    return true
  }

  const cspList = getCspList()
  const invalidKeys: Array<string> = []

  if (cspList.length > 0) {
    for (const csp of cspList) {
      const prefix = `${normalizeCspKey(csp)}_`
      if (needsImage) {
        await validateImageValue(prefix, csp, invalidKeys)
      }
      if (needsSpec) {
        await validateSpecValue(prefix, csp, invalidKeys)
      }
    }
  } else {
    const csp = getParamValue('CSP') || getParamValue('PROVIDER')
    if (needsImage) {
      await validateImageValue('', csp, invalidKeys)
    }
    if (needsSpec) {
      await validateSpecValue('', csp, invalidKeys)
    }
  }

  if (invalidKeys.length > 0) {
    toast.error(`${invalidKeys.join(', ')} 값을 현재 Region/Connection에 맞게 다시 선택해주세요.`)
    return false
  }

  return true
}

const validateSpecValue = async (prefix: string, csp: string, invalidKeys: Array<string>) => {
  const specKey = `${prefix}SPEC_ID`
  const specValue = getParamValue(specKey)
  const region = getParamValue(`${prefix}REGION`) || getParamValue('REGION')
  const connectionName = getParamValue(`${prefix}CONNECTION_NAME`) || getParamValue('CONNECTION_NAME') || deriveConnectionName(csp, region)

  if (!specValue || isConnectionLikeSpecValue(specValue, connectionName, region, csp)) {
    invalidKeys.push(specKey)
    return
  }

  const resourceParts = parseTumblebugResourceId(specValue)
  if (resourceParts.region && region && !matchesRegion(resourceParts.region, region)) {
    invalidKeys.push(specKey)
    return
  }

  await setRunProgressMessage(`${specKey} 목록 검증 중`)
  if (!(await isCatalogResourceValueAvailable('spec', specValue, csp, region, connectionName))) {
    invalidKeys.push(specKey)
  }
  await completeRunProgressStep(`${specKey} 목록 검증 완료`)
}

const validateImageValue = async (prefix: string, csp: string, invalidKeys: Array<string>) => {
  const imageKey = `${prefix}IMAGE_ID`
  const imageValue = getParamValue(imageKey)
  const specValue = getParamValue(`${prefix}SPEC_ID`)
  const region = getParamValue(`${prefix}REGION`) || getParamValue('REGION')
  const connectionName = getParamValue(`${prefix}CONNECTION_NAME`) || getParamValue('CONNECTION_NAME') || deriveConnectionName(csp, region)

  if (!imageValue || isConnectionLikeSpecValue(imageValue, connectionName, region, csp)) {
    invalidKeys.push(imageKey)
    return
  }

  const resourceParts = parseTumblebugResourceId(imageValue)
  if (resourceParts.region && region && !matchesRegion(resourceParts.region, region)) {
    invalidKeys.push(imageKey)
    return
  }

  await setRunProgressMessage(`${imageKey} 목록 검증 중`)
  if (!(await isCatalogResourceValueAvailable('image', imageValue, csp, region, connectionName, specValue))) {
    invalidKeys.push(imageKey)
  }
  await completeRunProgressStep(`${imageKey} 목록 검증 완료`)
}

const getWorkflowStageNames = () => {
  return (workflowFormData.value.workflowStageMappings || [])
    .map((stage: any) => String(stage.workflowStageName || '').trim().toLowerCase())
}

const needsSpecValidation = (params: Array<any>, stageNames: Array<string>) => {
  return stageNames.some((stageName) => ['infra-create', 'k8s-cluster-create'].includes(stageName))
    || params.some((param: any) => normalizeParamKey(param.paramKey) === 'SPEC_ID' || normalizeParamKey(param.paramKey).endsWith('_SPEC_ID'))
}

const needsImageValidation = (params: Array<any>, stageNames: Array<string>) => {
  return stageNames.some((stageName) => ['infra-create', 'k8s-cluster-create'].includes(stageName))
    || params.some((param: any) => normalizeParamKey(param.paramKey) === 'IMAGE_ID' || normalizeParamKey(param.paramKey).endsWith('_IMAGE_ID'))
}

const getCspList = () => {
  return getParamValue('CSP_LIST')
    .split(',')
    .map((csp) => csp.trim())
    .filter(Boolean)
}

const isCatalogResourceValueAvailable = async (
  resourceType: 'image' | 'spec',
  value: string,
  csp: string,
  region: string,
  connectionName: string,
  matchedSpecId = '',
) => {
  if (!value || !csp || !region) {
    return false
  }

  try {
    const { data } = await getMcInfraResources(getResourceCatalogNamespace(), resourceType, {
      providerName: csp,
      regionName: region,
      connectionName,
      matchedSpecId: resourceType === 'image' ? matchedSpecId : '',
    })
    const items = findFirstArray(data?.data ?? data)
    const normalizedValue = normalizeValue(value)
    return items.some((item: any) => {
      return getCatalogResourceCandidates(item, resourceType)
        .some((candidate) => normalizeValue(candidate) === normalizedValue)
    })
  } catch (error) {
    console.log(error)
    return false
  }
}

const getCatalogResourceCandidates = (item: any, resourceType: 'image' | 'spec') => {
  if (item === undefined || item === null) {
    return []
  }

  if (typeof item !== 'object') {
    return [String(item)]
  }

  if (resourceType === 'image') {
    return uniqueTextValues([
      item.id,
      item.name,
      item.imageId,
      item.cspImageId,
      item.cspImageName,
      item.imageName,
      item.displayName,
    ])
  }

  return uniqueTextValues([
    item.id,
    item.name,
    item.specId,
    item.cspSpecId,
    item.cspSpecName,
    item.CspSpecName,
    item.specName,
    item.Name,
    item.VMSpecName,
  ])
}

const findFirstArray = (payload: any): Array<any> => {
  if (Array.isArray(payload)) return payload
  if (!payload || typeof payload !== 'object') return []

  const preferredKeys = [
    'images', 'image', 'imageList',
    'specs', 'spec', 'specList',
    'resources', 'resource', 'resourceList',
    'items', 'list', 'result', 'output',
  ]

  for (const key of preferredKeys) {
    if (Array.isArray(payload[key])) return payload[key]
  }

  for (const nested of Object.values(payload)) {
    const items = findFirstArray(nested)
    if (items.length > 0) return items
  }

  return []
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

const getParamValue = (key: string) => {
  const normalizedKey = normalizeParamKey(key)
  const param = (workflowFormData.value.workflowParams || [])
    .find((item: any) => normalizeParamKey(item.paramKey) === normalizedKey)
  return String(param?.paramValue || '').trim()
}

const normalizeParamKey = (key?: string) => {
  return String(key || '').trim().toUpperCase()
}

const normalizeCspKey = (csp?: string) => {
  return String(csp || '').trim().toUpperCase().replace(/[^A-Z0-9]/g, '_')
}

const normalizeValue = (value?: string) => {
  return String(value || '').trim().toLowerCase()
}

const matchesRegion = (actualRegion?: string, expectedRegion?: string) => {
  const actual = normalizeValue(actualRegion)
  const expected = normalizeValue(expectedRegion)
  if (!actual || !expected) return true
  return actual === expected
    || actual.startsWith(`${expected}-`)
    || expected.startsWith(`${actual}-`)
}

const deriveConnectionName = (csp?: string, region?: string) => {
  return csp && region ? `${csp}-${region}` : ''
}

const parseTumblebugResourceId = (resourceId?: string) => {
  const parts = String(resourceId || '').split('+')
  if (parts.length < 3) {
    return { provider: '', region: '' }
  }

  return {
    provider: parts[0],
    region: parts[1],
  }
}

const getResourceCatalogNamespace = () => {
  return getParamValue('NAMESPACE') || 'system'
}

const isConnectionLikeSpecValue = (specValue: string, connectionName: string, region: string, csp: string) => {
  const normalizedSpecValue = normalizeValue(specValue)
  if (!normalizedSpecValue) return true

  return normalizedSpecValue === normalizeValue(connectionName)
    || normalizedSpecValue === normalizeValue(region)
    || normalizedSpecValue === normalizeValue(csp)
}
</script>

<style scoped>
.run-progress {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 4px;
  box-shadow: 0 16px 40px rgba(15, 23, 42, 0.22);
  left: 50%;
  padding: 0.75rem;
  position: fixed;
  top: 1rem;
  transform: translateX(-50%);
  width: min(720px, calc(100vw - 2rem));
  z-index: 2147483647;
}
</style>
