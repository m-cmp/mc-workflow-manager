<template>
  <div>
    <!-- Page header -->
    <div class="page-header">
      <div class="row align-items-center">
        <div class="col">
          <h2 class="page-title">{{ mode === 'new' ? 'New' : 'Detail' }} Workflow</h2>
        </div>
      </div>
    </div>

    <!-- Data card -->
    <div class="card card-flush w-100" ref="workflowForm">
      <div 
      class="card-body" 
      v-if="
            workflowInfoFormData &&
            workflowParamsFormData &&
            workflowStageMappingsFormData">
        <div class="card-title">
          <!-- Workflow Name -->
          <div class="mb-3">
            <label class="form-label required">
              Workflow Name
            </label>
            <div class="grid gap-0 column-gap-3">
              <input type="text" ref="workflowName" class="form-control p-2 g-col-11" placeholder="Enter the workflow name" v-model="workflowInfoFormData.workflowName" />
              <button
                  v-if="!duplicatedWorkflow"
                  class="btn btn-primary chk"
                  @click="onClickDuplicatWorkflowName(workflowInfoFormData.workflowName)"
                  style="margin:3px; width: 150px;"
                >Duplicate Check</button>
                <button
                  v-else
                  class="btn btn-success"
                  style="margin:3px; width: 150px;"
                >Duplicate Check</button>
            </div>
          </div>

          <!-- Purpose -->
          <div class="mb-3">
            <label class="form-label required">Purpose</label>
            <div class="grid gap-0 column-gap-3">
              <select ref="workflowPurpose" v-model="workflowInfoFormData.workflowPurpose" class="form-select p-2 g-col-12">
                <option value="">Select Workflow Purpose.</option>
                <option v-for="(purpose, idx) in workflowPurposeList" :value="purpose.value" :key="idx">
                  {{ purpose.name }}
                </option>
              </select>
            </div>
          </div>

          <!-- OSS URL -->
          <!-- <div class="mb-3">
            <label class="form-label required">OSS URL</label>
            <div class="grid gap-0 column-gap-3">
              <input type="text" class="form-control p-2 g-col-12" placeholder="Enter the OSS URL" :value="ossUrl" disabled/>
            </div>
          </div> -->
          <!-- Pipeline -->
          <PipelineGenerator
            :mode="mode"
            :workflow-stage-mappings-form-data="workflowStageMappingsFormData"
            @init-workflow-stage-mappings="initWorkflowStageMappings"
            @on-click-create-script="onClickCreateScript"
            @splice-workflow-stage-mappings-form-data="spliceWorkflowStageMappingsFormData"
          />

          <!-- Parameters -->
          <ParamForm 
            :popup="false"
            :workflow-param-data="workflowParamsFormData"
            event-listener-yn="N"
          />

          <WorkflowHistoryList
            :workflow-idx="workflowInfoFormData.workflowIdx"
            :workflow-name="workflowInfoFormData.workflowName"
          />
            
          <div class="row align-items-center">
            <div id="gap" class="col" />
            <div class="col-auto ms-auto">
              <div class="btn-list">
                <button class="btn btn-primary" @click="onClickSubmit">
                  {{ mode === 'new' ? 'Regist' : 'Edit' }}
                </button>
                <!-- <button v-show="mode === 'edit'" class="btn btn-info" @click="onClickRun">
                  Run
                </button> -->
                <button class="btn btn-secondary" @click="onClickGoBack">
                  Go Back
                </button>
                <button class="btn btn-right border" @click="onClickList">
                  To List
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref } from 'vue';
import { onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
// @ts-ignore
import { getOssList } from '@/api/oss'
// @ts-ignore
import type { Workflow, WorkflowPurpose, Oss, WorkflowInfo, WorkflowParams, WorkflowStageMappings } from '@/views/type/type'
// @ts-ignore
import PipelineGenerator from '@/views/workflow/components/PipelineGenerator.vue';
// @ts-ignore
import { duplicateCheck, getWorkflowDetailInfo, registWorkflow, updateWorkflow, getTemplateStage } from '@/api/workflow'
import { useToast } from 'vue-toastification';
// @ts-ignore
import ParamForm from './components/ParamForm.vue';
// @ts-ignore
import WorkflowHistoryList from '@/views/workflow/components/WorkflowHistoryList.vue';
import { reactive } from 'vue';
// @ts-ignore
import _ from 'lodash';
import { watch } from 'vue';

const toast = useToast()
const route = useRoute();
const router = useRouter();

onMounted(() => {
  setMode()
  setWorkflowFormData()
  setOssInfo()
  setWorkflowPurposeList()
})

// ================================================================================= Set mode
const mode = ref('new' as string)
const setMode = () => {
  mode.value = route.params.workflowIdx === undefined ? 'new' : 'detail'
}

// ================================================================================= Set create / edit data
// workflowInfo data
let workflowInfoFormData = reactive({} as WorkflowInfo)
const workflowParamsFormData = ref([] as Array<WorkflowParams>)
const workflowStageMappingsFormData = ref([] as Array<WorkflowStageMappings>)

const defaultWorkflowInfoFormData = {
    workflowIdx: 0,
    workflowName: '',
    workflowPurpose: '',
    ossIdx: 0,
    script: '',
}
const defaultWorkflowParamsFormData = [
    {
      paramKey: '',
      paramValue: '',
      eventListenerYn: 'N'
    }
  ]

const setWorkflowFormData = async () => {
  if (mode.value === 'new') {
    workflowInfoFormData = { ...defaultWorkflowInfoFormData }
    workflowParamsFormData.value = [ ...defaultWorkflowParamsFormData ]
    workflowStageMappingsFormData.value = []
  }
  else {
    const { data } = await getWorkflowDetailInfo(route.params.workflowIdx, 'N')
    workflowInfoFormData = { ...data.workflowInfo }
    workflowParamsFormData.value = [ ...data.workflowParams ]
    workflowStageMappingsFormData.value = [ ...data.workflowStageMappings ]

    workflowInfoFormData = { ...workflowInfoFormData, workflowIdx: route.params.workflowIdx }
    duplicatedWorkflow.value = true
  }
}


// ================================================================================= Duplicate check
const duplicatedWorkflow = ref(false as boolean)
const onClickDuplicatWorkflowName = async (workflowName: string) => {
  const { data } = await duplicateCheck(workflowName)
  if (!data) {
    toast.success('Name is available.')
    duplicatedWorkflow.value = true
  }
  else
    toast.error('Name is already in use.')
}

// ================================================================================= Purpose list

const workflowPurposeList = ref([] as Array<WorkflowPurpose>)
const setWorkflowPurposeList = () => {
  workflowPurposeList.value = [
    {
      name: "For Deployment",
      value: "deploy"
    },
    {
      name: "For Execution",
      value: "run"
    },
      {
      name: "For Testing",
      value: "test"
    },
      {
      name: "For Webhook",
      value: "webhook"
    },
  ]
}

// ================================================================================= OSS URL
const ossUrl = ref('')
const setOssInfo = async () => {
  try {
    const { data } = await getOssList('JENKINS')

    if (data) {
      if (workflowInfoFormData) {
        // Create
        if (mode.value === 'new') {
          workflowInfoFormData.ossIdx = data ? data[0].ossIdx : 'No OSS information'
          ossUrl.value = data ? data[0].ossUrl : 'NULL'  
        }

        // Edit
        else {
          data.forEach((oss: Oss) => {
              if (oss.ossIdx === workflowInfoFormData.ossIdx) {
                ossUrl.value = oss.ossUrl
              }
          }) 
        }
      }
    }
  } catch (error) {
    console.log(error)
  }
}

// ================================================================================= Registration Action
const onClickSubmit = async () => {
  // ================= Validation =================
  if (!workflowInfoFormData.workflowName) {
    toast.error('Please enter Workflow Name.');
    return;
  }
  if (!workflowInfoFormData.workflowPurpose) {
    toast.error('Please select Purpose.');
    return;
  }
  if (!workflowStageMappingsFormData.value || workflowStageMappingsFormData.value.length === 0) {
    toast.error('Please create Pipeline script.');
    return;
  }
  setSubmitParam()
  if(mode.value === 'new')
    await _registWorkflow()
  else 
    await _updateWorkflow()
}
const _registWorkflow = async () => {
  const param = {
    workflowInfo: { ...workflowInfoFormData },
    workflowParams: [ ...workflowParamsFormData.value ],
    workflowStageMappings: [ ...workflowStageMappingsFormData.value ]
  }
  const { data } = await registWorkflow(param)
  if (data) {
    toast.success('Registered successfully.')
    router.push('/web/workflow/list')
  }
  else {
    toast.error('Failed to register.')
  }
}

const _updateWorkflow = async () => {
  const param = {
    workflowInfo: { ...workflowInfoFormData },
    workflowParams: [ ...workflowParamsFormData.value ],
    workflowStageMappings: [ ...workflowStageMappingsFormData.value ]
  }

  const { data } = await updateWorkflow(param)

  if (data) {
    toast.success('Updated successfully.')
    router.push('/web/workflow/list')
  }
  else {
    toast.error('Failed to update.')
  }
}
const setSubmitParam = () => {
  setWorkflowInfoScript()
  setRemoveWorkflowParamIdx()
  if (mode.value == 'new') {
    setRemoveWorkflowIdx()
  }
}

const setWorkflowInfoScript = () => {
  let str:string = ''
  workflowStageMappingsFormData.value.forEach((item) => {
    str += item.stageContent

    if (!item.isDefaultScript) 
      str += '\n'
  })

  workflowInfoFormData = {...workflowInfoFormData, script: str}
}

const setRemoveWorkflowIdx = () => {
  delete workflowInfoFormData.workflowIdx
}

const setRemoveWorkflowParamIdx = () => {
  workflowParamsFormData.value.forEach((param) => {
    delete param['paramIdx']
  })
}
// ================================================================================= Run Action
const onClickRun = () => {
  toast.success('Executed!')
}

// ================================================================================= Go to list
const onClickList = () => {
  router.push('/web/workflow/list')
}

// ================================================================================= Go back
const onClickGoBack = () => {
  router.push('/web/workflow/list')
}

// ================================================================================= PipelineGenerator
const initWorkflowStageMappings = () => {
  workflowStageMappingsFormData.value = []
}

// Template stage list
const onClickCreateScript = async () => {

  if (workflowInfoFormData.workflowName === '') {
    toast.error('Please enter workflow name.')
    return
  }

  else if (!workflowInfoFormData.workflowPurpose) {
    toast.error('Please select purpose.')
    return
  }
  await _getTemplateStage(workflowInfoFormData.workflowName);
}

// Variable for marking default script start / end
const defaultScriptTagFlags = ["DEFAULT_START", "DEFAULT_END"]
// Generate default script after validation when 'Create Script' is clicked
const _getTemplateStage = async (workflowName:string) => {
  try {
    initWorkflowStageMappings()

    const { data } = await getTemplateStage(workflowName)
    const list:Array<WorkflowStageMappings> = data || []

    // Default script flag
    // Data to be included when creating variables to mark script start and end
    list.forEach((item:WorkflowStageMappings, index:number) => {
      item.isDefaultScript = true;
      item.defaultScriptTag = defaultScriptTagFlags[index];
    })
    
    workflowStageMappingsFormData.value = [...list]
  } catch (error) {
    workflowStageMappingsFormData.value = [];
    toast.error(String(error));
  }
}

const spliceWorkflowStageMappingsFormData = (transClone: WorkflowStageMappings) => {
  workflowStageMappingsFormData.value.splice(workflowStageMappingsFormData.value.length - 1, 0, transClone);
}
</script>