<template>
<!-- 스크립트 구역 -->
<div class="row" :class="{ 'draggable': !pipelineInfo.isDefaultScript }">
  <span :v-slot="'label'" class="field-label col-10">
    {{ pipelineInfo.defaultScriptTag && pipelineInfo.defaultScriptTag !== 'null' ? pipelineInfo.defaultScriptTag : "" }}
  </span>
  <span class="col-2">
    <button 
      v-if="!pipelineInfo.isDefaultScript && pipelineInfo.stageOrder !== null" 
      class="btn btn-danger btn"
      @click="onDeletePipeline(props.idx)">
      delete
    </button>
  </span>
  <VAceEditor
    ref="pipeline"
    v-model="pipelineInfo.stageContent"
    :value="pipelineInfo.stageContent" 
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
    @input="inputData"
    />
</div>
</template>

<script setup lang="ts">
import type { WorkflowStageMappings } from '@/views/type/type';
import { getCurrentInstance, toRefs } from 'vue';
import { VAceEditor } from "vue3-ace-editor";
import 'ace-builds/src-noconflict/mode-text';
import 'ace-builds/src-noconflict/theme-chrome';
import { watch } from 'vue';
import { watchEffect } from 'vue';
import { ref, onMounted } from 'vue';

const instance = getCurrentInstance()
const inputData = () => {
  pipelineInfo.value.stageContent = (instance?.refs.pipeline as any)._contentBackup
}


interface Props {
  idx: number,
  pipelineInfo: WorkflowStageMappings,
  dragFlag: boolean
}
const props = defineProps<Props>()
const { pipelineInfo } = toRefs(props)
// const test = {...pipelineInfo.value} as WorkflowStageMappings

const emit = defineEmits(['on-delete-pipeline'])
const onDeletePipeline = (idx:number) => {
  emit('on-delete-pipeline', idx)
}

// const preSrcipt = ref('')
// watch(pipelineInfo, newValue => {
//   console.log('pipelineInfo', pipelineInfo)
//   console.log('newValue', newValue);
//   preSrcipt.value = pipelineInfo.value.stageContent
// })
const preSrcipt = ref('')
watch(()=> preSrcipt.value,() => {
  console.log('preSrcipt', preSrcipt.value)
})
onMounted(() => {
  // preSrcipt.value = pipelineInfo.value.stageContent
  // preSrcipt.value = lodash.cloneDeep(pipelineInfo.value.stageContent)
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