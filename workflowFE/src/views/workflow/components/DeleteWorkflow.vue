<template>
  <div class="modal modal-blur fade" id="deleteWorkflow" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
      <div class="modal-content">
        <div class="modal-status bg-danger"></div>

        <div class="modal-header">
          <h3 class="modal-title">Delete Workflow</h3>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div class="modal-body py-4">
          <h4>Are you sure you want to delete {{ props.workflowName }}?</h4>

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
// @ts-ignore
import { deleteWorkflow } from '@/api/workflow';

const toast = useToast()
/**
 * @Title Props / Emit
 */
interface Props {
  workflowName: string
  workflowIdx: number
}
const props = defineProps<Props>()
const emit = defineEmits(['get-workflow-list'])

/**
 * @Title onClickDelete
 * @Desc 삭제 버튼 클릭시 동작 / 삭제 api 호출
 */
const onClickDelete = async () => {
  const { data } = await deleteWorkflow(props.workflowIdx)
  if (data)
    toast.success('삭제되었습니다.')
  else
    toast.error('삭제하지 못했습니다.')
  emit('get-workflow-list')
}
</script>