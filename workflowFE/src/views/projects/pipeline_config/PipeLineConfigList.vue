<template>
  <div class="card card-flush w-100">
    <div class="card-body">
      <div class="sub-header">
        <h3>{{ $t('project.pipeLine.list') }}</h3>
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
            <input type="text" class="form-control form-control-solid h-40px bg-body ps-13 fs-7" name="search" value=""
              :placeholder="$t('common.searchPlaceHolder')" data-kt-search-element="input" @input="onInputSearch" />
          </div> -->

          <div class="btn btn-flex flex-center btn-primary btn-text-white w-md-auto h-40px px-0 px-md-6 ps-8 pe-8"
            tooltip="New Stage" data-bs-toggle="modal" data-bs-target="#modalNewPipeLine" style="width:120px;"
            @click="onClickNewPipeLine">
            <span class="svg-icon svg-icon-3">
              <inline-svg src="media/icons/duotune/arrows/arr075.svg" />
            </span>
            <span class="d-none d-md-inline">
              {{ $t("project.pipeLine.newPipeLine") }}
            </span>
          </div>
        </div>

        <!-- 목록 -->
        <el-table :data="pipeLineListData" width="100%" class="list-table" header-row-class-name="list-header"
          highlight-current-row row-class-name="link-deploy-row">

          <!-- 구분 -->
          <el-table-column :label="pipeLineListHeader.value1" prop="pipelineCd" width="220" align="center" sortable />

          <!-- 이름 -->
          <el-table-column :label="pipeLineListHeader.value2" prop="pipelineName" align="center" sortable />

          <!-- 액션 -->
          <el-table-column :label="pipeLineListHeader.value3" width="220px" align="center">
            <template v-slot="scope">
              <div style="display: inline-block; margin-right: 5px;">
                <button class="svg-icon svg-icon-3 btn btn-primary btn-sm" data-bs-toggle="modal"
                  data-bs-target="#modalEditPipeLine" @click="onClickEdit(scope.row)"
                  style=" border: 0px; height: 35px;">
                  {{ $t('project.catalog.edit') }}
                </button>
              </div>

              <div style="display: inline-block; margin-right: 5px;">
                <button class="svg-icon svg-icon-3 btn btn-primary btn-sm" @click="onClickDelete(scope.row)"
                  style=" border: 0px; height: 35px;">
                  {{ $t('project.catalog.delete') }}
                </button>
              </div>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </div>
  </div>

  <component :is="components.NewPipeLineConfigModal" ref="newPipeLineConfigModal" :reloadList="_loadPipeLineListData"
    :stageCdList="stageCdList" :calback="_calBackList" />
  <component :is="components.EditPipeLineConfigModal" ref="EditPipeLineConfigModal" :reloadList="_loadPipeLineListData"
    :stageCdList="stageCdList" />
</template>

<script setup lang="ts">
import { useI18n } from "vue-i18n";
import { defineComponent, getCurrentInstance, onMounted, ref } from "vue";
import { useRoute } from "vue-router";
import { setCurrentPageBreadcrumbs } from "@/core/helpers/breadcrumb";
import asidePrimaryController from "@/layout/service/aside/AsidePrimaryController";
import asideSecondaryController from "@/layout/service/aside/AsideSecondaryController";
import subMenuConfig, { setMenuPermission } from "@/views/projects/menus/SubMenu";

import { getJenkinsPipeLineList, deleteJenkinsPipeline, getStageCdList, getBuildCdList } from '@/api/jenkinsPipeline'
import NewPipeLineConfigModal from './components/NewPipeLineConfigModal.vue';
import EditPipeLineConfigModal from './components/EditPipeLineConfigModal.vue';

import Swal from 'sweetalert2';
import { useToast } from 'vue-toastification';

const components = defineComponent({
  NewPipeLineConfigModal,
  EditPipeLineConfigModal,
})


const { t } = useI18n();
const instance = getCurrentInstance() as any;
const route = useRoute();
const toast = useToast();

const totalCount = ref(0)
const search = ref('')

// const displayItems = ref([] as any)
// const filteredItems = ref([] as any)
const stageCdList = ref([] as any)
const pipeLineListHeader = {
  value1: "구분",
  value2: "이름",
  value3: "액션",
}
const pipeLineListData = ref([] as any)

// const CNT_PER_PAGE = 10;     // 목록의 페이지별 출력 개수
// let currentPageNo = 1;


/* ============================================================================================================= */
// 라이프 사이클
/* ============================================================================================================= */
onMounted(() => {
  // 파이프라인 목록 가져오기
  _loadPipeLineListData()
  _loadStageCdData()
  initView();
});

/* ============================================================================================================= */
// 타이틀 
/* ============================================================================================================= */
const initView = () => {
  initTitle();
  initMenu();
}

const initTitle = () => {
  setCurrentPageBreadcrumbs(t("breadcrumb.project.pipeLineConfig"), []);
}

const initMenu = () => {
  asidePrimaryController.setMenu([]);
  asideSecondaryController.setMenu("Pipeline", subMenuConfig, route.params, setMenuPermission, null);
}


// const onInputSearch = (e) => {
//   search.value = e.target.value.toLowerCase().trim();
//   // filteredDisplayData();
// }

// const filteredDisplayData = () => {
//   filteredItems.value = [];
//   pipeLineListData.value.forEach(item => {
//     if (search.value.length == 0) {
//       filteredItems.value.push(item);
//     }
//     else if (
//       item.pipelineCd.toLowerCase().includes(search.value) ||
//       item.pipelineName.toLowerCase().includes(search.value)
//     ) {
//       filteredItems.value.push(item);
//     }
//   });

//   totalCount.value = filteredItems.value.length;

//   onChangedPage(1)
// }


const onClickNewPipeLine = () => {
  (instance?.refs['newPipeLineConfigModal'] as any).invoke();
}

const onClickEdit = row => {
  (instance?.refs['EditPipeLineConfigModal'] as any).invoke(row);
}

const onClickDelete = pipelineInfo => {
  Swal.fire({
    text: '해당 스테이지를 삭제 하시겠습니까?',
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
        await deleteJenkinsPipeline(pipelineInfo);
        // 스테이지 목록 가져오기
        await _loadPipeLineListData()
        toast.success('스테이지를 삭제했습니다')
      } catch (e) {
        toast.error(t("project.delete.failMsg"));
      }
    }
  });
}



// ========================================================================================
// API
// ========================================================================================

/**
 * 스테이지 목록 가져오기
 */
const _loadPipeLineListData = async () => {

  await getJenkinsPipeLineList().then((response) => {
    pipeLineListData.value = response.data;
    // 스테이지 목록 필터링
    // filteredDisplayData();
  });
}


const _loadStageCdData = async() => {
  await getStageCdList().then((response) => {
    stageCdList.value = response.data
    totalCount.value = stageCdList.value.length;
  })
}

// const onChangedPage = (pageNo: number) => {
//   currentPageNo = pageNo;
//   displayItems.value.length = 0;
//   for (let xx = (currentPageNo - 1) * CNT_PER_PAGE; xx < (currentPageNo * CNT_PER_PAGE) && xx < filteredItems.value.length; xx++)
//     displayItems.value.push(filteredItems.value[xx]);
// }

const _calBackList = () => {
  _loadPipeLineListData()
  _loadStageCdData()
}

</script>
<style scoped>
.mr-10 {
  margin-right: 10px;
}

.inlineBlock {
  display: inline-block;
}
</style>