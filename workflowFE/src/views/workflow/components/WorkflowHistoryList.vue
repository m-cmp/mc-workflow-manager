<template>
  <div v-if="hasRunHistory" class="mt-5 mb-5">
    
    <h3 class="card-title mb-3">History</h3>
    <b-overlay
      :show="overlayShow"
      id="overlay-background"
      variant="transparent"
      opacity="1"
      blur="1rem"
      rounded="lg"
      style="z-index: 1000;"
    />

    <div>
      <Tabulator 
        :columns="columns"
        :table-data="runHistoryList">
      </Tabulator>
    </div>
  </div>

  <WorkflowHistoryPopup
    v-if="hasRunHistory"
    :workflow-idx="props.workflowIdx"
    :build-name="selectBuildName"
    :workflow-name="props.workflowName"
    :workflow-stages="selectRunHistoryStage"
  />
  
</template>
<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue';
// @ts-ignore
import { getWorkflowRunHistory } from '@/api/workflow'
import type { ColumnDefinition } from 'tabulator-tables';
// @ts-ignore
import type { JenkinsStage } from '@/views/type/type'
// @ts-ignore
import Tabulator from '@/components/Table/Tabulator.vue'
// @ts-ignore
import type { RunHistory } from '@/views/type/type'
// @ts-ignore
import _ from 'lodash'
// @ts-ignore
import WorkflowHistoryPopup from '@/views/workflow/components/WorkflowHistoryPopoup.vue'

const overlayShow = ref(true as Boolean)

interface Props {
  workflowIdx?: number | string | string[]
  workflowName: string
}

const props = defineProps<Props>()
watch(() => props.workflowIdx, async () => {
  resetRunHistoryState()
  if(isRunnableWorkflowIdx(props.workflowIdx)) {
    await setRunHistory(props.workflowIdx)
    startRunHistoryPolling()
  } else {
    stopRunHistoryPolling()
  }
})
onMounted(() => {
  setColumns()
  if (isRunnableWorkflowIdx(props.workflowIdx)) {
    setRunHistory(props.workflowIdx)
    startRunHistoryPolling()
  }
})

onBeforeUnmount(() => {
  stopRunHistoryPolling()
})


const runHistoryList = ref([] as Array<RunHistory>)
const hasRunHistory = computed(() => runHistoryList.value.length > 0)
let runHistoryPollingTimer: ReturnType<typeof setInterval> | undefined
let runHistoryFetching = false
function resetRunHistoryState() {
  runHistoryList.value = []
  selectBuildName.value = ''
  selectRunHistoryStage.value = []
}
const isRunnableWorkflowIdx = (workflowIdx?: number | string | string[]) => {
  return workflowIdx !== undefined && workflowIdx !== 0 && workflowIdx !== '0'
}
const startRunHistoryPolling = () => {
  stopRunHistoryPolling()
  runHistoryPollingTimer = setInterval(() => {
    setRunHistory(props.workflowIdx, false)
  }, 5000)
}
const stopRunHistoryPolling = () => {
  if (runHistoryPollingTimer) {
    clearInterval(runHistoryPollingTimer)
    runHistoryPollingTimer = undefined
  }
}
const setRunHistory = async (workflowIdx?: number | string | string[], showLoading = true) => {
  if (runHistoryFetching || !isRunnableWorkflowIdx(workflowIdx)) {
    return
  }

  runHistoryFetching = true
  if (showLoading) {
    overlayShow.value = true
  }

  await getWorkflowRunHistory(workflowIdx).then(({ data }) => {
    const historyList = Array.isArray(data) ? data : []
    historyList.forEach((runHistoryInfo: RunHistory) => {
      runHistoryInfo.startTimeMillis = new Date(runHistoryInfo.startTimeMillis).toLocaleString();
      runHistoryInfo.user = 'ADMIN';
    })
    runHistoryList.value = _.sortBy(historyList, 'name').reverse()
    if (!runHistoryList.value.length) {
      resetRunHistoryState()
    }
  }).catch((error) => {
    console.log(error)
  }).finally(() => {
    if (showLoading) {
      overlayShow.value = false
    }
    runHistoryFetching = false
  })
}

/**
 * @Title selectBuildName / setColumns
 * @Desc
 *    selectBuildName : 상세 팝업을 위한 선택된 row의 buildName저장
 *    setColumns : 컬럼 set Callback 함수
 */
const columns = ref([] as Array<ColumnDefinition>)
const selectBuildName = ref('' as string)
const selectRunHistoryStage = ref([] as Array<JenkinsStage>)
const setColumns = () => {
  columns.value = [
    {
      title: "Name",
      field: "name",
      width: '20%'
    },
    {
      title: "Status",
      field: "status",
      width: '20%',
      formatter: statusFormatter
    },
    {
      title: "User",
      field: "user",
      width: '20%'
    },
    {
      title: "Run time",
      field: "startTimeMillis",
      width: '20%'
    },
    {
      title: "Action",
      width: "20%",
      formatter: detailButtonFormatter,
      cellClick: function (e, cell) {
        const rowData = cell.getRow().getData()
        if (!rowData.stages || rowData.stages.length === 0) {
          return
        }
        selectBuildName.value = rowData.name.replace('#', '')
        selectRunHistoryStage.value = rowData.stages
      }
    }
  ]
}

const statusFormatter = (cell: any) => {
  const status = cell.getValue(); 
  return `
  <div>
    <span class="
      status
      ${
        status === 'SUCCESS' ? 'status-green' :
        status === 'FAILED' ? 'status-red' :
        status === 'IN_PROGRESS' ? 'status-blue' : ''
      }" 
    >
      <span class="status-dot"></span>
      ${status}
    </span>
  </div>
  `
}
/**
 * @Title editButtonFormatter
 * @Desc 수정 / 삭제 버튼 Formatter
 */
const detailButtonFormatter = (cell: any) => {
  const rowData = cell.getRow().getData()
  if (!rowData.stages || rowData.stages.length === 0) {
    return `<span class="text-secondary">LOG</span>`
  }

  return `
  <div>
    <button
      class='btn btn-primary d-none d-sm-inline-block mr-5'
      id='detail-btn'
      data-bs-toggle='modal' 
      data-bs-target='#workflowHistoryDetailPopup'>
      DETAIL
    </button>
  </div>`;
}
</script>
