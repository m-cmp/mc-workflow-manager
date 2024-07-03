/*
	2023.03.15 stageId -> stageCd로 전환
*/
import store from "@/store";
import { createNamespacedHelpers } from "vuex";
import { NAMESPACE } from "./type";
import getters from "./getters";
import mutations from "./mutations";
import actions from "./actions";
import * as actionTypes from "./type";

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
	deployList: [],

	// deploy 컴포넌트 정보
	deployCd: "",
	stageCd: "",
	providerCd: "",
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
	
	// k8sId 전달용 (KubernetesInfoComponent => KubernetesItemInfoPropertiesPanel)
	passK8sId:""
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
