<template>
  <div class="modal modal-blur fade" id="ossForm" tabindex="-1" aria-hidden="true" ref="modalElement">
    <div class="modal-dialog modal-xl modal-dialog-centered" role="document">
      <div class="modal-content">

        <div class="modal-header">
          <h3 class="modal-title">{{ props.mode === 'new' ? 'New' : 'Edit' }} OSS</h3>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div class="modal-body py-4">
          <!-- Comment translated to English. -->

          <div>
          <!-- Comment translated to English. -->
            <div class="mb-3">
              <!-- <div v-if="ossFormData.ossTypeIdx === 1">
                <input class="d-lb mr-5" type="checkbox" v-model="createJenkinsJobYn">
                <label class="form-label d-lb">Create registered workflow jobs</label>
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

            <!-- Comment translated to English. -->
            <div class="row mb-3">
              <label class="form-label required">OSS Name</label>
              <input type="text" class="form-control p-2 g-col-11" placeholder="Enter the OSS Name" v-model="ossFormData.ossName" @change="initDuplicatedCheckBtn" />
            </div>
            
            <!-- Comment translated to English. -->
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

/* Comment translated to English. */
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

/* Comment translated to English. */
const ossIdx = computed(() => props.ossIdx);
watch(ossIdx, async () => {
  await setInit();
});
watch(() => props.mode, async () => {
  await _getOssTypeList(props.mode)
})

onMounted(async () => {
  // Comment translated to English.
  if (modalElement.value) {
    modalInstance.value = new Modal(modalElement.value)
  }
  
  await _getOssTypeList('init')
  await setInit()
})

// /**
//  * @Title createJenkinsJobYn 
// Comment translated to English.
//  */
// const createJenkinsJobYn = ref(false as Boolean)


/* Comment translated to English. */
const ossFormData = ref({} as Oss)

/* Comment translated to English. */
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

/* Comment translated to English. */
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

/* Comment translated to English. */
const removePassword = () => {
  ossFormData.value.ossPassword = ''
  connectionCheckedOss.value = false
}

/* Comment translated to English. */
const duplicatedOss = ref(false as boolean)
const onClickDuplicatOssName = async () => {
  const param = {
    ossName: ossFormData.value.ossName,
    ossUrl: ossFormData.value.ossUrl,
    ossUsername: ossFormData.value.ossUsername
  }
  const { data } = await duplicateCheck(param)
  if (!data) {
    toast.success('This name is available.')
    duplicatedOss.value = true
  }
  else
    toast.error('This name is already in use.')
}

/* Comment translated to English. */
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
    toast.success('This OSS connection is available.')
    connectionCheckedOss.value = true
  }
  else
    toast.error('This OSS connection is not available.')
}

/* Comment translated to English. */
const initDuplicatedCheckBtn = () => {
  duplicatedOss.value = false
}

/* Comment translated to English. */
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
  
  // Comment translated to English.
  if (success) {
  emit('get-oss-list');
  setInit();
    
    // Comment translated to English.
    if (modalInstance.value) {
      modalInstance.value.hide()
      // Comment translated to English.
      setTimeout(() => {
        document.body.classList.remove('modal-open')
        const backdrop = document.querySelector('.modal-backdrop')
        backdrop?.remove()
      }, 150)
    }
  }
}

/* Comment translated to English. */
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

/* Comment translated to English. */
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

/* Comment translated to English. */
const encriptPassword = (password:string) => {
  return btoa(password)
}

/* Comment translated to English. */
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