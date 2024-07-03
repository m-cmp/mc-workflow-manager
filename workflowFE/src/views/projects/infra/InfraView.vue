<template>
  <div class="app-container detail-page card">
    <div class="card-body py-6">
      <div class="tab-content">
        <div class="card-header" style="padding-left: 0px">
          <div class="card-title m-0">
            <h3 class="fw-bolder m-0">
              {{ $t("service.infra.title") }} 정보
            </h3>
          </div>
          <!--end::Card title-->

          <!--begin::Action-->
          <div>
            <a
              @click="gotoEditPage()"
              style="margin-right: 10px;">
              <span class="svg-icon svg-icon-3 mr-5">
                <button class="btn btn-primary">수정</button>
                <!-- <inline-svg src="images/icons/common/pen-to-square-solid.svg" /> -->
              </span>
            </a>
            <a
              data-bs-toggle="modal"
              data-bs-target="#kt_modal_1">
              <!-- class="btn btn-icon btn-bg-light btn-active-color-primary btn-sm"> -->
              <span class="svg-icon svg-icon-3">
                <button class="btn btn-primary">삭제</button>
                <!-- <inline-svg src="images/icons/common/trash-xmark-solid.svg" /> -->
              </span>
            </a>
          </div>
          <!--end::Action-->
        </div>
        <div class="fs-6 text-gray-600">
          <p>
            {{ $t("common.createdDate") }} {{ state.editData.regDate }}
            <template v-if="state.editData.modDate">
              / {{ $t("common.updatedDate") }}
              {{ state.editData.modDate }}
            </template>
          </p>
        </div>


        <el-form
          class="content-wrapper"
          ref="viewForm"
          label-position="top"
          label-width="100px"
          :model="state.editData"
          autocomplete="on"
        >
            <!-- 구분(providerCd) -->
            <el-form-item inline-message="true" class="col-md-6">
              <span class="field-label">
                {{ $t("service.clusterConfig.clusterPrividerCd") }}
              </span>

              <div class="duplicate-name-wrapper d-flex">
                <el-select 
                  class="col-md-12"
                  v-model="state.editData.providerCd"
                  readonly
                  :prefix-icon="null"
                  style="padding-right: 0px !important;">
                  <!-- <el-option 
                    v-for="item in state.providerList"
                    :key="item.commonCd"
                    :label="item.commonCd"
                    :value="item.commonCd"
                  /> -->
                </el-select>
              </div>
            </el-form-item>

          <!-- 클러스터 명 -->
          <el-form-item inline-message="true" prop="k8sName">
            <span class="field-label">{{ $t("service.clusterConfig.clusterConfigName") }}</span>
            <div class="duplicate-name-wrapper d-flex">
              <el-input
                v-model="state.editData.k8sName"
                :placeholder="$t('organization.setting.k8sConfig.msgIdInput')"
                readonly
              />
            </div>
          </el-form-item>

          <!-- 내용 -->
          <el-form-item inline-message="true" prop="content">
            <span class="field-label">
              {{ $t("organization.setting.k8sConfig.content") }}
            </span>
            <el-input
              v-model="state.editData.content"
              type="textarea"
              rows="10"
              readonly
            />
          </el-form-item>
          
          <!-- 설명 -->
          <el-form-item inline-message="true" prop="k8sDesc" class="desc-field-form">
            <div>
              <div style="float: left">
                <span class="field-label">
                  {{ $t("common.descriptionOpt") }}
                </span>
              </div>
            </div>
            <el-input
              v-model="state.editData.k8sDesc"
              type="textarea"
              rows="3"
              readonly
            />
          </el-form-item>

          <!-- argoCd URL -->
          <el-form-item inline-message="true" prop="argocdUrl">
            <span class="field-label">
              {{ $t("service.clusterConfig.argocdUrl") }}
            </span>
            <div class="duplicate-name-wrapper d-flex">
              <el-input
                v-model="state.editData.argocdUrl"
                :placeholder="$t('service.clusterConfig.msgArgocdUrl')"
                readonly
              />
            </div>
          </el-form-item>

          <!-- argoCd UserName / password  -->
          <el-row class="container-xl-max">
            
            <!-- argoCd UserName -->
            <el-form-item inline-message="true" prop="argocdUsername" class="col-md-6">
              <span class="field-label">
                {{ $t("service.clusterConfig.argocdUsername") }}
              </span>
              <div class="duplicate-name-wrapper d-flex">
                <el-input
                  class="col-md-10"
                  v-model.trim="state.editData.argocdUsername"
                  :placeholder="$t('service.clusterConfig.msgargocdUsername')"
                  readonly
                />
              </div>
            </el-form-item>

            <!-- argoCd Password -->
            <el-form-item inline-message="true" prop="argocdPassword" class="col-md-6">
              <span class="field-label">
                {{ $t("service.clusterConfig.argocdPassword") }}
              </span>
              <div class="duplicate-name-wrapper d-flex">
                <el-input
                  class="col-md-10"
                  type="password"
                  v-model.trim="state.editData.argocdPassword"
                  :placeholder="$t('service.clusterConfig.msgArgocdPassword')"
                  readonly
                />
              </div>
            </el-form-item>
          </el-row>
          

          <!-- argoCd Token -->
          <el-form-item inline-message="true" prop="argocdToken">
            <span class="field-label">
              {{ $t("service.clusterConfig.argocdToken") }}
            </span>
            <div class="duplicate-name-wrapper d-flex">
              <el-input
                v-model="state.editData.argocdToken"
                :placeholder="$t('service.clusterConfig.msgArgocdToken')"
                readonly
              />
            </div>
          </el-form-item>
        </el-form>
        
        <div>
          <span class="link-action cursor-pointer" @click.prevent="gotoListPage()">
            <button class="btn btn-primary btn-sm">목록으로</button>
            <!-- <i class="el-icon-back"/> -->
          </span>
        </div>
      </div>
    </div>
  </div>
  <ConfirmModal ref="confirmModal" :content="contentMsg" @fnParent="onRemove" />
</template>

<!-- ################################################################################################################### -->

<script lang="ts">
import {computed, getCurrentInstance, nextTick, onMounted, ref} from "vue";
import { useRoute, useRouter } from "vue-router";
import asidePrimaryController from "@/layout/service/aside/AsidePrimaryController";
import { AsideButtonProp } from "@/components/base/menu/AsideButtonProp";
import asideSecondaryController from "@/layout/service/aside/AsideSecondaryController";
import { useI18n } from "vue-i18n";
import {setCurrentPageBreadcrumbs, setCurrentPageTitle} from "@/core/helpers/breadcrumb";
import { useToast } from "vue-toastification";
// import projectListDocMenuConfig, {setMenuPermission} from "@/views/projects/menus/ProjectListSubmenu";
import subMenuConfig, {setMenuPermission} from "@/views/projects/menus/SubMenu";
import {
  _validateName,
  _validateLength,
  _validateURL,
  _valdateLimitLength,
} from "@/utils/input-validate";
import {
  getKubernetesConfig,
  deleteKubernetesConfig,
} from "@/api/kubernetesConfig";
// import serviceListDocMenuConfig from "@/views/services/submenu/ServiceListSubmenu";

import StageCheckbox from "@/components/deployStage/StageCheckbox.vue";
import ConfirmModal from "@/components/messagebox/ConfirmModal.vue";

import { useStore } from "vuex"
import { clusterConfigActions } from '@/store/modules/clusterConfig';



// import share from '@/store/modules/share'

export default {
  name: "CredentialView",
  components: { StageCheckbox, ConfirmModal },
  props: {},
  setup(props) {
    
    let { t, locale } = useI18n();

    const instance = getCurrentInstance();
    const router = useRouter();
    const route = useRoute();
    const toast = useToast();
    const store = useStore();

    const state = ref({
      isFirstDataLoadingCompleted: false,
      editData: computed(()=> store.state.clusterConfig.clusterDetailInfo),
    });
    
    // const companyInfo = computed(() => store.state.share.companyInfo);
    // const serviceGroupInfo = computed(() => store.state.share.serviceGroupInfo);
    /* ============================================================================================================= */
    // 라이프사이클
    /* ============================================================================================================= */

    onMounted(() => {
      nextTick(() => {
        init();
      });
    });
    function init() {
      initMenu();
      initTitle();
      initData();
    }

    function initMenu() {
      const menus = [
          // new AsideButtonProp(1,'Companies', false, "images/icons/menu/companies/company.svg", "CompanyList", null, route.params),
          // new AsideButtonProp(1,'ServiceGroups', false, "images/icons/menu/serviceGroups/serviceGroup.svg","ServiceGroupList", null, route.params),
          // new AsideButtonProp(1,'Projects', true, "images/icons/menu/projects/projects.svg", "ProjectList", projectListDocMenuConfig, route.params),
      ];
    
      asidePrimaryController.setMenu(menus);
      // asideSecondaryController.setMenu("Service Group", serviceListDocMenuConfig, route.params, null, authMenu.value);
      // asideSecondaryController.setMenu('Service Group', projectListDocMenuConfig, route.params, null, authMenu.value);
      asideSecondaryController.setMenu("Cluster", subMenuConfig, route.params, setMenuPermission, null);
    }

    function initTitle() {
      /* 타이틀 & 패스 */
      // setCurrentPageBreadcrumbs( t("service.clusterConfig.clusterConfigOf"), [
      //     companyInfo.value.companyName,
      //     serviceGroupInfo.value.serviceGroupName
      // ]);

      setCurrentPageBreadcrumbs(t("service.infra.title"), []);
    }
    
    async function initData() {
      store.dispatch(clusterConfigActions.NAMESPACE + "/" + clusterConfigActions.LOAD_CLUSTER_DETAIL_INFO, route.params.k8sId);
    }
    /* ================================================================================================================= */
    // 이벤트 처리
    /* ================================================================================================================= */
    function gotoListPage() {
      router.push({ path: "../list" });
    }

    function gotoEditPage() {
      router.push({
        path: "../edit/" + route.params.k8sId,
      });
    }

    //add confirm modal
    const confirmModal = ref(null);
    const contentMsg = ref(t("msg.deleteConfirm"));

    //add remove memver function
    const onRemove = () => {
      onDeleteItem();
      (instance as any).refs.confirmModal.closePop();
    };

    function onDeleteItem() {
      const params = route.params.k8sId;
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
        gotoListPage();
        return;
      } catch (error) {
        console.log(error);
        toast.error(t("msg.runFail"));
      }
    }

    return {
      state,
      instance,
      confirmModal,
      contentMsg,
      gotoListPage,
      gotoEditPage,
      onDeleteItem,
      onRemove,
    };
  },
};
</script>

<style scoped>
</style>