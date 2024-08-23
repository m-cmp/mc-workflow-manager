<template>
  <div class="mb-3">
    <div class="grid gap-0 column-gap-3 border-bottom pb-5 pt-5">
      <label class="form-label required p-2 g-col-11">
        파이프 라인
      </label>
      <button class="btn btn-primary" @click="onClickCreateScript">
        스크립트 생성
      </button>
    </div>
    <div class="p-1">
      <div class="grid gap-0 g-col-12">
        <!-- 스크립트 구역 -->        
        <div class="p-2 g-col-8"  v-if="workflowStageMappingsFormData">
          <VueDraggableNext 
            :list="workflowStageMappingsFormData" 
            :group="{ name: 'pipelineEidtor', pull: false, put: true }" 
            :move="onCheckDraggableEditor" 
            @start="onStartDrag" 
            @end="onFinishDrag">
            <div v-for="(pipeline, idx) in workflowStageMappingsFormData" :key="idx">
              <PipelineList
                :idx="idx"
                :pipeline-info="pipeline"
                :drag-flag="dragFlag"
                @onDeletePipeline="onDeletePipeline"
              />
            </div>
          </VueDraggableNext>
        </div>
        <div v-else>
          <span>스크립트 생성 버튼을 클릭해주세요</span>
        </div>

        <div class="p-2 g-col-4">
          <WorkflowStageList 
            :workflow-stage-mappings-form-data="workflowStageMappingsFormData"
            :pipeline-script-list="pipelineScriptList"
            @on-start-drag="onStartDrag"
            @on-finish-drag="onFinishDrag"
            @splice-workflow-stage-mappings-form-data="spliceWorkflowStageMappingsFormData"
            @set-pipeline-order="setPipelineOrder"
            />
        </div>
      </div>

      <!-- 구분 구역 -->
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted, toRefs } from 'vue';

import { getPipelineCdList, getWorkflowPipelineList } from '@/api/workflow'

import type { Workflow, WorkflowInfo, WorkflowStageMappings, WorkflowStage } from '@/views/type/type'

// import {VAceEditor} from "vue3-ace-editor";
// import 'ace-builds/src-noconflict/mode-text';
// import 'ace-builds/src-noconflict/theme-chrome';
import {VueDraggableNext} from "vue-draggable-next";
import { useToast } from "vue-toastification";
import { computed } from 'vue';
import PipelineList from '@/views/workflow/components/PipelineList.vue';
import WorkflowStageList from '@/views/workflow/components/workflowStageList.vue';

const toast = useToast()

/**
 * @Title 
 * @Desc
 */
interface Props {
  mode: String,
  workflowStageMappingsFormData: Array<WorkflowStageMappings>
}
const props = defineProps<Props>()
const emit = defineEmits(['init-workflow-stage-mappings', 'on-click-create-script', 'splice-workflow-stage-mappings-form-data'])

onMounted(() => {
  _getScriptList()
})

// ================================================================================= 스크립트 생성 버튼 클릭

const { workflowStageMappingsFormData }  = toRefs(props)

const onClickCreateScript = () => {
  emit('on-click-create-script')
}

// ================================================================================= key: 파이프라인 구분 / value: 파이프라인 
const pipelineScriptList = ref([] as any)
const _getScriptList = async () => {
  try {
    const response = await getWorkflowPipelineList()
    pipelineScriptList.value = response.data ? response.data : {}
  } catch (error) {
    pipelineScriptList.value = {}
    // toast.error(String(error))
  }
}

// ================================================================================= draggable 옵션 (우측 Pipeline Title)
const onCheckDraggableEditor = (e:any) => {
  let idx = e.draggedContext.futureIndex;
  let isDefaultScript = e.draggedContext.element.isDefaultScript;

  // checkoutBuild / fileUpload 위치 고정 위해 사용
  let check = true;
  if (isDefaultScript) check = false;
  if (idx < 1 || idx > pipelineScriptList.value.length - 2) check = false;

  return check;
}

// =================================================================================  draggable 옵션 (readOnly로 바꿔준다.)
const dragFlag = ref(false as boolean)
const onStartDrag = (e: any) => {
  dragFlag.value = true;
}
const onFinishDrag = (e: any) => {
  dragFlag.value = false;
  setPipelineOrder();
}

// =================================================================================  파이프라인 순서 set
const setPipelineOrder = () => {
  let cnt = 1;
  const keys = Object.keys(pipelineScriptList.value);
  keys.forEach(key => {
    pipelineScriptList.value[key].list.forEach((stage:WorkflowStageMappings) => {
      if (stage.defaultScriptTag) {
        if (stage.defaultScriptTag == "DEFAULT_START")
          stage.stageOrder = 0;
        else if (stage.defaultScriptTag == "DEFAULT_EMD")
          stage.stageOrder = pipelineScriptList.value.length - 1
        else {
          stage.stageOrder = cnt;
          cnt += 1;
        }
      }
    });
  });
}

// ================================================================================= 파이프라인에서 삭제 버튼 클릭시 동작
const onDeletePipeline = (idx: any) => {
  if (idx == 0 || idx == workflowStageMappingsFormData.value.length - 1) return;
  if (!confirm("파이프라인을 삭제하시겠습니까?")) return false;
  workflowStageMappingsFormData.value.splice(idx, 1);
}

const spliceWorkflowStageMappingsFormData = (transClone: WorkflowStageMappings) => {
  emit('splice-workflow-stage-mappings-form-data', transClone)
}

// ================================================================================= TEST
// const test = () => {
//   return workflowStageMappingsFormData
// }

// defineExpose({ test })
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