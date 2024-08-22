<template>
  <div class="modal" id="deleteEventListener" tabindex="-1">
    <div class="modal-dialog modal-lg" role="document">
      <div class="modal-content">

        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        <div class="modal-status bg-danger"></div>
        <div class="modal-body text-left py-4">
          <!-- Event Listener Title -->
          <h3 class="mb-5">
            Event Listener 삭제
          </h3>

          <h4>{{ props.eventListenerName }}을(를) 정말 삭제하시겠습니까?</h4>

        </div>

        <div class="modal-footer">
          <a href="#" class="btn btn-link link-secondary" data-bs-dismiss="modal">
            Cancel
          </a>
          <a href="#" class="btn btn-primary ms-auto" data-bs-dismiss="modal"  @click="onClickDelete()">
            삭제
          </a>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useToast } from 'vue-toastification';
import { deleteEventListener } from '@/api/eventListener';

const toast = useToast()
/**
 * @Title Props / Emit
 */
interface Props {
  eventListenerName: string
  eventListenerIdx: number
}
const props = defineProps<Props>()
const emit = defineEmits(['get-event-listener-list'])

/**
 * @Title onClickDelete
 * @Desc 삭제 버튼 클릭시 동작 / 삭제 api 호출
 */
const onClickDelete = async () => {
  const { data } = await deleteEventListener(props.eventListenerIdx)
  if (data)
    toast.success('삭제되었습니다.')
  else
    toast.error('삭제하지 못했습니다.')
  emit('get-event-listener-list')
}
</script>