import store from "@/store";
import { createNamespacedHelpers } from "vuex";
import { NAMESPACE } from "./type";
import getters from "./getters";
import mutations from "./mutations";
import actions from "./actions";
import * as actionTypes from "./type";

// import { getToken} from "@/core/services/AuthToken";

const { mapState, mapGetters, mapActions } = createNamespacedHelpers(NAMESPACE);
const state = {
    // token: getToken(),
    name: "",
    userId: "",
    authId: 0,
    authName:"",
    pwReset: false,
    tempUserInfo:null
};

export { mapState, mapGetters, mapActions, actionTypes, actionTypes as userActions };
export default {
    namespaced: true,
    state,
    mutations,
    actions,
    getters
};
