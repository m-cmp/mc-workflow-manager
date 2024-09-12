<template>
  <div class="card card-flush w-100">
    <TableHeander 
      :header-title="'Workflow Stage'"
      :new-btn-title="'New Stage'"
      :popup-flag="true"
      :popup-target="'#workflowStageForm'"
      @click-new-btn="onClickNewBtn"
    />
    <Tabulator 
      :columns="columns"
      :table-data="workflowStageList">
    </Tabulator>

    <WorkflowStageForm 
      :mode="formMode"
      :workflow-stage-idx="selectWorkflowStageIdx"
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
/**
 * @Title workflowStageList / columns
 * @Desc 
 *    workflowStageList : workflow Stage 목록 저장
 *    columns : 목록의 컬럼 저장
 */
const workflowStageList = ref([] as Array<WorkflowStage>)
const columns = ref([] as Array<ColumnDefinition>)

/**
 * @Title Life Cycle
 * @Desc 컬럼 set Callback 함수 호출 / workflow Stage List Callback 함수 호출
 */
onMounted(async () => {
  setColumns()
  await _getWorkflowStageList()
})


/**
 * @Title _getWorkflowStageList
 * @Desc workflowStage List Callback 함수 / workflow Stage List api 호출
 */
const _getWorkflowStageList = async () => {
  try {
    const { data } = await getWorkflowStageList()
    workflowStageList.value = data
  } catch(error) {
    console.log(error)
    toast.error('데이터를 가져올 수 없습니다.')
  }
}

/**
 * @Title selectWorkflowStageIdx / selectWorkflowStageName / setColumns
 * @Desc
 *    selectWorkflowStageIdx : 수정/삭제를 위한 선택된 row의 workflowStageIdx저장
 *    selectWorkflowStageName : 삭제를 위한 선택된 row의 workflowStageName저장
 *    setColumns : 컬럼 set Callback 함수
 */
const selectWorkflowStageIdx = ref(0 as number)
const selectWorkflowStageName = ref('' as string)
const setColumns = () => {
  columns.value = [
    {
      title: "Stage Type",
      field: "workflowStageTypeName",
      width: 500
    },
    {
      title: "Stage Name",
      field: "workflowStageName",
      width: 500
    },
    {
      title: "Stage Desc",
      field: "workflowStageDesc",
      width: 500
    },
    {
      title: "Action",
      width: 400,
      formatter: editDeleteButtonFormatter,
      cellClick: function (e, cell) {
          const target = e.target as HTMLElement;
          const btnFlag = target?.getAttribute('id');
          selectWorkflowStageIdx.value = cell.getRow().getData().workflowStageIdx;

          if (btnFlag === 'edit-btn') {
              formMode.value = 'edit';
          } else if (btnFlag === 'delete-btn') {
              selectWorkflowStageName.value = cell.getRow().getData().workflowStageName;
          }
      }
    }
  ]
}

/**
 * @Title editButtonFormatter
 * @Desc 수정 / 삭제 버튼 Formatter
 */
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

/**
 * @Title formMode
 * @Desc 기본값 new / workflowStageForm에 생성/수정 을 알려주는 값
 */
const formMode = ref('new')

/**
 * @Title onClickNewBtn
 * @Desc WorkflowStage 생성버튼 클릭시 동작하는 함수 (workflowStageIdx / formMode set)
 */
const onClickNewBtn = () => {
  selectWorkflowStageIdx.value = 0
  formMode.value = 'new'
}


</script>