import store from "@/store";
import { createNamespacedHelpers } from "vuex";
import { NAMESPACE } from "./type";
import getters from "./getters";
import mutations from "./mutations";
import * as connectionMutations from "./mutations";
import actions from "./actions";
import  * as actionTypes from "./type";


const { mapState, mapGetters, mapActions } = createNamespacedHelpers(NAMESPACE);
const state = {
    ossList: [],
    gitlabList: [],
    jenkinsList: [],
    nexusList: [],
    containerRegistryList: [],
    sonarqubeList: [],

    editServiceGroupOssData: {
        gitlabId: '',
        gitlabName: '',
        gitlabUrl: '',

        jenkinsId: '',
        jenkinsName: '',
        jenkinsUrl: '',
        
        nexusId: '',
        nexusName: '',
        nexusUrl: '',
        
        containerRegistryId: '',
        containerRegistryName: '',
        containerRegistryUrl: '',

        sonarqubeId: '',
        sonarqubeName: '',
        sonarqubeUrl: '',
    },

    ossCdList: [],

    editData: {
        companyId: 0,
        ossCd: '',
        ossName: '',
        ossDesc: '',
        ossUrl: '',
        ossUsername: '',
        ossPassword: '',
        ossToken: '',
    }
};

export { mapState, mapGetters, mapActions, actionTypes, actionTypes as connectionActions, connectionMutations};
export default {
    namespaced: true,
    state,
    mutations,
    actions,
    getters
};
