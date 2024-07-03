/*
	2023.03.15 신규 devops Store 작성
	- stageId -> stogeCd로 전환
 */
import * as deployActionTypes from "./type";
import * as mutations from "./mutations";
// import { getBuildList } from "@/api/build";

import DeployManagerFactory from "./manager/DeployManagerFactory";
import { getDeployConfigCount, getDeployDetailInfo } from "@/api/commonDeploy";
import { getKubernetesDeploy } from "@/api/kubernetesDeploy";
// import { getShellDeploy } from "@/api/shellDeploy";

import { getOssConnectionList } from "@/api/preference"
import { getCatalogList, getStageList, getProviderList, getClusterConfigList, putCatalogDeploy, getCatalogDeployDetailInfo } from "@/api/catalogDeploy";

// BELSNAKE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
import deployHelper from "@/views/projects/catalogDeploy/common/helper/deployHelper";
import { createKubernetesCatalogDeploy } from "../../../api/kubernetesDeploy";

export default {

	///////////////////////////////////////////////////
	[deployActionTypes.CLOSE_ALL_PANEL]: ({ commit })=>{
		commit(mutations.CLOSE_ALL_PANEL);
	},

	[deployActionTypes.SHOW_BUILD_PANEL]: ({ commit }) => {
		commit(mutations.CLOSE_ALL_PANEL);
		commit(mutations.SET_SHOW_BUILD_PANEL,true);
	},
	[deployActionTypes.CLOSE_BUILD_PANEL]: ({ commit }) => {
		commit(mutations.SET_SHOW_BUILD_PANEL,false);
	},

	[deployActionTypes.SHOW_ITEM_INFO_PANEL]: ({ commit }) => {
		commit(mutations.CLOSE_ALL_PANEL);
		commit(mutations.SET_SHOW_ITEM_INFO_PANEL,true);
	},
	[deployActionTypes.CLOSE_ITEM_INFO_PANEL]: ({ commit })=>{
		commit(mutations.SET_SHOW_ITEM_INFO_PANEL,false);
	},

	[deployActionTypes.SHOW_EXTEND_BUILD_PANEL]: ({ commit }) => {
		commit(mutations.CLOSE_ALL_PANEL);
		commit(mutations.SET_SHOW_EXTEND_BUILD_PANEL,true);
	},
	[deployActionTypes.CLOSE_EXTEND_BUILD_PANEL]: ({ commit })=>{
		commit(mutations.SET_SHOW_EXTEND_BUILD_PANEL,false);
	},
	///////////////////////////////////////////////////



	[deployActionTypes.CLEAR_ALL_EDIT_DATA]: ({ commit }) => {
		commit(mutations.CLOSE_ALL_PANEL);
		commit(mutations.SET_BUILD_EDIT_DATA, {})
		commit(mutations.SET_DEPLOY_TYPE_INFO, { deployCd: '', providerCd: '', stageCd: '', deployTypeId: '', deployComponentName: '' })
		commit(mutations.SET_DEPLOY_MANAGER, null);
		commit(mutations.SET_DEPLOY_EDIT_DATA, {});
		commit(mutations.SET_COMP_PROPERTIES, {});
		commit(mutations.SET_DEFAULT_ITEM_VALUE, {});
		commit(mutations.SET_EXTEND_BUILD_EDIT_DATA, {});
		commit(mutations.SET_ORIGINAL_EDIT_DATA, {});
		commit(mutations.SET_DEPLOY_CONFIG_COUNTS, []);
		commit(mutations.SET_CATALOG_EDIT_DATA, {});
		commit(mutations.SET_PASS_K8S_ID,"")
	},
	///////////////////////////////////////////////////


	/*
	신규 편집모드 실행 시 호출
	빌드 리스트 정보 설정하기
	*/
	[deployActionTypes.START_NEW_EDIT_MODE]: async ({ commit, dispatch, state, rootState, rootGetters }) => {
		// 빌드 정보 초기화
		dispatch(deployActionTypes.ATTACH_NEW_BUILD_DATA);
		// dispatch(deployActionTypes.ATTACH_NEW_CATALOG_DATA_CATALOG_NEW);
	},

	// NEW 모드일때 build 정보 초기화 처리 하기
	[deployActionTypes.ATTACH_NEW_BUILD_DATA]: ({ commit, dispatch, rootGetters }) => {
		let buildEditData = {
			buildId: '',
			buildName: '',
			deployCd:'',
			deployName: '',
			deployFrom: 1,
			deployId: -1,
			projectId: rootGetters.projectId,
			regId: rootGetters.userId,
			isDuplicateCheck:false,
			// deployApproveFlow: ''
			flowId:''
		}

		commit(mutations.SET_BUILD_EDIT_DATA, buildEditData)
	},


	////////////////////////////////






	////////////////////////////////
	// deploy 타입이 변경되는 경우 실행
	/*
		단계01: 배포 타입 정보 저장(SET_DEPLOY_TYPE_INFO)
			stageCd,
			deployTypeId,
			deployComponentName

		단계02: 배포 편집 정보 생성
			- 배포 헬퍼 생성 및 저장(SET_DEPLOY_MANAGER)


	*/
	[deployActionTypes.START_NEW_DEPLOY_EDTING]: async ({ commit, dispatch, state, rootState, rootGetters }, params) => {

		// 2023.03.17 tryoo - KUBERNETES 고정을 위한 임시 하드코딩
		// params.deployTypeId = DEPLOY_TYPE_ID.KUBERNETES;
		
		commit(mutations.CLOSE_ALL_PANEL);

		// 단계01: 배포 타입 정보 저장(SET_DEPLOY_TYPE_INFO)
		commit(mutations.SET_DEPLOY_TYPE_INFO, params);

		//단계02: 배포 헬퍼 생성 및 저장(SET_DEPLOY_MANAGER)
		const deployManager = DeployManagerFactory.create(params.deployTypeId, state, rootState, rootGetters);
		commit(mutations.SET_DEPLOY_MANAGER, deployManager);


		if (deployManager) {
			//단계03: 기본 복합 정보 생성 및 설정

			let compProperties = await deployManager.createCompProperties();
			commit(mutations.SET_COMP_PROPERTIES, compProperties);


			//단계02: 기본 배포 정보 생성 및 설정
			let deployEditData = deployManager.createNewDeployEditData();
			commit(mutations.SET_DEPLOY_EDIT_DATA, deployEditData);


			//단계04: 기본 아이템 정보 설정
			let defaultItemValue = deployManager.createDefaultItemValue();
			commit(mutations.SET_DEFAULT_ITEM_VALUE, defaultItemValue);

			//단계05: 확장 build정보 설정
			let extendBuildEditData = deployManager.createNewExtendBuildEditData();
			commit(mutations.SET_EXTEND_BUILD_EDIT_DATA, extendBuildEditData);


			//단계06: 기본 정보  생성하기
			let originalEditData = deployManager.createOriginalEditData();
			commit(mutations.SET_ORIGINAL_EDIT_DATA, originalEditData);
		} else {
			throw { code: DeployError.DATA_INIT_ERROR,  message: "initDataError", fieldName: "Deploy manager" };//new Error(errorMessage);
		}
	},

	// DEPLOY 선택을 취소(빈) 상태로 만들기
	[deployActionTypes.EMPTY_NEW_DEPLOY_EDTING]: ({ commit }) => {
		commit(mutations.CLOSE_ALL_PANEL);
		commit(mutations.SET_DEPLOY_TYPE_INFO, { deployCd: '', providerCd: '', stageCd: '',  deployTypeId: '', deployComponentName: '' })
	},
	/////////////////////////////////////////////////////////

	[deployActionTypes.START_NEW_CATALOG_EDTING]: async ({ commit, dispatch, state, rootState, rootGetters }, params) => {
		commit(mutations.CLOSE_ALL_PANEL);

		// 단계01: 배포 타입 정보 저장(SET_DEPLOY_TYPE_INFO)
		commit(mutations.SET_DEPLOY_TYPE_INFO, params);

		//단계02: 배포 헬퍼 생성 및 저장(SET_DEPLOY_MANAGER)
		const deployManager = DeployManagerFactory.create(params.deployTypeId, state, rootState, rootGetters);
		commit(mutations.SET_DEPLOY_MANAGER, deployManager);

		if (deployManager) {
			//단계03: 기본 복합 정보 생성 및 설정
			let compProperties = await deployManager.createCompPropertiesCatalog();
			commit(mutations.SET_COMP_PROPERTIES, compProperties);

			//단계02: 기본 배포 정보 생성 및 설정
			let deployEditData = deployManager.createNewDeployEditData();
			commit(mutations.SET_DEPLOY_EDIT_DATA, deployEditData);


			//단계04: 기본 아이템 정보 설정
			let defaultItemValue = deployManager.createDefaultItemValue();
			commit(mutations.SET_DEFAULT_ITEM_VALUE, defaultItemValue);

			//단계05: 확장 build정보 설정
			let extendBuildEditData = deployManager.createNewExtendBuildEditData();
			commit(mutations.SET_EXTEND_BUILD_EDIT_DATA, extendBuildEditData);


			//단계06: 기본 정보  생성하기
			let originalEditData = deployManager.createOriginalEditData();
			commit(mutations.SET_ORIGINAL_EDIT_DATA, originalEditData);
		} else {
			throw { code: DeployError.DATA_INIT_ERROR,  message: "initDataError", fieldName: "Deploy manager" };//new Error(errorMessage);
		}
	},

	// DEPLOY 선택을 취소(빈) 상태로 만들기
	[deployActionTypes.EMPTY_NEW_CATALOG_EDTING]: ({ commit }) => {
		commit(mutations.CLOSE_ALL_PANEL);
		commit(mutations.SET_DEPLOY_TYPE_INFO, { stageId: '', deployTypeId: '', deployComponentName: '' })
	},
//////////////////////////////////////////////////////////
	//config 개수 구하기
	[deployActionTypes.LOAD_DEPLOY_CONFIG_COUNTS]: async ({ commit, dispatch, state, rootState,rootGetters }, param) => {
		const response = await getDeployConfigCount(param);
		try{
			commit(mutations.SET_DEPLOY_CONFIG_COUNTS, response.data || [])
		}catch(error){
			commit(mutations.SET_DEPLOY_CONFIG_COUNTS, []);
		}
	},


	// stage 정보 가져오기
	[deployActionTypes.LOAD_STAGE_INFO]: async ({ commit, dispatch, state, rootState,rootGetters }) => {
		let response = null;
		try{
			response = await getStageList();
			commit(mutations.SET_STAGE_INFO, response.data || [])
		}catch(error){
			commit(mutations.SET_STAGE_INFO, []);
		}
	},

	[deployActionTypes.SET_PASS_K8S_ID]: async ({ commit },k8sId) => {
		commit(mutations.SET_PASS_K8S_ID,k8sId)
	},

	/////////////////////////////////////////////////////////
	/*
	신규 편집모드 실행 시 호출
	빌드 리스트 정보 설정하기
	*/
	[deployActionTypes.START_UPDATE_EDIT_MODE]: async ({ commit, dispatch, state, rootState,rootGetters }, deployId) => {
		///////////////
		// 단계02: 배포 상세정보 구하기
		let response = null;
		let deployInfo = null;
		let detail = null;
		try {

			// deployCd 정보 가져와서 해당 deploy에 맞는 상세 정보 불러오기
			response = await getKubernetesDeploy(deployId);

			console.log("########response");
			console.log(response);	
			deployInfo = response.data;

			// getKubernetesDeploy => deployCd == null (수정 예정)
			// deployInfo.deployCd = deployInfo.deployCd ? deployInfo.deployCd : DEPLOY_CD.KUBERNETES;

			// 빌드 정보 업데이트
			let buildEditData = {
				buildId: deployInfo.buildId,
				buildName: deployInfo.buildName,

				deployName: deployInfo.deployName,
				deployFrom: deployInfo.deployFrom,
				deployCd : deployInfo.deployCd,
				deployId: deployInfo.deployId,
				projectId: deployInfo.projectId,
				regId: deployInfo.regId,
				// jenkinsJobName: deployInfo.jenkinsJobName,
				isDuplicateCheck:true,
				// deployApproveFlow: ''
				flowId:''
			};

			commit(mutations.SET_BUILD_EDIT_DATA, buildEditData);
		} catch (error) {
			commit(mutations.SET_BUILD_EDIT_DATA, null);
			return false;
		}
		///////////////
		// 2023.03.17 tryoo - KUBERNETES 고정을 위한 임시 하드코딩
		// deployInfo.deployType = DEPLOY_TYPE_ID.KUBERNETES;

		// BELSNAKE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		// //////////////
		// let deployEditComponent = deployHelper.getDeployNewComponentName(deployInfo.deployTypeId);
		let deployEditComponent = deployHelper.getDeployNewComponentNameWithDeployCd(deployInfo.deployCd);

		// 단계01: 배포 타입 정보 저장(SET_DEPLOY_TYPE_INFO)
		let deployTypeInfo={
			stageCd:deployInfo.stageCd,
			providerCd:deployInfo.providerCd,
			deployCd:deployInfo.deployCd,
			deployTypeId:deployInfo.deployTypeId,
			deployComponentName:deployEditComponent
		};
		
		commit(mutations.SET_DEPLOY_TYPE_INFO, deployTypeInfo);


		// 단계02: 배포 정보 생성
		// 단계02: 배포 편집 정보 생성
		//단계02: 배포 헬퍼 생성 및 저장(SET_DEPLOY_MANAGER)
		let deployTypeId = deployHelper.getDeployCdToTypeId(deployInfo.deployCd);
		const deployManager = DeployManagerFactory.create(deployTypeId, state, rootState, rootGetters);
		commit(mutations.SET_DEPLOY_MANAGER, deployManager);
		if (deployManager) {
			//단계02: 기본 배포 정보 생성 및 설정
			commit(mutations.SET_DEPLOY_EDIT_DATA, deployManager.createUpdateDeployEditData(deployInfo));
			//단계03: 기본 복합 정보 생성 및 설정
			let compProperties = await deployManager.createCompProperties();
			commit(mutations.SET_COMP_PROPERTIES, compProperties);

			//단계04: 기본 아이템 정보 설정
			let defaultItemValue = deployManager.createDefaultItemValue();
			commit(mutations.SET_DEFAULT_ITEM_VALUE, defaultItemValue);

			//단계05: 확장 build정보 설정
			let extendBuildEditData = deployManager.createUpdateExtendBuildEditData(deployInfo);
			commit(mutations.SET_EXTEND_BUILD_EDIT_DATA, extendBuildEditData);

			//단계06: 기본 정보  생성하기
			let originalEditData = deployManager.createOriginalEditData();
			commit(mutations.SET_ORIGINAL_EDIT_DATA, originalEditData);
		} else {
			throw { code: DeployError.DATA_INIT_ERROR,  message: $t('project.deploy.msgInitDataError'), fieldName: "Deploy manager" };//new Error(errorMessage);
		}
		return true;
	},



	/////////////////////////////////////////////////////////

	/////////////////////////////////////////////////////////
	// NEXUS 정보 가져오기
	[deployActionTypes.LOAD_NEXUS_REPOSITORY_LIST]: async ({ commit, dispatch, rootGetters }) => {
		let response = null;
		try{
			// response = await getStageList();
			response = await getOssConnectionList({oss:"NEXUS"});

			commit(mutations.SET_NEXUS_REPOSITORY_LIST, response.data || [])
		}catch(error){
			commit(mutations.SET_NEXUS_REPOSITORY_LIST, []);
		}
	},

	[deployActionTypes.CLEAR_CATALOG_LIST]: async ({ commit, dispatch, rootGetters }) => {
		commit(mutations.SET_CATALOG_LIST, []);
	},

	[deployActionTypes.LOAD_CATALOG_LIST]: async ({ commit, dispatch, rootGetters }, payload) => {


		commit(mutations.LOADING_START);
		// 카탈로그 리스트구하기.
		let response = null;
		let catalogList = [];
		let nexusId = payload
		// 20230307
		// Todo: catalogId 받아오게 말씀드리기
		try {
			response = await getCatalogList(nexusId);
			let cnt = 0;

			if (response.data) {
				response.data.forEach(item => {
					catalogList.push({
						value: cnt,
						text: item.catalogName + " / " + item.catalogVersion,
						data: item
					});
					cnt++;
				});


				commit(mutations.SET_CATALOG_LIST, catalogList);
				commit(mutations.LOADING_END);
				return true;
			}
		} catch (error) {
			catalogList = [];
			throw error;
		}



		commit(mutations.SET_CATALOG_LIST, catalogList);
		commit(mutations.LOADING_END);
		return false;
	},
	/////////////////////////////////////////////////////////

	/////////////////////////////////////////////////////////
	// New, Edit 모드에서 오직 한번만 로드
	// [deployActionTypes.LOAD_BUILD_LIST]: async ({ commit, dispatch, rootGetters }) => {
	// 	commit(mutations.LOADING_START);
	// 	// 3. 빌드 리스트구하기.

	// 	let response = null;
	// 	let buildList = [];

	// 	let params = {
	// 		serviceGroupId : rootGetters.serviceGroupId,
	// 		projectId:rootGetters.projectId
	// 	}


	// 	try {
	// 		response = await getBuildList(params);
	// 		if (response.data) {
	// 			response.data.forEach(item => {
	// 				buildList.push({
	// 					value: item.buildId,
	// 					text: item.buildName,
	// 					data: item
	// 				});
	// 			});

	// 			commit(mutations.SET_BUILD_LIST, buildList);
	// 			commit(mutations.LOADING_END);
	// 			return true;
	// 		}
	// 	} catch (error) {
	// 		buildList = [];
	// 	}

	// 	commit(mutations.SET_BUILD_LIST, buildList);
	// 	commit(mutations.LOADING_END);
	// 	return false;
	// },
	/////////////////////////////////////////////////////////



	/////////////////////////////////////////////////////////
	[deployActionTypes.ADD_INFO_ITEM]: ({ commit }, infoItem) => {
		commit(mutations.ADD_INFO_ITEM, infoItem)
	},

	[deployActionTypes.REMOVE_INFO_ITEM_AT]: ({ commit }, index) => {
		commit(mutations.REMOVE_INFO_ITEM_AT, index)
	},


	[deployActionTypes.START_SAVE]: async ({ commit, dispatch, state }) => {
		let params = state.deployManager.createSaveParams();

		let success = false;
		await state.deployManager.executeSave(params);
		success = true;
		return success;
	},


	[deployActionTypes.START_UPDATE]: async ({ commit, dispatch, state }) => {
		let params = state.deployManager.createSaveParams();

		let success = false;
		await state.deployManager.executeUpdate(params);
		success = true;
		return success;
	},
	/////////////////////////////////////////////////////////

	[deployActionTypes.ATTACH_NEW_CATALOG_DATA]: ({ commit, dispatch, rootGetters }) => {
		let catalogEditData = {
			projectId: '',
			deployName: '',
			deployApproveFlow: '',

			nexusId:'',
			catalogId: '',
			catalogName: '',
			catalogVersion: '',
			clusterConfig: '',
			k8sId: '',
			catalogDeployYaml: '',

			providerCd: '',
			// stageCd: '',

			deployFrom: 1,
			deployId: -1,
			regId: '',
			isDuplicateCheck:false,
		}

		commit(mutations.SET_CATALOG_EDIT_DATA, catalogEditData)
	},

	[deployActionTypes.START_CATALOG_UPDATE_EDIT_MODE]: async ({ commit, dispatch, state, rootState,rootGetters }, param) => {
		
		let response = null;
		let catalogDeployInfo = null;
		try {
			response = await getCatalogDeployDetailInfo(param);
			catalogDeployInfo = response.data;
			// 카탈로그 정보 업데이트
			let catalogEditData = {
				
				// projectId: catalogDeployInfo.projectId,
				// projectName: catalogDeployInfo.projectName,
				deployName: catalogDeployInfo.deployName,
	
				nexusId: catalogDeployInfo.nexusId,
				catalogName: catalogDeployInfo.catalogName,
				catalogVersion: catalogDeployInfo.catalogVersion,

				providerCd: catalogDeployInfo.providerCd,
				// stageCd: catalogDeployInfo.stageCd,
				k8sId: catalogDeployInfo.k8sId,
				k8sName: catalogDeployInfo.k8sName,
				catalogDeployYaml: catalogDeployInfo.catalogDeployYaml,
	
				isDuplicateCheck: true,
			}

			commit(mutations.SET_CATALOG_EDIT_DATA, catalogEditData);
		} catch (error) {
			commit(mutations.SET_BUILD_EDIT_DATA, null);
			return false;
		}

	// BELSNAKE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	// 2023.03.14 하드코딩
		// let deployEditComponent = deployHelper.getDeployNewComponentName(catalogDeployInfo.deployType);
		let deployEditComponent = deployHelper.getDeployNewComponentName(1);
	// 단계01: 배포 타입 정보 저장(SET_DEPLOY_TYPE_INFO)
		let deployTypeInfo={
			stageCd:catalogDeployInfo.stageCd,
			providerCd:catalogDeployInfo.providerCd,
			deployComponentName:deployEditComponent
		}
		commit(mutations.SET_DEPLOY_TYPE_INFO, deployTypeInfo);
		// 단계02: 배포 정보 생성
		// 단계02: 배포 편집 정보 생성
		//단계02: 배포 헬퍼 생성 및 저장(SET_DEPLOY_MANAGER)
		// 2023.03.14 하드코딩
		// const deployManager = DeployManagerFactory.create(deployTypeInfo.deployTypeId, state, rootState, rootGetters);
		const deployManager = DeployManagerFactory.create(1, state, rootState, rootGetters);
		commit(mutations.SET_DEPLOY_MANAGER, deployManager);
		if (deployManager) {
			// //단계02: 기본 배포 정보 생성 및 설정
			// commit(mutations.SET_DEPLOY_EDIT_DATA, deployManager.createUpdateDeployEditData(deployInfo))
			// console.log('111111111111111111111111111111111111111111111111111111111111111111111111111111')

			//단계03: 기본 복합 정보 생성 및 설정
			let compProperties = await deployManager.createCompPropertiesCatalog();
			commit(mutations.SET_COMP_PROPERTIES, compProperties);


			// //단계04: 기본 아이템 정보 설정
			// let defaultItemValue = deployManager.createDefaultItemValue();
			// commit(mutations.SET_DEFAULT_ITEM_VALUE, defaultItemValue);
			// console.log('33333333333333333333333333333333333333333333333333333333333333333333333333333')


			// //단계05: 확장 build정보 설정
			// let extendBuildEditData = deployManager.createUpdateExtendBuildEditData(deployInfo);
			// commit(mutations.SET_EXTEND_BUILD_EDIT_DATA, extendBuildEditData);
			// console.log('44444444444444444444444444444444444444444444444444444444444444444444444444444444')


			// //단계06: 기본 정보  생성하기
			// let originalEditData = deployManager.createOriginalEditData();
			// commit(mutations.SET_ORIGINAL_EDIT_DATA, originalEditData);
		} else {
			throw { code: DeployError.DATA_INIT_ERROR,  message: "initDataError", fieldName: "Deploy manager" };//new Error(errorMessage);
		}
		return true;
	},

	
	[deployActionTypes.CLEAR_PROVIDER_INFO]: async ({ commit, dispatch, rootGetters }) => {
		commit(mutations.SET_PROVIDER_INFO, []);
	},

	// 카탈로그 배포 > 새배포 > Provider 정보 Store 추가
	[deployActionTypes.LOAD_PROVIDER_INFO]: async ({commit, dispatch, state, rootState, rootGetters}) => {
		let response = null;
		try {
			response = await getProviderList();
			commit(mutations.SET_PROVIDER_INFO, response.data || [])
		} catch(error) {
			commit(mutations.SET_PROVIDER_INFO, []);
		}
	},

	// 카탈로그 배포  > 새배포 > 등록
	[deployActionTypes.START_CATALOG_DEPLOY_SAVE]: async ({ commit, dispatch, state }, params) => {
		// let params = state.deployManager.createSaveParams();

		let success = false;
		try {
			await createKubernetesCatalogDeploy(params);
			success = true;
		} catch(error) {
			throw error
		}

		return success;
	},

	// 카탈로그 배포 > 새배포 > cluster 구성 목록 초기화
	[deployActionTypes.CLEAR_CLUSTER_CONFIG_INFO]: async ({commit, dispatch, state, rootState, rootGetters}) => {
		commit(mutations.SET_CLUSTER_CONFIG_INFO, []);
	},

	// 카탈로그 배포 > 새배포 > cluster 구성 목록
	[deployActionTypes.LOAD_CLUSTER_CONFIG_INFO]: async ({commit, dispatch, state, rootState, rootGetters}, params) => {
		let response = null;
		try {
			response = await getClusterConfigList(params);
			commit(mutations.SET_CLUSTER_CONFIG_INFO, response.data || [])
		} catch(error) {
			commit(mutations.SET_CLUSTER_CONFIG_INFO, []);
		}
	},

	// 카탈로그 배포 수정
	[deployActionTypes.START_UPDATE_CATALOG_EDIT]: async ({ commit, dispatch, state }, params) => {
		// let params = state.deployManager.createSaveParams();
		let success = false;
		// await state.deployManager.executeUpdate(params);
		await putCatalogDeploy(params);
		success = true;
		return success;
	},


	//Catalog config 개수 구하기
	// [deployActionTypes.LOAD_DEPLOY_CONFIG_COUNTS]: async ({ commit, dispatch, state, rootState,rootGetters }, param) => {
	// 	const response = await getDeployConfigCount(param);
	// 	try{
	// 		commit(mutations.SET_DEPLOY_CONFIG_COUNTS, response.data || [])
	// 	}catch(error){
	// 		commit(mutations.SET_DEPLOY_CONFIG_COUNTS, []);
	// 	}
	// },


	////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////
	
	[deployActionTypes.ATTACH_NEW_WORKFLOW_DEPLOY_DATA]: ({ commit, dispatch, rootGetters }) => {
		let editData = {
			workflowId:"",
			workflowName:"",
			gitlabId:"",
			gitlabProjectPath:"",
			branch: "",
			providerCd:"",
			k8sId:"",
			k8sName:"",
			workflowYaml:"",
			jenkinsId:"",
			// 등록시에만 입력받음
			pipelineScript:"",
			pipelines:[],
		}

		commit(mutations.SET_WORKFLOW_DEPLOY_EDIT_DATA, editData)
	},

};
