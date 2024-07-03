export const SET_CLUSTER_CONFIG_LIST = 'setClusterConfigList';
export const SET_PROVIDER_LIST = 'setProviderList';
export const SET_STAGE_LIST = 'setStageList';
export const SET_CLUSTER_DETAIL_INFO = 'setClusterDetailInfo';

export default {
    // 서비스 그룹 > 설정 > 클러스터 > 목록세팅
    [SET_CLUSTER_CONFIG_LIST]: (state, clusterConfigList) => {
        state.clusterConfigList = clusterConfigList;
    },

    // 서비스 그룹 > 설정 > 신규 클러스터 > 구성 목록 세팅
    [SET_PROVIDER_LIST]: (state, providerList) => {
        state.providerList = providerList;
    },
    // 서비스 그룹 > 설정 > 신규 클러스터 > 스테이지 목록 세팅
    [SET_STAGE_LIST]: (state, stageList) => {
        state.stageList = stageList;
    },

    // 클러스터 상세 정보 세팅
    [SET_CLUSTER_DETAIL_INFO]: (state, clusterDetailInfo) => {
        state.clusterDetailInfo = clusterDetailInfo;
    }

}
