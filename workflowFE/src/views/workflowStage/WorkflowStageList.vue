<template>

  <TableHeander 
    :header-title="'Workflow Stage'"
    :new-btn-title="'New Stage'"
    :popup-flag="true"
    :popup-target="'#workflowStageForm'"
    class="mb-3"
    @click-new-btn="onClickNewBtn"
  />

  <div class="card card-flush w-100">
    <Tabulator 
      :columns="columns"
      :table-data="workflowStageList">
    </Tabulator>

    <WorkflowStageForm 
      :mode="formMode"
      :workflow-stage-idx="selectWorkflowStageIdx"
      :workflow-stage-name="selectWorkflowStageName"
      @get-workflow-stage-list="_getWorkflowStageList"/>

    <DeleteWorkflowStage 
      :workflow-stage-name="selectWorkflowStageName"
      :workflow-stage-idx="selectWorkflowStageIdx"
      @get-workflow-stage-list="_getWorkflowStageList"/>

  </div>
</template>
<script setup lang="ts">
import TableHeander from '@/components/Table/TableHeader.vue'
import Tabulator from '@/components/Table/Tabulator.vue'
import { getWorkflowStageList } from '@/api/workflowStage'
import { onMounted } from 'vue';
import { ref } from 'vue';
import type { WorkflowStage } from '@/views/type/type'
import { type ColumnDefinition } from 'tabulator-tables';
import { useToast } from 'vue-toastification';
import WorkflowStageForm from './components/WorkflowStageForm.vue';
import DeleteWorkflowStage from './components/DeleteWorkflowStage.vue';

const toast = useToast()
/* Comment translated to English. */
const workflowStageList = ref([] as Array<WorkflowStage>)
const columns = ref([] as Array<ColumnDefinition>)

/* Comment translated to English. */
onMounted(async () => {
  setColumns()
  await _getWorkflowStageList()
})


/* Comment translated to English. */
const _getWorkflowStageList = async () => {
  try {
    const { data } = await getWorkflowStageList()
    workflowStageList.value = data
  } catch(error) {
    console.log(error)
    toast.error('Failed to load data.')
  }
}

/* Comment translated to English. */
const selectWorkflowStageIdx = ref(0 as number)
const selectWorkflowStageName = ref('' as string)
const setColumns = () => {
  columns.value = [
    {
      title: "Stage Type",
      field: "workflowStageTypeName",
      width: '27%'
    },
    {
      title: "Stage Name",
      field: "workflowStageName",
      width: '27%'
    },
    {
      title: "Stage Desc",
      field: "workflowStageDesc",
      width: '26%'
    },
    {
      title: "Action",
      width: '20%',
      formatter: editDeleteButtonFormatter,
      cellClick: function (e, cell) {
          const target = e.target as HTMLElement;
          const btnFlag = target?.getAttribute('id');
          selectWorkflowStageIdx.value = cell.getRow().getData().workflowStageIdx;
          selectWorkflowStageName.value = cell.getRow().getData().workflowStageName;

          if (btnFlag === 'edit-btn') {
              formMode.value = 'edit';
          }
      }
    }
  ]
}

/* Comment translated to English. */
const editDeleteButtonFormatter = () => {
  return `
  <div>
    <button
      class='btn btn-primary d-none d-sm-inline-block mr-5'
      id='edit-btn'
      data-bs-toggle='modal' 
      data-bs-target='#workflowStageForm'>
      EDIT
    </button>
    <button
      class='btn btn-danger d-none d-sm-inline-block'
      id='delete-btn'
      data-bs-toggle='modal' 
      data-bs-target='#deleteWorkflowStage'>
      DELETE
    </button>
  </div>`;
}

/* Comment translated to English. */
const formMode = ref('new')

/* Comment translated to English. */
const onClickNewBtn = () => {
  selectWorkflowStageIdx.value = 0
  formMode.value = 'new'
}


</script>