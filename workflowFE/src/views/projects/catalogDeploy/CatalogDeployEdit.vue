<template>
  <div
    v-if="state.isFirstDataLoadingCompleted"
    data-page-id="project-deploy-edit"
    class="app-container normal-page"
  >
    <header class="header">
      <h2>
        {{ $t("authority.catalogDeploy.catalogDeploy.update") }} - <span class="page-title-sub">{{ state.editData.deployName }}</span>
      </h2>
    </header>

    <StageMenuComponentList
      :provider-cd="state.currentProviderCd"
      :edit-mode="state.EDIT_MODE.EDIT"
    />
    
    <el-form
      ref="editForm"
      class="contents-wrapper_catalog"
      label-position="top"
      label-width="100px"
      :model="state.editData"
      autocomplete="on"
    >
      <!-- 프로젝트 명 -->
      <!-- <el-form-item>
        <span class="field-label">
          {{ $t("project.deploy.selectProjectTitle") }}
        </span>
        <el-select
          disabled=true
          v-model="state.editData.projectName"
          style="width:100%"
        >
        </el-select>
      </el-form-item> -->

      <!-- Nexus Repository-->
			<el-form-item class="mb-5" inline-message="true" prop="nexusId">
				<span class="field-label required">
					{{ $t('project.catalog.nexusRepo') }}
				</span>
				<el-select  
					v-model="state.editData.nexusId"
            disabled=true
            style="width: 100%; margin-top: 10px;"
        >
					<el-option
						key="empty"
						value=""
						:label="$t('project.catalog.selectNexusRepo')"
					>
					</el-option>
					<el-option 
						v-for="nexusRepository in state.nexusRepositoryList"
						:key="nexusRepository.ossId"
						:label="nexusRepository.ossName"
						:value="nexusRepository.ossId"
						>
						{{ nexusRepository.ossName }}
					</el-option>
				</el-select>
			</el-form-item>

			<div style="display: flex; justify-content: space-between;">
        <!-- <EmptyHieratchyEditList 
          :edit-mode="state.EDIT_MODE.EDIT"
          style="width: 48%;"
        /> -->
        <!-- 카탈로그 -->
        <el-form-item class="mt-5" inline-message="true" style="width: 48%;">
					<span class="field-label required">
						{{ $t("project.catalog.catalog") }}
					</span>
					<el-select 
            disabled="true"
						v-model="state.editData.catalogName"
						style="width: 100%"
					>
						<el-option
							key="empty"
							value=""
							:label="$t('project.catalog.msgSelectCatalog')"
						>
						</el-option>
						<el-option
							v-for="item in state.catalogList"
							:key="item.data.catalogName"
							:label="item.text"
							:value="item.data.catalogName"
						/>
					</el-select>
				</el-form-item>

        <!-- 배포명 -->
        <el-form-item class="mt-5" style="width: 50%;">
          <span class="field-label required">
            {{ $t("project.catalog.catalogDeployName") }}</span>
          <div class="duplicate-name-wrapper">
            <el-input
              disabled=true
              v-model="state.editData.deployName"
              :placeholder="$t('project.catalog.msgInputDeployName')"
            />
          </div>
        </el-form-item>
      </div>

      
			<!-- Yaml -->
			<!-- <div v-if="state.editData.k8sId" style="margin-top: 30px;"> -->
			<div style="margin-top: 30px;">
				<!-- <div style="margin-bottom: 10px;">
					<span class="field-label">
						{{ $t("project.deploy.kubernetesDeploy.deployCopyFrom") }}
					</span>
				</div>

				<div class="deploy-copy-wrapper">
					<el-select
						v-model="state.selectedCopyDeployItem"
						class="deploy-list"
						style="width: 87%; margin-right: 10px;"
					>
						<el-option key="empty" :label="$t('project.deploy.kubernetesDeploy.msgSelectCopyDeploy')" value="" />
						<el-option
							v-for="(item, index) in state.deployNameList"
							:key="index + '_' + item.deployName"
							:label="item.deployName"
							:value="item.deployName"
						/>
					</el-select>

					<el-button
						class="copy-button"
						:disabled="state.selectedCopyDeployItem == ''"
						type="primary"
						@click="onSelectedCopyDeployItem"
						style="width: 12%;"
						>
						{{ $t("project.deploy.kubernetesDeploy.copy") }}
					</el-button>
				</div> -->

				<div style="margin-top: 50px;">
					<span class="field-label required">
						{{$t("project.catalog.Yaml")}}
					</span>

					<!-- Yaml 버튼 -->
					<el-row type="flex"  justify="end">
						<el-button type="primary" size="mini" @click="onClickPreviewYaml">
							Values.Yaml
						</el-button>
					</el-row>

					<el-input
						type="textarea"
						v-model="state.editData.catalogDeployYaml"
						rows="30"
						:placeholder="$t('project.catalog.msgInputYaml')"
					/>
				</div>
      </div>
    </el-form>

    <footer style="margin-top: 20px; display:flex; justify-content: space-between;">
      <div>
        <el-button class="btn btn-light" @click="onCancel">
          목록으로
        </el-button>
      </div>
      <div
      >
        <el-button class="btn btn-light" @click="onCancel">
          {{ $t("common.cancel") }}
        </el-button>
        <el-button class="btn btn-primary" @click="submitForm">
            <span v-if="!state.isSaving" class="indicator-label"> 
              {{ $t("common.edit") }} 
            </span>
            <span v-if="state.isSaving">
              Please wait...
              <span class="spinner-border spinner-border-sm align-middle ms-2"></span>
            </span>
        </el-button>
        <el-button 
          class="btn btn-success"
          :disabled="state.isChangedYaml || state.isSaving" 
          @click="onClickRunDeploy">
        {{ $t("project.catalog.run") }}
        </el-button>
      </div>
      <YamlModal ref="yamlModal" /> 
      
    </footer>
  </div>
</template>

<script lang="ts">
import { getCurrentInstance, nextTick, onMounted, ref, computed, watch } from "vue";
import { useI18n } from "vue-i18n";
import { AsideButtonProp } from "@/components/base/menu/AsideButtonProp";
import { useRoute, useRouter, onBeforeRouteLeave } from "vue-router";
import asidePrimaryController from "@/layout/service/aside/AsidePrimaryController";
import asideSecondaryController from "@/layout/service/aside/AsideSecondaryController";
import subMenuConfig, {setMenuPermission} from "@/views/projects/menus/SubMenu";

import { useToast } from "vue-toastification";
import { setCurrentPageBreadcrumbs } from "@/core/helpers/breadcrumb";
import { useStore } from "vuex";
import {useLoading} from 'vue-loading-overlay';

import loaderMixin from "@/mixins/loaderMixin";
import EmptyHieratchyEditList from "./common/components/EmptyHieratchyEditList.vue";

import KubernetesDeployEdit from "./kubernetes/KubernetesDeployEdit.vue";
import { EDIT_MODE } from "@/constant/common";
import StageMenuComponentList from "./common/components/StageMenuComponentList.vue";
import BuildPropertiesPanel from "./common/panels/BuildPropertiesPanel.vue";
import { catalogDeployKubernetesNow } from "@/api/kubernetesDeploy";
import { deployActionTypes } from "@/store/modules/deploy";
// import share from '@/store/modules/share';
import { getYaml, getKubernetesCatalogDeployNameList } from '@/api/kubernetesDeploy';

import YamlModal from "./common/panels/YamlModal.vue";

import _ from 'lodash';

export default {
  name: "CatalogDeployEdit",
  components: {
    KubernetesDeployEdit,
    StageMenuComponentList,
    EmptyHieratchyEditList,
    BuildPropertiesPanel,
    YamlModal
  },
  mixins: [loaderMixin],

  props: {},
  setup() {
    let { t, locale } = useI18n();
    
    const router = useRouter();
    const route = useRoute();
    const instance = getCurrentInstance() as any;
    const toast = useToast();
    const store = useStore();
    const vueLoading = useLoading();

    const state = ref({
      editData: computed(() => store.state.deploy.catalogEditData || {}),
      
      isSaving : false,
      isFirstDataLoadingCompleted: false,
      deployApproveFlowList: [] as any,

      currentProviderCd: computed(() => store.state.deploy.catalogEditData.providerCd),
      // currentStageCd: computed(() => store.state.deploy.catalogEditData.stageCd),

      // stageInfo: computed(() => store.state.deploy.stageInfo),
      nexusRepositoryList: computed(() => store.state.deploy.nexusRepositoryList),
      catalogList: computed(() => store.state.deploy.catalogList),

      preCatalogDeployYaml:'',
      isChangedYaml:false,

      EDIT_MODE: computed(() => EDIT_MODE),
      deployId: computed(() => route.params.deployId),


			deployNameList: [] as any,
			selectedCopyDeployItem: '' as any,
    });

    // const companyInfo:any = computed(()=> share.state.companyInfo);
    // const serviceGroupInfo:any = computed(()=> share.state.serviceGroupInfo);

    onMounted(() => {
      nextTick(() => {
        init();
      });
    });

    async function init() {
      initMenu();
      initTitle();
      state.value.isFirstDataLoadingCompleted = false;
			// await setCopyCatalogDeployList();

      // 데이터 초기화      
      await store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.CLEAR_ALL_EDIT_DATA);
      // 스테이지 정보 가져오기
      // await store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.LOAD_STAGE_INFO);

      // Nexus Repository 정보 가져오기
      await store.dispatch(deployActionTypes.NAMESPACE+"/"+deployActionTypes.LOAD_NEXUS_REPOSITORY_LIST);
      
      let success;
      try {
        // 배포 정보 설정 시작
        success = await store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.START_CATALOG_UPDATE_EDIT_MODE, route.params.catalogDeployId);
        
        console.log("state.value.editDatastate.value.editData == ", state.value.editData)
        
        if (success == false) {
          toast.error(t("project.deploy.notDeployInfo"));
          gotoListPage();
          return;
        }

        await store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.LOAD_CATALOG_LIST, state.value.editData.nexusId);
        state.value.preCatalogDeployYaml = _.cloneDeep(state.value.editData.catalogDeployYaml);
        state.value.isChangedYaml = false;

        state.value.isFirstDataLoadingCompleted = true;
      } catch (error) {
        console.error("error ", error);
        gotoListPage();
      }
    }

    // 배포 버튼 활성화용
    watch(() => state.value.editData.catalogDeployYaml, () => {
      if(state.value.editData.catalogDeployYaml 
      != state.value.preCatalogDeployYaml) 
        state.value.isChangedYaml = true
      else 
        state.value.isChangedYaml = false
    })

    function initTitle() {
      setCurrentPageBreadcrumbs(t("breadcrumb.project.catalogDeploy"), []);
    }

    function initMenu() {
      const menus = [];
      asidePrimaryController.setMenu(menus);
      asideSecondaryController.setMenu("Catalog Deploy", subMenuConfig, route.params, setMenuPermission, null);
    }

    function gotoListPage() {
      router.push({ path: "../list" });
    }

    function onCancel() {
      gotoListPage();
    }

    async function submitForm(event) {
      event.stopPropagation();

      try {
        state.value.isSaving = true;
        state.value.editData.catalogDeployId = route.params.catalogDeployId
        await store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.START_UPDATE_CATALOG_EDIT, state.value.editData);
        state.value.preCatalogDeployYaml = _.cloneDeep(state.value.editData.catalogDeployYaml);
        state.value.isChangedYaml = false;
        toast.success(t("msg.modified"));
      } catch (error) {
        console.error(error);
        toast.error(t("msg.runFail"));
      }

      state.value.isSaving = false;
    }

		async function onClickRunDeploy() {
      let loader = vueLoading.show();

			const params = {
				catalogDeployId: route.params.catalogDeployId,
				catalogDeployYaml: state.value.editData.catalogDeployYaml
			}

      try{
        await catalogDeployKubernetesNow(params);
        toast.success(t("project.deploy.runDeploy"));
        loader.hide();
        gotoListPage();
      } catch(error) {
        console.log(error)
        toast.error(t("msg.runFail"));
      }

      loader.hide();
		}
    
		async function onSelectedCopyDeployItem() {
			let deployNameInfo = state.value.deployNameList.find((deployInfo) => {
				return deployInfo.deployName == state.value.selectedCopyDeployItem;
      });

      if (deployNameInfo == null) {
        return;
      } else {
        state.value.editData.catalogDeployYaml = deployNameInfo.catalogDeployYaml
      }
      
    }

		
		// async function setCopyCatalogDeployList() {
		// 	let params = {
		// 		serviceGroupId: serviceGroupInfo.value.serviceGroupId,
		// 	}
		// 	try {

		// 		let response = await getKubernetesCatalogDeployNameList(params)
		// 		state.value.deployNameList = response.data;

		// 	} catch (error) {
		// 		state.value.deployNameList = [];
		// 	}
		// }
		
    async function onClickPreviewYaml(event) {
			console.log(state.value.editData)
			let param = {
        // serviceGroupId: serviceGroupInfo.value.serviceGroupId,
        k8sId: state.value.editData.k8sId,
        nexusId: state.value.editData.nexusId,
        deployName: state.value.editData.deployName,
        catalogDeployId: state.value.editData.catalogDeployId,
        catalogName: state.value.editData.catalogName,
        catalogVersion: state.value.editData.catalogVersion,
      }

      let response = await getYaml(param);
      console.log("####onClickPreviewYaml");
			(instance?.refs.yamlModal as any).show(response.data);
    }

    return {
      state,
      gotoListPage,
      onCancel,
      submitForm,
      onSelectedCopyDeployItem,
      onClickPreviewYaml,
      onClickRunDeploy
    };
  },
};
</script>


<style scoped>
.header {
	height: 55px;
}
.el-form-item {
	height: 60px !important;
}
</style>