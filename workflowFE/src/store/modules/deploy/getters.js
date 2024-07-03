export const CURRENT_DEPLOY_TYPE_ID = "currentDeployTypeId";
export const CURRENT_DEPLOY_CD = "currentDeployCd";
export const BUILD_EDIT_DATA = "buildEditData";
export const DEPLOY_EDIT_DATA = "deployEditData";
export const EXTEND_BUILD_EDIT_DATA = "extendBuildEditData";
export const IS_BUILD_PANEL_OPEN = "isBuildPanelOpen";
export const IS_EXTEND_BUILD_PANEL_OPEN = "isExtendBuildPanelOpen";
export const IS_ITEM_INFO_PANEL_OPEN = "isItemInfoPanelOpen";

export const BUILD_LIST = "buildList";
export const DEFAULT_ITEM_VALUE = "defaultItemValue";
export const COMP_PROPERTIES = "compProperties";
export const CURRENT_DEPLOY_MANAGER = "currentDeployHelper";

export const CATALOG_EDIT_DATA = "catalogEditData";

export default {
	[CURRENT_DEPLOY_TYPE_ID]: (state) => {
		return state.deployTypeId
	},

	[CURRENT_DEPLOY_CD]: (state) => {
		return state.deployCd
	},

	[BUILD_EDIT_DATA]: (state) => {
		return state.buildEditData;
	},
	[DEPLOY_EDIT_DATA]: (state) => {
		return state.deployEditData;
	},
	[EXTEND_BUILD_EDIT_DATA]: (state) => {
		return state.extendBuildEditData;
	},
	

	[IS_BUILD_PANEL_OPEN]: (state) => {
		return state.buildPanel.opened;
	},
	[IS_EXTEND_BUILD_PANEL_OPEN]: (state) => {
		return state.extendBuildPanel.opened
	},
	
	[IS_ITEM_INFO_PANEL_OPEN]: (state) => {
		return state.itemInfoPanel.opened
	},
	

	[BUILD_LIST]: (state) => {
		if (state.buildList)
			return state.buildList;
		else
			return [];
	},
	[DEFAULT_ITEM_VALUE]:(state)=> {
		return state.defaultItemValue;
	},
	[COMP_PROPERTIES]: (state) => {
		return state.compProperties;
	},

	[CURRENT_DEPLOY_MANAGER]: (state) => {
		return state.deployManager;
	},

	[CATALOG_EDIT_DATA]: (state) => {
		return state.catalogEditData
	}
}