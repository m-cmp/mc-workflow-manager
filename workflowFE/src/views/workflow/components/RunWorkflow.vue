<template>
  <div class="modal modal-blur fade" id="runWorkflow" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
      <div class="modal-content">
        <div class="modal-status bg-info"></div>

        <div class="modal-header">
          <h3 class="modal-title">Run Workflow</h3>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div class="modal-body py-4">
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
// @ts-ignore
import { getWorkflowDetailInfo, runWorkflow } from '@/api/workflow';
import { watch, computed } from 'vue';
// @ts-ignore
import type { Workflow } from '@/views/type/type'
import { ref } from 'vue';
// @ts-ignore
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
  toast.success('워크플로우가 실행 되었습니다.')

  // 목록 상태 체크를 위한 emit
  emit('get-workflow-list')
  
  await runWorkflow(workflowFormData.value).then(({ data }) => {
    if (data)
      toast.success('워크플로우가 정상적으로 완료 되었습니다.')
    else
      toast.error('워크플로우가 정상적으로 완료 되지 못했습니다.')

    // 목록 상태 체크를 위한 emit
    emit('get-workflow-list')
  })
}
</script>