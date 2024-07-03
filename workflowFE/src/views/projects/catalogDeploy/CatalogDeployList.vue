<template>
  <div v-if="state.deployList.length > 0" class="deploy-list d-flex flex-column flex-xl-row">
  <!-- <div v-if="true" class="deploy-list d-flex flex-column flex-xl-row"> -->
    <div class="deploy-history-wrapper">
      <KubernetesDeployList
        ref="historyList"
        :catalog-deploy-list="state.deployList"
        :on-refresh-deploy-list="refreshDeployList"
        :current-deploy-info="state.currentDeployInfo"
        @changeItem="onChangeDeploy"
        :callbackCatalogList="getDeployListCall"
      />
    </div>
  </div>

  <!-- state.deployList에 데이터가 없을경우 노출 -->
  <div v-else class="d-flex row gy-5 col-12 p-0 m-0">
    <div class=" p-0 m-0">
      <div class="border border-gray-300 border-dashed rounded border-3">
        <div class="d-flex flex-column pt-12 p-7 align-items-center ">
            <div class="d-flex flex-wrap align-items-center mb-5 text-gray-600">
              <div class="fs-3 fw-bolder col-12 text-center mb-2">
                  {{ $t("project.catalog.notExistCatalogDeploy") }}
              </div>
              <div class="fs-6 fw-bolder  col-12 text-center">  
                  {{ $t("project.catalog.createCatalogDeployTxt") }}
              </div>
              <div class="d-flex align-content-center mt-8 ms-auto me-auto">
                <button class="flex-fill btn btn-primary" @click="gotoNewPage">
                  {{ $t("project.catalog.newCatalogDeploy") }}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>    
  </div>
</template>

<script lang="ts">
import { getCurrentInstance, nextTick, onMounted, defineComponent, computed, ref } from "vue";
import { useI18n } from "vue-i18n";
import { useRoute, useRouter, onBeforeRouteLeave } from "vue-router";
import { useToast } from "vue-toastification";
import { useStore } from "vuex";

// component
import { AsideButtonProp } from "@/components/base/menu/AsideButtonProp";
import asidePrimaryController from "@/layout/service/aside/AsidePrimaryController";
import asideSecondaryController from "@/layout/service/aside/AsideSecondaryController";
import subMenuConfig, {setMenuPermission} from "@/views/projects/menus/SubMenu";
// import projectListDocMenuConfig, {setMenuPermission}  from "@/views/projects/menus/ProjectListSubmenu";
//add
// import share from '@/store/modules/share'
import {setCurrentPageBreadcrumbs, setCurrentPageTitle} from "@/core/helpers/breadcrumb";
import { getCatalogDeployList, getCatalogDeployDetailInfo } from "@/api/catalogDeploy";

import KubernetesDeployList from "./kubernetes/KubernetesDeployList.vue";
import { DEPLOY_TYPE_ID } from "@/constant/deploy";


export default defineComponent({
  name: "Deploy",
  components: {
    KubernetesDeployList,
  },
  setup() {

    let { t, locale } = useI18n();

    const router = useRouter();
    const route = useRoute();
    const toast = useToast();
    const store = useStore();
    const instance = getCurrentInstance();

    const state = ref({
      // 전체 리스트
      deployList: [] as any, 

      // 선택한 Deploy
      currentDeployInfo: { infoItems: [] },
      
    });

      // 스토어에 담겨있는 회사 정보 / 서비스 그룹 정보 
    // const companyInfo:any = computed(()=> share.state.companyInfo);
    // const serviceGroupInfo:any = computed(()=> share.state.serviceGroupInfo);

    /* ============================================================================================================= */
    // 라이프사이클
    /* ============================================================================================================= */

    onMounted(() => {
      nextTick(() => {
        init();
        viewCreated();
      });
    });

    onBeforeRouteLeave((to, from, next) => {
      next();
    });

    function init() {
      initMenu();
      initTitle();
    }

    function initTitle() {
      // setCurrentPageBreadcrumbs(t("breadcrumb.project.catalogDeployList"), [
      //   companyInfo.value.companyName,
      //   serviceGroupInfo.value.serviceGroupName,
      // ]);

      setCurrentPageBreadcrumbs(t("breadcrumb.project.catalogDeploy"), []);
    }
    
    function initMenu() {
      const menus = [
        // new AsideButtonProp(1,'Companies', false, "images/icons/menu/companies/company.svg", "CompanyList", null, null),
        // new AsideButtonProp(1,'ServiceGroups', false, "images/icons/menu/serviceGroups/serviceGroup.svg", "ServiceGroupList", null, route.params),
        // new AsideButtonProp(1,'Projects', true, "images/icons/menu/projects/projects.svg", "ProjectList", projectListDocMenuConfig, route.params),
      ];
      asidePrimaryController.setMenu(menus);
      // asideSecondaryController.setMenu('Service Group', projectListDocMenuConfig, route.params, setMenuPermission, authMenu.value);
      asideSecondaryController.setMenu("Catalog Deploy", subMenuConfig, route.params, setMenuPermission, null);
    }

    async function viewCreated() {
      refreshDeployList();
    }

    /*
      deploy 목록 구하기
      call : deploy 항목이 추가되거나 삭제될때 호출.
    */
    async function getDeployListCall() {
      
      let success = false;

      try {
        state.value.deployList = [];

        // const response = await getCatalogDeployList(serviceGroupInfo.value.serviceGroupId);
        const response = await getCatalogDeployList({});
        
        state.value.deployList = response.data || [];

        if(state.value.deployList.length !== 0){
          (state.value.deployList as any).forEach(item =>{
            item.deployType = DEPLOY_TYPE_ID.KUBERNETES;
            return item
          })
        }

        success = true;
      } catch (error) {
        console.error(error);
        state.value.deployList = [];
      }
      return success;
    }
    
    // 처음 화면 로딩될때 + 히스토리가 추가되거나 삭제 될때 실행
    async function refreshDeployList() {
    /*
      - deploy 리스트 구하기
      - 0 = 히스토리 offset
    */
      let success = await getDeployListCall();
      if (success) {
        if (state.value.deployList.length > 0)
          nextTick(() => {
            _updateDeployDetailInfoAndHistoryList((state.value.deployList[0] as any).catalogDeployId);
          });
        else {
          console.log("deployList 개수가 0");
        }
      } else {
        toast.error("No data"); // 메시지 출력 후
      }
      return success;
    }


    // deploy가 변경되는 되는 경우
    // 선택한 deploy에 맞게 리스트 및 기타 항목 초기화
    async function onChangeDeploy(deployInfo, index) {
      // 상세 정보와 히스토리 리스트 업데이트
      await _updateDeployDetailInfoAndHistoryList(deployInfo.catalogDeployId);
    }



    // 상세정보와 히스토리 정보 업데이트 처리
    async function _updateDeployDetailInfoAndHistoryList(catalogDeployId) {
    
      let deployDetailInfo:any = null;
      
      try {
        let response = await getCatalogDeployDetailInfo(catalogDeployId);
       
        deployDetailInfo = response.data;

        deployDetailInfo.deployType = DEPLOY_TYPE_ID.KUBERNETES;

      } catch (error) {
        alert("에러, 임시 처리, 추후 변경 해야함.");
        return;
      }

      // _updateHistoryList(deployDetailInfo);
    }
    
    // 히스토리만 다시 부르기
    const historyList = ref(instance?.refs.historyList);

    function _updateHistoryList(deployDetailInfo) {
      state.value.currentDeployInfo = deployDetailInfo;
      state.value.currentDeployInfo.infoItems = [];
      
      nextTick(() => {
        if (instance?.refs.historyList) {
          (instance?.refs.historyList as any).updateHistoryList(
            deployDetailInfo
          );
        }
      });
    }

    // 새 배포 클릭시 동작
    function gotoNewPage() {
      router.push({ path: "new" });
    }

    return {
      state,
      gotoNewPage,
      onChangeDeploy,
      refreshDeployList,
      historyList,
      getDeployListCall,
    };
  },
});
</script>

<style scoped>
.deploy-history-wrapper {
  width: 100%;
}
</style>