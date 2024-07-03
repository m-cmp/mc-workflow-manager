import * as connectionActions from "./type";
import * as mutations from "./mutations";
import { async } from "validate.js";
import { 
    getClusterConfigList, 
    getKubernetesConfigList,
    getClusterConfigProviderList, 
    getClusterConfigStageList, 
    getKubernetesConfig 
} from "@/api/kubernetesConfig.ts"

export default {
    [connectionActions.LOAD_CLUSTER_CONFIG_LIST]: async ({ commit }, param)=> {
        let response = null;
        let clusterConfigList = [];

        try {

            // response = await getClusterConfigList(param);
            response = await getKubernetesConfigList();
            
            clusterConfigList = response.data;
            commit(mutations.SET_CLUSTER_CONFIG_LIST, clusterConfigList)
        } catch(error) {
            clusterConfigList = [];
            console.log(error);
        }
    },

    // 신규 클러스터 > 초기 데이터 세팅
    [connectionActions.CREATE_CLUSTER_CONFIG_INIT_DATA]: async ({ commit, dispatch })=> {
        await dispatch(connectionActions.LOAD_PROVIDER_LIST)
        // await dispatch(connectionActions.LOAD_STAGE_LIST)
    },

    // 신규클러스터 > 초기 데이터 세팅 > provider 목록
    [connectionActions.LOAD_PROVIDER_LIST]: async ({ commit })=> {
        let response = null;
        try {
            response = await getClusterConfigProviderList();
            commit(mutations.SET_PROVIDER_LIST, response.data)
        } catch(error) {
            console.log(error)
        }
    },

    // 신규클러스터 > 초기 데이터 세팅 > stage 목록
    [connectionActions.LOAD_STAGE_LIST]: async ({ commit })=> {
        let response = null;
        try {
            response = await getClusterConfigStageList();
            commit(mutations.SET_STAGE_LIST, response.data)
        } catch(error) {
            console.log(error)
        }
    },

    // 클러스터 > 상세 정보
    [connectionActions.LOAD_CLUSTER_DETAIL_INFO]: async ({ commit }, k8sId)=> {
        let response = null;
        try {
            response = await getKubernetesConfig(k8sId);
            commit(mutations.SET_CLUSTER_DETAIL_INFO, response.data)
        } catch(error) {
            console.log(error)
        }
    }

    
};
