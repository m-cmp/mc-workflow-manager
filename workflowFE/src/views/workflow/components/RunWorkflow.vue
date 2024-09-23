<template>
  <div class="modal" id="runWorkflow" tabindex="-1">
    <div class="modal-dialog modal-lg" role="document">
      <div class="modal-content">

        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        <div class="modal-status bg-danger"></div>
        <div class="modal-body text-left py-4">
          <!-- Workflow Title -->
          <h3 class="mb-5">
            Run Workflow
          </h3>

          <!-- 파라미터 -->
          <ParamForm 
            v-if="workflowFormData.workflowParams"
            :popup="true"
            :workflow-param-data="workflowFormData.workflowParams"
            event-listener-yn="N"
          />
        </div>

        <div class="modal-footer">
          <a href="#" class="btn btn-link link-secondary" data-bs-dismiss="modal">
            Cancel
          </a>
          <a href="#" class="btn btn-primary ms-auto" data-bs-dismiss="modal"  @click="onClickRun()">
            Run
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useToast } from 'vue-toastification';
import { getWorkflowDetailInfo, runWorkflow } from '@/api/workflow';
import { watch, computed } from 'vue';
import type { Workflow } from '@/views/type/type'
import { ref } from 'vue';
import ParamForm from '@/views/workflow/components/ParamForm.vue'

const toast = useToast()
/**
 * @Title Props / Emit
 */
interface Props {
  workflowIdx: number
}
const props = defineProps<Props>()
const emit = defineEmits(['get-workflow-list'])
const workflowIdx = computed(() => props.workflowIdx)
const workflowFormData = ref({} as Workflow)

watch(() => workflowIdx.value, async () => {
  const { data } = await getWorkflowDetailInfo(workflowIdx.value, 'N')
  workflowFormData.value = data
})

/**
 * @Title onClickRun
 * @Desc 실행 버튼 클릭시 동작 / 실행 api 호출
 */
const onClickRun = async () => {
  const { data } = await runWorkflow(workflowFormData.value)
  if (data)
    toast.success('실행되었습니다.')
  else
    toast.error('실행하지 못했습니다.')
  emit('get-workflow-list')
}
</script>