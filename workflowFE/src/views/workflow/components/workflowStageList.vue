<template>
  <!-- Palette 리스트 카드 -->
  <div class="card">
    <div class="accordion accordion-flush" id="accordionArea">
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
          <div class="accordion-body p-0">
            <VueDraggableNext
              :list="pipelineCd.list"
              :group="{ name: 'pipelineEidtor', pull: 'clone', put: false }" 
              :move="onCheckDraggablePalette"
              :clone="onClonePipeline" 
              @start="onStartDrag" 
              @end="onFinishDrag">
              <div
                v-for="(item, index) in pipelineCd.list"
                :key="index"
                class="list-group-item list-group-item-action paletteItem"
                @click="onClickPaletteItem(item)"
              >
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
// @ts-ignore
import { getWorkflowPipelineList } from '@/api/workflow';
// @ts-ignore
import type { WorkflowStage, WorkflowStageMappings } from '@/views/type/type';
import { onMounted } from 'vue';
import { ref } from 'vue';
// @ts-ignore
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
  // @ts-ignore
  const transClone: WorkflowStageMappings = {
    stageOrder: clone.workflowStageOrder,
    workflowStageIdx: clone.workflowStageIdx,
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

/* 아코디언 스타일 개선 */
.card {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
}

.accordion-item {
  border: none;
  border-bottom: 1px solid #e5e7eb;
}

.accordion-item:last-child {
  border-bottom: none;
}

.accordion-button {
  background-color: #f8fafc;
  border: none;
  color: #374151;
  font-weight: 600;
  padding: 1rem 1.25rem;
  transition: all 0.3s ease;
}

.accordion-button:not(.collapsed) {
  background-color: #3b82f6;
  color: white;
  box-shadow: none;
}

.accordion-button:hover {
  background-color: #e5e7eb;
}

.accordion-button:not(.collapsed):hover {
  background-color: #2563eb;
}

.accordion-button:focus {
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  border-color: transparent;
}

.accordion-button::after {
  transition: transform 0.3s ease;
}

/* 드래그 앤 드롭 리스트 스타일 */
.accordion-body {
  background-color: #ffffff;
  max-height: 300px;
  overflow-y: auto;
}

.accordion-body::-webkit-scrollbar {
  width: 6px;
}

.accordion-body::-webkit-scrollbar-track {
  background: #f1f5f9;
}

.accordion-body::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

.accordion-body::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}

.paletteItem {
  font-size: 14px;
  cursor: grab;
  padding: 0.75rem 1rem;
  margin: 0;
  border: none;
  border-bottom: 1px solid #f1f5f9;
  background-color: #ffffff;
  color: #374151;
  transition: all 0.2s ease;
  position: relative;
}

.paletteItem:last-child {
  border-bottom: none;
}

.paletteItem:hover {
  background-color: #f8fafc;
  color: #1f2937;
  transform: translateX(4px);
  border-left: 3px solid #3b82f6;
}

.paletteItem:active {
  cursor: grabbing;
  background-color: #e0e7ff;
  transform: scale(0.98);
}

/* 드래그 중일 때 스타일 */
.paletteItem.sortable-ghost {
  opacity: 0.5;
  background-color: #dbeafe;
  border: 2px dashed #3b82f6;
}

.paletteItem.sortable-chosen {
  background-color: #eff6ff;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.paletteItem.sortable-drag {
  opacity: 0.8;
  transform: rotate(5deg);
  background-color: #ffffff;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

/* 빈 상태 메시지 스타일 */
.paletteItem:has-text('등록된 스테이지가 없습니다.') {
  color: #9ca3af;
  font-style: italic;
  text-align: center;
  cursor: default;
  background-color: #f9fafb;
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

/* 추가 애니메이션 효과 */
@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.accordion-collapse.collapsing,
.accordion-collapse.show {
  animation: slideDown 0.3s ease-out;
}

/* 포커스 및 접근성 개선 */
.paletteItem:focus {
  outline: 2px solid #3b82f6;
  outline-offset: -2px;
  background-color: #eff6ff;
}

/* 모바일 반응형 */
@media (max-width: 768px) {
  .accordion-button {
    padding: 0.75rem 1rem;
    font-size: 14px;
  }
  
  .paletteItem {
    padding: 0.5rem 0.75rem;
    font-size: 13px;
  }
}
</style>