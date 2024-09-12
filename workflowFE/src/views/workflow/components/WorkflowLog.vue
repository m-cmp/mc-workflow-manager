<template>
  <div class="modal" id="workflowLog" tabindex="-1">
    <div class="modal-dialog modal-xl" role="document">
      <div class="modal-content">

        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        <div class="modal-body text-left py-4">
          <!-- OSS Title -->
          <h3 class="mb-5">
            Workflow Log
            <div v-if="!firstLoadData" class="spinner-border" role="status">
              <span class="visually-hidden">Loading...</span>
            </div>
          </h3>
          <div>
            <div v-if="workflowLogList.length <= 0">
              <p class="text-secondary">No Data</p>
            </div>
            <div v-else v-for="workflowLog in workflowLogList" :key="workflowLog.buildIdx">
              <div class="card mb-3">
                <div class="card-header" @click="onClickedBuildIdx(workflowLog.buildIdx)" style="cursor: pointer;">
                  <h3 class="card-title">{{ workflowLog.buildIdx }}</h3>
                </div>
                <div v-if="clickedBuildIdx === workflowLog.buildIdx" class="card-body">
                  <textarea :value="workflowLog.buildLog" disabled style="width: 100%;" rows="20"></textarea>
                  <!-- <p class="text-secondary">{{workflowLog.buildLog}}</p> -->
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <a href="#" class="btn btn-link link-secondary" data-bs-dismiss="modal" @click="setClear">
            Cancel
          </a>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// import type { Oss, OssType } from '@/views/type/type';
import { ref } from 'vue';
import { useToast } from 'vue-toastification';
import { getWorkflowLog } from '@/api/workflow';
import { onMounted } from 'vue';
import { computed } from 'vue';
import { watch } from 'vue';
import type { WorkflowLog } from '@/views/type/type';

const toast = useToast()
/**
 * @Title Props / Emit
 */
interface Props {
  workflowIdx: number
}
const props = defineProps<Props>()
const emit = defineEmits(['get-oss-list'])

const firstLoadData = ref(false as boolean)
/**
 * @Title Life Cycle
 * @Desc ossIdx 값의 변화에 따라 데이터 set함수 호출  
 */
const workflowIdx = computed(() => props.workflowIdx);
watch(workflowIdx, async () => {
  firstLoadData.value = false
  await setInit();
});

// onMounted(async () => {
//   await setInit();
// })

/**
 * @Title 초기화 Method
 * @Desc 
 */
const workflowLogList = ref([] as Array<WorkflowLog>)
const setInit = async () => {
    workflowLogList.value = []

  await getWorkflowLog(workflowIdx.value).then(({ data }) => {
    workflowLogList.value = data
    firstLoadData.value = true
  }) 
}

const setClear = () => {
  workflowLogList.value = []
  clickedBuildIdx.value = 1
}

const clickedBuildIdx = ref(1 as number)
const onClickedBuildIdx = (buildIdx: number) => {
  if (clickedBuildIdx.value === buildIdx) {
    clickedBuildIdx.value = 0
  }
  else {
    clickedBuildIdx.value = buildIdx
  }
}
</script>