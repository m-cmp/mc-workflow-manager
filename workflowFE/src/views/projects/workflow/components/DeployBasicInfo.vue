<template>
  <div>
    <!-- 워크플로우 명 -->
    <el-row type="flex">
      <el-form-item prop="workflowName" class="flex-1">
        <span 
          class="field-label" 
          :class="{'required':mode!=='edit'}">
          워크플로우 명
        </span>
        <div class="duplicate-name-wrapper">
          <el-input 
            ref="workflowName" 
            v-model.trim="props.workflow.workflowName"
            placeholder="워크플로우 명을 입력하세요"
            :readonly="mode=='edit'"
            @change="onChangeDuplicateCheck"
            @input="onChangeDuplicateCheck"
             />
          <el-button 
            v-if="isCheckedDuplication || mode==='edit'" 
            type="success" 
            icon="el-icon-success">
            {{ $t("common.duplicateCheck") }}
          </el-button>
          <el-button 
            v-else type="primary" 
            @click="onClickDuplicateCheck">
            {{ $t("common.duplicateCheck") }}
          </el-button>
        </div>
      </el-form-item>
    </el-row>

    <!-- 목적 -->
    <el-row type="flex">
      <el-form-item prop="workflowPurpose" class="flex-1">
        <span class="field-label required">
          목적
        </span>
        <el-select class="infra-select" v-model="workflow.workflowPurpose" >
          <el-option label="목적을 선택하세요" value="" />
          <el-option 
            v-for="(purpose, idx) in purposeList" 
            :key="idx" 
            :label="purpose.name"
            :value="purpose.value" />
        </el-select>
      </el-form-item>
    </el-row>
  </div>
</template>
<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { Workflow } from '../type/type'
import { useToast } from 'vue-toastification';
import { duplicateCheck } from '@/api/workflow'
import { useI18n } from 'vue-i18n';
import { _validateAlphaNumericHyphen, _validateLength } from "@/utils/input-validate";

const { t } = useI18n();
const toast = useToast()

interface Props {
  workflow: Workflow
  mode: String
}
const props = defineProps<Props>()
const emit = defineEmits(['set-input-rules'])

onMounted(async() => {
  setInputRules()
})

const setInputRules = () => {
  emit('set-input-rules', {
    workflowName: [
      {
        required: true,
        trigger: "blur",
        validator: _validateAlphaNumericHyphen,
        labelName: "Workflow Name"
      },
      {
        required: true,
        trigger: "blur",
        validator: _validateLength,
        length: 2
      }
    ],
  })
}

const isCheckedDuplication = ref(false as Boolean)
const purposeList = [
  {
    name: "배포용",
    value: "deploy"
  },
  {
    name: "실행용",
    value: "run"
  },
    {
    name: "테스트용",
    value: "test"
  },
    {
    name: "웹훅용",
    value: "webhook"
  },
]

// @Click
// 중복검사 클릭시 동작
const onClickDuplicateCheck = ref(async () => {
  const response = await duplicateCheck({ workflowName: props.workflow.workflowName })

  if (!response.data) {
    isCheckedDuplication.value = true
    toast.success(t('msg.availableName'));
  } else {
    isCheckedDuplication.value = false
    toast.error(t('msg.alreadyName'));
  }
}) 

//  @input
//  배포명 변경시 동작
const onChangeDuplicateCheck = () => {
  isCheckedDuplication.value = false
}

</script>
<style scoped>
.infra-select {
  width: 100%;
}
</style>