/*
	2023.03.15 기존 devops Store 백업 - deploy/index.js
 */
import store from "@/store";
import { createNamespacedHelpers } from "vuex";
import { NAMESPACE } from "./type";
import getters from "./getters";
import mutations from "./mutations";
import actions from "./actions";
import * as actionTypes from "./type";

import { getToken} from "@/core/services/AuthToken";

const { mapState, mapGetters, mapActions } = createNamespacedHelpers(NAMESPACE);
const state = {
	loading: false,
	error: false,
	errorMessage:"",
	buildPanel: {
		opened:false
	},
	extendBuildPanel: {
		opened:false
	},
	itemInfoPanel: {
		opened:false
	},


	buildEditData: {},
	deployEditData: {},
	extendBuildEditData:null,

	// 빌드 정보, 한번만 호출
	buildList: [],


	// deploy 컴포넌트 정보
	stageId: "",
	deployTypeId: "",
	deployComponentName: "",
	deployManager: null,
	compProperties: {},
	defaultItemValue: {},

	deployConfigCounts:[],
	stageInfo:[],

	//원본 편집값
	originalEditData: null,

	providerInfo: [],
	clusterConfigInfo: [],
};

export {
	mapState, mapGetters, mapActions, actionTypes,
	mapState as deployState,
	state as deployState2,
	mapGetters as deployGetters,
	mapActions as deployActions,
	actionTypes as deployActionTypes,
	getters as deployGetterTypes
};
export default {
    namespaced: true,
    state,
    mutations,
    actions,
    getters
};
