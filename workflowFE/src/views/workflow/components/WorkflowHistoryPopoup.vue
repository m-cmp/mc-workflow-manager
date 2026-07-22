<template>
  <div class="modal modal-blur fade" id="workflowHistoryDetailPopup" tabindex="-1" aria-hidden="true" ref="modalElement">
    <div class="modal-dialog modal-xl modal-dialog-centered" role="document">
      <div class="modal-content">
        <div class="modal-status bg-info"></div>

        <div class="modal-header">
          <h3 class="modal-title">{{ props.workflowName }}</h3>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div class="modal-body py-4">
          <div class="steps steps-counter">
            <span 
              v-for="(stage, index) in workflowStages" 
              class="step-item" 
              :class="{'active':stage.status === 'IN_PROGRESS'}" 
              :key="index"
              @click="selectStage(stage)"
              style="cursor: pointer;">
              {{ stage.name }}
            </span>
          </div>

          <div class="card mt-8">
            <div class="card-body">
              <div class="row row-deck">
                  <div class="card">
                    <div v-for="(stageInfo, idx) in runHistoryDetailList.stageFlowNodes" :key="idx" class="card-body">
                      <div style="display: flex !important; justify-content: space-between !important;">
                        <p class="stage-title">{{ stageInfo.name }}</p>
                        <a style="cursor: pointer;">
                          <svg v-if="!stageInfo.flag" @click="onClickDetail(idx)"  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-chevron-down"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M6 9l6 6l6 -6" /></svg>
                          <svg v-else xmlns="http://www.w3.org/2000/svg" @click="onClickDetail(idx)"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-chevron-up"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M6 15l6 -6l6 6" /></svg>
                        </a>
                      </div>
                      <div v-if="stageInfo.flag && stageInfo.parameterDescription"> {{ stageInfo.parameterDescription }}</div>
                      <div v-if="stageInfo.flag && stageInfo.error !== null">{{stageInfo.error.type}}</div>
                    </div>
                  </div>
              </div>

            </div>
          </div>
        </div>

        <div class="modal-footer">
          <a href="#" class="btn btn-link link-secondary" data-bs-dismiss="modal">
            Cancel
          </a>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useToast } from 'vue-toastification';
// @ts-ignore
import type { JenkinsStage } from '@/views/type/type'
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'
// @ts-ignore
import { getWorkflowRunHistoryDetail } from '@/api/workflow'

const toast = useToast()
const DETAIL_POLLING_INTERVAL_MS = 3000
/**
 * @Title Props / Emit
 */
interface Props {
  workflowIdx: string | number | string[] | undefined
  workflowName: string
  buildName: string
  workflowStages: Array<JenkinsStage>
}
const props = defineProps<Props>()

const modalElement = ref<HTMLElement>()
const selectedStage = ref<JenkinsStage>()
let detailPollingTimer: ReturnType<typeof setInterval> | undefined
let detailFetching = false

watch(() => props.workflowStages, async () => {
  syncSelectedStage()
  if (selectedStage.value && modalElement.value?.classList.contains('show')) {
    await getRunHistoryDetailList(selectedStage.value, false)
    startDetailPolling()
  }
}, { deep: true })

onMounted(() => {
  modalElement.value?.addEventListener('show.bs.modal', onShowModal)
  modalElement.value?.addEventListener('hidden.bs.modal', onHiddenModal)
})

onBeforeUnmount(() => {
  modalElement.value?.removeEventListener('show.bs.modal', onShowModal)
  modalElement.value?.removeEventListener('hidden.bs.modal', onHiddenModal)
  stopDetailPolling()
})

const runHistoryDetailList = ref([] as any)
const getRunHistoryDetailList = async (stage: JenkinsStage, showErrorToast = true) => {
  if (!stage || !props.workflowIdx || !props.buildName || detailFetching) {
    return
  }

  detailFetching = true
  const params = {
    workflowIdx: props.workflowIdx,
    buildName: props.buildName,
    stageIdx: stage.id
  }
  await getWorkflowRunHistoryDetail(params).then(({ data }) => {
    const previousFlags = new Map(
      (runHistoryDetailList.value?.stageFlowNodes || []).map((stageFlowNode: any, idx: number) => [
        getStageFlowNodeKey(stageFlowNode, idx),
        Boolean(stageFlowNode.flag)
      ])
    )
    // @ts-ignore
    ;(data?.stageFlowNodes || []).forEach((stageFlowNode:any, idx: number) => {
      stageFlowNode.flag = previousFlags.get(getStageFlowNodeKey(stageFlowNode, idx)) || false
    })
    runHistoryDetailList.value = data
  }).catch((error) => {
    console.log(error)
    if (showErrorToast) {
      toast.error('Failed to load workflow stage logs.')
    }
  }).finally(() => {
    detailFetching = false
  })
}

const onClickDetail = (idx: number) => {
  runHistoryDetailList.value.stageFlowNodes[idx].flag = !runHistoryDetailList.value.stageFlowNodes[idx].flag
}

const selectStage = async (stage: JenkinsStage) => {
  selectedStage.value = stage
  await getRunHistoryDetailList(stage)
  startDetailPolling()
}

const onShowModal = async () => {
  syncSelectedStage()
  if (selectedStage.value) {
    await getRunHistoryDetailList(selectedStage.value)
    startDetailPolling()
  }
}

const onHiddenModal = () => {
  stopDetailPolling()
  runHistoryDetailList.value = []
  selectedStage.value = undefined
}

const startDetailPolling = () => {
  stopDetailPolling()
  if (!canPollDetail()) {
    return
  }

  detailPollingTimer = setInterval(async () => {
    if (selectedStage.value) {
      await getRunHistoryDetailList(selectedStage.value, false)
    }

    if (!canPollDetail()) {
      stopDetailPolling()
    }
  }, DETAIL_POLLING_INTERVAL_MS)
}

const stopDetailPolling = () => {
  if (detailPollingTimer) {
    clearInterval(detailPollingTimer)
    detailPollingTimer = undefined
  }
}

const syncSelectedStage = () => {
  if (!props.workflowStages.length) {
    selectedStage.value = undefined
    runHistoryDetailList.value = []
    stopDetailPolling()
    return
  }

  const currentStageId = selectedStage.value?.id
  selectedStage.value = props.workflowStages.find((stage) => stage.id === currentStageId)
    || props.workflowStages[0]
}

const canPollDetail = () => {
  if (!modalElement.value?.classList.contains('show')) {
    return false
  }

  if (!props.workflowStages.length || !selectedStage.value) {
    return false
  }

  return Boolean(props.workflowIdx && props.buildName)
}

const getStageFlowNodeKey = (stageFlowNode: any, idx: number) => {
  return `${stageFlowNode?.id || ''}:${stageFlowNode?.name || ''}:${idx}`
}

</script>
<style scoped>
.stage-title {
  font-weight: bold;
  font-size: large;
}
</style>
