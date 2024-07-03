import store from "@/store";
import { createNamespacedHelpers } from "vuex";
import { NAMESPACE } from "./type";
import getters from "./getters";
import mutations from "./mutations";
import * as clusterConfigMutations from "./mutations";
import actions from "./actions";
import  * as actionTypes from "./type";


const { mapState, mapGetters, mapActions } = createNamespacedHelpers(NAMESPACE);
const state = {
    // 클러스터 설정 전체 목록
    clusterConfigList: [],

    // 신규 클러스터 > ProviderCD 목록
    providerList: [],
    // 신규 클러스터 > StageCD 목록
    stageList: [],

    // 클러스터 상세 정보
    clusterDetailInfo: {},
};

export { mapState, mapGetters, mapActions, actionTypes, actionTypes as clusterConfigActions, clusterConfigMutations};
export default {
    namespaced: true,
    state,
    mutations,
    actions,
    getters
};
