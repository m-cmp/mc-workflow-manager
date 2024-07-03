/*
1. deployType에 따른 확장 데이터 읽기
2. 유효성 체크
3. deployType에 따른 기본 데이터 초기화 처리
4. 편집 전 원본 데이터 저장
*/

import { BUILD_NETWORK_TYPE } from "@/constant/deploy";
import lodash from 'lodash'
import DeployManagerCore from "./DeployManagerCore"

import { createKubernetesDeploy  as createDeploy, createKubernetesCatalogDeploy  as createCatalogDeploy } from "@/api/kubernetesDeploy";
import { getKubernetesDeploy as getDeploy } from "@/api/kubernetesDeploy";
import { updateKubernetesDeploy as updateDeploy } from "@/api/kubernetesDeploy";

import { getKubernetesDeployNameList, getKubernetesCatalogDeployNameList } from '@/api/kubernetesDeploy';
import { getConfigList } from '@/api/kubernetesDeploy';
import { getControllerCodeList } from '@/api/kubernetesDeploy';
import { getStrategyTypeList, getRolloutStrategyTypeList } from '@/api/kubernetesDeploy';
import { getServiceTypeList } from '@/api/kubernetesDeploy';
import { getHostPathVolumeList } from '@/api/kubernetesDeploy';


import {arrayToObject, valueObjectToArray, isEmptyObject} from "@/utils/common";
import {objectToArray, arrayToValueObjectArray, splitACRServerInfo, joinACRServerInfo} from "@/utils/common";

import {DEPLOY_CONTROLLER_TYPE, DEFAULT_SERVICE_TYPE, DEFAULT_STRATEGY_TYPE} from "@/constant/deploy";
import DeployError from "@/error/deployError";
import validate from 'validate.js'

import { useToast } from "vue-toastification";
import i18n from "@/i18n";
// BELSNAKE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// import saveValidator from "@/views/projects/deploy/common/validate/saveValidator"

export default class KubernetesManager extends DeployManagerCore {

	constructor(deployState, rootState, rootGetters) {
		super(deployState, rootState, rootGetters);
	}


	createNewDeployEditData() {
		let editData = {
			infoItems:[{
				selected:false,
				info:{
					k8sId:"",
					namespace:"",
					controller:"",

					replicas:1,
					strategyType:"",
					schedule:"",

					name: "",
					isDuplicateCheckName:false,

					proxyInfo:{
						defaultDomainYn:"",
						domainName:"",
						tlsYn:"",
						tlsSecretName:"",
						tlsCrt:"",
						tlsCrtName:"",
						tlsKey:"",
						tlsKeyName:""
					},

					ports:[],
					// ingressPathRewriteYn:false,
						/*
						"name" : "p-8080",
						"protocol" : null,
						"port" : 8080,
						"containerPort" : 8080,
						"nodePort" : null,
						"ingressPath" : "/test"
					*/

					resource:{
						requestCpu:"",
						requestMemory:"",
						limitCpu:"",
						limitMemory:""
					},

					autoscale:{
						resourceName:"",
						maxReplicas:"",
						averageUtilization:"",
					},

					/* array => object 변환 */
					labels:[{
						key:"",
						value:""
					}],
					/*
						"key":"",
						"value":""
					*/
					/* 배열의 요소가 object가 아닌 문자열로 저장 */
					command:[{value:""}],

					// imagePullSecrets:[{value:""}],
					imagePullSecrets:"",
					/* 배열의 요소가 object가 아닌 문자열로 저장 */
					args:[{value:""}],
					/* array => object 변환 */
					configMapData:[{
						key:"",
						value:""
					}],
					/*
						"key":"",
						"value":""
					*/
					/* array => object 변환 */
					secretData:[{
						key:"",
						value:""
					}],
					/*
						"key":"",
						"value":""
					*/
					hostname:"",
					nodeSelector: [],
					hostPathVolumes:[],
					pvcVolumes:[],
					/*
						“name”:””
						“mountPath”:””,
						“claimName”:””

					*/

					// headlessYn:false,
					serviceType: "",
					// externalIPs:[{value:""}]
				}
			}]
		}

		let firstItem = editData.infoItems[0].info;


		// controller 기본 값 적용.
		if(this.compProperties.controllerList && this.compProperties.controllerList.length>0){
			firstItem.controller = DEPLOY_CONTROLLER_TYPE.DEPLOYMENT;
		}


		// strategyType 기본값 적용
		if(this.compProperties.strategyTypeList && this.compProperties.strategyTypeList.length>0){
			firstItem.strategyType = DEFAULT_STRATEGY_TYPE;
		}

		// 서비스 타입  기본값 적용
		if(this.compProperties.serviceTypeList && this.compProperties.serviceTypeList.length>0){
			firstItem.serviceType = DEFAULT_SERVICE_TYPE;
		}


		return editData;

	}

	// 확장 빌드 정보
	// 현재는 docker에서만 사용
	createNewExtendBuildEditData() {
		let editData = {
		}
		return editData;
	}
	//////////////////////////////////////////////////////////////////






	//////////////////////////////////////////////////////////////////
	/*
		기본값 : 현재는 docker에서만 사용
	*/
	createDefaultItemValue() {
		return null;
	}
	/*
		의존 데이터 읽기
		call : action.START_NEW_DEPLOY_EDTING, action.START_UPDATE_EDIT_MODE에서 호출됨.

	*/
	async createCompProperties() {
		// itemInfos(deployServers) 편집시에 사용
		let compProperties = {}

		compProperties.buildList = this.deployState.buildList;
		compProperties.deployNameList = await this.getDeployNameList();
		
		let result = await this._getConfigList();
		// 2023.04.25 tryoo - config list => cluster list로 전환
		if (result == false) throw { code: DeployError.DATA_INIT_ERROR,  message: this.errorMessage, fieldName: "clusterList" };//new Error(errorMessage);
		compProperties.kubernetesConfigList = result;

		result = await this._getControllerList();
		if (result == false) throw { code: DeployError.DATA_INIT_ERROR,  message: this.errorMessage, fieldName: "controllerList" };
		compProperties.controllerList = result;

		result = await this._getStrategyTypeList();
		if (result == false) throw { code: DeployError.DATA_INIT_ERROR,  message: this.errorMessage, fieldName: "strategyList" };
		compProperties.strategyTypeList = result;

		result = await this._getRolloutStrategyTypeList();
		if (result == false) throw { code: DeployError.DATA_INIT_ERROR,  message: this.errorMessage, fieldName: "rolloutStrategyList" };
		compProperties.rolloutStrategyTypeList = result;

		result = await this._getServiceTypeList();
		if (result == false) throw { code: DeployError.DATA_INIT_ERROR,  message: this.errorMessage, fieldName: "serviceList" };
		compProperties.serviceTypeList = result;

		result = await this._getHostPathVolumeList();
		if (result == false) throw { code: DeployError.DATA_INIT_ERROR,  message: this.errorMessage, fieldName: "hostPathVolumeList" };

		compProperties.hostPathVolumeList = result;

		compProperties.namespaceList = [];
		compProperties.nodeSelectorList = [];


		return compProperties;
	}
	//////////////////////////////////////
	/////////////////////////////////////////////
	/*
		편집 정보 유효성 체크
	*/

	// 아이템 정보 유효성 체크
	validateDeployEditData() {
		const { t }  = i18n.global;
		const toast = useToast();

		let firstItem = this.deployEditData.infoItems[0].info;

		if (firstItem.isDuplicateCheckName == false) {
			toast.error(t("project.deploy.validateMsg.msgDuplicateAppName"));
			// Vue.app.$message({
			// 	type: 'error',
			// 	message: Vue.app.$t("project.deploy.validateMsg.msgDuplicateAppName")
			// 	})

			return {
				showItemPanel:true
			};
		}

		// 2023.03.19 tryoo - imagePullSecret 필수 값 X
		// if (firstItem.imagePullSecrets[0].value == "") {
		// 	toast.error(t("project.deploy.validateMsg.msgNotInputError", {fieldName:"ImagePullSecrets"}));

		// 	return {
		// 		showItemPanel:true
		// 	};
		// }

		// BELSNAKE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		// let constraints = {
		// 	"k8sId": saveValidator.emptySelect,
		// 	"namespace": saveValidator.emptySelect,
		// 	"controller":saveValidator.controller,
		// 	"name": saveValidator.appName,
		// 	"ports": saveValidator.ports,
		// 	"hostPathVolumes":saveValidator.hostPathVolumes,
		// 	"pvcVolumes": saveValidator.pvcVolumes,
		//
		// }
		//
		// if (firstItem.controller == DEPLOY_CONTROLLER_TYPE.CRONJOB) {
		// 	constraints.schedule= saveValidator.twoLength
		// }
		//
		//
		// let result = validate(firstItem, constraints,{format: "detailed"});
		// if (result != null) {
		// 	Vue.app.$message({
		// 		type: 'error',
		// 		message: result[0].error
		// 		})
		//
		// 	return {
		// 		showItemPanel:true
		// 	};
		// }
		return true;
	}

	validateExtendBuildEditData() {
		return true;
	}




	//////////////////////////////////////
	// 저장을 위한 파라메터 생성
	createSaveParams() {
		let tempDeployEditData = {};
		let info = this.deployEditData.infoItems[0].info;
		
		// 승인 / 반려
		tempDeployEditData.flowId = this.buildEditData.deployApproveFlow;

		//////////////////////////
		tempDeployEditData.k8sId = info.k8sId;
		tempDeployEditData.namespace = info.namespace;
		tempDeployEditData.controller = info.controller;

		if(tempDeployEditData.controller == DEPLOY_CONTROLLER_TYPE.DEPLOYMENT ||
			tempDeployEditData.controller == DEPLOY_CONTROLLER_TYPE.STATEFUL_SET ||
			tempDeployEditData.controller == DEPLOY_CONTROLLER_TYPE.ROLLOUT){
				tempDeployEditData.replicas = info.replicas;
				tempDeployEditData.strategyType = info.strategyType;
		}
		if(tempDeployEditData.controller == DEPLOY_CONTROLLER_TYPE.DAEMON_SET){
			tempDeployEditData.strategyType = info.strategyType;
		}

		if(tempDeployEditData.controller == DEPLOY_CONTROLLER_TYPE.CRONJOB){
			tempDeployEditData.schedule = info.schedule;
		}

		tempDeployEditData.name = info.name;

		tempDeployEditData.proxyInfo = info.proxyInfo;

		// tls 사용 안할시 tls 관련 정보 초기화
		if(info.proxyInfo.tlsYn !== 'Y') {
			tempDeployEditData.proxyInfo.tlsSecretName = "";
			tempDeployEditData.proxyInfo.tlsKey = "";
			tempDeployEditData.proxyInfo.tlsKeyName = "";
			tempDeployEditData.proxyInfo.tlsCrt = "";
			tempDeployEditData.proxyInfo.tlsCrtName = "";
		}

		tempDeployEditData.ports = info.ports;
		// tempDeployEditData.ingressPathRewriteYn = info.ingressPathRewriteYn ? "Y" : "N";
		tempDeployEditData.resource = info.resource;
		tempDeployEditData.autoscale = info.autoscale;

		tempDeployEditData.labels = arrayToObject(info.labels);
		tempDeployEditData.command = valueObjectToArray(info.command);
		// tempDeployEditData.imagePullSecrets = valueObjectToArray(info.imagePullSecrets);
		tempDeployEditData.imagePullSecrets = info.imagePullSecrets;
		tempDeployEditData.args = valueObjectToArray(info.args);
		tempDeployEditData.configMapData = arrayToObject(info.configMapData);
		tempDeployEditData.secretData = arrayToObject(info.secretData);

		tempDeployEditData.hostname = info.hostname;
		tempDeployEditData.nodeSelector = info.nodeSelector;
		tempDeployEditData.hostPathVolumes = info.hostPathVolumes;
		tempDeployEditData.pvcVolumes = info.pvcVolumes;

		// tempDeployEditData.headlessYn = info.headlessYn ? "Y" : "N";
		tempDeployEditData.serviceType = info.serviceType;
		// tempDeployEditData.externalIPs = valueObjectToArray(info.externalIPs);

		let params = lodash.merge(this.buildEditData, tempDeployEditData);

		params.stageCd = this.deployState.stageCd;

		return params;
	}


	// 저장
	async executeSave(params) {
		return await createDeploy(params);
	}

	//////////////////////////////////






	//////////////////////////////////
	// 업데이트 처리

	async executeUpdate(params) {
		return await updateDeploy(params);
	}

	async getDeployInfo(deployId) {
		let response = await getDeploy(deployId);
		return response.data;
	}

	createUpdateDeployEditData(deployData) {
		let infoItems = [{
			info: {},
			selected:true
		}];


		// 계층도를 그리기 위해 데이터  편집
		let firstItem = infoItems[0].info;
		firstItem.k8sId = deployData.k8sId || "";
		firstItem.namespace = deployData.namespace || "";
		firstItem.controller = deployData.controller || "";

		firstItem.strategyType="";
		if(deployData.controller == DEPLOY_CONTROLLER_TYPE.DEPLOYMENT 
		|| deployData.controller == DEPLOY_CONTROLLER_TYPE.STATEFUL_SET 
		|| deployData.controller == DEPLOY_CONTROLLER_TYPE.ROLLOUT){
			firstItem.replicas = deployData.replicas || "";
			firstItem.strategyType = deployData.strategyType ||"";
		}
		if(deployData.controller == DEPLOY_CONTROLLER_TYPE.DAEMON_SET){
			firstItem.strategyType = deployData.strategyType ||"";
		}

		if(deployData.controller == DEPLOY_CONTROLLER_TYPE.CRONJOB){
			firstItem.schedule = deployData.schedule || "";
		}

		firstItem.name = deployData.name || "";
		firstItem.isDuplicateCheckName = true;

		if(isEmptyObject(deployData.proxyInfo) == false) {
			firstItem.proxyInfo = deployData.proxyInfo;
		} else {
			firstItem.proxyInfo = {
				defaultDomainYn:"",
				domainName:"",
				tlsYn:"",
				tlsSecretName:"",
				tlsCrt:"",
				tlsCrtName:"",
				tlsKey:"",
				tlsKeyName:""
			};
		}

		firstItem.ports = deployData.ports || [];
		// firstItem.ingressPathRewriteYn = (deployData.ingressPathRewriteYn==='Y');

		if(isEmptyObject(deployData.resource) == false) {
			firstItem.resource = deployData.resource;
		} else {
			firstItem.resource = {
				requestCpu:"",
				requestMemory:"",
				limitCpu:"",
				limitMemory:""
			};
		}

		if(isEmptyObject(deployData.labels)==false)
			firstItem.labels = objectToArray(deployData.labels);
		else {
			firstItem.labels = [{
				key:"",
				value:""
			}]
		}

		if(deployData.command && deployData.command.length>0)
			firstItem.command = arrayToValueObjectArray(deployData.command);
		else {
			firstItem.command= [{
				value:""
			}]
		}

		// if(deployData.imagePullSecrets && deployData.imagePullSecrets.length>0)
		// 	firstItem.imagePullSecrets = arrayToValueObjectArray(deployData.imagePullSecrets);
		// else {
		// 	firstItem.imagePullSecrets= [{
		// 		value:""
		// 	}]
		// }

		// firstItem.imagePullSecrets = deployData.imagePullSecrets  || [];
		firstItem.imagePullSecrets = deployData.imagePullSecrets || "";
		
		if(deployData.args && deployData.args.length>0)
			firstItem.args = arrayToValueObjectArray(deployData.args);
		else {
			firstItem.args=[{
				value:""
			}]
		}


		if(isEmptyObject(deployData.configMapData)==false)
			firstItem.configMapData = objectToArray(deployData.configMapData);
		else {
			firstItem.configMapData = [{
				key:"",
				value:""
			}]
		}


		if(isEmptyObject(deployData.secretData)==false)
			firstItem.secretData = objectToArray(deployData.secretData);
		else {
			firstItem.secretData = [{
				key:"",
				value:""
			}]
		}



		firstItem.hostname = deployData.hostname || "";
		firstItem.nodeSelector = deployData.nodeSelector || [];
		firstItem.hostPathVolumes = deployData.hostPathVolumes || [];
		firstItem.pvcVolumes = deployData.pvcVolumes || [];

		// firstItem.headlessYn = (deployData.headlessYn==='Y');
		firstItem.serviceType = deployData.serviceType || "";
		// if(deployData.externalIPs  && deployData.externalIPs.length>0)
		// 	firstItem.externalIPs = arrayToValueObjectArray(deployData.externalIPs);
		// else {
		// 	firstItem.externalIPs= [{
		// 		value:""
		// 	}]
		// }

		if(isEmptyObject(deployData.autoscale) == false) {
			firstItem.autoscale = deployData.autoscale;

			if(firstItem.autoscale.resourceName == "" || firstItem.autoscale.resourceName == null) {
				firstItem.autoscale.maxReplicas = "";
				firstItem.autoscale.averageUtilization = "";
			}
		} else {
			firstItem.autoscale = {
				resourceName:"",
				maxReplicas:"",
				averageUtilization:"",
			};
		}

		return {
			infoItems
		}
	}

	createUpdateExtendBuildEditData(deplyInfo) {
		let extendEditData = {
		}
		return extendEditData;
	}



	/*
		값이 없거나 오류가 있어도 괜찮음.
	*/
	async getDeployNameList() {

		let deployNameList = [];

		/*
			2023.03.18 tryoo : projectId 임시 조치 (수정 필요)
		*/
		try {
			let response = await getKubernetesDeployNameList(this.rootState.share.projectInfo.projectId)
			deployNameList = response.data || [];

		} catch (error) {
			deployNameList = [];
		}

		return deployNameList;

	}
	/*
		반드시 존재해야함.
	*/
	async _getConfigList() {
		let params = {
			stageCd : this.deployState.stageCd,
			providerCd : this.deployState.providerCd,
			serviceGroupId : this.rootGetters.serviceGroupId
		}

		let response = null;
		let configList = false;
		try {
			response = await getConfigList(params);
			configList = response.data || [];

			if (configList.length == 0)
				return false;

		} catch (error) {

			return false;
		}

		return configList;
	}

	async _getControllerList() {

		let response = null;
		let controllerList = false;
		try {
			response = await getControllerCodeList();
			controllerList = response.data || [];
		} catch (error) {
			return false;
		}
		return controllerList;
	}

	async _getStrategyTypeList() {
		let response = null;
		let strategyTypeList = false;
		try {
			response = await getStrategyTypeList();
			strategyTypeList = response.data || [];
		} catch (error) {
			return false;
		}
		return strategyTypeList;
	}

	async _getRolloutStrategyTypeList() {
		let response = null;
		let rolloutStrategyTypeList = false;
		try {
			response = await getRolloutStrategyTypeList();
			rolloutStrategyTypeList = response.data || [];
		} catch (error) {
			return false;
		}
		return rolloutStrategyTypeList;
	}


	async _getServiceTypeList() {
		let response = null;
		let serviceTypeList = false;
		try {
			response = await getServiceTypeList();
			serviceTypeList = response.data || [];
		} catch (error) {
			return false;
		}
		return serviceTypeList;
	}


	async _getHostPathVolumeList() {
		let response = null;
		let hostPathVolumeList = false;
		try {
			response = await getHostPathVolumeList();
			let list = response.data || [];
			let newList = list.map((item) => {
				return item.codeName;
			})
			hostPathVolumeList = newList;
		} catch (error) {
			return false;
		}

		// // this.serviceTypeList = "data": [{
        //     "commonGroupId": "HostPathVolumeType",
        //     "commonCodeId": "DirectoryOrCreate",
        //     "codeName": "DirectoryOrCreate",
        //     "description": "K8S VolumeType DirectoryOrCreate",
        //     "codeOrder": 1,
        //     "regId": "minchang",
        //     "regDate": "2020-04-13 15:12:23.0"
        // },

		return hostPathVolumeList;
	}

















	//////////////////////////////////////
	/*
		2023.03.08
		카탈로그용 메서드 추가
	*/
	async createCompPropertiesCatalog() {
		// itemInfos(deployServers) 편집시에 사용
		let compProperties = {}
		
		// compProperties.buildList = this.deployState.buildList;
		compProperties.deployNameList = await this.getCatalogDeployNameList();

		// let result = await this._getConfigListCatalog();
		// if (result == false) throw { code: DeployError.DATA_INIT_ERROR,  message: this.errorMessage, fieldName: "config list" };//new Error(errorMessage);
		// compProperties.kubernetesConfigList = result;

		// result = await this._getControllerList();
		// if (result == false) throw { code: DeployError.DATA_INIT_ERROR,  message: this.errorMessage, fieldName: "controller list" };
		// compProperties.controllerList = result;

		// result = await this._getStrategyTypeList();
		// if (result == false) throw { code: DeployError.DATA_INIT_ERROR,  message: this.errorMessage, fieldName: "strategy list" };
		// compProperties.strategyTypeList = result;


		// result = await this._getServiceTypeList();
		// if (result == false) throw { code: DeployError.DATA_INIT_ERROR,  message: this.errorMessage, fieldName: "service list" };
		// compProperties.serviceTypeList = result;

		// result = await this._getHostPathVolumeList();
		// if (result == false) throw { code: DeployError.DATA_INIT_ERROR,  message: this.errorMessage, fieldName: "host path volume list" };

		// compProperties.hostPathVolumeList = result;
		compProperties.namespaceList = [];
		compProperties.nodeSelectorList = [];


		return compProperties;
	}
	//////////////////////////////////////
	/*
		2023.03.08
		카탈로그용 메서드 추가
		값이 없거나 오류가 있어도 괜찮음.
	*/
	async getCatalogDeployNameList() {
		let params = {
			serviceGroupId: this.rootGetters.serviceGroupId,
		}
		let deployNameList = [];
		try {

			let response = await getKubernetesCatalogDeployNameList(params)
			deployNameList = response.data || [];

		} catch (error) {
			deployNameList = [];
		}

		return deployNameList;

	}

	/*
		2023.03.08
		카탈로그용 메서드 추가
		반드시 존재해야함.
	*/
	async _getConfigListCatalog() {
		let params = {
			groupId: this.serviceId,
			stageId: this.stageId
		}

		let response = null;
		let configList = false;
		try {
			let response = await getConfigListCatalog(params);
			configList = response.data || [];

			if (configList.length == 0)
				return false;

		} catch (error) {

			return false;
		}

		return configList;
	}

////////////////////////////////////////////////////////////////////////////
createSaveCatalogParams(param) {
	// let tempDeployEditData = {};
	// let info = this.deployEditData.infoItems[0].info;
	// //////////////////////////
	// tempDeployEditData.k8sId = info.k8sId;
	// tempDeployEditData.namespace = info.namespace;
	// tempDeployEditData.controller = info.controller;

	// if(tempDeployEditData.controller == DEPLOY_CONTROLLER_TYPE.DEPLOYMENT ||
	// 	tempDeployEditData.controller == DEPLOY_CONTROLLER_TYPE.STATEFUL_SET ){
	// 		tempDeployEditData.replicas = info.replicas;
	// 		tempDeployEditData.strategyType = info.strategyType;
	// }
	// if(tempDeployEditData.controller == DEPLOY_CONTROLLER_TYPE.DAEMON_SET){
	// 	tempDeployEditData.strategyType = info.strategyType;
	// }

	// if(tempDeployEditData.controller == DEPLOY_CONTROLLER_TYPE.CRONJOB){
	// 	tempDeployEditData.schedule = info.schedule;
	// }

	// tempDeployEditData.name = info.name;
	// tempDeployEditData.ports = info.ports;
	// tempDeployEditData.ingressPathRewriteYn = info.ingressPathRewriteYn ? "Y" : "N";


	// tempDeployEditData.labels = arrayToObject(info.labels);
	// tempDeployEditData.command = valueObjectToArray(info.command);
	// tempDeployEditData.imagePullSecrets = valueObjectToArray(info.imagePullSecrets);
	// tempDeployEditData.args = valueObjectToArray(info.args);
	// tempDeployEditData.configMapData = arrayToObject(info.configMapData);
	// tempDeployEditData.secretData = arrayToObject(info.secretData);

	// tempDeployEditData.hostname = info.hostname;
	// tempDeployEditData.nodeSelector = info.nodeSelector;
	// tempDeployEditData.hostPathVolumes = info.hostPathVolumes;
	// tempDeployEditData.pvcVolumes = info.pvcVolumes;

	// tempDeployEditData.headlessYn = info.headlessYn ? "Y" : "N";
	// tempDeployEditData.serviceType = info.serviceType;
	// tempDeployEditData.externalIPs = valueObjectToArray(info.externalIPs);

	// let params = lodash.merge(this.buildEditData, tempDeployEditData);

	// params.stageId = this.deployState.stageId;



	// 고민중
	// let params = {
	// 	serviceGroupId: this.rootGetters.serviceGroupId,
	// 	k8sId: param.k8sId,
	// 	deployName: param.deployName,
	// 	catalogName: param.catalogName,
	// 	catalogVersion: param.catalogVersion,
	// }
	// console.log('paramsparamsparamsparamsparams == ', param)
	// console.log('paramsparamsparamsparamsparams == ', params)
	
	return params;
}



	// 카탈로그 배포 등록
	async excuteCatalogSave(params) {
		return await createCatalogDeploy(params);
	}


































}
