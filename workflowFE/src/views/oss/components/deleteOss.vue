<template>
  <div class="modal modal-blur fade" id="deleteOss" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
      <div class="modal-content">

        <div class="modal-status bg-danger"></div>

        <div class="modal-header">
          <h3 class="modal-title">Delete OSS</h3>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div class="modal-body py-4">

          <h4>Are you sure you want to delete {{ props.ossName }}?</h4>

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
import { deleteOss } from '@/api/oss';

const toast = useToast()
/**
 * @Title Props / Emit
 */
interface Props {
  ossName: string
  ossIdx: number
}
const props = defineProps<Props>()
const emit = defineEmits(['get-oss-list'])

/**
 * @Title onClickDelete
 * @Desc 삭제 버튼 클릭시 동작 / 삭제 api 호출
 */
const onClickDelete = async () => {
  const { data } = await deleteOss(props.ossIdx)
  if (data)
    toast.success('삭제되었습니다.')
  else
    toast.error('삭제하지 못했습니다.')
  emit('get-oss-list')
}
</script>