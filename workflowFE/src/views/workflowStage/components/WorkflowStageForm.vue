<template>
  <div class="modal" id="workflowStageForm" tabindex="-1">
    <div class="modal-dialog modal-lg" role="document">
      <div class="modal-content">

        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        <div class="modal-body text-left py-4">
          <!-- Workflow Stage Title -->
          <h3 class="mb-5">
            Workflow Stage {{ props.mode === 'new' ? '생성' : '수정'}}
          </h3>

          <div>
          <!-- Workflow Stage 타입 -->
            <div class="mb-3">
              <div style="display: flex; justify-content: start;">
                <label class="form-label required col"> Workflow Stage 타입 </label>
                <div v-if="props.mode === 'new'">
                  <input type="checkBox" @change="onChangeWorkflowStageTypeAdd">
                  <label>타입 추가</label>
                </div>
              </div>
              <div class="grid gap-0 column-gap-3">
                  <select  v-if="!addWorkflowStageTypeFlag" v-model="workflowStageFormData.workflowStageTypeIdx" class="form-select p-2 g-col-12" @change="onClickedWorkflowStageType">
                    <option :value="0">Workflow Stage 타입을 선택하세요.</option>
                    <option v-for="(type, idx) in workflowStageTypeList" :value="type.workflowStageTypeIdx" :key="idx">
                      {{ type.workflowStageTypeName }}
                    </option>
                  </select>
                  <input v-else type="text" class="form-control p-2 g-col-12" placeholder="추가하실 Workflow Stage 타입을 입력하세요" v-model="workflowStageFormData.workflowStageTypeName" @focusout="_getWorkflowStageDefaultScript(workflowStageFormData.workflowStageTypeName)"/>
              </div>
            </div>

            <!-- Workflow Stage 명 -->
            <div class="mb-3">
              <label class="form-label required">Workflow Stage 명</label>
              <div class="grid gap-0 column-gap-3">
                <input type="text" class="form-control p-2 g-col-11" placeholder="Workflow Stage 명을 입력하세요" v-model="workflowStageFormData.workflowStageName" />
                <div class="col">
                  <button v-if="!duplicatedWorkflowStage" class="btn btn-primary chk" @click="onClickDuplicatWorkflowStageName">중복 체크</button>
                  <button v-else class="btn btn-success" style="margin: 3px;">중복 체크</button>
                </div>
              </div>
            </div>
            
            <!-- Workflow Stage 설명 -->
            <div class="mb-3">
              <label class="form-label required">Workflow Stage 설명</label>
              <input type="text" class="form-control p-2 g-col-11" placeholder="Workflow Stage 설명을 입력하세요" v-model="workflowStageFormData.workflowStageDesc" />
            </div>

            <!-- Workflow Stage Contents -->
            <div class="mb-3">
              <label class="form-label required">Script</label>
              <textarea rows="10" class="form-control p-2 g-col-11" placeholder="스크립트 입력하세요" v-model="workflowStageFormData.workflowStageContent" />
            </div>

          </div>
        </div>

      <div class="modal-footer">
        <a href="#" class="btn btn-link link-secondary" data-bs-dismiss="modal" @click="setInit()">
          Cancel
        </a>
        <a href="#" class="btn btn-primary ms-auto" data-bs-dismiss="modal"  @click="onClickSubmit()">
          {{props.mode === 'new' ? '생성' : '수정'}}
        </a>
      </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { WorkflowStage, WorkflowStageType } from '@/views/type/type';
import { ref } from 'vue';
import { useToast } from 'vue-toastification';
import { getWorkflowStageTypeList, getWorkflowStageDetailInfo, duplicateCheck, registWorkflowStage, updateWorkflowStage, getWorkflowStageDefaultScript } from '@/api/workflowStage';
import { onMounted } from 'vue';
import { computed } from 'vue';
import { watch } from 'vue';

const toast = useToast()
/**
 * @Title Props / Emit
 */
interface Props {
  mode: String,
  workflowStageIdx: number
}
const props = defineProps<Props>()
const emit = defineEmits(['get-workflow-stage-list'])

/**
 * @Title Life Cycle
 * @Desc workflowStageIdx 값의 변화에 따라 데이터 set함수 호출  
 */
const workflowStageIdx = computed(() => props.workflowStageIdx);
watch(workflowStageIdx, async () => {
  _getWorkflowStageTypeList()
  await setInit();
});

onMounted(async () => {
  _getWorkflowStageTypeList()
  await setInit();
})

/**
 * @Title formData 
 * @Desc workflowStage 생성 / 수정데이터
 */
const workflowStageFormData = ref({} as WorkflowStage)

/**
 * @Title 초기화 Method
 * @Desc 
 *    1. 생성 모드일경우 / workflowStageIdx 가 달라질경우 데이터 초기화
 *    2. 중복검사 버튼 활성화 여부 set
 *    3. 닫기 / 생성 / 수정 버튼 클릭시 데이터 초기화
 */
const setInit = async () => {
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
  }
  else {
    const { data } = await getWorkflowStageDetailInfo(props.workflowStageIdx)
    workflowStageFormData.value = data
    duplicatedWorkflowStage.value = true
  }
}

/**
 * @Title workflowStageTypeList / _getWorkflowStageTypeList
 * @Desc 
 *    workflowStageTypeList : workflowStageType 목록 저장
 *    _getWorkflowStageTypeList : workflowStageType 목록 API 호출
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
 *    addWorkflowStageTypeFlag : Workflow Stage 타입 추가 Flag 
 *    onChangeWorkflowStageTypeAdd : 
 *                      1. '타입 추가' 체크박스 클릭시 동작
 *                      2. 플래그 값 변경, Workflow Stage Idx, Name 초기화
 */
const addWorkflowStageTypeFlag = ref(false as boolean)
const onChangeWorkflowStageTypeAdd = async() => {
  addWorkflowStageTypeFlag.value = !addWorkflowStageTypeFlag.value
  workflowStageFormData.value.workflowStageTypeIdx = 0
  workflowStageFormData.value.workflowStageTypeName = ''
}

/**
 * @Title onClickedWorkflowStageType
 * @Desc workflow Stage Type Idx 변경시 동작 
 *                      1. workflow Stage Type Name Set
 *                      2. 기본 스크립트 Set
 */
const onClickedWorkflowStageType = async() => {
  workflowStageTypeList.value.forEach((type) => {
    if (workflowStageFormData.value.workflowStageTypeIdx === type.workflowStageTypeIdx)
      workflowStageFormData.value.workflowStageTypeName = type.workflowStageTypeName
  })
  await _getWorkflowStageDefaultScript(workflowStageFormData.value.workflowStageTypeName)
} 

/**
 * @Title _getWorkflowStageDefaultScript
 * @param workflowStageTypeName : workflow Stage Type 명을 인자값으로 받는다
 * @Desc 기본 스크립트를 생성하는 API 호출 후 workflowStageFormData.workflowStageContent에 저장
 */
const _getWorkflowStageDefaultScript = async (workflowStageTypeName:string) => {
  const { data } = await getWorkflowStageDefaultScript(workflowStageTypeName)
  workflowStageFormData.value.workflowStageContent = data[0].workflowStageContent
}

/**
 * @Title duplicatedWorkflowStage / onClickDuplicatWorkflowStageName
 * @Desc 
 *    duplicatedWorkflowStage : 중복검사 여부
 *    onClickDuplicatWorkflowStageName : workflow Stage명 로 중복검사 API 호출
 */
const duplicatedWorkflowStage = ref(false as boolean)
const onClickDuplicatWorkflowStageName = async () => {
  const param = {
    workflowStageName: workflowStageFormData.value.workflowStageName,
    workflowStageTypeName: workflowStageFormData.value.workflowStageTypeName,
  }
  const { data } = await duplicateCheck(param)
  if (!data) {
    toast.success('사용 가능한 이름입니다.')
    duplicatedWorkflowStage.value = true
  }
  else
    toast.error('이미 사용중인 이름입니다.')
}

/**
 * @Title onClickSubmit
 * @Desc 
 *     1. 생성 / 수정 버튼 클릭시 동작
 *     2. 부모로 부터 받은 mode값에 따라서 생성/수정 Callback 함수 호출후 부모에게 workflowStage목록 api 호출  
 */
const onClickSubmit = async () => {
  if (props.mode === 'new')
    await _registWorkflowStage().then(() => {
    emit('get-workflow-stage-list')
  })
  else
    await _updateWorkflowStage().then(() => {
    emit('get-workflow-stage-list')
  })
  setInit()
}

/**
 * @Title _registWorkflowStage
 * @Desc 생성 Callback 함수 / 생성 api 호출
 */
const _registWorkflowStage = async () => {
  const { data } = await registWorkflowStage(workflowStageFormData.value)
  if (data)
    toast.success('등록되었습니다.')
  else
    toast.error('등록 할 수 없습니다.')
}

/**
 * @Title _updateWorkflowStage
 * @Desc 수정 Callback 함수 / 수정 api 호출
 */
const _updateWorkflowStage = async () => {
  const { data } = await updateWorkflowStage(workflowStageFormData.value)
  if (data)
    toast.success('수정되었습니다.')
  else
    toast.error('수정 할 수 없습니다.')
}

</script>
