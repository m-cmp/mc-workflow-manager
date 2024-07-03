<template>
  <div class="app-container normal-page card">
    <div class="card-body py-6">
      <div class="tab-content">
        <div class="card-header" style="padding-left: 0px">
          <div class="card-title m-0">
            <h3 class="fw-bolder m-0">
              {{ $t("service.clusterConfig.clusterConfigOf") }} 수정
            </h3>
          </div>
        </div>
        <el-form
          ref="newItemForm"
          class="content-wrapper"
          label-position="top"
          label-width="100px"
          :model="state.editData"
          :rules="state.inputRules"
          autocomplete="on"
        >
        
          <!-- 구분(providerCd) -->
          <el-form-item inline-message="true">
            <span class="field-label required">
              {{ $t("service.clusterConfig.clusterPrividerCd") }}
            </span>

            <div class="duplicate-name-wrapper d-flex">
              <el-select 
                class="col-md-12"
                v-model="state.editData.providerCd"
                disabled>
                <el-option 
                  v-for="item in state.providerList"
                  :key="item.commonCd"
                  :label="item.commonCd"
                  :value="item.commonCd"
                />
              </el-select>
            </div>
          </el-form-item>

          <!-- 클러스터 명 / 중복체크 -->
          <el-form-item inline-message="true" prop="k8sName">
            <span class="field-label required">{{ $t("service.clusterConfig.clusterConfigName") }}</span>
            <div class="duplicate-name-wrapper d-flex">
              <el-input
                v-model.trim="state.editData.k8sName"
                :placeholder="$t('organization.setting.k8sConfig.msgIdInput')"
                @change="onChangeName"
                disabled
              />
              <el-button
                v-if="state.isDuplicateCheck == false"
                type="primary"
                @click="onDuplicateCheck">
                {{ $t("common.duplicateCheck") }}
              </el-button>

              <el-button
                v-if="state.isDuplicateCheck == true"
                type="success"
                icon="el-icon-success">
                {{ $t("common.duplicateCheck") }}
              </el-button>
            </div>
          </el-form-item>

          <!-- 내용 -->
          <el-form-item inline-message="true" prop="content">
            <span class="field-label required">
              {{ $t("organization.setting.k8sConfig.content") }}
            </span>
            <el-input
              v-model="state.editData.content"
              type="textarea"
              rows="10"
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

              <div style="float: right">
                <span class="txt-info" v-if="state.editData.k8sDesc">
                  {{ state.editData.k8sDesc.length }}/250{{ $t("common.limitCharacterGuide") }}
                </span>
              </div>
            </div>
            <el-input
              v-model="state.editData.k8sDesc"
              type="textarea"
              rows="3"
            />
          </el-form-item>

          <!-- argoCd URL -->
          <el-form-item inline-message="true" prop="argocdUrl">
            <span class="field-label required">
              {{ $t("service.clusterConfig.argocdUrl") }}
            </span>
            <div class="duplicate-name-wrapper d-flex">
              <el-input
                v-model="state.editData.argocdUrl"
                :placeholder="$t('service.clusterConfig.msgArgocdUrl')"
                @change="onChangeArgoCd()"
              />
            </div>
          </el-form-item>

          <!-- argoCd UserName / password  -->
          <el-row class="container-xl-max">
            
            <!-- argoCd UserName -->
            <el-form-item inline-message="true" prop="argocdUsername" class="col-md-6">
              <span class="field-label required">
                {{ $t("service.clusterConfig.argocdUsername") }}
              </span>
              <div class="duplicate-name-wrapper d-flex">
                <el-input
                  class="col-md-10"
                  v-model.trim="state.editData.argocdUsername"
                  :placeholder="$t('service.clusterConfig.msgArgocdUsername')"
                  @change="onChangeArgoCd()"
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
                  @focus="onClickedPasswordInput()"
                />
              </div>
            </el-form-item>
          </el-row>
          

          <!-- argoCd Token -->
          <el-form-item inline-message="true" prop="argocdToken">
            <span class="field-label required">
              {{ $t("service.clusterConfig.argocdToken") }}
            </span>
            <div class="duplicate-name-wrapper d-flex">
              <el-input
                v-model="state.editData.argocdToken"
                type="password"
                :placeholder="$t('service.clusterConfig.msgArgocdToken')"
                @change="onChangeArgoCd()"
                @focus="onClickedTokenInput()"
              />
              <el-button
                  v-if="state.isConnectionCheck == false"
                  type="primary"
                  @click="onConnectionCheck">
                  {{ $t("service.clusterConfig.connectionCheck") }}
                </el-button>

                <el-button
                  v-if="state.isConnectionCheck == true"
                  type="success"
                  icon="el-icon-success">
                  {{ $t("service.clusterConfig.connectionCheck") }}
                </el-button>
            </div>
          </el-form-item>

          <!-- 취소 / 저장 버튼 -->
          <div class="submit-wrapper">
            <el-button
              class="btn btn-light"
              size="medium"
              @click="cancelForm()">
              {{ $t("common.cancel") }}
            </el-button>

            <el-button
              class="btn btn-primary"
              size="medium"
              @click="submitForm()">
              {{ $t("common.save") }}
            </el-button>
          </div>
        </el-form>
      </div>
    </div>
  </div>
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
import subMenuConfig, {setMenuPermission} from "@/views/projects/menus/SubMenu";
// import projectListDocMenuConfig, {setMenuPermission} from "@/views/projects/menus/ProjectListSubmenu";
import {
  _validateName,
  _validateLength,
  _validateURL,
  _valdateLimitLength,
  _validateAlphanumericUnderbarHyphen,
} from "@/utils/input-validate";
import { duplicateCheck, updateKubernetesConfig, connectionCheck } from "@/api/kubernetesConfig";
import StageCheckbox from "@/components/deployStage/StageCheckbox.vue";

// import serviceListDocMenuConfig from "@/views/services/submenu/ServiceListSubmenu";
import { useStore } from 'vuex'
import { clusterConfigActions } from '@/store/modules/clusterConfig';
import _ from 'lodash';

export default {
  name: "KubernetesNew",
  components: { StageCheckbox },
  props: {},
  setup(props) {
    /* ============================================================================================================= */
    // 다국어 설정
    /* ============================================================================================================= */

    let { t, locale } = useI18n();


    /* ============================================================================================================= */
    // 데이터
    /* ============================================================================================================= */

    const instance = getCurrentInstance();
    const router = useRouter();
    const route = useRoute();
    const toast = useToast();
    const store = useStore();
    
    const state = ref({
      providerList: computed(()=> store.state.clusterConfig.providerList),
      stageList: computed(()=> store.state.clusterConfig.stageList),

      editData: computed(()=> store.state.clusterConfig.clusterDetailInfo),

      isDuplicateCheck: true,
      isConnectionCheck: false,
      isChangedPassword: false,
      isChangedToken: false,

      // validation rule 처리
      inputRules: {
        k8sName: [
          {
            required: true,
            trigger: "blur",
            validator: _validateName,
            labelName: "Name",
          },
          {
            required: true,
            trigger: "blur",
            validator: _validateLength,
            length: 3,
          },
        ],
        content: [
          {
            required: true,
            trigger: "blur",
            validator: _validateName,
            labelName: "ID",
          },
          {
            required: true,
            trigger: "blur",
            validator: _validateLength,
            length: 2,
          },
        ],
        description: [
          {
            required: false,
            trigger: "blur",
            validator: _valdateLimitLength,
            length: 250,
          },
        ],
        argocdUrl: [
          {
            required: true,
            trigger: "blur",
            validator: _validateURL,
            labelName: "URL",
          },
        ],
        argocdUsername: [
          {
            required: true,
            trigger: "blur",
            validator: _validateName,
            labelName: "ID",
          },
        ],
        // argocdPassword: [
        //     {
        //       required: true,
        //       trigger: "blur",
        //       validator: _validateName,
        //       labelName: "Password",
        //     },
        //     {
        //       required: true,
        //       trigger: "blur",
        //       validator: _validateLength,
        //       length: 4,
        //     },
        // ],
        argocdToken: [
          {
            required: true,
            trigger: "blur",
            validator: _validateName,
            labelName: "API Token",
          },
          {
            required: true,
            trigger: "blur",
            validator: _validateLength,
            length: 4,
          },
        ]
      },
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

    function initData() {
      store.dispatch(clusterConfigActions.NAMESPACE + "/" + clusterConfigActions.LOAD_CLUSTER_DETAIL_INFO, route.params.k8sId)
    }

    /* ============================================================================================================= */
    // 데이터 관리
    /* ============================================================================================================= */

    /* ================================================================================================================= */
    // 이벤트 처리
    /* ================================================================================================================= */

    function onChangeName() {
      state.value.isDuplicateCheck = false;
    }
    function onChangeArgoCd() {
      state.value.isConnectionCheck = false;
    }

    async function onDuplicateCheck() {
      try {
        const result = await duplicateCheck(state.value.editData.k8sName);
        console.log(result);
        if (result.data === false) {
          state.value.isDuplicateCheck = true;
          toast.success(t("msg.availableName"));
        } else {
          toast.error(t("msg.alreadyName"));
          state.value.isDuplicateCheck = false;
        }
      } catch (error) {
        toast.error(t("msg.runFail"));
      }
    }
    
    async function onConnectionCheck() {

      // if(state.value.isChangedPassword) {
      //   state.value.editData.argocdPassword = btoa(state.value.editData.argocdPassword)
      // }
      // if(state.value.isChangedToken) {
      //   state.value.editData.argocdToken = btoa(state.value.editData.argocdToken)
      // }

      let encodingPwd = btoa(state.value.editData.argocdPassword)
      let encodingToken = btoa(state.value.editData.argocdToken)

      const param = {
        argocdUrl: state.value.editData.argocdUrl,
        argocdId: state.value.editData.argocdUsername,
        argocdPassword: encodingPwd,
        argocdToken: encodingToken,
      }
      try {
        const result = await connectionCheck(param);
        console.log(result);
        if (result.data === true) {
          state.value.isConnectionCheck = true;
          toast.success(t("msg.connectSuccess"));
        } else {
          toast.error(t("msg.connectFailed"));
          state.value.isConnectionCheck = false;
        }
      } catch (error) {
        console.error(error)
        toast.error(t("msg.runFail"));
      }
    }
    function gotoListPage() {
      router.push({ path: "../list" });
    }

    function cancelForm() {
      gotoListPage();
    }

    function submitForm() {

      if (state.value.isDuplicateCheck == false) {
        toast.error(t("msg.msgDuplicate"));
        return false;
      }
      if (state.value.isConnectionCheck == false) {
        toast.error(t("msg.msgConnect"));
        return false;
      }

      (instance as any).refs["newItemForm"].validate((valid) => {
        if (valid) {
          (async () => {
            try {
              
              let requestParam = _.cloneDeep(state.value.editData);
              let encodingPwd = btoa(state.value.editData.argocdPassword);
              let encodingToken = btoa(state.value.editData.argocdToken);

              requestParam.argocdPassword = encodingPwd;
              requestParam.argocdToken = encodingToken;

              const response = await updateKubernetesConfig(requestParam) as any;

              if (response.code === 200) {
                toast.success(t("msg.regiComplete"));
                gotoListPage();
              } else {
                toast.error(t("msg.runFail"));
              }

              console.log("저장전 데이터 ", state.value.editData);
            } catch (error) {
              console.log("error submit!!", error);
              toast.error(t("msg.runFail"));
            }
          })();
        } else {
          console.log("error submit!!");
          return false;
        }
      });
    }

    function onClickedPasswordInput() {
      state.value.editData.argocdPassword = '';
      state.value.isChangedPassword = true;
      onChangeArgoCd();
    }

    function onClickedTokenInput() {
      state.value.editData.argocdToken = '';
      state.value.isChangedToken = true;
      onChangeArgoCd();
    }

    /* ============================================================================================================= */

    return {
      state,
      instance,
      onChangeName,

      onDuplicateCheck,
      onClickedPasswordInput,
      onClickedTokenInput,

      cancelForm,
      submitForm,

      onChangeArgoCd,
      onConnectionCheck,
    };
  },
};
</script>

<style scoped>
.submit-wrapper {
  text-align: right;
}
</style>