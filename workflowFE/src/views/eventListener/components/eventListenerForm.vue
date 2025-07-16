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
            <!-- Event Listener 명 -->
            <div class="row mb-3">
              <label class="form-label required">Event Listener Name</label>
              <div class="grid gap-0 column-gap-3">
                <input type="text" class="form-control p-2 g-col-11" placeholder="Enter Event Listener Name" v-model="eventListenerFormData.eventListenerName" @focus="onfocusEventListenerName"/>

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
import type { EventListener, Workflow } from '@/views/type/type';
import { ref } from 'vue';
import { useToast } from 'vue-toastification';
// @ts-ignore
import { duplicateCheck, getEventListenerDetailInfo, registEventListener, updateEventListener } from '@/api/eventListener';
// @ts-ignore
import { getWorkflowList } from '@/api/workflow';
import { onMounted } from 'vue';
import { computed } from 'vue';
import { watch } from 'vue';
// @ts-ignore
import ParamForm from '@/views/workflow/components/ParamForm.vue';
import { Modal } from 'bootstrap'

const toast = useToast()

/**
 * @Title Modal 관리
 */
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

/**
 * @Title Life Cycle
 * @Desc eventListenerIdx 값의 변화에 따라 데이터 set함수 호출  
 */
const eventListenerIdx = computed(() => props.eventListenerIdx);
watch(eventListenerIdx, async () => {
  await setInit()
  await _getWorkflowList()
});
onMounted(async () => {
  // Modal 인스턴스 초기화
  if (modalElement.value) {
    modalInstance.value = new Modal(modalElement.value)
  }
  
  await setInit()
  await _getWorkflowList()
})

/**
 * @Title formData 
 * @Desc Event Listener 생성 / 수정데이터
 */
const eventListenerFormData = ref({} as EventListener)
const setParamFlag = ref(false as Boolean)

/**
 * @Title 초기화 Method
 * @Desc 
 *    1. 생성 모드일경우 / eventListenerIdx 가 달라질경우 데이터 초기화
 *    2. 중복검사 / 연결 확인 버튼 활성화 여부 set
 *    3. 닫기 / 생성 / 수정 버튼 클릭시 데이터 초기화
 */
const setInit = async () => {
  if (props.mode === 'new') {
    eventListenerFormData.value.eventListenerName = ''
    eventListenerFormData.value.eventListenerDesc = ''
    eventListenerFormData.value.workflowIdx = 0
    eventListenerFormData.value.workflowParams = []

    duplicatedEventListener.value = false
    setParamFlag.value = true
  }
  else {
    const { data } = await getEventListenerDetailInfo(props.eventListenerIdx)
    eventListenerFormData.value = data

    duplicatedEventListener.value = true
    setParamFlag.value = true
  }
}

const workflowList = ref([] as Array<Workflow>)
const _getWorkflowList = async () => {
  const { data } = await getWorkflowList("N")
  workflowList.value = data;
}

/**
 * @Title duplicatedEventListener / onClickDuplicatEventListenerName
 * @Desc 
 *    duplicatedEventListener : 중복검사 여부
 *    onClickDuplicatEventListenerName : Event Listener 명으로 중복검사 API 호출
 */
const duplicatedEventListener = ref(false as boolean)
const onClickDuplicatEventListenerName = async () => {
  const { data } = await duplicateCheck(eventListenerFormData.value.eventListenerName)
  if (!data) {
    toast.success('Name is available.')
    duplicatedEventListener.value = true
  }
  else
    toast.error('Name is already in use.')
}


/**
 * @Title onClickSubmit
 * @Desc 
 *     1. 생성 / 수정 버튼 클릭시 동작
 *     2. 부모로 부터 받은 mode값에 따라서 생성/수정 Callback 함수 호출후 부모에게 Event Listener목록 api 호출  
 */
const onClickSubmit = async () => {
  // =========================== Validation ===========================
  if (!eventListenerFormData.value.eventListenerName) {
    toast.error('Please enter Event Listener name.');
    return;
  }

  if (!duplicatedEventListener.value) {
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
  
  // 성공적으로 처리된 경우에만 모달 닫기
  if (success) {
    emit('get-event-listener-list');
    setInit();
    
    // 모달 닫기
    if (modalInstance.value) {
      modalInstance.value.hide()
      // 백드롭이 남아있을 경우 강제 제거
      setTimeout(() => {
        document.body.classList.remove('modal-open')
        const backdrop = document.querySelector('.modal-backdrop')
        backdrop?.remove()
      }, 150)
    }
  }
}

/**
 * @Title _registEventListener
 * @Desc 생성 Callback 함수 / 생성 api 호출
 */
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

/**
 * @Title _updateEventListener
 * @Desc 수정 Callback 함수 / 수정 api 호출
 */
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





const onfocusEventListenerName = () => {
  duplicatedEventListener.value = false
}

const onSelectWorkflow = (selectedWorkflowIdx:number) => {
  workflowList.value.forEach((workflow) => {
    if (workflow.workflowInfo.workflowIdx === selectedWorkflowIdx) {
      eventListenerFormData.value.workflowParams = workflow.workflowParams
    }
  })
}

</script>