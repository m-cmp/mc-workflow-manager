<template>
  <div class="card card-flush w-100">
    <TableHeander 
      :header-title="'Event Listener'"
      :new-btn-title="'New Event Listener'"
      :popup-flag="true"
      :popup-target="'#eventListenerForm'"
      @click-new-btn="onClickNewBtn"
    />
    <Tabulator 
      :columns="columns"
      :table-data="eventListenerList">
    </Tabulator>

    <EventListenerForm  
      :mode="formMode"
      :event-listener-idx="selectEventListenerIdx"
      @get-event-listener-list="_getEventListenerList"/>

    <DeleteEventListener 
      :event-listener-name="selectEventListenerName"
      :event-listener-idx="selectEventListenerIdx"
      @get-event-listener-list="_getEventListenerList"/>

  </div>
</template>
<script setup lang="ts">
import TableHeander from '@/components/Table/TableHeader.vue'
import Tabulator from '@/components/Table/Tabulator.vue'
import { getEventListenerList } from '@/api/eventListener'
import { onMounted } from 'vue';
import { ref } from 'vue';
import { type EventListener } from '@/views/type/type'
import { type ColumnDefinition } from 'tabulator-tables';
import { useToast } from 'vue-toastification';
import EventListenerForm from './components/eventListenerForm.vue';
import DeleteEventListener from './components/deleteEventListener.vue';

const toast = useToast()
/**
 * @Title eventListenerList / columns
 * @Desc 
 *    eventListenerList : eventListener 목록 저장
 *    columns : 목록의 컬럼 저장
 */
const eventListenerList = ref([] as Array<EventListener>)
const columns = ref([] as Array<ColumnDefinition>)

/**
 * @Title Life Cycle
 * @Desc 컬럼 set Callback 함수 호출 / eventListenerList Callback 함수 호출
 */
onMounted(async () => {
  setColumns()
  await _getEventListenerList()
})

/**
 * @Title _getEventListenerList
 * @Desc Event Listener List Callback 함수 / Event Listener List api 호출
 */
const _getEventListenerList = async () => {
  try {
    const { data } = await getEventListenerList()
    eventListenerList.value = data
  } catch(error) {
    console.log(error)
    toast.error('데이터를 가져올 수 없습니다.')
  }
}

/**
 * @Title selectEventListenerIdx / selectEventListenerName / setColumns
 * @Desc
 *    selectEventListenerIdx : 수정/삭제를 위한 선택된 row의 eventListenerIdx저장
 *    selectEventListenerName : 삭제를 위한 선택된 row의 eventListenerName저장
 *    setColumns : 컬럼 set Callback 함수
 */
const selectEventListenerIdx = ref(0 as number)
const selectEventListenerName = ref('' as string)
const setColumns = () => {
  columns.value = [
    {
      title: "Event Listener Name",
      field: "eventListenerName",
      width: 400
    },
    {
      title: "Event Listener Desc",
      field: "eventListenerDesc",
      width: 500
    },
    {
      title: "URL",
      field: "eventListenerUrl",
      width: 600
    },
    {
      title: "Action",
      width: 400,
      formatter: editDeleteButtonFormatter,
      cellClick: function (e, cell) {
        const target = e.target as HTMLElement;
        const btnFlag = target?.getAttribute('id')
        selectEventListenerIdx.value = cell.getRow().getData().eventListenerIdx

        if (btnFlag === 'edit-btn') {
          formMode.value = 'edit'
        }
        else {
          selectEventListenerName.value = cell.getRow().getData().eventListenerName
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
      data-bs-target='#eventListenerForm'>
      수정
    </button>
    <button
      class='btn btn-danger d-none d-sm-inline-block'
      id='delete-btn'
      data-bs-toggle='modal' 
      data-bs-target='#deleteEventListener'>
      삭제
    </button>
  </div>`;
}

/**
 * @Title formMode
 * @Desc 기본값 new / eventListenerForm에 생성/수정 을 알려주는 값
 */
const formMode = ref('new')

/**
 * @Title onClickNewBtn
 * @Desc EventListener 생성버튼 클릭시 동작하는 함수 (eventListnerIdx / formMode set)
 */
const onClickNewBtn = () => {
  selectEventListenerIdx.value = 0
  formMode.value = 'new'
}


</script>