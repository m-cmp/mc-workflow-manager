<template>
	<div
		data-page-id="project-deploy-new"
		class="app-container normal-page"
	>
		<!-- "새 배포" Title -->
		<header class="header">
			<h2> {{ $t("project.catalog.newCatalogDeploy") }} </h2>
		</header>
		<!-- 
			스테이지 / 프로바이더 / 클러스터 
		-->
		<StageMenuComponentList 
			:stage-info="state.stageInfo"
			:stage-id="state.currentStageId"
			:deploy-type-id="state.currentDeployTypeId"
			:edit-mode="EDIT_MODE.NEW"
			:deploy-config-counts="state.deployConfigCounts"/>

		<!-- <StageMenuComponentList 
			v-if="state.stageInfo && state.stageInfo.length"
			:stage-info="state.stageInfo"
			:stage-id="state.currentStageId"
			:deploy-type-id="state.currentDeployTypeId"
			:edit-mode="EDIT_MODE.NEW"
			:deploy-config-counts="state.deployConfigCounts"/> -->

		<el-form
			ref="newForm"
			class="contents-wrapper_catalog"
			label-position="top"
			label-width="100px"
			:model="state.editData"
			:rules="state.inputRules"
			autocomplete="on"
		>

			<!-- 프로젝트 명 -->
			<!-- <el-form-item inline-message="true" style="margin-top: 30px;">
				<span class="field-label">
					{{ $t("project.deploy.selectProjectTitle") }}
				</span>
				<el-select v-model="state.editData.projectId"	style="width:100%">
					<el-option key="empty" value="" :label="$t('project.deploy.selectProjectName')"/>
					<el-option
						v-for="item in state.projectList"
						:key="item.value"
						:label="item.text"
						:value="item.value"
						@click="onClickProject(item)"
					/>
				</el-select>
			</el-form-item> -->

			<!-- Nexus Repository-->
			<el-form-item class="mb-5 mt-5" inline-message="true" prop="nexusId">
				<span class="field-label required">
					{{ $t('project.catalog.nexusRepo') }}
				</span>
				<el-select  
					v-model="state.editData.nexusId"
					@change="onValidateSelect('nexusId')"
					@blur="onValidateSelect('nexusId')"
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

			<!-- 카탈로그 / 카탈로그 배포명 -->
			<div style="display: flex; justify-content: space-between;">
				<!-- 카탈로그 -->
				<!-- <EmptyHieratchyEditList
					:edit-mode="state.EDIT_MODE.NEW"
					style="width: 48%;"
				/> -->
				<el-form-item class="mt-5" inline-message="true" style="width: 48%;" prop="catalogName">
					<span class="field-label required">
						{{ $t("project.catalog.catalog") }}
					</span>
					<el-select 
						v-model="state.editData.catalogName"
						@change="onValidateSelect('catalogName')"
						@blur="onValidateSelect('catalogName')"
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
							@click="onSelectedCatalogItem(item)"
							:key="item.data.catalogName"
							:label="item.text"
							:value="item.data.catalogName"
						/>
					</el-select>
				</el-form-item>
				
				<!-- 카탈로그 배포명 -->
				<el-form-item class="mt-5" inline-message="true" prop="deployName" style="width: 50%;">
					<span class="field-label required">
						{{ $t("project.catalog.catalogDeployName") }}
					</span>
					<div class="duplicate-name-wrapper">
						<el-input
							v-model.trim="state.editData.deployName"
							:placeholder="$t('project.catalog.msgInputCatalogDeployName')"
							@input="onChangeDuplicateCheck"
						/>

						<!-- 배포명 중복 체크 -->
						<el-button
							v-if="state.editData.isDuplicateCheck === false && !state.nameLengthLimitFlag"
							type="plain"
							disabled
							>
							{{ $t("common.duplicateCheck") }}
						</el-button>
						<el-button
							v-if="state.editData.isDuplicateCheck === false && state.nameLengthLimitFlag"
							type="primary"
							@click="duplicateChecked"
							>
							{{ $t("common.duplicateCheck") }}
						</el-button>
						<el-button
							v-if="state.editData.isDuplicateCheck === true"
							type="success"
							icon="el-icon-success">
							{{ $t("common.duplicateCheck") }}
						</el-button>
					</div>
				</el-form-item>
			</div>

			<!-- Yaml -->
			<!-- <div v-if="state.editData.k8sId" style="margin-top: 30px;"> -->
			<div>
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

				<el-form-item>
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
				</el-form-item>
			</div>
		</el-form>

		<footer v-if="hasDeployConfig" class="mt-5">
			<button class="btn btn-light me-3" @click="onCancel">
			{{ $t("common.cancel") }}
			</button>
			<button class="btn btn-primary" @click="submitForm">
				<span v-if="!state.isSaving" class="indicator-label"> 
					{{ $t("common.save") }} 
				</span>
				<span v-if="state.isSaving">
						Please wait...
						<span class="spinner-border spinner-border-sm align-middle ms-2"></span>
				</span>
			</button>
		</footer>
	</div>
	<YamlModal ref="yamlModal" />

</template>


<script lang="ts">

import {useI18n} from "vue-i18n";
import { computed, getCurrentInstance, nextTick, onMounted, onBeforeUnmount, onUnmounted, ref, watch} from "vue";
import {useStore} from "vuex";
import { useRoute, useRouter } from 'vue-router';
import {useToast} from "vue-toastification";
import validate from 'validate.js'

// constant
import {EDIT_MODE} from "@/constant/common";

// component
// import EmptyHieratchyEditList from "./common/components/EmptyHieratchyEditList.vue";
import StageMenuComponentList from "./common/components/StageMenuComponentList.vue";
// import projectListDocMenuConfig, { setMenuPermission }  from "@/views/projects/menus/ProjectListSubmenu";
import subMenuConfig, {setMenuPermission} from "@/views/projects/menus/SubMenu";
import { AsideButtonProp } from "@/components/base/menu/AsideButtonProp";

// api
import { duplicateCheck } from "@/api/catalogDeploy";
// import { getProjectList } from "@/api/projects";

// etc
import { setCurrentPageBreadcrumbs } from "@/core/helpers/breadcrumb";
import asidePrimaryController from "@/layout/service/aside/AsidePrimaryController";
import asideSecondaryController from "@/layout/service/aside/AsideSecondaryController";

import { deployActionTypes, deployState } from "@/store/modules/deploy";
import { _validateName, _validateLength, _validateSelect, _valdateLimitLength } from "@/utils/input-validate";
// import share from '@/store/modules/share';
import { getYaml, getKubernetesCatalogDeployNameList } from '@/api/kubernetesDeploy';

import YamlModal from "./common/panels/YamlModal.vue";

export default {
	name: "DeployNew",
	components: {
		StageMenuComponentList,
		// EmptyHieratchyEditList,
		YamlModal,
	},

	setup(props) {

		let { t, locale } = useI18n();

		const instance = getCurrentInstance() as any;
		const toast = useToast();
		const route = useRoute();
		const router = useRouter();
		const store = useStore();
		
		store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.ATTACH_NEW_CATALOG_DATA);

		const state = ref({
			isSaving : false,
			
			currentDeployTypeId : computed(() => store.state.deploy.deployTypeId),
			currentStageId : computed(() => store.state.deploy.stageId),
			deployConfigCounts : computed(() => store.state.deploy.deployConfigCounts),
			stageInfo : computed(() => store.state.deploy.stageInfo),
			
			// companyId : computed(() => store.state.share.serviceGroupInfo.companyId),
			// serviceGroupId : computed(() =>store.state.share.serviceGroupInfo.serviceGroupId),
			
			deployNewComponentName: "",
			// projectList: new Array,
			nexusRepositoryList: computed(() => store.state.deploy.nexusRepositoryList),
			catalogList: computed(() => store.state.deploy.catalogList),

			editData : computed(() => store.state.deploy.catalogEditData),
			EDIT_MODE: computed(() => EDIT_MODE),

			clusterList: [] as any,

			inputRules: {
				nexusId : [
					{
						required: true,
						trigger: "select",
						validator: _validateSelect, 
					}
				],
				catalogName : [
					{
						required: true,
						trigger: "select",
						validator: _validateSelect, 
					}
				],
				deployName: [
					{
						required: true,
						trigger: "blur",
						validator: _validateName,
						labelName: "Deploy name"
					},
					{
						required: true,
						trigger: "blur",
						validator: _validateLength,
						length: 2
					},
					{
						required: true,
						trigger: "blur",
						validator: _valdateLimitLength,
						length: 50
					}
				],
			},
			deployNameList: [] as any,
			selectedCopyDeployItem: '' as any,

			nameLengthLimitFlag: false
		});
		
		// const companyInfo = computed(()=> share.state.companyInfo) as any;
		// const serviceGroupInfo = computed(()=> share.state.serviceGroupInfo) as any;
		// const authMenuList = computed(() => store.getters.authMenuList);
		// const authMenu = computed(() => {
		// for(let item of authMenuList.value) {
		// 	if(item.name == 'svg_'+serviceGroupInfo.value.serviceGroupId) {
		// 	return item.authMenu;
		// 	}
		// }
		// })
    //////////////////////////////////////////////////////////////////////////////////////
    // 라이프 사이클
    //////////////////////////////////////////////////////////////////////////////////////

		onMounted( () => {
			nextTick(async () => {
				initMenu();
				initTitle();
				initData();
			});
		});

		// watch(()=> state.value.editData.stageCd, ()=> {
		// 	state.value.nameLengthLimitFlag = watchingData()
		// })
		watch(()=> state.value.editData.providerCd, ()=> {
			state.value.nameLengthLimitFlag = watchingData()
		})
		watch(()=> state.value.editData.k8sId, ()=> {
      		state.value.nameLengthLimitFlag = watchingData()
		})
		watch(()=> state.value.editData.nexusId, async (nexusId) => {
			onChangedNexusRepositoryId(nexusId);
			state.value.nameLengthLimitFlag = watchingData();
		})
		watch(()=> state.value.editData.catalogName, ()=> {
     		 state.value.nameLengthLimitFlag = watchingData()
		})
		watch(()=> state.value.editData.deployName, ()=> {
			state.value.nameLengthLimitFlag = watchingData()

			if(state.value.nameLengthLimitFlag) {
				instance?.refs.newForm.validate((valid)=> {
					state.value.nameLengthLimitFlag = valid
				}) 
			}
		})
		
		async function onChangedNexusRepositoryId(nexusId:any) {
			clearCatalogInfo();

			if(state.value.editData.nexusId) {
				try {
					await store.dispatch(deployActionTypes.NAMESPACE+"/"+deployActionTypes.LOAD_CATALOG_LIST, nexusId);
				} catch(error) {
					toast.error('카탈로그 목록을 가져올 수 없습니다.')
				}
			}
		}

		function clearCatalogInfo() {
			// state.value.editData.catalogId = "";
			state.value.editData.catalogName = "";
			state.value.editData.catalogTypeCd = "";
			state.value.editData.catalogVersion = "";
			store.dispatch(deployActionTypes.NAMESPACE+"/"+deployActionTypes.CLEAR_CATALOG_LIST);
		}

		function watchingData() {
			let flag = false
			if(
				// state.value.editData.stageCd != "" && 
				state.value.editData.providerCd != "" && 
				state.value.editData.k8sId != "" && 
				state.value.editData.nexusId != "" &&
				state.value.editData.catalogName != "" && 
				state.value.editData.deployName != ""
			) 
				flag = true;
			return flag;
		}

		async function initData() {
			//초기화 처리
			// await store.dispatch(deployActionTypes.NAMESPACE+"/"+deployActionTypes.LOAD_CATALOG_LIST, {
			// 	serviceGroupId: state.value.serviceGroupId,
			// });
			await store.dispatch(deployActionTypes.NAMESPACE+"/"+deployActionTypes.LOAD_NEXUS_REPOSITORY_LIST);
			// await store.dispatch(deployActionTypes.NAMESPACE+"/"+deployActionTypes.LOAD_CATALOG_LIST, {});
			
			// await store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.LOAD_STAGE_INFO);
			// await store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.LOAD_DEPLOY_CONFIG_COUNTS,state.value.serviceGroupId);
			await store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.LOAD_DEPLOY_CONFIG_COUNTS,"");
			await store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.ATTACH_NEW_CATALOG_DATA);
			// if(!hasDeployConfig.value){
			// 	toast.info(t("project.deploy.msgEmptyDeployConfig"));
			// }
			// await getProjectListCatalog();
			// await setCopyCatalogDeployList();
		}

		//destroyed
		onUnmounted(() => {
			store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.CLEAR_ALL_EDIT_DATA);
		});

    //////////////////////////////////////////////////////////////////////////////////////
    // 라이프 사이클
    //////////////////////////////////////////////////////////////////////////////////////

		function initTitle() {
			// setCurrentPageBreadcrumbs(t("breadcrumb.project.catalogDeployNew"), [
			// 	companyInfo.value.companyName,
			// 	serviceGroupInfo.value.serviceGroupName,
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
			//   asideSecondaryController.setMenu('Service Group', projectListDocMenuConfig, route.params, setMenuPermission, authMenu.value);
			asideSecondaryController.setMenu("Catalog Deploy", subMenuConfig, route.params, setMenuPermission, null);
		}

		function executeValidation(){
			// 단계01: 빌드 정보 유효성 체크
			let success = validateBuildEditData();
			
			if(success==false) return false;
			
			if(!store.state.deploy.catalogEditData.isDuplicateCheck){
				toast.error(t("msg.msgDuplicate"));
				return false;
			}
			// else if(!store.state.deploy.catalogEditData.stageCd) {
			// 	toast.error('스테이지를 선택해주세요');
			// 	return false;
			// }

			else if(!store.state.deploy.catalogEditData.providerCd) {
				toast.error('프로바이더를 선택해주세요');
				return false;
			}
			else if(!store.state.deploy.catalogEditData.k8sId) {
				toast.error('클러스터를 선택해주세요');
				return false;
			}
			else if(!store.state.deploy.catalogEditData.nexusId) {
				toast.error('Nexus Repository를 선택해주세요');
				return false;
			}
			else if(!store.state.deploy.catalogEditData.catalogName) {
				toast.error('카탈로그를 선택해주세요');
				return false;
			}
			else if(!store.state.deploy.catalogEditData.catalogDeployYaml) {
				toast.error('Yaml 내용을 입력해주세요');
				return false;
			}

			return true;
		}

		// 편집 정보 유효성 체크
		function validateBuildEditData() {
			
			let constraints = {
				// "catalogId": {
				// 	exclusion: {
				// 		within: [""],
				// 		"message":(value, attribute)=>{
				// 			return "^"+ t("project.deploy.validateMsg.msgNotSelectCatalogError")
				// 		}
				// 	}
				// },
				"deployName":{
					"length": { 
						"minimum": 2,
						"message":(value, attribute, validatorOptions)=>{
							return "^"+ t("project.deploy.validateMsg.msg2LengthInputError", {fieldName:attribute})
						}
					}
				}
			}
			let result = validate(state.value.editData, constraints,{format: "detailed"});
			
			if (result != null) {				
				toast.error(result[0].error);

				return false;
			}

			return true;
		}

		// async function getProjectListCatalog() {
		// 	try {
		// 		const response = await getProjectList(state.value.serviceGroupId);
		// 		state.value.projectList = []

		// 		if (response.data && response.data.length > 0) {
		// 				for (const data of response.data) {
		// 					state.value.projectList.push({
		// 							value: data.projectId,
		// 							text: data.projectName
		// 					})
		// 				}
		// 		}
		// 	} catch (error) {
		// 		console.log(error);
		// 		toast.error(t("msg.runFail"));
		// 	}
		// }

		const hasDeployConfig = computed(() =>{
			return state.value.deployConfigCounts.filter((x)=>{
				let count = 0;

				for(let key in x)	
					if(key == 'cnt') count+=x[key];
				if(count > 0) return x;
			}).length > 0;
		});


		// 배포명 중복체크 상태값
		function onChangeDuplicateCheck() {
			store.state.deploy.catalogEditData.isDuplicateCheck = false;
		}

		// 목록으로 이동
		function gotoListPage() {
			router.push({ path: "list" });
		}
		
		// 새 배포 화면 닫기
		function onCancel(event) {
			gotoListPage();
			event.stopPropagation();			
		}


		// 저장 버튼 클릭
		async function submitForm(event) {
			event.stopPropagation();
			
			if(state.value.currentDeployTypeId != 5){
				if(executeValidation()==false)
				return;
			}
			
			try {
				state.value.isSaving = true;

				let param = {
					deployName: state.value.editData.deployName,

					// serviceGroupId: state.value.serviceGroupId,
					k8sId: state.value.editData.k8sId,

					nexusId: state.value.editData.nexusId,
					catalogTypeCd: state.value.editData.catalogTypeCd,
					catalogName: state.value.editData.catalogName,
					catalogVersion: state.value.editData.catalogVersion,
					catalogDeployYaml: state.value.editData.catalogDeployYaml,

					// projectId: state.value.editData.projectId,
					// projectName: state.value.editData.projectName
				}

				await store.dispatch(deployActionTypes.NAMESPACE + "/" + deployActionTypes.START_CATALOG_DEPLOY_SAVE, param);

				toast.success(t("msg.saved"))
				gotoListPage();
			} catch (error) {
				console.error(error);
				toast.error(t("msg.runFail"));
     		 }

			state.value.isSaving = false;
		}
		
		// 배포명 중복체크
		async function duplicateChecked() {
			
			try {
				const length = state.value.editData.deployName.trim().length;
				if (length < 2) {
					const msg = length == 0 ? t("project.deploy.msgInputDeployName") : t("msg.least2Charac");
					toast.error(msg);
				} else {
					const params = {
							deployName: state.value.editData.deployName,
							k8sId: state.value.editData.k8sId,
					};

					const response = await duplicateCheck(params);
					if (response.data === false) {
						store.state.deploy.catalogEditData.isDuplicateCheck = true;
						toast.success(t("msg.availableName"));
					} else {
						store.state.deploy.catalogEditData.isDuplicateCheck = false;
						toast.error(t("msg.duplicateFailed"));
					}
				}
			} catch (error) {
				console.log(error)
				console.log(state.value.editData.k8sId)
				
				if(state.value.editData.k8sId.trim().length < 2)
					toast.error('클러스터를 선택해주세요.')
			}
		}

		// 카탈로그 상품 선택시 동작
		function onSelectedCatalogItem(item) {
			// state.value.editData.catalogName = item.data.catalogName
			state.value.editData.catalogTypeCd = item.data.catalogTypeCd
			state.value.editData.catalogVersion = item.data.catalogVersion
		}
		
		function onValidateSelect(prop) {
			(instance?.refs.newForm as any).validateField(prop);
		}
		// function onClickProject(item) {
		// 	state.value.editData.projectName = item.text
		// }

		
		// async function onSelectedCopyDeployItem() {
		// 	let deployNameInfo = state.value.deployNameList.find((deployInfo) => {
		// 		return deployInfo.deployName == state.value.selectedCopyDeployItem;
		// 	});

		// 	if (deployNameInfo == null) {
		// 		return;
		// 	} else {
		// 		state.value.editData.catalogDeployYaml = deployNameInfo.catalogDeployYaml
		// 	}
		// }
		
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
				catalogName: state.value.editData.catalogName,
				catalogVersion: state.value.editData.catalogVersion,
			}

      		let response = await getYaml(param);
			console.log("####onClickPreviewYaml");
				(instance?.refs.yamlModal as any).show(response.data);
			}

		function onClicknotFlag() {
			toast.error("필수값을 입력후 체크해주세요")
		}

		return {
			state,
			EDIT_MODE,
			hasDeployConfig,
			onValidateSelect,

			onCancel,
			// onSelectedSegmentItem,
			submitForm,
			onChangeDuplicateCheck,
			duplicateChecked,
			onSelectedCatalogItem,

			// onClickProject,
			
			// onSelectedCopyDeployItem,
			onClickPreviewYaml,

			onClicknotFlag,
    	};
	}
};

</script>