import store from "@/store";
import { createNamespacedHelpers } from "vuex";
import { NAMESPACE } from "./type";
import getters from "./getters";
import mutations from "./mutations";
import actions from "./actions";
import * as actionTypes from "./type";

const { mapState, mapGetters, mapActions } = createNamespacedHelpers(NAMESPACE);
const state = {
    authMenu: [],
    generalAuthMenu:[],
    routes: [],
    addRoutes: [],
    mainMenu: {},
    currentMainMenuName: "",
    groupAuthMenu:[]
};


export { mapState, mapGetters, mapActions, actionTypes, actionTypes as permissionActions };
export default {
    namespaced: true,
    state,
    mutations,
    actions,
    getters
};
