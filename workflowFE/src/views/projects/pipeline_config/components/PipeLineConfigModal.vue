<template>
  <div 
    class="modal fade" 
    id="modalPipeLine" 
    aria-hidden="true" 
    tabindex="-1" 
    ref="PipeLineConfigModal">
    <div class="modal-dialog modal-dialog-centered mw-1000px">
      <div class="modal-content">
        <div class="modal-header">
          <h2 class="fw-bolder">
            {{ $t("project.pipeLine.newPipeLine") }}
          </h2>
          <div 
            ref="Btn_Close" 
            data-bs-dismiss="modal" 
            class="btn btn-icon btn-sm btn-active-icon-primary">
            <span class="svg-icon svg-icon-1">
              <inline-svg src="media/icons/duotune/arrows/arr061.svg" />
            </span>
          </div>
        </div>

        <div class="modal-body py-10 px-lg-17">
          <el-form 
            ref="pipelineForm" 
            label-position="top" 
            :model="form" 
            :rules="inputRules">
            <el-row>
              <!-- 파이프라인 구분 -->
              <el-form-item class="me-3">
                <span class="field-label required">
                  {{ $t('project.pipeLine.pipeLineDivision') }}
                </span>
                <div>
                  <el-radio 
                    v-model="form.pipelineCd" 
                    v-for="(pipelineCd, idx) in stageCdList"
                    :key="pipelineCd.commonCd" 
                    :label="pipelineCd.commonCd" 
                    :value="pipelineCd.commonCd"
                    @change="onChangeValidatePipelineCd">
                    <label>{{ pipelineCd.commonCd }}</label>
                    <span v-if="pipelineCd.protectedYn == 'N'" class="svg-icon svg-icon-1"
                      @click="deleteStatgeCdList(pipelineCd.commonCd)" style="cursor: pointer;">
                      <inline-svg src="media/icons/duotune/arrows/arr061.svg" />
                    </span>
                  </el-radio>
                </div>
              </el-form-item>

              <!-- 스테이지 구분 추가 -->
              <el-form-item prop="newStageCd" class="ms-3 pe-7">
                <el-input 
                  v-model="form.newStageCd" 
                  class="w-100"
                  placeholder="추가할 스테이지 구분 입력" />
                <span 
                  class="svg-icon svg-icon-1" 
                  @click="onClickAddStageCd" 
                  style="cursor: pointer; margin-left: 5px;">
                  <inline-svg src="media/icons/duotune/general/gen035.svg" />
                </span>
              </el-form-item>
            </el-row>

            <!-- 파이프라인 명 -->
            <el-form-item prop="pipelineName">
              <label class="field-label required">
                {{ $t('project.pipeLine.pipeLineName') }}
              </label>

              <div>
                <el-input 
                  class="pipelineName-input" 
                  v-model="form.pipelineName"
                  :placeholder="$t('project.pipeLine.pipeLineNamePlaceHolder')" 
                  @input="onChangeValidate" />
                <el-button 
                  v-if="isDuplicateChecked == false" 
                  class="ml-10" 
                  type="primary"
                  :loading="isChecking" 
                  @click="_onDuplicate">
                  {{ $t("configuration.toolChain.btnCheckDuplicateCheck") }}
                </el-button>
                <el-button 
                  v-if="isDuplicateChecked == true" 
                  class="ml-10" 
                  type="success" 
                  icon="el-icon-success">
                  {{ $t("configuration.toolChain.btnCheckDuplicateCheck") }}
                </el-button>
              </div>
            </el-form-item>

            <!-- 파이프라인 내용 -->
            <el-form-item>
              <label class="field-label required">
                {{ $t('project.pipeLine.pipeLineContents') }}
              </label>
              <component 
                :is="components.VAceEditor" 
                v-model:value="form.pipelineScript"
                :placeholder="$t('project.pipeLine.pipeLineContentsPlaceHolder')" 
                style="height: 300px;" />
            </el-form-item>
          </el-form>
        </div>


        <!-- ================================================================================ -->
        <!-- Footer -->
        <!-- ================================================================================ -->

        <div class="modal-footer flex-center">

          <button 
            class="btn btn-light me-3" 
            style="width:10em;" 
            data-bs-dismiss="modal">
            {{ $t("common.cancel") }}
          </button>

          <button 
            v-if="!isSaving" 
            class="btn btn-primary" 
            style="width:12em;" 
            @click.prevent="_onSave()">
            <span class="indicator-label">
              등록
            </span>
          </button>

          <button 
            v-if="isSaving" 
            class="btn btn-primary" 
            style="width:12em;" 
            @click.prevent="">
            <span>
              Please wait...
              <span class="spinner-border spinner-border-sm align-middle ms-2"></span>
            </span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { defineComponent, getCurrentInstance, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { VAceEditor } from 'vue3-ace-editor';
import { createJenkinsPipeLine, duplicateJenkinsPipelineName, getDefaultScript, getStageCdList, updateStageCdList } from '@/api/jenkinsPipeline'
import { useToast } from 'vue-toastification';
import { _validateLength, _validateName, _validateSelect, _validateAlphanumericUnderbarHyphenSpace } from '@/utils/input-validate';
import Swal from 'sweetalert2';

const components = defineComponent({
  VAceEditor,
})

interface Props {
  reloadList: Function,
  stageCdList: Array<any>,
  calback: Function,
}
const props = defineProps<Props>()

let { t } = useI18n();

const instance:any = getCurrentInstance();
const toast:any = useToast();

const isSaving = ref(false)
const isDuplicateChecked = ref(false)
const isChecking = ref(false)

const form = ref({}) as any
form.value = {
  pipelineCd: '',
  pipelineName: '',
  pipelineScript: '',
  pipelineOrder: null,
  newStageCd: '',
}

const stageCdList = ref([]) as any
const inputRules = ref({}) as any
inputRules.value = {
  // pipelineCd: [
  //   {
  //     required: true,
  //     trigger: "blur",
  //     validator: _validateSelect,
  //     labelName: "pipelineCd",
  //   },
  // ],
  newStageCd: [
    {
      required: true,
      trigger: "blur",
      validator: _validateAlphanumericUnderbarHyphenSpace,
    },
  ],
  pipelineName: [
    {
      required: true,
      trigger: "blur",
      validator: _validateName,
      labelName: "User name",
    },
    {
      required: true,
      trigger: "blur",
      validator: _validateLength,
      length: 2,
    },
  ],
}


watch(() => form.value.pipelineCd, () => {
  if (form.value.pipelineCd !== '') {
    // if(state.value.form.buildCd !== null) {
    //   onChangeStageCdValidate()
    // }  
    onChangeStageCdValidate()
  }
})

const invoke = () => {
  init();
  resetStateInputRules();
  stageCdList.value = props.stageCdList
}

const init = () => {
  form.value = {
    pipelineCd: '',
    // buildCd: null,
    pipelineName: '',
    pipelineScript: ''
  }
  form.value.newStageCd = '';
  isSaving.value = false;
  isDuplicateChecked.value = false;
}

const resetStateInputRules = () => {
  let validKey = [] as any
  Object.keys(form.value).forEach((item: any) => {
    validKey.push(item)
  })
  instance?.refs.pipelineForm.clearValidate(validKey)
}

const onChangeValidate = () => {
  isDuplicateChecked.value = false
}
const onChangeValidatePipelineCd = () => {
  form.value.newStageCd = form.value.pipelineCd
  isDuplicateChecked.value = false
}


/**
 * Trigger: @click
 * 입력된 파이프라인 명 중복검사 메서드
 */
const _onDuplicate = async() => {
  if (form.value.pipelineCd == '') {
    toast.error('파이프라인 구분을 선택해주세요')
    return;
  }
  isChecking.value = true

  const param = {
    pipelineCd: form.value.pipelineCd,
    pipelineName: form.value.pipelineName
  }

  try {
    const response: any = await duplicateJenkinsPipelineName(param)

    if (response.data == false) {
      toast.success('사용 가능한 이름입니다.')
      isDuplicateChecked.value = true
    }
    else {
      toast.error('이미 존재하는 이름입니다.')
      isDuplicateChecked.value = false

    }
  }
  catch (error) {
    console.log(error)
    toast.error('중복검사를 할 수 없습니다.')
    isDuplicateChecked.value = false
  }
  isChecking.value = false
}

const _onSave = () => {

  if (isDuplicateChecked.value == false) {
    toast.error(t("msg.duplicateMessage"));
    return false;
  }

  instance?.refs['pipelineForm'].validate(async valid => {
    if (valid) {

      isSaving.value = true;
      const response: any = await createJenkinsPipeLine(form.value);

      init();

      if (response.code == 200) {
        toast.success('파이프라인 생성 성공')
        instance?.refs['Btn_Close'].click();
        props.reloadList();
      }
      else {
        toast.error('파이프라인 생성 실패')
      }
    }
    else {
      toast.error('파이프라인 생성 실패')
    }
  })
}

const onClickAddStageCd = async() => {

  if (form.value.newStageCd.trim() == '') return;

  let success = false;

  (instance?.refs['pipelineForm']).validateField('newStageCd', msg => {
    if (!msg) success = true;
  })

  if (!success) return;

  let response: any

  try {
    const param = {
      commonGroupCd: 'Pipeline',
      commonCd: form.value.newStageCd.toUpperCase().trim(),
      codeName: form.value.newStageCd.toUpperCase().trim(),
      codeDesc: "Add StageCd",
      codeOrder: stageCdList.value.length + 1,
    }

    response = await updateStageCdList(param)

    if (response.code == 200) {
      toast.success('추가되었습니다')
      form.value.newStageCd = '';

      props.calback()
    }
  } catch (error) {
    console.log(error)
    toast.error('영문 및 숫자만 입력해 주시기 바랍니다.')
  }

  response = await getStageCdList()
  stageCdList.value = response.data
}



const deleteStatgeCdList = async(commonCd) => {
  Swal.fire({
    text: '해당 스테이지 구분을 삭제할 경우 관련된 스테이지 등록 내용이 모두 사라집니다. 그래도 삭제하시겠습니까?',
    icon: "info",
    buttonsStyling: false,
    showCancelButton: true,
    cancelButtonText: t("common.cancel"),
    confirmButtonText: t("common.confirm"),
    customClass: {
      cancelButton: "btn btn-light",
      confirmButton: "btn fw-bold btn-light-danger",
    },
  }).then(async (result) => {
    if (result.isConfirmed) {
      try {
        const response: any = await deleteStatgeCdList({
          commonCd: commonCd
        });
        if (response.code == 200) {
          const { data } = await getStageCdList();
          stageCdList.value = data;
          form.value.stageCd = '';
          form.value.newStageCd = '';
          toast.success('스테이지 구분을 삭제했습니다')
          props.calback()
        }
      } catch (e) {
        toast.error(t("project.delete.failMsg"));
      }
    }
  });
}

const onChangeStageCdValidate = async() => {
  const { data } = await getDefaultScript({ pipelineCd: form.value.pipelineCd })

  form.value.pipelineScript = data[0].pipelineScript
}

defineExpose({
  invoke
})
</script>
<style scoped>
.block {
  display: block;
}
.pipelineName-input {
  width: 85% !important
}
.ml-10 {
  margin-left: 10px;
}
.pipelineCd {
  display: flex;
  justify-content: space-between;
}
</style>