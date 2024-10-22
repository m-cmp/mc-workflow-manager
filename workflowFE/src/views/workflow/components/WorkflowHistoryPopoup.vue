<template>
  <div class="modal" id="workflowHistoryDetailPopup" tabindex="-1">
    <div class="modal-dialog modal-xl" role="document">
      <div class="modal-content">

        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        <div class="modal-status bg-info"></div>
        <div class="modal-body text-left py-4">
          <h3 class="mb-5">
            {{props.workflowName}}
          </h3>

          <div class="steps steps-counter">
            <span 
              v-for="(stage, index) in workflowStages" 
              class="step-item" 
              :class="{'active':stage.status === 'IN_PROGRESS'}" 
              :key="index"
              @click="getRunHistoryDetailList(stage)"
              style="cursor: pointer;">
              {{ stage.name }}
            </span>
          </div>

          <div class="card mt-8">
            <div class="card-body">
              <div class="row row-deck">
                  <div class="card">
                    <div v-for="(stageInfo, idx) in runHistoryDetailList.stageFlowNodes" :key="idx" class="card-body">
                      <div style="display: flex !important; justify-content: space-between !important;">
                        <p class="stage-title">{{ stageInfo.name }}</p>
                        <a style="cursor: pointer;">
                          <svg v-if="!stageInfo.flag" @click="onClickDetail(idx)"  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-chevron-down"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M6 9l6 6l6 -6" /></svg>
                          <svg v-else xmlns="http://www.w3.org/2000/svg" @click="onClickDetail(idx)"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-chevron-up"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M6 15l6 -6l6 6" /></svg>
                        </a>
                      </div>
                      <div v-if="stageInfo.flag && stageInfo.parameterDescription"> {{ stageInfo.parameterDescription }}</div>
                      <div v-if="stageInfo.flag && stageInfo.error !== null">{{stageInfo.error.type}}</div>
                    </div>
                  </div>
              </div>

            </div>
          </div>
        </div>

        <div class="modal-footer">
          <a href="#" class="btn btn-link link-secondary" data-bs-dismiss="modal">
            Cancel
          </a>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useToast } from 'vue-toastification';
import type { JenkinsStage } from '@/views/type/type'
import { ref, watch } from 'vue'
import { getWorkflowRunHistoryDetail } from '@/api/workflow'

const toast = useToast()
/**
 * @Title Props / Emit
 */
interface Props {
  workflowIdx: string | number | string[] | undefined
  workflowName: string
  buildName: string
  workflowStages: Array<JenkinsStage>
}
const props = defineProps<Props>()

watch(() => props.workflowStages, () => {
  if(props.workflowStages.length > 0) getRunHistoryDetailList(props.workflowStages[0])
})

const runHistoryDetailList = ref([] as any)
const getRunHistoryDetailList = async (stage: JenkinsStage) => {
  const params = {
    workflowIdx: props.workflowIdx,
    buildName: props.buildName,
    stageIdx: stage.id
  }
  await getWorkflowRunHistoryDetail(params).then(({ data }) => {
    data.stageFlowNodes.forEach(stageFlowNode => {
      stageFlowNode.flag = false
    });
    runHistoryDetailList.value = data
  })
}

const onClickDetail = (idx: number) => {
  runHistoryDetailList.value.stageFlowNodes[idx].flag = !runHistoryDetailList.value.stageFlowNodes[idx].flag
}

</script>
<style scoped>
.stage-title {
  font-weight: bold;
  font-size: large;
}
</style>