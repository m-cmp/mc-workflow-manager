<template>
  <div class="mt-5 mb-5" v-if="paramData">
    <label class="form-label">
      파라미터
    </label>
    <div v-for="(paramColum, idx) in paramData" :key="idx">
      <div class="grid gap-0 column-gap-3 mb-2">
        <input 
          class="form-control p-2" 
          :class="props.popup ? 'g-col-6' : 'g-col-5'" 
          type="text" 
          placeholder="Key 입력" 
          v-model="paramColum.paramKey" 
          :disabled="props.popup">
        <input 
          class="form-control p-2" 
          :class="props.popup ? 'g-col-6' : 'g-col-5'" 
          type="text" 
          placeholder="Value 입력" 
          v-model="paramColum.paramValue">

        <button v-if="!props.popup" class="btn btn-primary" @click="addParams" style="text-align: center !important;">
          <svg  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-plus" style="margin: 0 !important;">
            <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
            <path d="M12 5l0 14" />
            <path d="M5 12l14 0" />
          </svg>
        </button>
        <button v-if="!props.popup" class="btn btn-primary" @click="removeParams(idx)">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon icon-tabler icons-tabler-outline icon-tabler-minus" style="margin: 0 !important;">
            <path stroke="none" d="M0 0h24v24H0z" fill="none" />
            <path d="M5 12l14 0" />
          </svg>
        </button>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import type { WorkflowParams } from '@/views/type/type';
import { onMounted } from 'vue';
import { computed } from 'vue';
import { useToast } from 'vue-toastification';

const toast = useToast()

interface Props {
  popup: boolean
  workflowParamData: Array<WorkflowParams>
}
const props = defineProps<Props>()
const paramData = computed(() => props.workflowParamData)

onMounted(() => {
  setInitParam()
})

const setInitParam = () => {
  if(paramData.value.length === 0)
    paramData.value.push({
      paramIdx: 0,
      paramKey: '',
      paramValue: '',
    })
}

const addParams = () => {
  paramData.value.push({
    paramIdx: 0,
    paramKey: '',
    paramValue: '',
  })
}

const removeParams = (idx: number) => {
  if(paramData.value.length !== 1)
    paramData.value.splice(idx, 1)
  else
    toast.error('비워두셔도 됩니다.')
}

</script>

<style scoped>
.w45 {
  width: 45% !important;
}
</style>