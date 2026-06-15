<template>
  <div>
    <!-- Page header -->
    <TableHeader
      :header-title="'Event Listener'"
      :new-btn-title="'New Event Listener'"
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
          :table-data="eventListenerList"
        />
      </div>
    </div>

    <EventListenerForm  
      style="width: 100%;"
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
// @ts-ignore
import TableHeader from '../../components/Table/TableHeader.vue'
// @ts-ignore
import Tabulator from '@/components/Table/Tabulator.vue'
// @ts-ignore
import { getEventListenerList } from '@/api/eventListener'
import { nextTick, onMounted } from 'vue';
import { ref } from 'vue';
// @ts-ignore
import { type EventListener } from '@/views/type/type'
import { type ColumnDefinition } from 'tabulator-tables';
import { useToast } from 'vue-toastification';
// @ts-ignore
import EventListenerForm from './components/eventListenerForm.vue';
// @ts-ignore
import DeleteEventListener from './components/deleteEventListener.vue';
import { Modal } from 'bootstrap'

const toast = useToast()
/* Comment translated to English. */
const eventListenerList = ref([] as Array<EventListener>)
const columns = ref([] as Array<ColumnDefinition>)

/* Comment translated to English. */
onMounted(async () => {
  setColumns()
  await _getEventListenerList()
})

/* Comment translated to English. */
const _getEventListenerList = async () => {
  try {
    const { data } = await getEventListenerList()    
    eventListenerList.value = data

    eventListenerList.value.forEach((eventListenerInfo) => {
      eventListenerInfo.eventListenerUrl = setEventListenerUrl(eventListenerInfo.eventListenerCallUrl)
    })

  } catch(error) {
    console.log(error)
    toast.error('Failed to load data.')
  }
}
const setEventListenerUrl = (eventListenerCallUrl:string) => {
  const baseUrl = window.location.origin
  return baseUrl+eventListenerCallUrl;
}


/* Comment translated to English. */
const selectEventListenerIdx = ref(0 as number)
const selectEventListenerName = ref('' as string)
const setColumns = () => {
  columns.value = [
    {
      title: "Event Listener Name",
      field: "eventListenerName",
      width: '20%'
    },
    {
      title: "Connect Workflow Name",
      field: "workflowName",
      width: '20%'
    },
    {
      title: "Event Listener Desc",
      field: "eventListenerDesc",
      width: '20%'
    },
    {
      title: "Action URL",
      field: "eventListenerUrl",
      width: '20%'
    },
    {
      title: "Action",
      width: '20%',
      formatter: editDeleteButtonFormatter,
      cellClick: async function (e, cell) {
        const target = e.target as HTMLElement;
        const btnFlag = target?.getAttribute('id')
        selectEventListenerIdx.value = cell.getRow().getData().eventListenerIdx

        if (btnFlag === 'edit-btn') {
          formMode.value = 'edit'
          await showModal('eventListenerForm')
        }
        else if (btnFlag === 'delete-btn') {
          selectEventListenerName.value = cell.getRow().getData().eventListenerName
          await showModal('deleteEventListener')
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

/* Comment translated to English. */
const editDeleteButtonFormatter = () => {
  return `
  <div>
    <button
      class='btn btn-primary d-none d-sm-inline-block mr-5'
      id='edit-btn'>Edit</button>
    <button
      class='btn btn-danger d-none d-sm-inline-block'
      id='delete-btn'>Delete</button>
  </div>`;
}

/* Comment translated to English. */
const formMode = ref('new')

/* Comment translated to English. */
const onClickNewBtn = async () => {
  selectEventListenerIdx.value = 0
  formMode.value = 'new'
  await showModal('eventListenerForm')
}


</script>
