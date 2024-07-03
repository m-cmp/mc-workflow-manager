<template>
    <!-- <iframe src="http://192.168.6.7:8080/#/projects/workflow/list" style="width:100%; height: 100vh"></iframe> -->

  <div div class="card card-flush w-100">
    <div class="card-body">
      <div class="sub-header">
        <h3>{{ $t("project.workflow.workflowDeployList") }}</h3>
      </div>

      <div class="d-flex flex-stack flex-wrap mb-4 mt-5">
        <!-- ==== 전체 개수 ==== -->
        <div class="fs-6 fw-bolder text-gray-700 ps-4">
          {{ $t('common.total') }}
          <span>
            ({{ totalCount }})
          </span>
        </div>

        <div class="ms-auto d-flex flex-shrink-0">

          <!-- ---- 검색 ---- -->
          <!-- <div class="d-flex ms-3 ">
            <span class="svg-icon svg-icon-2 svg-icon-gray-400 position-absolute ms-3 me-0 pe-0 mt-3 ">
              <inline-svg src="images/icons/search/list-search-light.svg" class="commit-detail-icon" />
            </span>
            <input 
              class="form-control form-control-solid h-40px bg-body ps-13 fs-7" 
              type="text" 
              name="search" 
              value=""
              :placeholder="$t('common.searchPlaceHolder')" 
              data-kt-search-element="input" 
              @input="onInputSearch" />
          </div> -->

          <div class="btn btn-flex flex-center btn-primary btn-text-white w-md-auto h-40px px-0 px-md-6 ps-8 pe-8 w-120"
            tooltip="New Stage" @click="gotoNewPage">
            <span class="d-none d-md-inline">
              <!-- {{ $t("project.workflow.newWorkflowDeploy") }} -->
                워크플로우 등록
            </span>
          </div>
        </div>
        <component 
          :is="components.WorkflowListTable" 
          ref="workflowListTable"
          @setTotalCount="setTotalCount"
          @gotoEditPage="gotoEditPage" 
          @onClickDelete="onClickDelete" 
          @onClickHistory="onClickOpenHistory"
        />
      </div>
    </div>

    <component 
      :is="components.WorkflowHistory" 
      ref="workflowHistory"
      :popup-flag="clickedHistoryFlag"
      :workflow-id="clickedHistoryWorkflowId"
      @onClickCloseHistory="onClickCloseHistory"
    />
  </div>
</template>
<script setup lang="ts">
import { useI18n } from "vue-i18n";
import {defineComponent, getCurrentInstance, onMounted, ref} from "vue";
import {useRoute, useRouter} from "vue-router";
import { useToast } from "vue-toastification";
import { setCurrentPageBreadcrumbs } from "@/core/helpers/breadcrumb";
import asidePrimaryController from "@/layout/service/aside/AsidePrimaryController";
import asideSecondaryController from "@/layout/service/aside/AsideSecondaryController";
import subMenuConfig, {setMenuPermission} from "@/views/projects/menus/SubMenu";
import Swal from 'sweetalert2';

import { deleteWorkflowDeploy } from "@/api/workflow"
import WorkflowListTable from "@/views/projects/workflow/components/WorkflowListTable.vue"
import WorkflowHistory from "@/views/projects/workflow/components/WorkflowHistory.vue"

const { t } = useI18n();
const router = useRouter();
const route = useRoute();
const toast = useToast();
const instance = getCurrentInstance();

const components = defineComponent({
  WorkflowListTable,
  WorkflowHistory
})
/* ============================================================================================================= */
// 초기 Set
/* ============================================================================================================= */

const initUI = () => {
  initTitle();
  // initMenu();
}

const initTitle = () => {
  setCurrentPageBreadcrumbs(t("project.workflow.workflowDeploy"), []);
}

// const initMenu = () => {
//   const menus = [];

//   asidePrimaryController.setMenu(menus);
//   asideSecondaryController.setMenu("Workflow Deploy", subMenuConfig, route.params, setMenuPermission, null);
// }

/* ============================================================================================================= */
// 라이프사이클
/* ============================================================================================================= */
onMounted(async () => {
  initUI();
});

const totalCount = ref(0 as Number)
/* ================================================================================================================= */
// Event
/* ================================================================================================================= */

// @Click
// 새 배포 클릭시 동작 
const gotoNewPage = () => {
  router.push("new")
}

// @Click
// 수정 클릭시 동작
const gotoEditPage = row => {
  router.push({ path: "edit/" + row.workflowId });
}

// @Click
// 삭제 클릭시 동작
const onClickDelete = row => {
  Swal.fire({
    text: '해당 워크플로우 배포를 삭제 하시겠습니까?',
    icon: "info",
    buttonsStyling: false,
    showCancelButton: true,
    cancelButtonText: t("common.cancel"),
    confirmButtonText: t("common.confirm"),
    customClass: {
      cancelButton: "btn btn-light",
      confirmButton: "btn fw-bold btn-light-danger",
    },
  }).then((result) => {
    if (result.isConfirmed) {
      onDeleteItem(row)
    }
  });
}

// onClickDelete 콜백
// 삭제 API 호출 
const onDeleteItem = (async row => {

  const workflowId = row.workflowId;

  try {
    await deleteWorkflowDeploy(workflowId);
    toast.success(t("msg.delCompleted"));
    (instance?.refs.workflowListTable as any)._getWorkflowList();
  } catch (error) {
    console.log(error);
    toast.error(t("msg.runFail"));
  }
})

// History popup Flag
const clickedHistoryFlag = ref(false)
// 클릭된 워크플로우 Id
const clickedHistoryWorkflowId = ref(0)

const onClickOpenHistory = (item) => {
  clickedHistoryFlag.value = !clickedHistoryFlag.value
  clickedHistoryWorkflowId.value = item.workflowId
}
const onClickCloseHistory = () => {
  clickedHistoryFlag.value = !clickedHistoryFlag.value
}

const setTotalCount = (value) => {
  totalCount.value = value
}

const searchString = ref('' as String)
const onInputSearch = (e) => {
  searchString.value = e.target.value.trim();
}
</script>