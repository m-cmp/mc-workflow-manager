<template>
  <div class="card w-100" ref="workflowForm">
    <div class="card-header">
      <div class="card-title">
        <h1>{{ mode === "new" ? "New" : "Detail" }} Workflow</h1>
      </div>
    </div>
    <div 
      class="card-body" 
      v-if="
            workflowInfoFormData &&
            workflowParamsFormData &&
            workflowStageMappingsFormData">
      <div class="card-title">
        <!-- 워크플로우 명 -->
        <div class="mb-3">
          <label class="form-label required">
            Workflow Name
          </label>
          <div class="grid gap-0 column-gap-3">
            <input type="text" ref="workflowName" class="form-control p-2 g-col-11" placeholder="Enter the workflow name" v-model="workflowInfoFormData.workflowName" />
            <button v-if="!duplicatedWorkflow" class="btn btn-primary" @click="onClickDuplicatWorkflowName(workflowInfoFormData.workflowName)">Duplicate Check</button>
            <button v-else class="btn btn-success">Duplicate Check</button>
          </div>
        </div>

        <!-- 목적 -->
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
        <!-- 파이프 라인 -->
        <PipelineGenerator
          :mode="mode"
          :workflow-stage-mappings-form-data="workflowStageMappingsFormData"
          @init-workflow-stage-mappings="initWorkflowStageMappings"
          @on-click-create-script="onClickCreateScript"
          @splice-workflow-stage-mappings-form-data="spliceWorkflowStageMappingsFormData"
        />

        <!-- 파라미터 -->
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
                실행
              </button> -->
              <button class="btn btn-right border" @click="onClickList">
                To List
              </button>
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
import { getOssList } from '@/api/oss'
import type { Workflow, WorkflowPurpose, Oss, WorkflowInfo, WorkflowParams, WorkflowStageMappings } from '@/views/type/type'
import PipelineGenerator from '@/views/workflow/components/PipelineGenerator.vue';
import { duplicateCheck, getWorkflowDetailInfo, registWorkflow, updateWorkflow, getTemplateStage } from '@/api/workflow'
import { useToast } from 'vue-toastification';
import ParamForm from './components/ParamForm.vue';
import WorkflowHistoryList from '@/views/workflow/components/WorkflowHistoryList.vue';
import { reactive } from 'vue';
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

// ================================================================================= 모드 set
const mode = ref('new' as string)
const setMode = () => {
  mode.value = route.params.workflowIdx === undefined ? 'new' : 'detail'
}

// ================================================================================= 생성 / 수정 데이터 set
// workflowInfo 데이터 ()
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


// ================================================================================= 중복체크
const duplicatedWorkflow = ref(false as boolean)
const onClickDuplicatWorkflowName = async (workflowName: string) => {
  const { data } = await duplicateCheck(workflowName)
  if (!data) {
    toast.success('사용 가능한 이름입니다.')
    duplicatedWorkflow.value = true
  }
  else
    toast.error('이미 사용중인 이름입니다.')
}

// ================================================================================= 목적 목록

const workflowPurposeList = ref([] as Array<WorkflowPurpose>)
const setWorkflowPurposeList = () => {
  workflowPurposeList.value = [
    {
      name: "배포용",
      value: "deploy"
    },
    {
      name: "실행용",
      value: "run"
    },
      {
      name: "테스트용",
      value: "test"
    },
      {
      name: "웹훅용",
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
        // 등록
        if (mode.value === 'new') {
          workflowInfoFormData.ossIdx = data ? data[0].ossIdx : 'OSS 정보가 없습니다.'
          ossUrl.value = data ? data[0].ossUrl : 'NULL'  
        }

        // 수정
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

// ================================================================================= 등록 Action
const onClickSubmit = async () => {
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
    toast.success('등록 되었습니다.')
    router.push('/web/workflow/list')
  }
  else {
    toast.error('등록하지 못했습니다.')
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
    toast.success('수정 되었습니다.')
    router.push('/web/workflow/list')
  }
  else {
    toast.error('수정하지 못했습니다.')
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
// ================================================================================= 실행 Action
const onClickRun = () => {
  toast.success('실행!')
}

// ================================================================================= 목록으로 이동
const onClickList = () => {
  router.push('/web/workflow/list')
}

// ================================================================================= PipelineGenerator
const initWorkflowStageMappings = () => {
  workflowStageMappingsFormData.value = []
}

// Template 스테이지 목록
const onClickCreateScript = async () => {

  if (workflowInfoFormData.workflowName === '') {
    toast.error('워크플로우 명을 입력해주세요.')
    return
  }

  else if (!workflowInfoFormData.workflowPurpose) {
    toast.error('목적을 선택해주세요.')
    return
  }
  await _getTemplateStage(workflowInfoFormData.workflowName);
}

// 기본 스크립트 시작 / 끝 표시를 위한 변수
const defaultScriptTagFlags = ["DEFAULT_START", "DEFAULT_END"]
// '스크립트 생성' 클릭시 validation 이 끝나고 기본 스크립트 생성
const _getTemplateStage = async (workflowName:string) => {
  try {
    initWorkflowStageMappings()

    const { data } = await getTemplateStage(workflowName)
    const list:Array<WorkflowStageMappings> = data || []

    // 기초 스크립트 Flag
    // 스크립트 시작과 끝 표시를 위한 변수를 생성해줄때 넣어줄 데이터
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