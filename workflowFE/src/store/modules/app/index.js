import store from "@/store";
import {useCookies} from "vue3-cookies/dist";
import { createNamespacedHelpers } from "vuex";
import { NAMESPACE } from "./type";
import getters from "./getters";
import mutations from "./mutations";
import actions from "./actions";
import * as actionTypes from "./type";

const { cookies } = useCookies();
const { mapState, mapGetters, mapActions } = createNamespacedHelpers(NAMESPACE);
const state = {
    sidebar: {
        opened: cookies.get("sidebarStatus")
            ? !!+cookies.get("sidebarStatus")
            : true,
        withoutAnimation: false
    },
    device: "desktop",
    size: cookies.get("size") || "medium"
};


export { mapState, mapGetters, mapActions, actionTypes, mapActions as appMapActions, actionTypes as appActions };
export default {
    namespaced: true,
    state,
    mutations,
    actions,
    getters
};
