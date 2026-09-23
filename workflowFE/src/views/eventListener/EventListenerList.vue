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
        <div class="event-listener-table">
          <Tabulator
            :columns="columns"
            :table-data="eventListenerList"
          />
        </div>
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
      minWidth: 190,
      widthGrow: 1.4,
      cssClass: 'event-listener-text-cell',
      variableHeight: true,
    },
    {
      title: "Connect Workflow Name",
      field: "workflowName",
      minWidth: 220,
      widthGrow: 1.6,
      cssClass: 'event-listener-text-cell',
      variableHeight: true,
    },
    {
      title: "Event Listener Desc",
      field: "eventListenerDesc",
      minWidth: 220,
      widthGrow: 1.8,
      cssClass: 'event-listener-text-cell',
      variableHeight: true,
    },
    {
      title: "Action URL",
      field: "eventListenerUrl",
      minWidth: 260,
      widthGrow: 2.2,
      cssClass: 'event-listener-url-cell',
      variableHeight: true,
    },
    {
      title: "Action",
      minWidth: 180,
      widthGrow: 1,
      formatter: editDeleteButtonFormatter,
      cssClass: 'event-listener-action-cell',
      headerSort: false,
      variableHeight: true,
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
  <div class='event-listener-action-buttons'>
    <button
      class='btn btn-primary'
      id='edit-btn'>Edit</button>
    <button
      class='btn btn-danger'
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
<style>
.event-listener-table .tabulator .tabulator-tableholder {
  overflow-x: auto;
}

.event-listener-table .tabulator-row {
  min-height: 56px;
}

.event-listener-table .tabulator-row .tabulator-cell {
  min-height: 56px;
  display: inline-flex;
  align-items: center;
}

.event-listener-table .tabulator-row .tabulator-cell.event-listener-text-cell,
.event-listener-table .tabulator-row .tabulator-cell.event-listener-url-cell,
.event-listener-table .tabulator-row .tabulator-cell.event-listener-action-cell {
  white-space: normal !important;
  overflow: visible !important;
  text-overflow: clip !important;
  line-height: 1.35;
}

.event-listener-table .tabulator-row .tabulator-cell.event-listener-url-cell {
  overflow-wrap: anywhere !important;
  word-break: break-word;
}

.event-listener-table .event-listener-action-buttons {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  width: 100%;
  min-width: 0;
}

.event-listener-table .event-listener-action-buttons .btn {
  flex: 0 0 auto;
  margin: 0;
  white-space: nowrap;
}

@media (max-width: 960px) {
  .event-listener-table .tabulator-row .tabulator-cell {
    padding: 8px 10px;
  }

  .event-listener-table .event-listener-action-buttons .btn {
    min-height: 32px;
    padding: 0.3rem 0.55rem;
  }
}
</style>
