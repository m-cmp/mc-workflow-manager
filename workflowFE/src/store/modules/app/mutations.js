import { constantRoutes } from "@/router";
export const TOGGLE_SIDEBAR = "toggleSidebar";
export const CLOSE_SIDEBAR = "closeSidebar";
export const TOGGLE_DEVICE = "toggleDevice";
export const SET_SIZE = "setSize";
import { useCookies } from "vue3-cookies/dist";

export default {


    [TOGGLE_SIDEBAR]: state => {
        const { cookies } = useCookies();

        state.sidebar.opened = !state.sidebar.opened;
        state.sidebar.withoutAnimation = false;
        if (state.sidebar.opened) {
            cookies.set("sidebarStatus", 1);
        } else {
            cookies.set("sidebarStatus", 0);
        }
    },
    [CLOSE_SIDEBAR]: (state, withoutAnimation) => {
        Cookies.set("sidebarStatus", 0);
        state.sidebar.opened = false;
        state.sidebar.withoutAnimation = withoutAnimation;
    },
    [TOGGLE_DEVICE]: (state, device) => {
        state.device = device;
    },
    [SET_SIZE]: (state, size) => {
        state.size = size;
        Cookies.set("size", size);
    }
};
