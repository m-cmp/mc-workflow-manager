<template>
  <div class="modal" id="workflowLog" tabindex="-1" ref="modalElement">
    <div class="modal-dialog modal-xl" role="document">
      <div class="modal-content">

        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        <div class="modal-body text-left py-4">
          <!-- OSS Title -->
          <h3 class="mb-5">
            Workflow Log
            <div v-if="!firstLoadData" class="spinner-border" role="status">
              <span class="visually-hidden">Loading...</span>
            </div>
          </h3>
          <div>
            <div v-if="workflowLogList.length <= 0">
              <p class="text-secondary">No Data</p>
            </div>
            <div v-else v-for="workflowLog in workflowLogList" :key="workflowLog.buildIdx">
              <div class="card mb-3">
                <div class="card-header" @click="onClickedBuildIdx(workflowLog.buildIdx)" style="cursor: pointer;">
                  <h3 class="card-title">{{ getBuildTitle(workflowLog.buildIdx) }}</h3>
                </div>
                <div v-if="clickedBuildIdx === workflowLog.buildIdx" class="card-body">
                  <textarea :value="workflowLog.buildLog" disabled style="width: 100%;" rows="20"></textarea>
                  <!-- <p class="text-secondary">{{workflowLog.buildLog}}</p> -->
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <a href="#" class="btn btn-link link-secondary" data-bs-dismiss="modal" @click="setClear">
            Cancel
          </a>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// import type { Oss, OssType } from '@/views/type/type';
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import { useToast } from 'vue-toastification';
import { getWorkflowLog } from '@/api/workflow';
import type { WorkflowLog } from '@/views/type/type';

const toast = useToast()
const LOG_POLLING_INTERVAL_MS = 3000
/**
 * @Title Props / Emit
 */
interface Props {
  workflowIdx: number
}
const props = defineProps<Props>()
const emit = defineEmits(['get-oss-list'])

const firstLoadData = ref(false as boolean)
const modalElement = ref<HTMLElement>()
/* Comment translated to English. */
const workflowIdx = computed(() => props.workflowIdx);
watch(workflowIdx, async () => {
  if (modalElement.value?.classList.contains('show')) {
    stopWorkflowLogPolling()
    await setInit(true);
    startWorkflowLogPolling()
  }
});

onMounted(() => {
  modalElement.value?.addEventListener('show.bs.modal', onShowModal)
  modalElement.value?.addEventListener('hidden.bs.modal', onHiddenModal)
})

onBeforeUnmount(() => {
  modalElement.value?.removeEventListener('show.bs.modal', onShowModal)
  modalElement.value?.removeEventListener('hidden.bs.modal', onHiddenModal)
  stopWorkflowLogPolling()
})

/* Comment translated to English. */
const workflowLogList = ref([] as Array<WorkflowLog>)
let workflowLogPollingTimer: ReturnType<typeof setInterval> | undefined
let workflowLogFetching = false

const setInit = async (showLoading = true) => {
  if (!workflowIdx.value) {
    workflowLogList.value = []
    firstLoadData.value = true
    stopWorkflowLogPolling()
    return
  }

  if (workflowLogFetching) {
    return
  }

  workflowLogFetching = true
  if (showLoading) {
    firstLoadData.value = false
    workflowLogList.value = []
  }

  await getWorkflowLog(workflowIdx.value).then(({ data }) => {
    const nextLogList = Array.isArray(data) ? data : []
    const currentBuildIdx = clickedBuildIdx.value
    workflowLogList.value = nextLogList

    if (!nextLogList.some((workflowLog) => workflowLog.buildIdx === currentBuildIdx)) {
      clickedBuildIdx.value = nextLogList[0]?.buildIdx ?? 0
    }
  }).catch((error) => {
    console.log(error)
    if (showLoading) {
      toast.error('Failed to load workflow logs.')
    }
  }).finally(() => {
    if (showLoading) {
      firstLoadData.value = true
    }
    workflowLogFetching = false
  })
}

const onShowModal = async () => {
  await setInit(true)
  startWorkflowLogPolling()
}

const onHiddenModal = () => {
  setClear()
}

const setClear = () => {
  stopWorkflowLogPolling()
  workflowLogList.value = []
  clickedBuildIdx.value = 1
}

const clickedBuildIdx = ref(1 as number)
const onClickedBuildIdx = (buildIdx: number) => {
  if (clickedBuildIdx.value === buildIdx) {
    clickedBuildIdx.value = 0
  }
  else {
    clickedBuildIdx.value = buildIdx
  }
}

const getBuildTitle = (buildIdx: number) => {
  return buildIdx === 0 ? 'DB History' : buildIdx
}

const startWorkflowLogPolling = () => {
  stopWorkflowLogPolling()
  if (!isWorkflowLogModalOpen() || !workflowIdx.value) {
    return
  }

  workflowLogPollingTimer = setInterval(async () => {
    await setInit(false)
    if (!isWorkflowLogModalOpen() || !workflowIdx.value) {
      stopWorkflowLogPolling()
    }
  }, LOG_POLLING_INTERVAL_MS)
}

const stopWorkflowLogPolling = () => {
  if (workflowLogPollingTimer) {
    clearInterval(workflowLogPollingTimer)
    workflowLogPollingTimer = undefined
  }
}

const isWorkflowLogModalOpen = () => {
  return Boolean(modalElement.value?.classList.contains('show'))
}
</script>
