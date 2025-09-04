<template>
  <div class="modal modal-blur fade" id="workflowStageForm" tabindex="-1" aria-hidden="true" ref="modalElement">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
      <div class="modal-content">

        <div class="modal-header">
          <h3 class="modal-title">{{ props.mode === 'new' ? 'New' : 'Edit'}} Workflow Stage</h3>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div class="modal-body py-4">
          <div>
                      <!-- Workflow Stage Type -->
            <div class="mb-3">
              <div style="display: flex; justify-content: start;">
                <label class="form-label required col"> Workflow Stage Type </label>
                <div v-if="props.mode === 'new'">
                  <input type="checkBox" @change="onChangeWorkflowStageTypeAdd">
                  <label class="ms-2">Add Workflow Type</label>
                </div>
              </div>
              <div class="grid gap-0 column-gap-3">
                  <select  v-if="!addWorkflowStageTypeFlag" v-model="workflowStageFormData.workflowStageTypeIdx" class="form-select p-2 g-col-12" @change="onClickedWorkflowStageType">
                    <option :value="0">Select Workflow Stage Type</option>
                    <option v-for="(type, idx) in workflowStageTypeList" :value="type.workflowStageTypeIdx" :key="idx">
                      {{ type.workflowStageTypeName }}
                    </option>
                  </select>
                  <input v-else type="text" class="form-control p-2 g-col-12" placeholder="Please enter the Workflow Stage type you want to add" v-model="workflowStageFormData.workflowStageTypeName" @focusout="_getWorkflowStageDefaultScript(workflowStageFormData.workflowStageTypeName)"/>
              </div>
            </div>

            <!-- Workflow Stage Name -->
            <div class="mb-3">
              <label class="form-label required">Workflow Stage Name</label>
              <div class="grid gap-0 column-gap-3">
                <input type="text" class="form-control p-2 g-col-11" placeholder="Enter the Workflow Stage Name" v-model="workflowStageFormData.workflowStageName" />
                <div class="col">
                  <button v-if="!duplicatedWorkflowStage" class="btn btn-primary chk" @click="onClickDuplicatWorkflowStageName">Duplicate Check</button> 
                  <button v-else class="btn btn-success" style="margin: 3px;">Duplicate Check</button>
                </div>
              </div>
            </div>
            
            <!-- Workflow Stage Description -->
            <div class="mb-3">
              <label class="form-label">Workflow Stage Description</label>
              <input type="text" class="form-control p-2 g-col-11" placeholder="Enter the Workflow Stage Description" v-model="workflowStageFormData.workflowStageDesc" />
            </div>

            <!-- Workflow Stage Contents -->
            <div class="mb-3">
              <label class="form-label required">Script</label>
              <textarea rows="10" class="form-control p-2 g-col-11" placeholder="Enter the Script" v-model="workflowStageFormData.workflowStageContent" />
            </div>

          </div>
        </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-link link-secondary" data-bs-dismiss="modal" @click="setInit()">
          Cancel
        </button>
        <button type="button" class="btn btn-primary ms-auto"  @click="onClickSubmit()">
          {{props.mode === 'new' ? 'Regist' : 'Edit'}}
        </button>
      </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// @ts-ignore
import type { WorkflowStage, WorkflowStageType } from '@/views/type/type';
import { ref } from 'vue';
import { useToast } from 'vue-toastification';
// @ts-ignore
import { getWorkflowStageTypeList, getWorkflowStageDetailInfo, duplicateCheck, registWorkflowStage, updateWorkflowStage, getWorkflowStageDefaultScript } from '@/api/workflowStage';
import { onMounted } from 'vue';
import { computed } from 'vue';
import { watch } from 'vue';
import { Modal } from 'bootstrap'

const toast = useToast()

/**
 * @Title Modal Management
 */
const modalElement = ref<HTMLElement>()
const modalInstance = ref<Modal>()

/**
 * @Title Props / Emit
 */
interface Props {
  mode: String,
  workflowStageIdx: number,
  workflowStageName: string
}
const props = defineProps<Props>()
const emit = defineEmits(['get-workflow-stage-list'])

/**
 * @Title Life Cycle
 * @Desc Call data set function according to workflowStageIdx value changes
 */
const workflowStageIdx = computed(() => props.workflowStageIdx);
const workflowStageName = computed(() => props.workflowStageName);

// 초기화 중 상태 플래그
const isInitializing = ref(false as boolean)

watch(workflowStageIdx, async () => {
  _getWorkflowStageTypeList()
  await setInit();
});

onMounted(async () => {
  // Initialize Modal instance
  if (modalElement.value) {
    modalInstance.value = new Modal(modalElement.value)
  }
  
  _getWorkflowStageTypeList()
  await setInit();
})

/**
 * @Title formData 
 * @Desc workflowStage creation / update data
 */
const workflowStageFormData = ref({} as WorkflowStage)

/**
 * @Title Initialization Method
 * @Desc 
 *    1. Initialize data in create mode / when workflowStageIdx changes
 *    2. Set duplicate check button activation status
 *    3. Initialize data when close / create / edit button is clicked
 */
const setInit = async () => {
  isInitializing.value = true
  if (props.mode === 'new') {
    workflowStageFormData.value.workflowStageIdx = 0
    workflowStageFormData.value.workflowStageTypeIdx = 0
    workflowStageFormData.value.workflowStageTypeName = ''
    workflowStageFormData.value.workflowStageName = ''
    workflowStageFormData.value.workflowStageDesc = ''
    workflowStageFormData.value.workflowStageContent = ''
    workflowStageFormData.value.workflowStageOrder = 0

    duplicatedWorkflowStage.value = false
    addWorkflowStageTypeFlag.value = false
    isInitializing.value = false
    console.log('isInitializing', isInitializing.value)
  }
  else {
    await getWorkflowStageDetailInfo(props.workflowStageIdx).then((res) => {
      workflowStageFormData.value = res.data
      duplicatedWorkflowStage.value = true
      isInitializing.value = false
    })
  }
}

/**
 * @Title workflowStageTypeList / _getWorkflowStageTypeList
 * @Desc 
 *    workflowStageTypeList : Store workflowStageType list
 *    _getWorkflowStageTypeList : Call workflowStageType list API
 */
const workflowStageTypeList = ref([] as Array<WorkflowStageType>)
const _getWorkflowStageTypeList = async () => {
  try {
    const { data } = await getWorkflowStageTypeList()
    workflowStageTypeList.value = data
  } catch (error) {
    console.log(error)
  }
}

/**
 * @Title addWorkflowStageTypeFlag / onChangeWorkflowStageTypeAdd
 * @Desc 
 *    addWorkflowStageTypeFlag : Workflow Stage type addition flag
 *    onChangeWorkflowStageTypeAdd : 
 *                      1. Action when 'add type' checkbox is clicked
 *                      2. Change flag value, initialize Workflow Stage Idx and Name
 */
const addWorkflowStageTypeFlag = ref(false as boolean)
const onChangeWorkflowStageTypeAdd = async() => {
  addWorkflowStageTypeFlag.value = !addWorkflowStageTypeFlag.value
  workflowStageFormData.value.workflowStageTypeIdx = 0
  workflowStageFormData.value.workflowStageTypeName = ''
}

/**
 * @Title onClickedWorkflowStageType
 * @Desc Action when workflow Stage Type Idx changes
 *                      1. Set workflow Stage Type Name
 *                      2. Set default script
 */
const onClickedWorkflowStageType = async() => {
  duplicatedWorkflowStage.value = false
  workflowStageTypeList.value.forEach((type) => {
    if (workflowStageFormData.value.workflowStageTypeIdx === type.workflowStageTypeIdx)
      workflowStageFormData.value.workflowStageTypeName = type.workflowStageTypeName
  })
  await _getWorkflowStageDefaultScript(workflowStageFormData.value.workflowStageTypeName)
} 


/**
 * @Title _getWorkflowStageDefaultScript
 * @param workflowStageTypeName : receives workflow Stage Type name as parameter
 * @Desc Call API to generate default script and store in workflowStageFormData.workflowStageContent
 */
const _getWorkflowStageDefaultScript = async (workflowStageTypeName:string) => {
  const { data } = await getWorkflowStageDefaultScript(workflowStageTypeName)
  workflowStageFormData.value.workflowStageContent = data[0].workflowStageContent
}

/**
 * @Title duplicatedWorkflowStage / onClickDuplicatWorkflowStageName
 * @Desc 
 *    duplicatedWorkflowStage : duplicate check status
 *    onClickDuplicatWorkflowStageName : call duplicate check API with workflow Stage name
 */
const duplicatedWorkflowStage = ref(false as boolean)
const onClickDuplicatWorkflowStageName = async () => {
  const param = {
    workflowStageName: workflowStageFormData.value.workflowStageName,
    workflowStageTypeName: workflowStageFormData.value.workflowStageTypeName,
  }
  const { data } = await duplicateCheck(param)
  if (!data) {
    toast.success('Name is available.')
    duplicatedWorkflowStage.value = true
  }
  else
    toast.error('Name is already in use.')
}

// 이름/타입 변경 시 중복체크 상태 초기화
watch(
  () => [
    workflowStageFormData.value.workflowStageName,
    workflowStageFormData.value.workflowStageTypeName
  ],
  () => {
    if (isInitializing.value) return
    if(workflowStageName.value === workflowStageFormData.value.workflowStageName) {
      duplicatedWorkflowStage.value = true
      return
    }
    duplicatedWorkflowStage.value = false
  }
)

/**
 * @Title onClickSubmit
 * @Desc 
 *     1. Action when create / edit button is clicked
 *     2. Call create/edit callback function according to mode value from parent, then call workflowStage list API to parent
 */
const onClickSubmit = async () => {
  // ================= Validation =================
  if (!addWorkflowStageTypeFlag.value && (!workflowStageFormData.value.workflowStageTypeIdx || workflowStageFormData.value.workflowStageTypeIdx === 0)) {
    toast.error('Please select Workflow Stage Type.');
    return;
  }
  if (addWorkflowStageTypeFlag.value && !workflowStageFormData.value.workflowStageTypeName) {
    toast.error('Please enter new Workflow Stage Type.');
    return;
  }
  if (!workflowStageFormData.value.workflowStageName) {
    toast.error('Please enter Workflow Stage Name.');
    return;
  }
  if (!duplicatedWorkflowStage.value) {
    toast.error('Please perform duplicate check.');
    return;
  }
  if (!workflowStageFormData.value.workflowStageContent) {
    toast.error('Please enter Script.');
    return;
  }

  let success = false;
  
  if (props.mode === 'new') {
    success = await _registWorkflowStage();
  } else {
    success = await _updateWorkflowStage();
  }
  
  // Close modal only when successfully processed
  if (success) {
    emit('get-workflow-stage-list');
    setInit();
    
    // Close modal
    if (modalInstance.value) {
      modalInstance.value.hide()
      // Force remove backdrop if it remains
      setTimeout(() => {
        document.body.classList.remove('modal-open')
        const backdrop = document.querySelector('.modal-backdrop')
        backdrop?.remove()
      }, 150)
    }
  }
}

/**
 * @Title _registWorkflowStage
 * @Desc Creation callback function / creation api call
 */
const _registWorkflowStage = async (): Promise<boolean> => {
  try {
  const { data } = await registWorkflowStage(workflowStageFormData.value)
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
 * @Title _updateWorkflowStage
 * @Desc Update callback function / update api call
 */
const _updateWorkflowStage = async (): Promise<boolean> => {
  try {
  const { data } = await updateWorkflowStage(workflowStageFormData.value)
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

</script>
