<template>
  <div class="mt-5 mb-5">
    
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
    :workflow-idx="props.workflowIdx"
    :build-name="selectBuildName"
    :workflow-name="props.workflowName"
    :workflow-stages="selectRunHistoryStage"
  />
  
</template>
<script setup lang="ts">
import { onMounted, ref, watch } from 'vue';
// @ts-ignore
import { getWorkflowRunHistory } from '@/api/workflow'
import type { ColumnDefinition } from 'tabulator-tables';
// @ts-ignore
import type { JenkinsStage } from '@/views/type/type'
// @ts-ignore
import Tabulator from '@/components/Table/Tabulator.vue'
// @ts-ignore
import WorkflowLog from '@/views/workflow/components/WorkflowLog.vue'
// @ts-ignore
import type { RunHistory } from '@/views/type/type'
// @ts-ignore
import _ from 'lodash'
// @ts-ignore
import WorkflowHistoryPopup from '@/views/workflow/components/WorkflowHistoryPopoup.vue'

const overlayShow = ref(true as Boolean)
const showComponentFlag = ref(false as Boolean)

interface Props {
  workflowIdx?: number | string | string[]
  workflowName: string
}

const props = defineProps<Props>()
watch(() => props.workflowIdx, async () => {
  if(props.workflowIdx !== 0)
    await setRunHistory(props.workflowIdx)
})
watch(() => showComponentFlag.value, () => {
})

onMounted(() => {
  setColumns()
})


const runHistoryList = ref([] as Array<RunHistory>)
const setRunHistory = async (workflowIdx?: number | string | string[]) => {
  overlayShow.value = true
  await getWorkflowRunHistory(workflowIdx).then(({ data }) => {
    overlayShow.value = false
    data.forEach((runHistoryInfo: RunHistory) => {
      runHistoryInfo.startTimeMillis = new Date(runHistoryInfo.startTimeMillis).toLocaleString();
      runHistoryInfo.user = 'ADMIN';
    })
    runHistoryList.value = _.sortBy(data, 'name').reverse()
    showComponentFlag.value = true
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
        selectBuildName.value = cell.getRow().getData().name.replace('#', '')
        selectRunHistoryStage.value = cell.getRow().getData().stages
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
const detailButtonFormatter = () => {
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