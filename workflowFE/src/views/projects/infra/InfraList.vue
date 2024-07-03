<template>
  <div class="card" :class="{widgetClasses: true}">
    <div class="card-header border-0 pt-5">
      <strato-table-title :title="t('service.infra.title')" :radioData="radioData" @toggle-view="changeView" />
      <strato-table-search tool-tip="New Infra" :new-text="t('service.infra.newInfra')"
        :search-data="state.searchData.k8sName" @execute-filter="executeFilter()" @goto-new-page="gotoNewPage()" />
    </div>

    <div class="card-body py-3">
      <div class="table-responsive">
        <!-- <div v-if="state.mapFlag === 'LIST'"> -->
          <strato-data-table :data="state.displayItems" :headers="headers" @on-edit-item="onEditItem"
            @on-delete-item="deleteVal" />
          <!-- <div class="mt-5 mb-5">
          <Paginator 
            ref="paginator" 
            :cntPerPage="CNT_PER_PAGE" 
            :itemCount="state.totalCount" 
            @changedPage="onChangedPage"
          />
        </div>
        </div>
        <div v-else>
          
        </div> -->
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import {computed, getCurrentInstance, nextTick, onMounted, ref, watch} from "vue";
import { useRoute, useRouter } from "vue-router";
import asidePrimaryController from "@/layout/service/aside/AsidePrimaryController";
import asideSecondaryController from "@/layout/service/aside/AsideSecondaryController";
import { useI18n } from "vue-i18n";
import { setCurrentPageBreadcrumbs } from "@/core/helpers/breadcrumb";
import { useToast } from "vue-toastification";
import { deleteKubernetesConfig } from "@/api/kubernetesConfig";
import ConfirmModal from "@/components/messagebox/ConfirmModal.vue";

import subMenuConfig, { setMenuPermission } from "@/views/projects/menus/SubMenu";
import { useStore } from "vuex"
import { clusterConfigActions } from '@/store/modules/clusterConfig';
import Paginator from "@/components/paginator/Paginator.vue";
import Swal from 'sweetalert2';
import StratoTableTitle from '@/components/Table/StratoTableTitle.vue';
import StratoTableSearch from '@/components/Table/StratoTableSearch.vue';
import StratoDataTable from '@/components/Table/StratoDataTable.vue';

export default {
  name: "InfraList",
  components: {
    Paginator,
    ConfirmModal,
    StratoTableTitle,
    StratoTableSearch,
    StratoDataTable,
  },
  props: {},
  setup(props) {
    let { t, locale } = useI18n();
    // const instance = getCurrentInstance();
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
      displayItems: [] as any,
      mapFlag: ""
    });

    const headers = ref([]) as any
    headers.value = [
      {
        title: t('service.infra.vmSpec'),
        column: "vmSpec",
        desc: "VM 스펙",
        type: "text",
        width: "200",
        align: "center"
      },
      {
        title: t('service.infra.vmImage'),
        column: "vmImage",
        desc: "VM 이미지",
        type: "text",
        width: "150",
        align: "center"
      },
      {
        title: t('service.infra.vmCPU'),
        column: "vmCPU",
        desc: "CPU",
        type: "text",
        width: "100",
        align: "center"
      },
      {
        title: t('service.infra.vmMomery'),
        column: "vmMomery",
        desc: "메모리",
        type: "text",
        width: "100",
        align: "center"
      },
      {
        title: t('service.infra.vmCost'),
        column: "vmCost",
        desc: "비용",
        type: "text",
        width: "150",
        align: "center"
      },
      {
        title: t('service.infra.csp'),
        column: "csp",
        desc: "Cloud Service Portal",
        type: "text",
        width: "150",
        align: "center"
      },
      {
        title: t('service.infra.region'),
        column: "region",
        desc: "리전",
        type: "text",
        width: "250",
        align: "center"
      },
      {
        title: t('common.actions'),
        column: "",
        desc: "Action",
        type: ["edit", "delete"],
        width: "300",
        align: "center"
      },
    ]

    const radioData = ref([]) as any
    // radioData.value = [
    //   {
    //     label: "LIST",
    //     value: "LIST",
    //   },
    //   {
    //     label: "MAP",
    //     value: "MAP",
    //   },
    // ]

    const changeView = ((value) => {
      state.value.mapFlag = value
    })


    const CNT_PER_PAGE = 10; // 목록의 페이지별 출력 개수
    let currentPageNo = 1;
    
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
      asidePrimaryController.setMenu([]);
      asideSecondaryController.setMenu("Infra", subMenuConfig, route.params, setMenuPermission, null);
    }

    function initTitle() {
      setCurrentPageBreadcrumbs( t("service.infra.title"), []);
    }

    async function loadKubernetesConfigList() {
      store.dispatch(clusterConfigActions.NAMESPACE + "/" + clusterConfigActions.LOAD_CLUSTER_CONFIG_LIST, 0)
    }

    const itemList = computed(()=> {
      let clusterConfigListItem = [] as any;
      
      if(state.value.searchData.k8sName == '') {
        for(let item of store.state.clusterConfig.clusterConfigList) {
          clusterConfigListItem.push(item);
        }
      } else {
        const clusterConfigList = store.state.clusterConfig.clusterConfigList;
        for(let item of clusterConfigList) {
          if(item.k8sName != null && item.k8sName.toLowerCase().includes(state.value.searchData.k8sName.toLocaleLowerCase().trim())){
            clusterConfigListItem.push(item);
          }
        }
      }

      state.value.totalCount = clusterConfigListItem ? clusterConfigListItem.length : 0;
      return clusterConfigListItem ? clusterConfigListItem : [];
    }) as any

    const gotoViewPage = ((itemId) => {
      router.push("view/" + itemId);
    })

    const gotoNewPage = (() => {
      router.push("new")
    })

    const onEditItem = ((itemId) => {
      console.log("test")
      router.push({ path: "edit/" + itemId });
    })

    const deleteVal = ((param) => {
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
    }) 

    const onDeleteItem = ((itemId) => {
      const params = itemId;
      try {
        requestDelete(params);
        return;
      } catch (error) {
        console.log(error);
      }
    })

    const requestDelete = (async (params) => {
      try {
        const response = await deleteKubernetesConfig(params);
        toast.success(t("msg.delCompleted"));
        executeFilter();
        return;
      } catch (error) {
        console.log(error);
        toast.error(t("msg.runFail"));
      }
    }) 

    const executeFilter = (() => {
      currentPageNo = 1;
      state.value.searchData.paging.offset = 0;
      loadKubernetesConfigList();
    })

    const onChangedPage = (pageNo: number) => {
			currentPageNo = pageNo;
			state.value.displayItems.length = 0;
      for (let xx = (currentPageNo - 1) * CNT_PER_PAGE; xx < (currentPageNo * CNT_PER_PAGE) && xx < itemList.value.length; xx++) {
        // state.value.displayItems.push(itemList.value[xx]);
        state.value.displayItems.push(
          {
            vmSpec: "t3a.nano",
            vmImage: "Ubuntu20.04",
            vmCPU: "2",
            vmMomery: "0.5",
            vmCost: "0.0059",
            csp: "AWS",
            region: "ap-northeast-2",
          }
        );
      }
		}
    
    watch(itemList, ()=> {
      // 초기 데이터 세팅 / 테스트 필요
      onChangedPage(1)
    })

    return {
      t,
      state,
      headers,
      radioData,
      changeView,

      // instance,
      CNT_PER_PAGE,
      gotoNewPage,
      gotoViewPage,
      onEditItem,
      onDeleteItem,
      executeFilter,
      deleteVal,
      itemList,
      onChangedPage,
    };
  },
};
</script>