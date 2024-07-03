<template>
  <div>
    <!-- Jenkins 주소 -->
    <el-row type="flex">
      <el-form-item inline-message="true" prop="jenkinsId" class="flex-1">
        <span slot="label" class="field-label required">
          {{ $t("project.workflow.jenkins") }}
        </span>

        <div class="duplicate-name-wrapper">
          <el-select class="w-100" v-model="props.workflow.jenkinsId"
            :placeholder='$t("project.workflow.selectJenkins")' @change="onValidateSelect('jenkinsId')"
            @blur="onValidateSelect('jenkinsId')">
            <el-option :label='$t("project.workflow.selectJenkins")' value="" />
            <el-option v-for="(item, index) in jenkinsList" :key="index" :label="item.ossName + '(' + item.ossUrl + ')'"
              :value="item.ossId" />
          </el-select>
        </div>
      </el-form-item>
    </el-row>

    <!-- 파이프라인 타이틀 / 스크립트 생성 Btn -->
    <div class="hr">
      <el-row class="group docker-build row mb-5 space-between">
        <strong class="field-group-title col-10 required">
          {{ $t("project.workflow.jenkinsPipeline") }}
        </strong>
        <el-button class="mw-150px" type="primary" @click="onClickCreateScript()">
          {{ $t("project.workflow.createScript") }}
        </el-button>
      </el-row>
    </div>

    <!-- 파이프라인 -->
    <el-row type="flex">
      <div class="container">
        <div class="row">
          <div class="col-9">
            <el-form-item class="flex-1" inline-message="true" prop="pipelines">
              <div v-if="props.workflow.pipelines">
                <draggable :list="props.workflow.pipelines" :group="{
                    name: 'pipelineEidtor',
                    pull: false,
                    put: true
                  }" :move="onCheckDraggableEditor" @start="onStartDrag" @end="onFinishDrag">

                  <div v-for="(item, idx) in props.workflow.pipelines" :key="idx">
                    <div class="row" :class="{ 'draggable': !item.isDefaultScript }">
                      <span slot="label" class="field-label col-10">
                        {{ item.pipelineCd ? item.pipelineCd : "&nbsp" }}
                      </span>
                      <span class="col-2">
                        <el-button v-if="!item.isDefaultScript" class="btn btn-danger btn-sm"
                          @click="onDeletePipeline(idx)">delete</el-button>
                      </span>
                      <v-ace-editor v-model:value="(props.workflow.pipelines[idx]).pipelineScript" :id="item.pipelineCd"
                        :options="{
                          readOnly: dragFlag,
                          maxLines: 9999,
                          minLines: 10,
                          selectionStyle: 'text',
                          highlightActiveLine: false,
                          cursorStyle: 'smooth',
                          hasCssTransforms: true
                        }" />
                    </div>
                  </div>
                </draggable>
              </div>
              <div v-else>
                {{ $t('project.workflow.msgCreateScript') }}
              </div>
            </el-form-item>
          </div>
          <div class="col-3 mt-1">
            <el-collapse v-model="activeName" accordion>
              <el-collapse-item v-for="(pipeList, pipelineCd) in pipelineScriptList" :name="pipelineCd"
                :key="pipelineCd">
                <template #title>
                  <span class="paletteTitle">
                    {{ pipelineCd }}
                  </span>
                </template>
                <div>
                  <component :is="components.draggable" :list="pipeList"
                    :group="{ name: 'pipelineEidtor', pull: 'clone', put: false }" :move="onCheckDraggablePalette"
                    :clone="onClonePipeline" @start="onStartDrag" @end="onFinishDrag">
                    <div v-for="(item, index) in pipeList" :key="index" class="paletteItem"
                      @click="onClickPaletteItem(item)">
                      {{ item ? item.pipelineName : '등록된 스테이지가 없습니다.' }}
                    </div>
                  </component>
                </div>
              </el-collapse-item>
            </el-collapse>
          </div>
        </div>
      </div>
    </el-row>

    <el-row type="flex"> 
      <div v-for="(param, index) in props.workflow.pipelineParam" class="space-between w-100">
        <!-- key -->
        <el-form-item inline-message="true" prop="" class="flex-1">
          <span v-if="!index" slot="label" class="field-label">
            key
          </span>

          <div class="w-90">
            <el-input 
              v-model="param.paramKey" 
              :placeholder="'파라미터 Key 입력'" 
              :disabled="props.mode === 'edit'"
            />
          </div>
        </el-form-item>

        <!-- value -->
        <el-form-item inline-message="true" prop="" class="flex-1">
          <span v-if="!index" slot="label" class="field-label">
            value
          </span>

          <div class="w-90">
            <el-input 
              v-model="param.paramValue" 
              :placeholder="'파라미터 Value 입력'" 
              :disabled="props.mode === 'edit'"
            />
          </div>
        </el-form-item>

        <!-- desc -->
        <el-form-item inline-message="true" prop="" class="flex-1">
          <span v-if="!index" slot="label" class="field-label">
            Desc
          </span>

          <div class="w-90">
            <el-input 
              v-model="param.paramDesc" 
              :placeholder="'파라미터 설명 입력'" 
              :disabled="props.mode === 'edit'"
            />
          </div>
        </el-form-item>

        <!-- Btn -->
        <el-form-item class="btn-align">
          <el-button 
            v-if="index === 0" 
            type="primary" 
            :disabled="props.mode === 'edit'"
            @click="onClickAddParam(index)">
            추가
          </el-button>

          <el-button 
            v-else 
            type="danger" 
            :disabled="props.mode === 'edit'"
            @click="onClickRemoveParam(index)">
            제거
          </el-button>
        </el-form-item>
      </div>
    </el-row>
  </div>
</template>
<script setup lang="ts">
import { useI18n } from "vue-i18n";
import lodash from 'lodash';

import { nextTick, onMounted, ref, getCurrentInstance, onUnmounted, markRaw, watch } from "vue";

import { useToast } from 'vue-toastification';
import { Oss, Workflow, PipelineCd, Pipeline } from "@/views/projects/workflow/type/type";
import { getOssConnectionList } from "@/api/preference"
import { getDefaultPipeline, getPipelineCdList, getWorkflowPipelineCdList } from '@/api/workflow'
import { _validateName, _validateAlphaNumericHyphen, _validateLength, _validateSelect, _validateArrayLength } from "@/utils/input-validate";

import { VAceEditor } from "vue3-ace-editor";
import 'ace-builds/src-noconflict/mode-text';
import 'ace-builds/src-noconflict/theme-chrome';
import { VueDraggableNext } from "vue-draggable-next";

const components = ref({
  // VAceEditor,
  draggable: markRaw(VueDraggableNext),
})
interface Props {
  mode: String,
  workflow: Workflow
  isChangedContents: Boolean
}
const props = defineProps<Props>()
const emit = defineEmits(['checked-connection-status', 'set-input-rules', 'set-is-change-contents'])

const { t } = useI18n();
const instance = getCurrentInstance();
const toast = useToast();


// ======================================================================
// 라이프 사이클
// ======================================================================
// 배포 버튼 활성화용
// 파이프라인 내용이 달라졌을 경우 isChangedContents 값 변경
watch(() => props.workflow.pipelines, () => {

  let pipelineScript = getPipelineScript();
  // prePipelineScript.value += '\n'

  if (prePipelineScript.value.trim() != pipelineScript.trim() && prePipelineScript.value !== '') {
    emit('set-is-change-contents', true)
  }
  else {
    emit('set-is-change-contents', false)
  }
}, { deep: true })

function getPipelineScript() {
  let pipelineScript = ""

  if(props.workflow.pipelines) 
    props.workflow.pipelines.forEach(item => {

      pipelineScript += item.pipelineScript

      if (item.defaultScriptTag != "DEFAULT_END")
        pipelineScript += "\n"
    });

  return pipelineScript;
}

onMounted(async () => {

  nextTick(async() => {
    await _getJenkinsList();
    await _getPipelineCdList();
  })
});

onUnmounted(async () => {
  setInputRules()
})

const setInputRules = () => {
  emit('set-input-rules', {
    jenkinsId: [
      {
        required: true,
        trigger: "select",
        validator: _validateSelect
      }
    ],
  })
}

// ======================================================================
// Jenkins 주소
// ======================================================================
// Jenkins 목록
const jenkinsList = ref([] as Array<Oss>)
const _getJenkinsList = async () => {
  try {
    const response = await getOssConnectionList({ oss: "JENKINS" });
    jenkinsList.value = response.data ? response.data : [];
  } catch (error) {
    jenkinsList.value = [];
    toast.error(String(error));
  }
}


// ======================================================================
// 스크립트 생성 Btn
// ======================================================================
const prePipelineScript = ref('' as String)
// Default 스크립트 목록
const defaultScriptList = ref([])
// Default 스크립트 작성완료 Flag
const loadDefaultPipelineFlag = ref(false as Boolean)

// @click
// 스크립트 생성 버튼 클릭시 동작
const onClickCreateScript = async () => {
  // Popup Toast
  const popupToast = (filendName, comment) => {
    const newForm = (instance?.parent as any).parent.refs.newForm

    newForm.validateField(filendName);
    toast.info(comment);
    return;
  }

  if (!props.workflow.workflowName)
    return popupToast("workflowName", "워크플로우 명을 입력해주세요.")

  else if (!props.workflow.workflowPurpose)
    return popupToast("workflowPurpose", "목적을 선택해주세요.")

  else if (!props.workflow.jenkinsId)
    return popupToast("jenkinsId", "Jenkins를 선택해주세요.")

  if (!loadDefaultPipelineFlag.value)
    await _getDefaultPipeline(props.workflow);

  await createDefaultScript();
}


// 기본 스크립트 시작 / 끝 표시를 위한 변수
const defaultScriptTagFlags = ["DEFAULT_START", "DEFAULT_END"]
// '스크립트 생성' 클릭시 validation 이 끝나고 기본 스크립트 생성
const _getDefaultPipeline = async (workflow) => {
  try {
    const param = {
      workflowName: workflow.workflowName,
      workflowPurpose: workflow.workflowPurpose,
      jenkinsId: workflow.jenkinsId
    }
    const response = await getDefaultPipeline(param)
    const list = response.data ? response.data : []

    // 기초 스크립트 Flag
    // 스크립트 시작과 끝 표시를 위한 변수를 생성해줄때 넣어줄 데이터

    list.forEach((item, index) => {
      item.isDefaultScript = true;
      item.defaultScriptTag = defaultScriptTagFlags[index];
    })

    defaultScriptList.value = list;
    loadDefaultPipelineFlag.value = true;
  } catch (error) {
    defaultScriptList.value = [];
    loadDefaultPipelineFlag.value = false;
    toast.error(String(error));
  }
}

// @click
// 기본 스크립트 생성
const createDefaultScript = () => {
  let confirmFlag = false;
  let insertFlag = false;
  let defaultList = lodash.cloneDeep(defaultScriptList.value);
  props.workflow.pipelines = []

  for (const scriptObj of (defaultList as any)) {
    let find = props.workflow.pipelines.find(item => item.defaultScriptTag == scriptObj.defaultScriptTag);
    if (find) {
      insertFlag = true;
      if (find.pipelineScript.length > 0) confirmFlag = true;
    }
  }

  if (insertFlag) {
    if (confirmFlag) {
      if (!confirm(t('project.workflow.msgChangeDefaultScript'))) return;
    }

    for (const scriptObj of (defaultList as any[])) {
      let find = props.workflow.pipelines.find(item => (item as any).defaultScriptTag == scriptObj.defaultScriptTag) as any;
      find.pipelineScript = scriptObj.pipelineScript;
    }
  } else {
    for (const scriptObj of defaultList) {
      props.workflow.pipelines.push(scriptObj);
    }
  }
} 
// ======================================================================
// 파이프라인
// ======================================================================

// 파이프라인 영역 우측 Title
const pipelineCdList = ref([] as Array<PipelineCd>)
// 파이프라인 영역 우측 클릭된 Title 
const activeName = ref("" as String)

// 파이프라인 영역 우측 Title 목록 API
const _getPipelineCdList = async() => {
  try {
    const response = await getPipelineCdList();
    
    pipelineCdList.value = response.data ? response.data : []
    _getScriptList();
  } catch (error) {
    toast.error(String(error));
  }
}


// 파이프라인 영역 우측 Title 하위 목록
const pipelineScriptList = ref({} as any)
/**
 * {
 *    pipelineCd1: [],
 *    pipelineCd2: [],
 *    pipelineCd3: [],
 * }
 * 
 * 형태로 데이터를 넣어준다.
 */
const _getScriptList = async () => {
  try {
    const response = await getWorkflowPipelineCdList()
    pipelineScriptList.value = response.data ? response.data : {}
  } catch (error) {
    pipelineScriptList.value = {}
    toast.error(String(error))
  }
}


// draggable 옵션 (우측 Pipeline Title)
const onCheckDraggableEditor = (e) => {
  let idx = e.draggedContext.futureIndex;
  let isDefaultScript = e.draggedContext.element.isDefaultScript;

  // checkoutBuild / fileUpload 위치 고정 위해 사용
  let check = true;
  if (isDefaultScript) check = false;
  if (idx < 1 || idx > props.workflow.pipelines.length - 2) check = false;

  return check;
}

// draggable 옵션 (readOnly로 바꿔준다.)
const dragFlag = ref(false as Boolean)
const onStartDrag = (e) => {
  dragFlag.value = true;
}
const onFinishDrag = (e) => {
  dragFlag.value = false;
  setPipelineOrder();
}

// pipeline 순서
const setPipelineOrder = () => {
  let pipelines = props.workflow.pipelines;

  let cnt = 1;
  for (const item of (pipelines as any[])) {
    if (item.defaultScriptTag == "DEFAULT_START")
      item.pipelineOrder = 0;
    else if (item.defaultScriptTag == "DEFAULT_EMD")
      item.pipelineOrder = pipelines.length - 1
    else {
      item.pipelineOrder = cnt;
      cnt += 1;
    }
  }
}

// @click
// 파이프라인에서 삭제 버튼 클릭시 동작
const onDeletePipeline = (idx) => {
  if (idx == 0 || idx == props.workflow.pipelines.length - 1) return;
  if (!confirm(t("project.workflow.msgDeletePipelineConfirm"))) return false;
  props.workflow.pipelines.splice(idx, 1);
}

// Palette 옵션 (Pipeline stage)
const onCheckDraggablePalette = (e) => {
  let idx = e.draggedContext.futureIndex;
  let isDefaultScript = e.draggedContext.element.isDefaultScript;
  // let pipelineName = e.draggedContext.element.pipelineName;

  let check = true;

  // checkoutBuild / fileUpload 위치(Index) 고정
  if (isDefaultScript) check = false;

  // 다른 item을 checkoutBuild보다 앞이나 fileUpload보다 뒤에 둘 수 없도록 설정
  if (idx < 1 || idx > props.workflow.pipelines.length - 1) check = false;

  return check;
}

// Palette 옵션
const onClonePipeline = (obj) => {
  const newObj = lodash.cloneDeep(obj);

  return newObj;
}

// 선택된 Palette 아이템
const onClickPaletteItem = (obj) => {
  if (props.workflow.pipelines.length < 1) return;
  let clone: any = lodash.cloneDeep(obj);
  (props.workflow.pipelines as any).splice(props.workflow.pipelines.length - 1, 0, clone);

  setPipelineOrder();
}

// ======================================================================
// Event
// ======================================================================

// select 태그에서는 blur 이벤트 발생을 하지 않기 때문에
// 수동으로 blur시 유효성 체크 실행
const onValidateSelect = prop => {
  (instance?.parent as any).parent.refs.newForm.validateField(prop);
}





const onClickAddParam = (index) => {
  props.workflow.pipelineParam.push({key: '', value: ''})
}
const onClickRemoveParam = (index) => {
  props.workflow.pipelineParam.splice(index, 1)
}


// 상위컴포넌트에서 해당 함수 사용
defineExpose({
  pipelineCdList,
  defaultScriptTagFlags,
  _getDefaultPipeline,
  _getPipelineCdList,
  setPipelineOrder,
  prePipelineScript
})
</script>
<style scoped>
.hr {
  border-bottom: 2px solid #ccc;
}
.space-between {
  display: flex !important;
  justify-content: space-between !important;
}
.palette {
  background-color: yellow;
}
.paletteItem {
  font-size: 15px;
  cursor: pointer;
}

.pipelineContour {
  border-top: 2px dashed black;
}

.paletteTitle {
  font-size: 15px;
  font-weight: bold;
}
.w-90 {
  width: 95%;
}
.btn-align {
  display: flex;
  align-items: flex-end;
}
</style>