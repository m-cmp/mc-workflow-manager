<template>
  <div class="card" :class="{widgetClasses: true}">
    <!--begin::Header-->
    <div class="card-header border-0 pt-5">
      <h3 class="card-title align-items-start flex-column">
        <span class="card-label fw-bolder fs-3 mb-1">
          {{ $t("service.clusterConfig.clusterConfigOf") }}
        </span>
      </h3>

      <div
        class="card-toolbar"
        data-bs-toggle="tooltip"
        data-bs-placement="top"
        data-bs-trigger="hover"
      >
        <div class="d-flex ms-3">
          <span class="svg-icon svg-icon-2 svg-icon-gray-700 position-absolute translate-middle-y ms-4" style="top: 42px">
            <inline-svg 
              src="images/icons/search/list-search-light.svg"
              class="commit-detail-icon"  
            />
          </span>
          <input
            class="form-control form-control-solid h-40px bg-body ps-13 fs-7"
            v-model="state.searchData.k8sName"
            :placeholder="$t('common.searchPlaceHolder')"
            @input="executeFilter()"
          />
        </div>
        <div
            class="btn btn-flex flex-center btn-primary btn-text-white w-md-auto h-40px px-0 px-md-6 ps-8 pe-8"
            tooltip="New Cluster" 
            style="width:120px;"
            @click="gotoNewPage"
          >
            <span class="svg-icon svg-icon-3">
              <inline-svg src="media/icons/duotune/arrows/arr075.svg" />
            </span>
            <span class="d-none d-md-inline"> 
              {{ $t("service.clusterConfig.newCluster") }} 
            </span>
          </div>
      </div>
    </div>
    <!--end::Header-->

    
    <!--begin::Body-->
    <div class="card-body py-3">
      <!--begin::Table container-->
      <div class="table-responsive">
        <!--begin::Table-->
        <table class="table table-row-dashed table-row-gray-300 align-middle gs-0 gy-4">
          <!--begin::Table head-->
          <thead>
            <tr class="fw-bolder text-muted">
              <th class="min-w-70px">
                {{ $t("service.clusterConfig.clusterPrividerCd") }}
              </th>
              <th class="min-w-300px">
                {{ $t("service.clusterConfig.clusterConfigName") }}
              </th>
              <th class="min-w-350px">
                {{ $t("common.description") }}
              </th>
              <th class="min-w-20px">
                {{ $t("common.actions") }}
              </th>
            </tr>
          </thead>
          <!--end::Table head-->

          <!--begin::Table body-->
          <tbody>
            <template v-if="state.displayItems.length === 0">
              <tr>
                <td colspan="4">
                  <center>
                    {{ $t("service.clusterConfig.noData") }}
                  </center>
                </td>
              </tr>
            </template>

            <template v-if="state.displayItems.length > 0">
              <tr v-for="(item, index) in state.displayItems" :key="index">
                
                <td
                  style="cursor: pointer"
                  @click="gotoViewPage(item.k8sId)">
                  
                  <span class="text-muted fw-bold text-muted d-block fs-6">
                    {{ item.providerCd }}
                  </span>
                </td>

                <td
                  style="cursor: pointer"
                  @click="gotoViewPage(item.k8sId)">
                  
                  <span class="text-muted fw-bold text-muted d-block fs-6">
                    {{ item.k8sName }}
                  </span>
                </td>

                <td>
                  <span class="text-muted fw-bold text-muted d-block fs-6">
                    {{ item.k8sDesc }}
                  </span>
                </td>
                <!-- <td class="text-end"> -->
                <td>
                  <a
                    @click="onEdtItem(item.k8sId)">
                    <span class="svg-icon svg-icon-3">
                      <button class="btn btn-primary btn-sm" style="margin-right: 10px;">수정</button>
                    </span>
                  </a>
                  <a
                    data-bs-toggle="modal"
                    data-bs-target="#kt_modal_1"
                    @click="deleteVal(item.k8sId)">
                    <span class="svg-icon svg-icon-3">
                      <button class="btn btn-primary btn-sm">삭제</button>
                    </span>
                  </a>
                </td>
              </tr>
            </template>
          </tbody>
          <!--end::Table body-->
        </table>
        <!--end::Table-->
        <!-- <div class="mt-5 mb-5">
          <Paginator 
            ref="paginator" 
            :cntPerPage="CNT_PER_PAGE" 
            :itemCount="state.totalCount" 
            @changedPage="onChangedPage"
          />
        </div> -->
      </div>
      <!--end::Table container-->
    </div>
  </div>
  <!--begin::Body-->
  <!-- <ConfirmModal ref="confirmModal" :content="contentMsg" @fnParent="onRemove" /> -->
</template>

<!-- ################################################################################################################### -->

<script lang="ts">
import {computed, getCurrentInstance, nextTick, onMounted, onUnmounted, ref, watch} from "vue";
import { useRoute, useRouter } from "vue-router";
import asidePrimaryController from "@/layout/service/aside/AsidePrimaryController";
import { AsideButtonProp } from "@/components/base/menu/AsideButtonProp";
import asideSecondaryController from "@/layout/service/aside/AsideSecondaryController";
import { useI18n } from "vue-i18n";
import {setCurrentPageBreadcrumbs, setCurrentPageTitle} from "@/core/helpers/breadcrumb";
import Pagination from "@/components/paginationBkup/Pagination.vue";
import { useToast } from "vue-toastification";
import { getKubernetesConfigList, deleteKubernetesConfig } from "@/api/kubernetesConfig";
import ConfirmModal from "@/components/messagebox/ConfirmModal.vue";

import subMenuConfig, { setMenuPermission } from "@/views/projects/menus/SubMenu";
import { useStore } from "vuex"
import { clusterConfigActions } from '@/store/modules/clusterConfig';
// import projectListDocMenuConfig, { setMenuPermission } from '@/views/projects/menus/ProjectListSubmenu';
import Paginator from "@/components/paginator/Paginator.vue";
import Swal from 'sweetalert2';

export default {
  name: "KubernetesList",
  components: {
    Paginator,
    ConfirmModal,
  },
  props: {},
  setup(props) {

    let { t, locale } = useI18n();

    const instance = getCurrentInstance();
    const router = useRouter();
    const route = useRoute();
    const toast = useToast();
    const store = useStore();

    const state = ref({
      isFirstDataLoadingCompleted: true,
      totalCount: 0,

      searchData: {
        k8sName: "",
        paging: {
          offset: 0,
          rowCount: 10,
        },
      },
      // removeItem: "",
      displayItems: [] as any,
    });
    
    const CNT_PER_PAGE = 10; // 목록의 페이지별 출력 개수
    let currentPageNo = 1;
    
    // const companyInfo = computed(() => store.state.share.companyInfo);
    // const serviceGroupInfo = computed(() => store.state.share.serviceGroupInfo);

    /* ============================================================================================================= */
    // 라이프사이클
    /* ============================================================================================================= */

    
    onMounted(() => {
      nextTick(() => {
        init();
        loadKubernetesConfigList();
      });
    });

    function init() {
      initMenu();
      initTitle();
    }

    function initMenu() {
      const menus = [
        // new AsideButtonProp(1,'Companies', false, "images/icons/menu/companies/company.svg", "CompanyList", null, route.params),
        // new AsideButtonProp(1,'ServiceGroups', false, "images/icons/menu/serviceGroups/serviceGroup.svg","ServiceGroupList", null, route.params),
        // new AsideButtonProp(1,'Projects', true, "images/icons/menu/projects/projects.svg", "ProjectList", projectListDocMenuConfig, route.params),
      ];
    
      asidePrimaryController.setMenu(menus);
      asideSecondaryController.setMenu("Cluster", subMenuConfig, route.params, setMenuPermission, null);
    }

    function initTitle() {
      /* 타이틀 & 패스 */
      // setCurrentPageBreadcrumbs( t("service.clusterConfig.clusterConfigOf"), [
      //     companyInfo.value.companyName,
      //     serviceGroupInfo.value.serviceGroupName
      // ]);

      setCurrentPageBreadcrumbs( t("service.clusterConfig.clusterConfigOf"), []);
    }

    async function loadKubernetesConfigList() {
      // store.dispatch(clusterConfigActions.NAMESPACE + "/" + clusterConfigActions.LOAD_CLUSTER_CONFIG_LIST, serviceGroupInfo.value.serviceGroupId)
      store.dispatch(clusterConfigActions.NAMESPACE + "/" + clusterConfigActions.LOAD_CLUSTER_CONFIG_LIST, 0)
    }

    const itemList = computed(()=> {
      let clusterConfigListItem = [] as any;
      
      if(state.value.searchData.k8sName == '') {
        for(let item of store.state.clusterConfig.clusterConfigList) {
          // if(item.companyId == companyInfo.value.companyId) {
          //   clusterConfigListItem.push(item);
          // }

          clusterConfigListItem.push(item);
        }
      } else {
        const clusterConfigList = store.state.clusterConfig.clusterConfigList;
        for(let item of clusterConfigList) {
          // if(item.companyId == companyInfo.value.companyId) {
          //   if(item.k8sName != null && item.k8sName.toLowerCase().includes(state.value.searchData.k8sName.toLocaleLowerCase().trim())){
          //     clusterConfigListItem.push(item);
          //   }
          // }

          if(item.k8sName != null && item.k8sName.toLowerCase().includes(state.value.searchData.k8sName.toLocaleLowerCase().trim())){
            clusterConfigListItem.push(item);
          }
        }
      }

      state.value.totalCount = clusterConfigListItem ? clusterConfigListItem.length : 0;
      return clusterConfigListItem ? clusterConfigListItem : [];
    }) as any
    /* ================================================================================================================= */
    // 이벤트 처리
    /* ================================================================================================================= */

    function gotoViewPage(itemId) {
      router.push("view/" + itemId);
    }

    function gotoNewPage() {
      router.push("new")
    }

    function onEdtItem(itemId) {
      router.push({ path: "edit/" + itemId });
    }

    //add confirm modal
    // const confirmModal = ref(null);
    // const contentMsg = ref(t("msg.deleteConfirm"));

    function deleteVal(param) {
      // state.value.removeItem = param;

      
      Swal.fire({
        text: '해당 클러스터를 삭제 하시겠습니까?',
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
          onDeleteItem(param)
        }
      });
    }

    //add remove memver function
    // const onRemove = () => {
    //   onDeleteItem(state.value.removeItem);
    //   (instance?.refs.confirmModal as any).closePop();
    // };

    

    function onDeleteItem(itemId) {
      const params = itemId;
      try {
        requestDelete(params);
        return;
      } catch (error) {
        console.log(error);
      }
    }

    async function requestDelete(params) {
      try {
        const response = await deleteKubernetesConfig(params);
        toast.success(t("msg.delCompleted"));
        executeFilter();
        return;
      } catch (error) {
        console.log(error);
        toast.error(t("msg.runFail"));
      }
    }

    /* ================================================================================================================= */
    // PAGINATION
    /* ================================================================================================================= */
    
    function executeFilter() {
      currentPageNo = 1;
      state.value.searchData.paging.offset = 0;
      loadKubernetesConfigList();
    }

    /* ============================================================================================================= */

    const onChangedPage = (pageNo: number) => {
			currentPageNo = pageNo;
			state.value.displayItems.length = 0;
			for (let xx = (currentPageNo - 1) * CNT_PER_PAGE; xx < (currentPageNo * CNT_PER_PAGE) && xx < itemList.value.length; xx++) 
				state.value.displayItems.push(itemList.value[xx]);
		}

    
    watch(itemList, ()=> {
      // 초기 데이터 세팅 / 테스트 필요
      onChangedPage(1)
    })

    return {
      state,
      instance,
      CNT_PER_PAGE,
      // confirmModal,
      // contentMsg,
      gotoNewPage,
      gotoViewPage,
      onEdtItem,
      onDeleteItem,
      executeFilter,
      // onRemove,
      deleteVal,

      itemList,
      onChangedPage,
    };
  },
};
</script>