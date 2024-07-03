import store from "@/store";
import { createNamespacedHelpers } from "vuex";
import { NAMESPACE } from "./type";
import getters from "./getters";
import mutations from "./mutations";
import * as shareMutations from "./mutations";
import actions from "./actions";
import  * as actionTypes from "./type";


const { mapState, mapGetters, mapActions } = createNamespacedHelpers(NAMESPACE);
const state = {
    groupInfo: null,
    serviceInfo: null,
    projectInfo: null,
    pageLoadingFlag: false
};

export { mapState, mapGetters, mapActions, actionTypes, actionTypes as shareActions, shareMutations};
export default {
    namespaced: true,
    state,
    mutations,
    actions,
    getters
};
