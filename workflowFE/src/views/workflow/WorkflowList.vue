<template>
  <div>
    <!-- Page header -->
    <TableHeader
      :header-title="'Workflow'"
      :new-btn-title="'New Workflow'"
      :popup-flag="false"
      :popup-target="''"
      class="mb-3"
      @click-new-btn="onClickNewBtn"
    />

    <!-- Data card -->
    <div class="card card-flush w-100">
      <div class="card-body">
        <Tabulator
          :columns="columns"
          :table-data="workflowList"
        />
      </div>
    </div>

    <DeleteWorkflow
      :workflow-name="selectWorkflowName"
      :workflow-idx="selectWorkflowIdx"
      @get-workflow-list="_getWorkflowList"/>

    <RunWorkflow
      :workflow-idx="selectWorkflowIdx"
      @get-workflow-list="_getWorkflowList"/>

    <WorkflowLog
      :workflow-idx="selectWorkflowIdx"/>

      <b-overlay
        :show="overlayShow"
        id="overlay-background"
        variant="transparent"
        opacity="1"
        blur="1rem"
        rounded="lg"
        style="z-index: 1000;"
      />

    <!-- <div v-show="overlayShow" class="spinner-border" role="status" style="z-index: 1000;"></div> -->

  </div>
</template>
<script setup lang="ts">
// @ts-ignore
import TableHeader from '../../components/Table/TableHeader.vue'
// @ts-ignore
import Tabulator from '@/components/Table/Tabulator.vue'
// @ts-ignore
import { getWorkflowList, existEventListener } from '@/api/workflow'
import { onBeforeUnmount, onMounted, ref } from 'vue';
// @ts-ignore
import type { Workflow } from '@/views/type/type'
import type { ColumnDefinition } from 'tabulator-tables';
// @ts-ignore
import router from '@/router';
// @ts-ignore
import DeleteWorkflow from '@/views/workflow/components/DeleteWorkflow.vue'
// @ts-ignore
import RunWorkflow from '@/views/workflow/components/RunWorkflow.vue'
import { useToast } from 'vue-toastification';
// @ts-ignore
import WorkflowLog from '@/views/workflow/components/WorkflowLog.vue'

const overlayShow = ref(true as Boolean)

const toast = useToast()
const workflowList = ref([] as Array<Workflow>)
const columns = ref([] as Array<ColumnDefinition>)

onMounted(async () => {
  setColumns()
  await _getWorkflowList()
  startWorkflowListPolling()
})

onBeforeUnmount(() => {
  stopWorkflowListPolling()
})

let workflowListPollingTimer: ReturnType<typeof setInterval> | undefined
let workflowListFetching = false
const WORKFLOW_LIST_POLLING_INTERVAL_MS = 15000
const startWorkflowListPolling = () => {
  stopWorkflowListPolling()
  workflowListPollingTimer = setInterval(() => {
    _getWorkflowList(false)
  }, WORKFLOW_LIST_POLLING_INTERVAL_MS)
}
const stopWorkflowListPolling = () => {
  if (workflowListPollingTimer) {
    clearInterval(workflowListPollingTimer)
    workflowListPollingTimer = undefined
  }
}

const _getWorkflowList = async (showLoading = true) => {
  if (workflowListFetching) {
    return
  }

  workflowListFetching = true
  try {
    if (showLoading) {
      overlayShow.value = true
    }
    await getWorkflowList('N').then(({ data }) => {
      workflowList.value = data
    })
  } catch(error) {
    console.log(error)
  } finally {
    if (showLoading) {
      overlayShow.value = false
    }
    workflowListFetching = false
  }
}

const selectWorkflowIdx = ref(0 as number)
const selectWorkflowName = ref('' as string)
const setColumns = () => {
  columns.value = [
    {
      title: "Workflow Name",
      field: "workflowInfo.workflowName",
      width: '30%'
    },
    {
      title: "Workflow Purpose",
      field: "workflowInfo.workflowPurpose",
      width: '10%'
    },
    {
      title: "Status",
      field: "workflowInfo.status",
      width: '10%',
      formatter: statusFormatter
    },
    {
      title: "Params Count",
      formatter: paramsCountFomatter,
      width: '10%',
      // widthShrink: 1,
    },
    {
      title: "Last Run Date",
      field: "runDate",
      width: '20%',
      formatter: runDateFormatter,
      // widthShrink: 5,
    },
    {
      title: "Action",
      width: '20%',
      formatter: buttonFormatter,
      cellClick: async(e, cell) => {
        const target = e.target as HTMLElement;
        const btnFlag = target?.getAttribute('id')
        selectWorkflowIdx.value = cell.getRow().getData().workflowInfo.workflowIdx

        if (btnFlag === 'detail-btn') {
          router.push('/web/workflows/workflow/detail/' + selectWorkflowIdx.value)
        }
        else if (btnFlag === 'delete-btn') {
          selectWorkflowName.value = cell.getRow().getData().workflowInfo.workflowName
        }
      }
    }

  ]
}

const onClickNewBtn = () => {
  router.push('/web/workflows/workflow/new')
}
const paramsCountFomatter = (cell: any) => {
  const paramsCnt = cell._cell.row.data.workflowParams.length
  return `<span>${ paramsCnt }</span>`
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
const runDateFormatter = (cell: any) => {
  const value = cell.getValue()
  if (!value) {
    return '<span>-</span>'
  }

  const date = new Date(value)
  if (Number.isNaN(date.getTime())) {
    return `<span>${value}</span>`
  }

  return `<span>${date.toLocaleString()}</span>`
}
const buttonFormatter = () => {
  return `
    <div>
      <button
        class='btn btn-primary d-none d-sm-inline-block'
        id='detail-btn'
        style='margin-right: 5px'>
          Detail
      </button>
      <button class='btn btn-danger d-none d-sm-inline-block'
        id='delete-btn'
        data-bs-toggle='modal' 
        data-bs-target='#deleteWorkflow'
        style='margin-right: 5px'>
        DELETE
      </button>
      <button class='btn btn-info d-none d-sm-inline-block'
        id='run-btn'
        data-bs-toggle='modal' 
        data-bs-target='#runWorkflow'>
        RUN
      </button>
      <button class='btn btn-primary d-none d-sm-inline-block'
        id='log-btn'
        data-bs-toggle='modal' 
        data-bs-target='#workflowLog'>
        LOG
      </button>
    </div>`;
}
</script>
