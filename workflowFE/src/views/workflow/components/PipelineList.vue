<template>
<!-- Comment translated to English. -->
<div class="row" :class="{ 'draggable': !pipelineInfo.isDefaultScript }">
  <span :v-slot="'label'" class="col-10" style="margin-top: 10px !important;">
    <!-- Comment translated to English. -->
    <div v-for="(pipelineScript, idx) in pipelineScriptList" :key="idx">
      <div v-for="(test, index) in pipelineScript.list" :key="index">
        <p v-if="pipelineInfo.workflowStageIdx > 0 && pipelineInfo.workflowStageIdx === test.workflowStageIdx" style="margin-bottom: 0px !important;">
          {{ getStageTypeLabel(test.workflowStageTypeName) }} ({{ test.workflowStageName }})
        </p>
      </div>
    </div>
    <!-- {{ pipelineInfo.defaultScriptTag && pipelineInfo.defaultScriptTag !== 'null' ? pipelineInfo.defaultScriptTag : "" }} -->
  </span>
	<span class="col-2">
	  <button
	    v-if="!pipelineInfo.isDefaultScript && pipelineInfo.workflowStageIdx !== null"
	    class="btn btn-danger btn"
	    @click="onDeletePipeline(props.idx)">
	    delete
    </button>
  </span>
  <VAceEditor
    ref="pipeline"
    :value="editorContent"
    :id="pipelineInfo.mappingIdx"
    :options="{
      readOnly: dragFlag,
      maxLines: 9999,
      minLines: 10,
      selectionStyle: 'text',
      highlightActiveLine: false,
      cursorStyle: 'smooth',
      hasCssTransforms: true
    }" 
    @update:value="updateStageContent"
    />
</div>
</template>

<script setup lang="ts">
import type { WorkflowStageMappings } from '@/views/type/type';
import { computed, toRefs, watch } from 'vue';
import { VAceEditor } from "vue3-ace-editor";
import 'ace-builds/src-noconflict/mode-text';
import 'ace-builds/src-noconflict/theme-chrome';


interface Props {
  idx: number,
  pipelineInfo: WorkflowStageMappings,
  pipelineScriptList: any,
  dragFlag: boolean
}
const props = defineProps<Props>()
const { pipelineInfo } = toRefs(props)
// const test = {...pipelineInfo.value} as WorkflowStageMappings

const getSourceStageContent = () => {
  if (!pipelineInfo.value.workflowStageIdx || !Array.isArray(props.pipelineScriptList)) return ''

  for (const pipelineScript of props.pipelineScriptList) {
    const sourceStage = pipelineScript?.list?.find((stage: any) => (
      stage.workflowStageIdx === pipelineInfo.value.workflowStageIdx
    ))
    if (typeof sourceStage?.workflowStageContent === 'string') {
      return sourceStage.workflowStageContent
    }
    if (typeof sourceStage?.stageContent === 'string') {
      return sourceStage.stageContent
    }
  }

  return ''
}

const isInvalidStageContent = (value: unknown) => {
  if (!pipelineInfo.value.workflowStageIdx || pipelineInfo.value.isDefaultScript) return false
  if (typeof value !== 'string') return true

  const normalizedValue = value.trim().toLowerCase()
  return normalizedValue === 'true'
    || normalizedValue === 'false'
    || !normalizedValue.includes('stage(')
}

const normalizeStageContent = () => {
  if (!isInvalidStageContent(pipelineInfo.value.stageContent)) return

  const sourceStageContent = getSourceStageContent()
  if (sourceStageContent) {
    pipelineInfo.value.stageContent = sourceStageContent
  }
}

const editorContent = computed(() => {
  normalizeStageContent()
  return typeof pipelineInfo.value.stageContent === 'string' ? pipelineInfo.value.stageContent : ''
})

const updateStageContent = (value: string) => {
  pipelineInfo.value.stageContent = value
}

watch(
  () => [pipelineInfo.value.stageContent, pipelineInfo.value.workflowStageIdx, props.pipelineScriptList],
  () => normalizeStageContent(),
  { immediate: true, deep: true }
)

const emit = defineEmits(['on-delete-pipeline'])
const onDeletePipeline = (idx:number) => {
  emit('on-delete-pipeline', idx)
}

const getStageTypeLabel = (stageTypeName: string) => {
  const labels: Record<string, string> = {
    infra: 'Infra',
    k8s: 'K8s',
    app: 'App',
    database: 'Database',
    utility: 'Utility',
    'app-deploy': 'App',
    'db-backup-restore': 'Database',
    'common-util': 'Utility',
  }

  return labels[stageTypeName] || stageTypeName
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
