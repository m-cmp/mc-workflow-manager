<template>
  <div class="modal modal-blur fade" id="eventListenerForm" tabindex="-1" aria-hidden="true" ref="modalElement">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document" style="max-width: 900px;">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title">Event Listener {{ props.mode === 'new' ? 'New' : 'Edit' }}</h3>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div class="modal-body py-4">
          <div>
            <!-- Comment translated to English. -->
            <div class="row mb-3">
              <label class="form-label required">Event Listener Name</label>
              <div class="grid gap-0 column-gap-3">
                <input type="text" class="form-control p-2 g-col-11" placeholder="Enter Event Listener Name" v-model="eventListenerFormData.eventListenerName" @input="onChangeEventListenerName"/>

                <button
                  v-if="!duplicatedEventListener"
                  class="btn btn-primary chk"
                  @click="onClickDuplicatEventListenerName"
                  style="margin:3px; width: 150px;"
                >Duplicate Check</button>
                <button
                  v-else
                  class="btn btn-success"
                  style="margin:3px; width: 150px;"
                >Duplicate Check</button>
              </div>
            </div>
            
            <!-- Event Listener Description -->
            <div class="mb-3">
              <label class="form-label required">Event Listener Description</label>
              <input type="text" class="form-control p-2 g-col-11" placeholder="Enter Event Listener Description" v-model="eventListenerFormData.eventListenerDesc" />
            </div>

            <!-- workflow -->
            <div class="mb-3">
              <label class="form-label required">Workflow</label>
              <select class="form-select p-2 g-col-12" v-model="eventListenerFormData.workflowIdx"  @change="onSelectWorkflow(eventListenerFormData.workflowIdx)">
                <option :value="0">Select Workflow</option>
                <option v-for="(workflow, idx) in workflowList" :value="workflow.workflowInfo.workflowIdx" :key="idx">
                  {{ workflow.workflowInfo.workflowName }}
                </option>
              </select>
            </div>
            <!-- Params -->
            <TumblebugParamSelector
              v-if="setParamFlag && selectorReady && eventListenerFormData.workflowIdx && eventListenerFormData.workflowParams"
              :key="`${eventListenerFormData.workflowIdx}-${selectorRevision}`"
              :workflow-name="selectedWorkflowName"
              :workflow-param-data="eventListenerFormData.workflowParams"
              :workflow-stage-mappings="selectedWorkflow?.workflowStageMappings || []"
            />
            <ParamForm 
              v-if="setParamFlag"
              :popup="false"
              :workflow-param-data="eventListenerFormData.workflowParams"
              event-listener-yn="Y"
              style="margin: 0 !important;"
            />
          </div>
        </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-link link-secondary" data-bs-dismiss="modal" @click="setInit()">
          Cancel
        </button>
        <button type="button" class="btn btn-primary ms-auto"  @click="onClickSubmit()">
          {{props.mode === 'new' ? 'Create' : 'Edit'}}
        </button>
      </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// @ts-ignore
import type { EventListener, Workflow, WorkflowParams } from '@/views/type/type';
import { ref } from 'vue';
import { useToast } from 'vue-toastification';
// @ts-ignore
import { duplicateCheck, getEventListenerDetailInfo, registEventListener, updateEventListener } from '@/api/eventListener';
// @ts-ignore
import { getWorkflowList } from '@/api/workflow';
import { onBeforeUnmount, onMounted } from 'vue';
import { computed } from 'vue';
import { watch } from 'vue';
// @ts-ignore
import ParamForm from '@/views/workflow/components/ParamForm.vue';
// @ts-ignore
import TumblebugParamSelector from '@/views/workflow/components/TumblebugParamSelector.vue';
import { Modal } from 'bootstrap'
import { useUserStore } from '@/stores/user'

const toast = useToast()
const userInfo = useUserStore()

/* Comment translated to English. */
const modalElement = ref<HTMLElement>()
const modalInstance = ref<Modal>()

/**
 * @Title Props / Emit
 */
interface Props {
  mode: String,
  eventListenerIdx: number
}
const props = defineProps<Props>()
const emit = defineEmits(['get-event-listener-list'])

/* Comment translated to English. */
const eventListenerIdx = computed(() => props.eventListenerIdx);
watch(eventListenerIdx, async () => {
  await setInit()
  await _getWorkflowList()
});
onMounted(async () => {
  // Comment translated to English.
  if (modalElement.value) {
    modalInstance.value = new Modal(modalElement.value)
    modalElement.value.addEventListener('show.bs.modal', onShowModal)
  }
  
  await setInit()
  await _getWorkflowList()
})

onBeforeUnmount(() => {
  modalElement.value?.removeEventListener('show.bs.modal', onShowModal)
})

const onShowModal = async () => {
  await setInit()
  await _getWorkflowList()
}

/* Comment translated to English. */
const eventListenerFormData = ref({} as EventListener)
const setParamFlag = ref(false as Boolean)
const selectorReady = ref(false)
const selectorRevision = ref(0)

/* Comment translated to English. */
const setInit = async () => {
  selectorReady.value = false
  if (props.mode === 'new') {
    eventListenerFormData.value = {
      eventListenerIdx: 0,
      eventListenerName: '',
      eventListenerDesc: '',
      eventListenerUrl: '',
      eventListenerCallUrl: '',
      workflowIdx: 0,
      workflowParams: [],
    }

    duplicatedEventListener.value = false
    checkedEventListenerName.value = ''
    originalEventListenerName.value = ''
    setParamFlag.value = true
  }
  else {
    const { data } = await getEventListenerDetailInfo(props.eventListenerIdx)
    eventListenerFormData.value = data

    duplicatedEventListener.value = true
    checkedEventListenerName.value = normalizeEventListenerName(data.eventListenerName)
    originalEventListenerName.value = normalizeEventListenerName(data.eventListenerName)
    setParamFlag.value = true
    selectorReady.value = Boolean(eventListenerFormData.value.workflowIdx)
  }
  selectorRevision.value += 1
}

const workflowList = ref([] as Array<Workflow>)
const WORKFLOW_DISPLAY_ORDER = [
  'vm-mariadb-backup-import-data-init',
  'vm-mariadb-data-init-cleanup',
  'k8s-mariadb-backup-import-data-init',
  'k8s-mariadb-data-init-cleanup',
  'multi-csp-vm-deploy',
  'multi-csp-vm-cleanup',
  'multi-csp-k8s-cluster-deploy',
  'multi-csp-k8s-cluster-cleanup',
  'vm-object-storage-data-lab-init',
  'vm-object-storage-data-lab-cleanup',
]
const workflowDisplayOrder = new Map(
  WORKFLOW_DISPLAY_ORDER.map((workflowName, index) => [workflowName, index])
)

const _getWorkflowList = async () => {
  const { data } = await getWorkflowList("N")
  workflowList.value = [...data].sort((left, right) => {
    const leftOrder = workflowDisplayOrder.get(left.workflowInfo.workflowName) ?? WORKFLOW_DISPLAY_ORDER.length
    const rightOrder = workflowDisplayOrder.get(right.workflowInfo.workflowName) ?? WORKFLOW_DISPLAY_ORDER.length

    return leftOrder - rightOrder
  })
}
const selectedWorkflow = computed(() => {
  return workflowList.value.find((workflow) => Number(workflow.workflowInfo.workflowIdx) === Number(eventListenerFormData.value.workflowIdx))
})
const selectedWorkflowName = computed(() => {
  return selectedWorkflow.value?.workflowInfo.workflowName || eventListenerFormData.value.workflowName || ''
})

/* Comment translated to English. */
const duplicatedEventListener = ref(false as boolean)
const checkedEventListenerName = ref('')
const originalEventListenerName = ref('')
const normalizeEventListenerName = (eventListenerName?: string) => (eventListenerName || '').trim()
const onChangeEventListenerName = () => {
  const currentEventListenerName = normalizeEventListenerName(eventListenerFormData.value.eventListenerName)
  duplicatedEventListener.value = Boolean(currentEventListenerName && currentEventListenerName === checkedEventListenerName.value)
}
const onClickDuplicatEventListenerName = async () => {
  const currentEventListenerName = normalizeEventListenerName(eventListenerFormData.value.eventListenerName)
  if (!currentEventListenerName) {
    toast.error('Please enter Event Listener name.')
    return
  }
  if (props.mode !== 'new' && currentEventListenerName === originalEventListenerName.value) {
    toast.success('Name is available.')
    duplicatedEventListener.value = true
    checkedEventListenerName.value = currentEventListenerName
    return
  }

  const { data } = await duplicateCheck(currentEventListenerName)
  if (!data) {
    toast.success('Name is available.')
    duplicatedEventListener.value = true
    checkedEventListenerName.value = currentEventListenerName
  }
  else {
    toast.error('Name is already in use.')
    duplicatedEventListener.value = false
  }
}


/* Comment translated to English. */
const onClickSubmit = async () => {
  // =========================== Validation ===========================
  if (!eventListenerFormData.value.eventListenerName) {
    toast.error('Please enter Event Listener name.');
    return;
  }

  if (!duplicatedEventListener.value || checkedEventListenerName.value !== normalizeEventListenerName(eventListenerFormData.value.eventListenerName)) {
    toast.error('Please perform duplicate check for the name.');
    return;
  }

  if (!eventListenerFormData.value.eventListenerDesc) {
    toast.error('Please enter Event Listener description.');
    return;
  }

  if (!eventListenerFormData.value.workflowIdx || eventListenerFormData.value.workflowIdx === 0) {
    toast.error('Please select a Workflow.');
    return;
  }

  let success = false;

  if (props.mode === 'new') {
    eventListenerFormData.value.workflowParams.forEach((eventListenerInfo) => {
      eventListenerInfo.paramIdx = 0
      eventListenerInfo.eventListenerYn = 'Y'
    })
    success = await _registEventListener();
  } else {
    success = await _updateEventListener();
  }
  
  // Comment translated to English.
  if (success) {
    emit('get-event-listener-list');
    setInit();
    
    // Comment translated to English.
    if (modalInstance.value) {
      modalInstance.value.hide()
      // Comment translated to English.
      setTimeout(() => {
        document.body.classList.remove('modal-open')
        const backdrop = document.querySelector('.modal-backdrop')
        backdrop?.remove()
      }, 150)
    }
  }
}

/* Comment translated to English. */
const _registEventListener = async (): Promise<boolean> => {
  try {
  const { data } = await registEventListener(eventListenerFormData.value)
  if (data) {
      toast.success('Registered successfully.')
      return true
    } else {
      toast.error('Failed to register.')
      return false
    }
  } catch (error) {
    toast.error('Failed to register.')
    return false
  }
}

/* Comment translated to English. */
const _updateEventListener = async (): Promise<boolean> => {
  try {
  const { data } = await updateEventListener(eventListenerFormData.value)
  if (data) {
      toast.success('Updated successfully.')
      return true
    } else {
      toast.error('Failed to update.')
      return false
    }
  } catch (error) {
    toast.error('Failed to update.')
    return false
  }
}
const onSelectWorkflow = (selectedWorkflowIdx:number) => {
  selectorReady.value = false
  const workflow = workflowList.value.find((item) => {
    return Number(item.workflowInfo.workflowIdx) === Number(selectedWorkflowIdx)
  })

  if (!workflow) {
    eventListenerFormData.value.workflowParams = []
    return
  }

  eventListenerFormData.value.workflowParams = cloneWorkflowParams(workflow.workflowParams)
  selectorRevision.value += 1
  selectorReady.value = true
}

const cloneWorkflowParams = (params: Array<WorkflowParams> = []) => {
  const namespace = (userInfo.projectInfo.ns_id || userInfo.projectInfo.name || '').trim()

  return params.map((param) => ({
    ...param,
    paramIdx: 0,
    paramValue: namespace && param.paramKey?.trim().toUpperCase() === 'NAMESPACE'
      ? namespace
      : param.paramValue,
    eventListenerYn: 'Y',
  }))
}

</script>
