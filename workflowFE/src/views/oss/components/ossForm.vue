<template>
  <div class="modal modal-blur fade" id="ossForm" tabindex="-1" aria-hidden="true" ref="modalElement">
    <div class="modal-dialog modal-xl modal-dialog-centered" role="document">
      <div class="modal-content">

        <div class="modal-header">
          <h3 class="modal-title">{{ props.mode === 'new' ? 'New' : 'Edit' }} OSS</h3>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div class="modal-body py-4">
          <!-- OSS Title (header에서 표시하므로 삭제) -->

          <div>
          <!-- OSS 타입 -->
            <div class="mb-3">
              <!-- <div v-if="ossFormData.ossTypeIdx === 1">
                <input class="d-lb mr-5" type="checkbox" v-model="createJenkinsJobYn">
                <label class="form-label d-lb">등록된 워크플로우 Job 생성 여부</label>
              </div> -->


              <label class="form-label required">OSS Type</label>
              <div class="grid gap-0 column-gap-3">
                <select v-model="ossFormData.ossTypeIdx" class="form-select p-2 g-col-12">
                  <option :value="0">Select OSS Type</option>
                  <option v-for="(type, idx) in ossTypeList" :value="type.ossTypeIdx" :key="idx">
                    {{ type.ossTypeName }}
                  </option>
                </select>
              </div>
            </div>

            <!-- OSS 명 -->
            <div class="row mb-3">
              <label class="form-label required">OSS Name</label>
              <input type="text" class="form-control p-2 g-col-11" placeholder="Enter the OSS Name" v-model="ossFormData.ossName" @change="initDuplicatedCheckBtn" />
            </div>
            
            <!-- OSS 설명 -->
            <div class="mb-3">
              <label class="form-label">OSS Description</label>
              <input type="text" class="form-control p-2 g-col-11" placeholder="Enter the OSS Description" v-model="ossFormData.ossDesc" />
            </div>

            <!-- URL -->
            <div class="mb-3">
              <label class="form-label required">URL</label>
              <input type="text" class="form-control p-2 g-col-7" placeholder="Enter the Server URL" v-model="ossFormData.ossUrl" @focus="initConnectionCheckBtn" />
            </div>
            
            <div class="row">
              <!-- OSS ID -->
              <div class="col">
                <label class="form-label required">OSS ID</label>
                <input type="text" class="form-control p-2 g-col-7" placeholder="Enter the OSS ID" v-model="ossFormData.ossUsername" @focus="initConnectionCheckBtn"/>
              </div>

              <!-- OSS PW -->
              <div class="col">
                <label class="form-label required">OSS PW</label>
                <input type="password" class="form-control p-2 g-col-11" placeholder="Enter the OSS Password" v-model="ossFormData.ossPassword" @click="removePassword" @focus="initConnectionCheckBtn"/>
              </div>

              <div class="col mt-4 row">
                <button v-if="!duplicatedOss" class="btn btn-primary col" @click="onClickDuplicatOssName" style="margin-right: 3px;">Duplicate Check</button>
                <button v-else class="btn btn-success col" style="margin-right: 3px;">Duplicate Check</button>
                <button v-if="!connectionCheckedOss" class="btn btn-primary col" @click="onClickConnectionCheckOss">Connection Check</button>
                <button v-else class="btn btn-success col">Connection Check</button>
              </div>
            </div>
          </div>
        </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-link link-secondary" data-bs-dismiss="modal" @click="setInit()">
          Cancel
        </button>
        <button type="button" ref="submitBtn" class="btn btn-primary ms-auto"  @click="onClickSubmit()">
          {{props.mode === 'new' ? 'Regist' : 'Edit'}}
        </button>
      </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// @ts-ignore
import type { Oss, OssType } from '@/views/type/type';
import { ref, onMounted as vueOnMounted } from 'vue';
import { useToast } from 'vue-toastification';
// @ts-ignore
import { getOssTypeList, getOssTypeFilteredList, duplicateCheck, getOssDetailInfo, registOss, updateOss, ossConnectionChecked } from '@/api/oss';
import { onMounted } from 'vue';
import { computed } from 'vue';
import { watch } from 'vue';
import { Modal } from 'bootstrap'
  
const toast = useToast()

/**
 * @Title Modal 관리
 */
const modalElement = ref<HTMLElement>()
const modalInstance = ref<Modal>()

/**
 * @Title Props / Emit
 */
interface Props {
  mode: String,
  ossIdx: number
}
const props = defineProps<Props>()
const emit = defineEmits(['get-oss-list'])

/**
 * @Title Life Cycle
 * @Desc ossIdx 값의 변화에 따라 데이터 set함수 호출  
 */
const ossIdx = computed(() => props.ossIdx);
watch(ossIdx, async () => {
  await setInit();
});
watch(() => props.mode, async () => {
  await _getOssTypeList(props.mode)
})

onMounted(async () => {
  // Modal 인스턴스 초기화
  if (modalElement.value) {
    modalInstance.value = new Modal(modalElement.value)
  }
  
  await _getOssTypeList('init')
  await setInit()
})

// /**
//  * @Title createJenkinsJobYn 
//  * @Desc Jenkins Job 생성 여부
//  */
// const createJenkinsJobYn = ref(false as Boolean)


/**
 * @Title formData 
 * @Desc oss 생성 / 수정데이터
 */
const ossFormData = ref({} as Oss)

/**
 * @Title 초기화 Method
 * @Desc 
 *    1. 생성 모드일경우 / ossIdx 가 달라질경우 데이터 초기화
 *    2. 중복검사 / 연결 확인 버튼 활성화 여부 set
 *    3. 닫기 / 생성 / 수정 버튼 클릭시 데이터 초기화
 */
const setInit = async () => {
  if (props.mode === 'new') {
    ossFormData.value.ossTypeIdx = 0
    ossFormData.value.ossName = ''
    ossFormData.value.ossDesc = ''
    ossFormData.value.ossUrl = ''
    ossFormData.value.ossUsername = ''
    ossFormData.value.ossPassword = ''

    duplicatedOss.value = false
    connectionCheckedOss.value = false
  }
  else {
    const { data } = await getOssDetailInfo(props.ossIdx)
    ossFormData.value = data
    ossFormData.value.ossPassword = decriptPassword(ossFormData.value.ossPassword)

    duplicatedOss.value = true
    connectionCheckedOss.value = true
  }
}

/**
 * @Title ossTypeList / _getOssTypeList
 * @Desc 
 *    ossTypeList : ossType 목록 저장
 *    _getOssTypeList : ossType 목록 API 호출
 */
const ossTypeList = ref([] as Array<OssType>)
const _getOssTypeList = async (mode:String) => {
  try {
    if (mode === 'new' || mode === 'init') {
      const { data } = await getOssTypeFilteredList()
      ossTypeList.value = data
    }
    else {
      const { data } = await getOssTypeList()
      ossTypeList.value = data
    }
  } catch (error) {
    console.log(error)
  }
}

/**
 * @Title removePassword
 * @Desc 패스워드 클릭시 패스워드 항목 초기화
 */
const removePassword = () => {
  ossFormData.value.ossPassword = ''
  connectionCheckedOss.value = false
}

/**
 * @Title duplicatedOss / onClickDuplicatOssName
 * @Desc 
 *    duplicatedOss : 중복검사 여부
 *    onClickDuplicatOssName : oss명 / ossUrl / ossId 로 중복검사 API 호출
 */
const duplicatedOss = ref(false as boolean)
const onClickDuplicatOssName = async () => {
  const param = {
    ossName: ossFormData.value.ossName,
    ossUrl: ossFormData.value.ossUrl,
    ossUsername: ossFormData.value.ossUsername
  }
  const { data } = await duplicateCheck(param)
  if (!data) {
    toast.success('사용 가능한 이름입니다.')
    duplicatedOss.value = true
  }
  else
    toast.error('이미 사용중인 이름입니다.')
}

/**
 * @Title connectionCheckedOss / onClickConnectionCheckOss
 * @Desc 
 *    connectionCheckedOss : 연결확인 여부
 *    onClickConnectionCheckOss : ossUrl / ossId / ossPassword / ossType 으로 연결확인 API 호출
 */
const connectionCheckedOss = ref(false as boolean)
const onClickConnectionCheckOss = async () => {
  const param = {
    ossUrl: ossFormData.value.ossUrl,
    ossUsername: ossFormData.value.ossUsername,
    ossPassword: encriptPassword(ossFormData.value.ossPassword),
    ossTypeIdx: ossFormData.value.ossTypeIdx
  }
  const { data } = await ossConnectionChecked(param)
  if (data) {
    toast.success('사용 가능한 OSS입니다.')
    connectionCheckedOss.value = true
  }
  else
    toast.error('사용 불가능한 OSS입니다.')
}

/**
 * @Title initDuplicatedCheckBtn
 * @Desc 
 *    initDuplicatedCheckBtn : 연결확인 변수 false
 */
const initDuplicatedCheckBtn = () => {
  duplicatedOss.value = false
}

/**
 * @Title initConnectionCheckBtn
 * @Desc 
 *    initConnectionCheckBtn : 연결확인 변수 false
 */
const initConnectionCheckBtn = () => {
  connectionCheckedOss.value = false
}

const onClickSubmit = async () => {
  // ================= Validation ==================
  if (!ossFormData.value.ossTypeIdx || ossFormData.value.ossTypeIdx === 0) {
    toast.error('Please select OSS Type.');
    return;
  }
  if (!ossFormData.value.ossName) {
    toast.error('Please enter OSS Name.');
    return;
  }
  if (!ossFormData.value.ossDesc) {
    toast.error('Please enter OSS Description.');
    return;
  }
  if (!ossFormData.value.ossUrl) {
    toast.error('Please enter URL.');
    return;
  }
  if (!ossFormData.value.ossUsername) {
    toast.error('Please enter OSS ID.');
    return;
  }
  if (!ossFormData.value.ossPassword) {
    toast.error('Please enter OSS Password.');
    return;
  }

  if (!duplicatedOss.value) {
    toast.error('Please perform duplicate check.');
    return;
  }

  if (!connectionCheckedOss.value) {
    toast.error('Please perform connection check.');
    return;
  }

  ossFormData.value.ossPassword = encriptPassword(ossFormData.value.ossPassword)
  
  let success = false;
  
  if (props.mode === 'new') {
    success = await _registOss();
  } else {
    success = await _updateOss();
  }
  
  // 성공적으로 처리된 경우에만 모달 닫기
  if (success) {
  emit('get-oss-list');
  setInit();
    
    // 모달 닫기
    if (modalInstance.value) {
      modalInstance.value.hide()
      // 백드롭이 남아있을 경우 강제 제거
      setTimeout(() => {
        document.body.classList.remove('modal-open')
        const backdrop = document.querySelector('.modal-backdrop')
        backdrop?.remove()
      }, 150)
    }
  }
}

/**
 * @Title _registOss
 * @Desc 생성 Callback 함수 / 생성 api 호출
 */
const _registOss = async (): Promise<boolean> => {
  try {
    const { data } = await registOss(ossFormData.value)
    if (data) {
      toast.success('Regist SUCCESS.')
      return true
    } else {
      toast.error('Regist FAIL.')
      return false
    }
  } catch (error) {
    toast.error('Regist FAIL.')
    return false
  }
}

/**
 * @Title _updateOss
 * @Desc 수정 Callback 함수 / 수정 api 호출
 */
const _updateOss = async (): Promise<boolean> => {
  try {
    const { data } = await updateOss(ossFormData.value)
    if (data) {
      toast.success('Update SUCCESS.')
      return true
    } else {
      toast.error('Update FAIL.')
      return false
    }
  } catch (error) {
    toast.error('Update FAIL.')
    return false
  }
}

/**
 * @Title encriptPassword
 * @param password
 * @Desc 평문으로 인자값을 받으며 Base64로 인코딩 하는 함수 
 */
const encriptPassword = (password:string) => {
  return btoa(password)
}

/**
 * @Title decriptPassword
 * @param password
 * @Desc Base64로 인자값을 받으며 평문으로 디코딩 하는 함수 
 */
const decriptPassword = (password: string) => {
  return atob(password)
}

</script>

<!-- <style scoped>
.d-lb {
  display: inline-block;
}
.mr-5 {
   margin-right: 5px;
}
</style> -->