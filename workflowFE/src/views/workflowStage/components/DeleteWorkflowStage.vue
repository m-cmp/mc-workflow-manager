<template>
  <div class="modal" id="deleteWorkflowStage" tabindex="-1">
    <div class="modal-dialog modal-lg" role="document">
      <div class="modal-content">

        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        <div class="modal-status bg-danger"></div>
        <div class="modal-body text-left py-4">
          <!-- Workflow Stage Title -->
          <h3 class="mb-5">
            Delete Workflow Stage
          </h3>

          <h4>Are you sure you want to delete {{ props.workflowStageName }}?</h4>

        </div>

        <div class="modal-footer">
          <a href="#" class="btn btn-link link-secondary" data-bs-dismiss="modal">
            Cancel
          </a>
          <a href="#" class="btn btn-primary ms-auto" data-bs-dismiss="modal"  @click="onClickDelete()">
            Delete
          </a>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useToast } from 'vue-toastification';
import { deleteWorkflowStage } from '@/api/workflowStage';

const toast = useToast()
/**
 * @Title Props / Emit
 */
interface Props {
  workflowStageName: string
  workflowStageIdx: number
}
const props = defineProps<Props>()
const emit = defineEmits(['get-workflow-stage-list'])

/**
 * @Title onClickDelete
 * @Desc 삭제 버튼 클릭시 동작 / 삭제 api 호출
 */
const onClickDelete = async () => {
  const { data } = await deleteWorkflowStage(props.workflowStageIdx)
  if (data)
    toast.success('삭제되었습니다.')
  else
    toast.error('삭제하지 못했습니다.')
  emit('get-workflow-stage-list')
}
</script>