<template>

  <header class="header mt-5 mb-5">
    <h2>
      {{ $t("project.list.title") }}
    </h2>
  </header>
    
  <!-- =============================================================================================================== -->
  <!-- 프로젝트 목록 -->
  <!-- =============================================================================================================== -->
  <div class="card">
    <div class="mt-5 mb-5 ps-8 pe-8">
      <div class="d-flex flex-stack flex-wrap mb-4 mt-0">
        
        <!-- ==== 전체 개수 ==== -->
        <div class="fs-6 fw-bolder text-gray-700 ps-4">
          {{$t('common.total')}} ({{state.filteredItems.length}})
        </div>
            
        <div class="ms-auto d-flex flex-shrink-0">
                
          <!-- ---- 검색 ---- -->
          <div class="d-flex ms-3 ">
                    
            <span class="svg-icon svg-icon-2 svg-icon-gray-400 position-absolute ms-3 me-0 pe-0 mt-3 ">
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                <rect opacity="0.5" x="17.0365" y="15.1223" width="8.15546" height="2" rx="1" transform="rotate(45 17.0365 15.1223)" fill="black" />
                <path d="M11 19C6.55556 19 3 15.4444 3 11C3 6.55556 6.55556 3 11 3C15.4444 3 19 6.55556 19 11C19 15.4444 15.4444 19 11 19ZM11 5C7.53333 5 5 7.53333 5 11C5 14.4667 7.53333 17 11 17C14.4667 17 17 14.4667 17 11C17 7.53333 14.4667 5 11 5Z" fill="black" />
              </svg>
            </span>
            
            <input 
              type="text" 
              class="form-control form-control-solid h-40px bg-body ps-13 fs-7" 
              name="search" 
              value=""
              :placeholder='$t("project.list.searchPlaceHolder")'
              data-kt-search-element="input" 
              @input="onInputSearch" 
            />
          
          </div>
                
          <!-- ---- NEW ---- -->
          <div class="d-flex ms-3">
            <div
                class="btn btn-flex flex-center btn-primary btn-text-white w-md-auto h-40px px-0 px-md-6 ps-8 pe-8"
                tooltip="New Organization"
                data-bs-toggle="modal"
                data-bs-target="#modalProjectNew"
                style="width:120px;"
                @click="onClickNew"
              >
            
              <span class="d-none d-md-inline"> 
                {{ $t("project.list.new") }} 
              </span>
            </div>
          </div>
        </div>
      </div>
      
      <DataTable
        :tableData="state.displayItems"
        :clickView="onClickView"
        :clickRow="onClickRow"
        :clickDelete="onClickDelete"
      />
                
      <!-- =============================================================================================================== -->
      <!-- PAGINATION -->
      <!-- =============================================================================================================== -->
      <div class="row">
        <div class="pt-8 col-12 d-flex flex-fill align-items-center justify-content-center  ">
          <!-- <Paginator
              :class="{hidden: state.filteredItems.length == 0 ? true : false }"
              ref="paginator"
              :cntPerPage="CNT_PER_PAGE"
              :itemCount="state.filteredItems.length"
              @changedPage="onChangedPage"/> -->
          </div>
        </div>
      </div>
    </div>
    
    <!-- =============================================================================================================== -->
    <!-- MODAL -->
    <!-- =============================================================================================================== -->
    <ProjectNewModal ref="modalProjectNew" @callback="loadProjectList(false)" />
    <ProjectEditModal ref="modalProjectEdit" @callback="loadProjectList(false)" />

</template>

<!-- ################################################################################################################### -->

<script lang="ts">
import { useRoute, useRouter } from 'vue-router';
import asidePrimaryController from "@/layout/service/aside/AsidePrimaryController"
import {getCurrentInstance, nextTick, onMounted, ref} from "vue";
import {AsideButtonProp} from "@/components/base/menu/AsideButtonProp";
import asideSecondaryController from "@/layout/service/aside/AsideSecondaryController";
import {useI18n} from "vue-i18n";
import {setCurrentPageBreadcrumbs} from "@/core/helpers/breadcrumb";
import {ProjectInfo} from "./model/ProjectInfo";
import {deleteProject, getProjectList} from "@/api/projects";
import store from "@/store";
import Swal from "sweetalert2/dist/sweetalert2.min.js";
import { useToast } from "vue-toastification";
import ProjectNewModal from "@/views/projects/project/components/AddProjectModal.vue";
import ProjectEditModal from "@/views/projects/project/components/EditProjectModal.vue";
import projectListDocMenuConfig, {setMenuPermission}  from "@/views/projects/menus/ProjectListSubmenu";
import Paginator from "@/components/paginator/Paginator.vue";
import DataTable from "./components/ProjectTable.vue";
import * as shareActions from "@/store/modules/share/type";

export default {
  name: "ProjectList",
  components: {
    Paginator,
    ProjectNewModal,
    ProjectEditModal,
    DataTable
  },

  setup(props) {
    /* ============================================================================================================= */
    // 데이터
    /* ============================================================================================================= */
    
    const instance = getCurrentInstance();
    const router = useRouter();
    const route = useRoute();
    const toast = useToast();
    const { t } = useI18n();

    const state = ref({
      isFirstLoading: true,
      items: new Array<ProjectInfo>(),                   // API 조회 결과
      filteredItems: new Array<ProjectInfo>(),           // 검색으로 필터된 결과
      displayItems: new Array<ProjectInfo>(),            // 현재 화면 춮력 목록
      search: {
        name: "",
        groupId: route.params.groupId,
        subgroupId: route.params.serviceId,
        paging: {
          offset: 0,
          rowCount: 1000
        }
      },
    });
    
    const CNT_PER_PAGE = 9;     // 목록의 페이지별 출력 개수
    let currentPageNo = 1;
        
    /* ============================================================================================================= */
    // 라이프사이클
    /* ============================================================================================================= */

    onMounted( () => {
      nextTick(() => {
        init();
        
        loadProjectList(true);
        state.value.isFirstLoading = false;
      });
    });
 
    function init() {
      initMenu();
      initTitle();
    }
        

    function initMenu() {
      const menus = [
        new AsideButtonProp(1,'Projects', true, "images/icons/menu/projects/projects.svg", "ProjectList", projectListDocMenuConfig, route.params),
      ];
      
      asidePrimaryController.setMenu(menus);
      asideSecondaryController.setMenu("Projects", projectListDocMenuConfig, route.params, setMenuPermission, '');
    }

    function initTitle() {
      setCurrentPageBreadcrumbs(t("project.list.title"), []);
    }
    
    /* ============================================================================================================= */
    // 데이터 관리
    /* ============================================================================================================= */
    
    async function loadProjectList(notiFlag) {
      let response;
      try {
        response = await getProjectList(state.value.search);
      } catch (error:any) {
        if(notiFlag) {
          Swal.fire({
            text: store.getters.getErrors[error],
            icon: "error",
            buttonsStyling: false,
            confirmButtonText: t("common.confirm"),
            customClass: {
              confirmButton: "btn fw-bold btn-light-danger",
            },
          });
        }
        return;
      }
    
      state.value.items = [] as any;
      /* 수신된 조직 목록을 저장한다. */
      (response!!.data || []).forEach( (el) => {
        state.value.items.push(new ProjectInfo(
          el.projectId, el.projectName, el.packageName, el.gitlabCloneHttpUrl, el.gitlab, el.regDate, el.modDate
        ));
      });
      
      buildProjectList();
    }
        
    function buildProjectList() {
      /* 실 데이터에서 필트된 데이터 구성 */
      state.value.filteredItems = [];
      state.value.items.forEach(item => {
        let regFlag = false;
        if(state.value.search.name.length == 0) { state.value.filteredItems.push(item); regFlag = true; }
        else if(item.projectName.startsWith(state.value.search.name)) { state.value.filteredItems.push(item); regFlag = true; }
      });
    
      /* 필터된 데이터에서 현재 출력 데이터 구성 */
      state.value.displayItems = [];
      for(let xx = (currentPageNo-1)*CNT_PER_PAGE; xx < (currentPageNo*CNT_PER_PAGE) && xx < state.value.filteredItems.length; xx++)
          state.value.displayItems.push(state.value.filteredItems[xx]);
  
      /* beginItemIndex 재조정 (삭제 후) */
      if(currentPageNo > state.value.filteredItems.length/CNT_PER_PAGE) {
          currentPageNo--;
      }
      if(currentPageNo <= 0) currentPageNo = 1;
    }
    
    /* ================================================================================================================= */
    // 이벤트 처리
    /* ================================================================================================================= */
    
    const onClickNew = () => {
      (instance?.refs.modalProjectNew as any).invoke(()=>{
          loadProjectList(false);
      });
    }
        
    const onClickView = async (project) => {
      (instance?.refs.modalProjectEdit as any).invoke(project,()=>{
        loadProjectList(false);
      });
      // router.push({
      //     name: "ProjectSettingsGeneral",
      //     params: {
      //         projectId: project.projectId
      //     }
      // });
    }
        
    function onClickDelete (projectId) {
      Swal.fire({
        text: t("project.delete.deleteConfirmMsg"),
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
        if(result.isConfirmed) {
          try {
            await deleteProject(projectId);
            toast.success(t('project.delete.successMsg'));
            await loadProjectList(false);
          } catch (e) {
            toast.error(t("project.delete.failMsg"));
          }
        }
      });
    }
        
    function onClickRow(row) {
      store.dispatch(shareActions.NAMESPACE + "/" + shareActions.SET_PROJECT_INFO, row)
      router.push({ name: 'ApiMapperConnectionList', params: {
        projectId: row.projectId
      }});
    }
    
    const onInputSearch = (e) => {
      state.value.search.name = e.target.value.trim();
      currentPageNo = 1;
      buildProjectList();
    }
        
    /* ================================================================================================================= */
    // PAGINATION
    /* ================================================================================================================= */
    
    const onChangedPage = (pageNo: number) => {
      currentPageNo = pageNo;
      state.value.displayItems.length = 0;
      for(let xx = (currentPageNo-1)*CNT_PER_PAGE; xx < (currentPageNo*CNT_PER_PAGE) && xx < state.value.filteredItems.length; xx++)
        state.value.displayItems.push(state.value.filteredItems[xx]);
    }
        
    /* ============================================================================================================= */
        
    return {
      state,
      CNT_PER_PAGE,


      onClickNew,
      onClickView,
      onClickDelete,
      onClickRow,
      loadProjectList,

      onChangedPage,
      onInputSearch,
    }
  }
}
</script>