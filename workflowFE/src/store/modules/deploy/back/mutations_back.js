/*
	2023.03.15 기존 devops Store 백업 - devops/mutaions.js
*/

export const CLOSE_ALL_PANEL = "closeAllPanel";
export const SET_SHOW_BUILD_PANEL = "setShowBuildPanel";
export const SET_SHOW_ITEM_INFO_PANEL = "setShowItemInfoPanel";
export const SET_SHOW_EXTEND_BUILD_PANEL = "setShowExtendBuildPanel";
export const LOADING_START = "loadingStart";
export const LOADING_END = "loadingEnd";
export const ERROR = "error";
//////////////////////



//////////////////////

export const CLEAR_DEPLOY_EDIT_DATA = "clearDeployEditData";
export const SET_BUILD_LIST = "setBuildList";
export const SET_BUILD_EDIT_DATA = "setBuildEditData";
export const SET_DEPLOY_EDIT_DATA = "setDeployEditData";
export const SET_DEPLOY_TYPE_INFO = "setDeployTypeInfo";
export const SET_DEPLOY_MANAGER = "setDockerHelper"
export const SET_DEFAULT_ITEM_VALUE = "setDefaultItemValue";
export const SET_COMP_PROPERTIES = "setCompProperties"
export const SET_EXTEND_BUILD_EDIT_DATA = "setExtendEditData";
export const SET_ORIGINAL_EDIT_DATA = "setOriginalEditData";
export const REMOVE_INFO_ITEM_AT = "removeInfoItemAt";
export const SET_DEPLOY_CONFIG_COUNTS = "setDeployConfigCounts";
export const SET_STAGE_INFO = "setStageInfo";
export const ADD_INFO_ITEM = "addInfoItem";

export const SET_CATALOG_LIST = "setCatalogList";
export const SET_CATALOG_EDIT_DATA = "setCatalogEditData";
export const SET_PROVIDER_INFO = "setProviderInfo";

export const SET_CLUSTER_CONFIG_INFO = "seClusterConfigInfo";
export const SET_CATALOG_DEPLOY_TYPE_INFO = "setCatalogDeployTypeInfo";


export default {
	////////////////////////////////////////////////////////
	
	[CLOSE_ALL_PANEL]: (state) => {
		state.buildPanel.opened = false;	
		state.itemInfoPanel.opened = false;
		state.extendBuildPanel.opened = false;
	},
	[SET_SHOW_BUILD_PANEL]: (state, open) => {
		state.buildPanel.opened = open;
	},
	
	[SET_SHOW_ITEM_INFO_PANEL]: (state, open) => {
		state.itemInfoPanel.opened = open;
	},

	[SET_SHOW_EXTEND_BUILD_PANEL]: (state, open) => {
		state.extendBuildPanel.opened = open;
	},
	////////////////////////////////////////////////////////
	
	[SET_DEPLOY_CONFIG_COUNTS]:(state, configConts)=>{
		state.deployConfigCounts = configConts;
	},

	[SET_STAGE_INFO]:(state, stageInfo)=>{
		state.stageInfo = stageInfo;
	},

	[SET_PROVIDER_INFO]:(state, providerInfo)=>{
		state.providerInfo = providerInfo
	},
	[SET_CLUSTER_CONFIG_INFO]:(state, clusterConfigInfo)=>{
		state.clusterConfigInfo = clusterConfigInfo
	},
	////////////////////////////////////////////////////////
	[LOADING_START]: (state) => {
		state.loading = true;
	},
	[LOADING_END]: (state) => {
		state.loading = false;
	},

	[ERROR]: (state,message) => {
		state.error = true;
		state.errorMessage = message; 
	},
	
	[SET_DEPLOY_MANAGER]: (state, deployManager) => {
		state.deployManager = deployManager;
	},
	[SET_BUILD_EDIT_DATA]: (state, buildEditData) => {
		state.buildEditData = buildEditData;	
	},

	[SET_BUILD_LIST]: (state, buildList) => {
        state.buildList = buildList;
	},

	[SET_DEPLOY_TYPE_INFO]: (state, typeInfo)=>{
		state.stageId = typeInfo.stageId;
		state.deployTypeId = typeInfo.deployTypeId;
		state.deployComponentName = typeInfo.deployComponentName;
	},

	[SET_DEPLOY_EDIT_DATA]: (state, deployEditData) => {
		state.deployEditData = deployEditData;		
	},

	[SET_DEFAULT_ITEM_VALUE]: (state, defaultItemValue) => {
		state.defaultItemValue = defaultItemValue;
	},

	[SET_COMP_PROPERTIES]: (state, compProperties) => {
		state.compProperties = compProperties;
	},

	[SET_EXTEND_BUILD_EDIT_DATA]: (state, extendEditData) => {
		state.extendBuildEditData = extendEditData;
	},
	[SET_ORIGINAL_EDIT_DATA]: (state, originalEditData, originalEditDataString) => {
		state.originalEditData = originalEditData;
	},
	////////////////////////////////////////////////////////




	////////////////////////////////////////////////////////
	[ADD_INFO_ITEM]: (state, newInfoItem) => { 
		state.deployEditData.infoItems.push(newInfoItem);
	},

	[REMOVE_INFO_ITEM_AT]: (state, index) => {
		state.deployEditData.infoItems.splice(index, 1);
	},
	////////////////////////////////////////////////////////


	////////////////////////////////////////////////////////
	
	[SET_CATALOG_LIST]: (state, catalogList) => {
		state.catalogList = catalogList;
	},
	[SET_CATALOG_EDIT_DATA]: (state, catalogEditData) => {
		state.catalogEditData = catalogEditData;	
	},
	[SET_CATALOG_DEPLOY_TYPE_INFO]: (state, typeInfo)=>{
		state.stageCd = typeInfo.stageCd;
		state.providerCd = typeInfo.providerCd;
		state.deployComponentName = typeInfo.deployComponentName;
	},
	////////////////////////////////////////////////////////

};
