<template>
  <div data-page-id="project-build-new" class="app-container normal-page">
    <div>
      <el-form label-position="top" :model="workflow" autocomplete="on" :rules="inputRules" ref="newForm">
        <!-- 최 상단 Title -->
        <el-row>
          <strong class="field-group-title">
            {{ mode === 'new' ? '새 워크플로우 등록' : '워크플로우 수정' }}
          </strong>
        </el-row>

        <hr />

        <!-- 
          배포명 / 인프라
          * 코드가 너무 길어져 컴포넌트 사용
         -->
        <component :is="components.DeployBasicInfo" :workflow="workflow" :mode="mode"
          @set-input-rules="setInputRules" />

        <component ref="providerManager" :is="components.ProviderManager" :mode="mode" :workflow="workflow"
          :is-changed-contents="isChangedContents" @set-is-change-contents="setIsChangeContents"
          @set-input-rules="setInputRules" />
      </el-form>
    </div>

    <!-- ========================================================================================================= -->
    <!-- FOOTER (BUTTON) -->
    <!-- ========================================================================================================= -->

    <hr class="mt-8">
    <div class=" modal-footer flex-wrap ms-auto">

      <!-- ==== CANCEL BUTTON ==== -->
      <button class="btn btn-light" size="medium" @click.prevent="cancelForm()">
        {{ $t("common.cancel") }}
      </button>

      <!-- ==== SAVE BUTTON ==== -->
      <button class="btn btn-primary" size="medium" @click.prevent="confirmSubmit()">
        <span v-if="!isSaving" class="indicator-label">
          {{ mode === 'new' ? $t("common.confirm") : $t("common.edit") }}
        </span>
        <span v-if="isSaving">
          Please wait...
          <span class="spinner-border spinner-border-sm align-middle ms-2" />
        </span>
      </button>
      <el-button v-if="mode === 'edit'" class="btn btn-success" :disabled="isChangedContents || isSaving"
        @click="onClickRun">
        실행
      </el-button>
    </div>
  </div>


  <!-- Modal -->
  <el-dialog v-model="centerDialogVisible" title="RUN" width="500" align-center>
    <div>
      <span slot="label" style="font-size: 1.3em; font-weight: 700; margin-bottom: 5px;">수정할 파라미터를 변경해주세요.</span>

      <el-row type="flex">
        <div v-for="(param, index) in workflow.pipelineParam" class="w-100"
          style="display: flex; justify-content: space-between;">
          <!-- key -->
          <el-form-item inline-message="true" prop="" class="flex-1">
            <span v-if="!index" slot="label" class="field-label">key</span>
            <div class="w-90" style="margin-right: 5px;">
              <el-input v-model="param.paramKey" disabled />
            </div>
          </el-form-item>

          <!-- value -->
          <el-form-item inline-message="true" prop="" class="flex-1">
            <span v-if="!index" slot="label" class="field-label">value</span>
            <div class="w-90">
              <el-input v-model="param.paramValue" :placeholder="param.paramDesc" />
            </div>
          </el-form-item>
        </div>
      </el-row>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <el-button @click="centerDialogVisible = false">Cancel</el-button>
        <el-button type="primary" @click="onClickRunDeploy">
          Run
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>
<script setup lang="ts">
import { onMounted, getCurrentInstance, ref, onBeforeMount, defineComponent } from "vue";
import { useI18n } from "vue-i18n";
import { useToast } from "vue-toastification";
import { useRoute, useRouter } from "vue-router";
import { _validateName, _validateAlphaNumericHyphen, _validateLength, _validateSelect, _validateArrayLength } from "@/utils/input-validate";

import { setCurrentPageBreadcrumbs } from "@/core/helpers/breadcrumb";
import subMenuConfig, { setMenuPermission } from "@/views/projects/menus/SubMenu";
import asidePrimaryController from "@/layout/service/aside/AsidePrimaryController";
import asideSecondaryController from "@/layout/service/aside/AsideSecondaryController";

import lodash from 'lodash';

import DeployBasicInfo from "@/views/projects/workflow/components/DeployBasicInfo.vue";
import ProviderManager from "@/views/projects/workflow/components/ProviderManager.vue";
import { getWorkflowDetailInfo, postWorkflowDeploy, putWorkflowDeploy, runWorkflowDeploy } from '@/api/workflow'

import Swal from "sweetalert2/dist/sweetalert2.js";
import { Workflow } from "@/views/projects/workflow/type/type";
import { useLoading } from "vue-loading-overlay";
import { useValidateForm } from "vee-validate";

const components = defineComponent({
  DeployBasicInfo,
  ProviderManager,
})

const { t } = useI18n();
const toast = useToast();
const instance = getCurrentInstance();
const route = useRoute();
const router = useRouter();
const vueLoading = useLoading();

const isSaving = ref(false as Boolean)
const isChangedContents = ref(false as Boolean)
// ======================================================================
// BeforeMounted (Data Set)
// ======================================================================
// 초기값 설정
onBeforeMount(async() => {
  checkMode()
}) 

// 배포 생성 / 수정 데이터 
const workflow = ref({} as Workflow)

const mode = ref('')
const checkMode = (() => {
  route.params.workflowId === undefined ? mode.value = 'new' : mode.value = 'edit'
})

// inputRule
const inputRules = ref({} as Object)
const setInputRules = ((emitInputRules) => {
  inputRules.value = { ...inputRules.value, ...emitInputRules };
})

// ======================================================================
// onMounted
// ======================================================================
onMounted(() => {
  initData();
  initUI();
});

const initUI = () => {
  initTitle();
  // initMenu();
}

// 타이틀 및 breadcrumb 세팅 (breadcrumb 은 계위가 없기 때문에 현재 사용 X)
const initTitle = () => {
  setCurrentPageBreadcrumbs(t("project.workflow.workflowDeploy"), []);
}

// 메뉴 세팅
// const initMenu = () => {
//   asidePrimaryController.setMenu([])
//   asideSecondaryController.setMenu("Workflow Deploy", subMenuConfig, route.params, setMenuPermission, null)
// }

const initData = async () => {
  if (mode.value === 'edit') {
    await _getWorkflowDetailInfo(route.params.workflowId as String)
    if (workflow.value.pipelineParam.length === 0)
      workflow.value.pipelineParam = null as any
  }
  if (!workflow.value.pipelineParam) {
    workflow.value.pipelineParam = [
      {
        paramKey: "",
        paramValue: "",
        paramDesc: "",
      }
    ]
  }
}

const _getWorkflowDetailInfo = (async (workflowId) => {
  try {
    await getWorkflowDetailInfo(workflowId).then(async (response) => {
      
      workflow.value = response.data as Workflow

      await (instance?.refs.providerManager as any)._getDefaultPipeline(workflow.value);
      await (instance?.refs.providerManager as any)._getPipelineCdList(workflow.value);

      workflow.value.pipelines = workflow.value.pipelines

      workflow.value.pipelines.forEach((item: any, index) => {
        if (item.pipelineCd == "") {
          item.isDefaultScript = true;
          item.defaultScriptTag = (instance?.refs.providerManager as any).defaultScriptTagFlags[index];
        }
      })

      workflow.value.pipelines.sort((x: any, y: any) => {
        return x.pipelineOrder - y.pipelineOrder
      });
      (instance?.refs.providerManager as any).setPipelineOrder();
      (instance?.refs.providerManager as any).prePipelineScript = workflow.value.pipelineScript


    });
    
  } catch (error) {
    toast.error(String(error));
    (instance?.refs.providerManager as any).pipelineCdList.value = [];
  }
}) 


// ======================================================================
// Event
// ======================================================================
// 자식 컴포넌트(ProviderManager)에서 배포 yaml 또는 파이프라인 변경시 동작
// isChangedContents가 false경우 배포버튼 비활성화 
const setIsChangeContents = status => {
  isChangedContents.value = status
}

const gotoItemListPage = () => {
  router.replace({ name: "WorkflowList", params: route.params });
};

const cancelForm = () => {
  gotoItemListPage();
};

const confirmSubmit = () => {
  if (validateWorkflowForm(workflow.value)) {
    if (mode.value === "edit") {
      Swal.fire({
        html: '워크플로우를 수정 하시겠습니까?',
        icon: "info",
        buttonsStyling: false,
        showCancelButton: true,
        cancelButtonText: t("common.cancel"),
        confirmButtonText: t("common.confirm"),
        customClass: {
          cancelButton: "btn btn-light",
          confirmButton: "btn fw-bold btn-primary",
        },
      }).then(result => {
        if (result.isConfirmed) submitForm();
      });
    }
    else {
      submitForm();
    }
  }
}

// 배포 정보 저장 API
const submitForm = () => {
  let params = lodash.cloneDeep(workflow.value) as Workflow;
  let pipelineScript = ""

  let paramPipelines = [] as any
  workflow.value.pipelines.forEach(item => {
    pipelineScript += (item as any).pipelineScript

    if ((item as any).defaultScriptTag != "DEFAULT_END") pipelineScript += "\n"

    paramPipelines.push({
      pipelineScript: item.pipelineScript,
      pipelineOrder: item.pipelineOrder,
      isDefaultScript: item.isDefaultScript,
      defaultScriptTag: item.defaultScriptTag
    })
  });

  params.pipelines = paramPipelines;
  params.pipelineScript = pipelineScript;


  // (instance?.refs.newForm as any).validate((valid) => {
    // if (valid) {
      (async () => {
        // if ((instance?.refs.newForm as any).isCheckedDuplication.value == false) {
        //   toast.info(t("project.workflow.doubleCheckBuildNameMsg"));
        //   return false;
        // }

        try {
          isSaving.value = true;

          let response
          if (mode.value === 'new')
            response = await postWorkflowDeploy(params) as any
          else 
            response = await putWorkflowDeploy(params) as any

          if (response?.code == 200) {
            toast.success(t("msg.saved"));
            gotoItemListPage();
            isSaving.value = false;
            return;
          } else {
            toast.error(t('msg.runFail'));
          }

        } catch (error) {
          toast.error(String(error));
        }
        isSaving.value = false;
      })()
  //   } else {
  //     console.log('error submit!!');

  //     isSaving.value = false;
  //     return false;
  //   }
  // });
};

const validateWorkflowForm = (formData) => {
  if (!formData.workflowName) {
    toast.error('배포명을 입력해주세요.')
    return false;
  }
  else if (!formData.workflowPurpose) {
    toast.error('목적을 선택해주세요.')
    return false;
  }
  else if (!formData.jenkinsId) {
    toast.error('젠킨스를 선택해주세요.')
    return false;
  }
  else if (formData.pipelines.length <= 0) {
    toast.error('파이프 라인을 생성해주세요.')
    return false;
  }
  return true
}




////////////////////////////////////////////////////////////////////////////////
// MODAL
////////////////////////////////////////////////////////////////////////////////

// 모달 Flag
const centerDialogVisible = ref(false)


const onClickRun = () => {
  centerDialogVisible.value = true
}




// 배포 실행 API
const onClickRunDeploy = async () => {
  centerDialogVisible.value = false

  let loader = vueLoading.show();
  try {
    const params = {
      workflowId: workflow.value.workflowId,
      pipelineParam: workflow.value.pipelineParam,
      jenkinsId: workflow.value.jenkinsId,
      jenkinsJobName: workflow.value.jenkinsJobName,
      pipelineScript: workflow.value.pipelineScript
    }
    await runWorkflowDeploy(params);
    toast.success(t("project.deploy.runDeploy"));
    loader.hide();
    gotoItemListPage();
  } catch (error) {
    console.log(error)
    toast.error(t("msg.runFail"));
  }

  loader.hide();
}



















</script>