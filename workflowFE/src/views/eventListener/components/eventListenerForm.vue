<template>
  <div class="modal" id="eventListenerForm" tabindex="-1">
    <div class="modal-dialog modal-lg" role="document">
      <div class="modal-content">

        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        <div class="modal-body text-left py-4">
          <!-- Event Listener Title -->
          <h3 class="mb-5">
            Event Listener {{ props.mode === 'new' ? '생성' : '수정'}}
          </h3>

          <div>

            <!-- Event Listener 명 -->
            <div class="row mb-3">
              <label class="form-label required">Event Listener 명</label>
              <div class="grid gap-0 column-gap-3">
                <input type="text" class="form-control p-2 g-col-11" placeholder="Event Listener 명을 입력하세요" v-model="eventListenerFormData.eventListenerName" />

                <button v-if="!duplicatedEventListener" class="btn btn-primary chk" @click="onClickDuplicatEventListenerName" style="margin: 3px;">중복 체크</button>
                <button v-else class="btn btn-success" style="margin: 3px;">중복 체크</button>
              </div>
            </div>
            
            <!-- Event Listener 설명 -->
            <div class="mb-3">
              <label class="form-label required">Event Listener 설명</label>
              <input type="text" class="form-control p-2 g-col-11" placeholder="Event Listener 설명을 입력하세요" v-model="eventListenerFormData.eventListenerDesc" />
            </div>

            <!-- URL -->
            <div class="mb-3">
              <label class="form-label required">URL</label>
              <input type="text" class="form-control p-2 g-col-11" placeholder="서버 URL을 입력하세요" v-model="eventListenerFormData.eventListenerUrl" />
            </div>
          </div>
        </div>

      <div class="modal-footer">
        <a href="#" class="btn btn-link link-secondary" data-bs-dismiss="modal" @click="setInit()">
          Cancel
        </a>
        <a href="#" class="btn btn-primary ms-auto" data-bs-dismiss="modal"  @click="onClickSubmit()">
          {{props.mode === 'new' ? '생성' : '수정'}}
        </a>
      </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { type EventListener } from '@/views/type/type';
import { ref } from 'vue';
import { useToast } from 'vue-toastification';
import { duplicateCheck, getEventListenerDetailInfo, registEventListener, updateEventListener } from '@/api/eventListener';
import { getWorkflowList } from '@/api/workflow';
import { onMounted } from 'vue';
import { computed } from 'vue';
import { watch } from 'vue';

const toast = useToast()
/**
 * @Title Props / Emit
 */
interface Props {
  mode: String,
  eventListenerIdx: number
}
const props = defineProps<Props>()
const emit = defineEmits(['get-event-listener-list'])

/**
 * @Title Life Cycle
 * @Desc eventListenerIdx 값의 변화에 따라 데이터 set함수 호출  
 */
const eventListenerIdx = computed(() => props.eventListenerIdx);
watch(eventListenerIdx, async () => {
  await setInit();
});
onMounted(async () => {
  await setInit();
})

/**
 * @Title formData 
 * @Desc Event Listener 생성 / 수정데이터
 */
const eventListenerFormData = ref({} as EventListener)

/**
 * @Title 초기화 Method
 * @Desc 
 *    1. 생성 모드일경우 / eventListenerIdx 가 달라질경우 데이터 초기화
 *    2. 중복검사 / 연결 확인 버튼 활성화 여부 set
 *    3. 닫기 / 생성 / 수정 버튼 클릭시 데이터 초기화
 */
const setInit = async () => {
  if (props.mode === 'new') {
    eventListenerFormData.value.eventListenerName = ''
    eventListenerFormData.value.eventListenerDesc = ''
    eventListenerFormData.value.eventListenerUrl = ''
    eventListenerFormData.value.workflowIdx = 0

    duplicatedEventListener.value = false
  }
  else {
    const { data } = await getEventListenerDetailInfo(props.eventListenerIdx)
    eventListenerFormData.value = data

    duplicatedEventListener.value = true
  }
}

/**
 * @Title duplicatedEventListener / onClickDuplicatEventListenerName
 * @Desc 
 *    duplicatedEventListener : 중복검사 여부
 *    onClickDuplicatEventListenerName : Event Listener 명 / Event Listener Url 로 중복검사 API 호출
 */
const duplicatedEventListener = ref(false as boolean)
const onClickDuplicatEventListenerName = async () => {
  const param = {
    eventListenerName: eventListenerFormData.value.eventListenerName,
    eventListenerUrl: eventListenerFormData.value.eventListenerUrl,
  }
  const { data } = await duplicateCheck(param)
  if (!data) {
    toast.success('사용 가능한 이름입니다.')
    duplicatedEventListener.value = true
  }
  else
    toast.error('이미 사용중인 이름입니다.')
}


/**
 * @Title onClickSubmit
 * @Desc 
 *     1. 생성 / 수정 버튼 클릭시 동작
 *     2. 부모로 부터 받은 mode값에 따라서 생성/수정 Callback 함수 호출후 부모에게 Event Listener목록 api 호출  
 */
const onClickSubmit = async () => {
  if (props.mode === 'new') {
    await _registEventListener().then(() => {
    emit('get-event-listener-list')
  })
  }
  else
    await _updateEventListener().then(() => {
    emit('get-event-listener-list')
  })
  setInit()
}

/**
 * @Title _registEventListener
 * @Desc 생성 Callback 함수 / 생성 api 호출
 */
const _registEventListener = async () => {
  const { data } = await registEventListener(eventListenerFormData.value)
  if (data)
    toast.success('등록되었습니다.')
  else
    toast.error('등록 할 수 없습니다.')
}

/**
 * @Title _updateEventListener
 * @Desc 수정 Callback 함수 / 수정 api 호출
 */
const _updateEventListener = async () => {
  const { data } = await updateEventListener(eventListenerFormData.value)
  if (data)
    toast.success('등록되었습니다.')
  else
    toast.error('등록 할 수 없습니다.')
}

</script>