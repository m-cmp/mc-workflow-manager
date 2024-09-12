<template>
  <div class="card card-flush w-100">
    <TableHeander 
      :header-title="'Workflow'"
      :new-btn-title="'New Workflow'"
      :popupFlag="false"
      :popupTarget="''"
      @click-new-btn="onClickNewBtn"
    />
    <Tabulator 
      :columns="columns"
      :table-data="workflowList">
    </Tabulator>

    <DeleteWorkflow
      :workflow-name="selectWorkflowName"
      :workflow-idx="selectWorkflowIdx"
      @get-workflow-list="_getWorkflowList"/>

    <RunWorkflow
      :workflow-idx="selectWorkflowIdx"
      @get-workflow-list="_getWorkflowList"/>

    <WorkflowLog
      :workflow-idx="selectWorkflowIdx"/>
  </div>
</template>
<script setup lang="ts">
import TableHeander from '@/components/Table/TableHeader.vue'
import Tabulator from '@/components/Table/Tabulator.vue'
import { getWorkflowList, existEventListener } from '@/api/workflow'
import { onMounted, ref } from 'vue';
import type { Workflow } from '@/views/type/type'
import type { ColumnDefinition } from 'tabulator-tables';
import router from '@/router';
import DeleteWorkflow from '@/views/workflow/components/DeleteWorkflow.vue'
import RunWorkflow from '@/views/workflow/components/RunWorkflow.vue'
import { useToast } from 'vue-toastification';
import WorkflowLog from '@/views/workflow/components/WorkflowLog.vue'

const toast = useToast()
const workflowList = ref([] as Array<Workflow>)
const columns = ref([] as Array<ColumnDefinition>)

onMounted(async () => {
  setColumns()
  await _getWorkflowList()
})

const _getWorkflowList = async () => {
  try {
    const { data } = await getWorkflowList('N')
    workflowList.value = data
  } catch(error) {
    console.log(error)
  }
}

const selectWorkflowIdx = ref(0 as number)
const selectWorkflowName = ref('' as string)
const setColumns = () => {
  columns.value = [
    {
      title: "Workflow Name",
      field: "workflowInfo.workflowName",
      width: 500
    },
    {
      title: "Workflow Purpose",
      field: "workflowInfo.workflowPurpose",
      width: 200
    },
    {
      title: "Params Count",
      formatter: paramsCountFomatter,
      width: 400,
      // widthShrink: 1,
    },
    {
      title: "Created Date",
      field: "regDate",
      width: 400,
      // widthShrink: 5,
    },
    {
      title: "Action",
      width: 400,
      formatter: editButtonFormatter,
      cellClick: async(e, cell) => {
        const target = e.target as HTMLElement;
        const btnFlag = target?.getAttribute('id')
        selectWorkflowIdx.value = cell.getRow().getData().workflowInfo.workflowIdx

        if (btnFlag === 'edit-btn') {
          router.push('/web/workflow/edit/' + selectWorkflowIdx.value)
        }
        else if (btnFlag === 'delete-btn') {
          selectWorkflowName.value = cell.getRow().getData().workflowInfo.workflowName
        }
      }
    }

  ]
}

const onClickNewBtn = () => {
  router.push('/web/workflow/new')
}
const paramsCountFomatter = (cell: any) => {
  const paramsCnt = cell._cell.row.data.workflowParams.length
  return `<span>${ paramsCnt }</span>`
}
const editButtonFormatter = () => {
  return `
    <div>
      <button
        class='btn btn-primary d-none d-sm-inline-block'
        id='edit-btn'
        style='margin-right: 5px'>
          EDIT
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