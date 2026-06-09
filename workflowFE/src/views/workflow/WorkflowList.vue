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
import { nextTick, onBeforeUnmount, onMounted, ref } from 'vue';
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
import { Modal } from 'bootstrap'

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
const WORKFLOW_LIST_POLLING_INTERVAL_MS = 30000
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
      workflowList.value = mergeWorkflowList(data || [], !showLoading)
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

const getWorkflowRowKey = (workflow: Workflow) => {
  return String(workflow.workflowInfo?.workflowIdx || workflow.workflowInfo?.workflowName || '')
}

const mergeWorkflowList = (nextWorkflowList: Array<Workflow>, preserveCurrentRows = false) => {
  if (workflowList.value.length === 0) {
    return nextWorkflowList
  }

  const nextWorkflowByKey = new Map(
    nextWorkflowList.map((workflow) => [getWorkflowRowKey(workflow), workflow])
  )
  const mergedWorkflowKeys = new Set<string>()

  const mergedWorkflowList = workflowList.value
    .map((workflow) => {
      const workflowKey = getWorkflowRowKey(workflow)
      const nextWorkflow = nextWorkflowByKey.get(workflowKey)

      if (!nextWorkflow) {
        return preserveCurrentRows ? workflow : null
      }

      mergedWorkflowKeys.add(workflowKey)
      return nextWorkflow
    })
    .filter((workflow): workflow is Workflow => workflow !== null)

  if (preserveCurrentRows) {
    return mergedWorkflowList
  }

  const appendedWorkflowList = nextWorkflowList.filter((workflow) => {
    return !mergedWorkflowKeys.has(getWorkflowRowKey(workflow))
  })

  return [
    ...mergedWorkflowList,
    ...appendedWorkflowList,
  ]
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
      title: "Purpose",
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
          await showModal('deleteWorkflow')
        }
        else if (btnFlag === 'run-btn') {
          await showModal('runWorkflow')
        }
        else if (btnFlag === 'log-btn') {
          await showModal('workflowLog')
        }
      }
    }

  ]
}

const showModal = async (modalId: string) => {
  await nextTick()
  const modalElement = document.getElementById(modalId)
  if (modalElement) {
    Modal.getOrCreateInstance(modalElement).show()
  }
}

const onClickNewBtn = () => {
  router.push('/web/workflows/workflow/new')
}
const paramsCountFomatter = (cell: any) => {
  const paramsCnt = (cell._cell.row.data.workflowParams || [])
    .filter((param: any) => String(param?.paramKey || '').trim())
    .length
  return `<span>${ paramsCnt }</span>`
}

const statusFormatter = (cell: any) => {
  const status = cell.getValue() || '-'
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
        style='margin-right: 5px'>
        DELETE
      </button>
      <button class='btn btn-info d-none d-sm-inline-block'
        id='run-btn'>
        RUN
      </button>
      <button class='btn btn-primary d-none d-sm-inline-block'
        id='log-btn'>
        LOG
      </button>
    </div>`;
}
</script>
