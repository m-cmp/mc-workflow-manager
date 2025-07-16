<template>
  <div>
    <!-- Page header -->
    <TableHeader
      :header-title="'OSS'"
      :new-btn-title="'New OSS'"
      :popup-flag="true"
      :popup-target="'#ossForm'"
      @click-new-btn="onClickNewBtn"
    />

    <!-- Data card -->
    <div class="card card-flush w-100">
      <div class="card-body table-responsive">
        <Tabulator
          :columns="columns"
          :table-data="ossList"
        />
      </div>
    </div>

    <!-- Modals -->
    <OssForm
      :mode="formMode"
      :oss-idx="selectOssIdx"
      @get-oss-list="_getOssList"
    />

    <DeleteOss
      :oss-name="selectOssName"
      :oss-idx="selectOssIdx"
      @get-oss-list="_getOssList"
    />
  </div>
</template>
<script setup lang="ts">
// @ts-ignore
import TableHeader from '../../components/Table/TableHeader.vue'
// @ts-ignore
import Tabulator from '@/components/Table/Tabulator.vue'
// @ts-ignore
import { getOssAllList } from '@/api/oss'
import { onMounted } from 'vue';
import { ref } from 'vue';
// @ts-ignore
import { type Oss } from '@/views/type/type'
import { type ColumnDefinition } from 'tabulator-tables';
import { useToast } from 'vue-toastification';
// @ts-ignore
import OssForm from './components/ossForm.vue';
// @ts-ignore
import DeleteOss from './components/deleteOss.vue';

const toast = useToast()
/**
 * @Title ossList / columns
 * @Desc 
 *    ossList : oss 목록 저장
 *    columns : 목록의 컬럼 저장
 */
const ossList = ref([] as Array<Oss>)
const columns = ref([] as Array<ColumnDefinition>)

/**
 * @Title Life Cycle
 * @Desc 컬럼 set Callback 함수 호출 / ossList Callback 함수 호출
 */
onMounted(async () => {
  setColumns()
  await _getOssList()
})

/**
 * @Title _getOssList
 * @Desc oss List Callback 함수 / oss List api 호출
 */
const _getOssList = async () => {
  try {
    const { data } = await getOssAllList()
    ossList.value = data
  } catch(error) {
    console.log(error)
    toast.error('데이터를 가져올 수 없습니다.')
  }
}

/**
 * @Title selectOssIdx / selectOssName / setColumns
 * @Desc
 *    selectOssIdx : 수정/삭제를 위한 선택된 row의 ossIdx저장
 *    selectOssName : 삭제를 위한 선택된 row의 ossName저장
 *    setColumns : 컬럼 set Callback 함수
 */
const selectOssIdx = ref(0 as number)
const selectOssName = ref('' as string)
const setColumns = () => {
  columns.value = [
    {
      title: "OSS Name",
      field: "ossName",
      width: '25%',
    },
    {
      title: "OSS Desc",
      field: "ossDesc",
      width: '25%',
    },
    {
      title: "URL",
      field: "ossUrl",
      width: '25%',
    },
    {
      title: "Action",
      hozAlign: "center",
      width: '25%',
      formatter: editDeleteButtonFormatter,
      cellClick: function (e, cell) {
        const target = e.target as HTMLElement;
        const btnFlag = target?.getAttribute('id')
        selectOssIdx.value = cell.getRow().getData().ossIdx

        if (btnFlag === 'edit-btn') {
          formMode.value = 'edit'
        }
        else {
          selectOssName.value = cell.getRow().getData().ossName
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
      data-bs-target='#ossForm'>
      EDIT
    </button>
    <button
      class='btn btn-danger d-none d-sm-inline-block'
      id='delete-btn'
      data-bs-toggle='modal' 
      data-bs-target='#deleteOss'>
      DELETE
    </button>
  </div>`;
}

/**
 * @Title formMode
 * @Desc 기본값 new / ossForm에 생성/수정 을 알려주는 값
 */
const formMode = ref('new')

/**
 * @Title onClickNewBtn
 * @Desc Oss 생성버튼 클릭시 동작하는 함수 (ossIdx / formMode set)
 */
const onClickNewBtn = () => {
  selectOssIdx.value = 0
  formMode.value = 'new'
}


</script>