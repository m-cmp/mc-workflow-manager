<template>
<!-- 구분 구역 -->
  <div class="container pt-5">
    <div class="accordion" id="accordionArea">
      <div class="accordion-item" v-for="(pipelineCd, idx) in pipelineScriptList" :key="idx">
        <h2 class="accordion-header" :id="'heading' + pipelineCd">
          <button 
            class="accordion-button collapsed" 
            type="button" 
            data-bs-toggle="collapse" 
            :data-bs-target="'#collapse' + idx" 
            aria-expanded="false" 
            :aria-controls="'collapse' + idx">
            {{ pipelineCd.title }} 
          </button>
        </h2>
        <div 
          :id="'collapse' + idx" 
          class="accordion-collapse collapse" 
          :aria-labelledby="'heading' + idx" 
          data-bs-parent="#accordionArea">
          <div class="accordion-body">
            <VueDraggableNext
              :list="pipelineCd.list"
              :group="{ name: 'pipelineEidtor', pull: 'clone', put: false }" 
              :move="onCheckDraggablePalette"
              :clone="onClonePipeline" 
              @start="onStartDrag" 
              @end="onFinishDrag">
                <div v-for="(item, index) in pipelineCd.list" :key="index" class="paletteItem"
                  @click="onClickPaletteItem(item)">
                  {{ item ? item.workflowStageName : '등록된 스테이지가 없습니다.' }}
                </div>
              </VueDraggableNext>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { getWorkflowPipelineList } from '@/api/workflow';
import type { WorkflowStage, WorkflowStageMappings } from '@/views/type/type';
import { onMounted } from 'vue';
import { ref } from 'vue';
import _ from 'lodash';

interface Props {
  workflowStageMappingsFormData: Array<WorkflowStageMappings>
  pipelineScriptList: any
}
const props = defineProps<Props>()
const emit = defineEmits(['on-start-drag', 'on-finish-drag', 'splice-workflow-stage-mappings-form-data', 'set-pipeline-order'])

// Palette 옵션 (Pipeline stage)
const onCheckDraggablePalette = (e:any) => {
  let idx = e.draggedContext.futureIndex;
  let isDefaultScript = e.draggedContext.element.isDefaultScript;
  // let pipelineName = e.draggedContext.element.pipelineName;

  let check = true;

  // checkoutBuild / fileUpload 위치(Index) 고정
  if (isDefaultScript) check = false;

  // 다른 item을 checkoutBuild보다 앞이나 fileUpload보다 뒤에 둘 수 없도록 설정
  if (idx < 1 || idx > props.workflowStageMappingsFormData.length - 1) check = false;

  return check;
}

// Palette 옵션
const onClonePipeline = (obj:any) => {
  const newObj = obj;
  return newObj;
}

// 선택된 Palette 아이템
const onClickPaletteItem = (obj:WorkflowStage) => {
  if (props.workflowStageMappingsFormData.length < 1) return;
  const clone: WorkflowStage = obj;
  const transClone: WorkflowStageMappings = {
    stageOrder: clone.workflowStageOrder,
    workflowStageTypeIdx: clone.workflowStageTypeIdx,
    stageContent: clone.workflowStageContent,
    defaultScriptTag: 'null',
    isDefaultScript: false,
  }
  emit('splice-workflow-stage-mappings-form-data', transClone)
  emit('set-pipeline-order')
}

const onStartDrag = () => {
  emit('on-start-drag')
}
const onFinishDrag = () => {
  emit('on-finish-drag')
}
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