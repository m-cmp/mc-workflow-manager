<template>
  <div class="mb-3">
    <div class="grid gap-0 column-gap-3 border-bottom pb-2 pt-2">
      <label class="form-label required p-2 g-col-11">
        Pipeline
      </label>
      <button class="btn btn-primary" @click="onClickCreateScript">
        Create Script
      </button>
    </div>
    <div class="p-1">
      <div class="grid gap-0 g-col-12">
        <!-- Comment translated to English. -->
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
	                :pipeline-script-list="pipelineScriptList"
	                :drag-flag="dragFlag"
	                @on-delete-pipeline="onDeletePipeline"
	              />
            </div>
          </VueDraggableNext>
        </div>
        <div v-else>
          <span>Click Create Script first.</span>
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

      <!-- Comment translated to English. -->
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

// Comment translated to English.

const { workflowStageMappingsFormData }  = toRefs(props)

const onClickCreateScript = () => {
  emit('on-click-create-script')
}

// Comment translated to English.
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

// Comment translated to English.
const onCheckDraggableEditor = (e:any) => {
  let idx = e.draggedContext.futureIndex;
  let isDefaultScript = e.draggedContext.element.isDefaultScript;

  // Comment translated to English.
  let check = true;
  if (isDefaultScript) check = false;
  if (idx < 1 || idx > workflowStageMappingsFormData.value.length - 1) check = false;

  return check;
}

// Comment translated to English.
const dragFlag = ref(false as boolean)
const onStartDrag = (e: any) => {
  dragFlag.value = true;
}
const onFinishDrag = (e: any) => {
  dragFlag.value = false;
  setPipelineOrder();
}

// Comment translated to English.
const setPipelineOrder = () => {
  let cnt = 1;
  workflowStageMappingsFormData.value.forEach((stage:WorkflowStageMappings) => {
    if (stage.defaultScriptTag == "DEFAULT_START") {
      stage.stageOrder = 0;
    } else if (stage.defaultScriptTag == "DEFAULT_END") {
      stage.stageOrder = workflowStageMappingsFormData.value.length - 1
    } else {
      stage.stageOrder = cnt;
      cnt += 1;
    }
  });
}

// Comment translated to English.
const onDeletePipeline = (idx: any) => {
  if (idx == 0 || idx == workflowStageMappingsFormData.value.length - 1) return;
  if (!confirm("Do you want to delete this pipeline?")) return false;
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
